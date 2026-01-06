import glob
import random
import os
import scipy.io
from torch.utils.data import Dataset
import numpy as np
import tifffile
# from PIL import Image
import torchvision.transforms as transforms
from PIL import Image
class ImageDataset(Dataset):
    def __init__(self, root, transforms_=None, unaligned=False, mode='train'):
        self.transform = transforms.Compose(transforms_)
        self.unaligned = unaligned
        self.files_A = sorted(glob.glob(os.path.join(root, 'A') + '/*.*'))
        self.files_B = sorted(glob.glob(os.path.join(root, 'B') + '/*.*'))
    def __getitem__(self, index):
        item_A = scipy.io.loadmat(self.files_A[index % len(self.files_A)])
        item_A = item_A['noisy'].astype(np.float32)
        item_A = self.transform(item_A)
        

        if self.unaligned:
            item_B = scipy.io.loadmat(self.files_B[random.randint(0, len(self.files_B) - 1)])
            item_B = item_B['ripple_n'].astype(np.float32)
            item_B = self.transform(item_B)
        #     item_B = self.transform(Image.open(self.files_B[random.randint(0, len(self.files_B) - 1)]))
        else:
            item_B = scipy.io.loadmat(self.files_B[index % len(self.files_B)])
            item_B = item_B['ripple_n'].astype(np.float32)
            item_B = self.transform(item_B)
        #     item_B = self.transform(Image.open(self.files_B[index % len(self.files_B)]))

        return {'A': item_A, 'B': item_B}

    def __len__(self):
     return max(len(self.files_A), len(self.files_B))

class PeriodicDenoiseDataset(Dataset):
    def __init__(self, raw_tif_path, noise_tif_path, num_samples=None, size=512, domain='A',seed = 42):
        """
        Lazy-loading dataset for large multi-page TIFF files.
        - Does NOT load all frames into memory.
        - Samples rows on-the-fly.
        - Automatically applies offset correction if needed.

        Args:
            raw_tif_path (str): Path to multi-page TIFF with raw noisy signals.
            noise_tif_path (str): Path to multi-page TIFF with periodic noise only.
            num_samples (int): Total number of 1D samples to generate.
            size (int): Desired signal length (will crop/pad).
            domain (str): 'A' for raw noisy, 'B' for noise component.
        """
        self.raw_tif_path = raw_tif_path
        self.noise_tif_path = noise_tif_path
        self.num_samples = num_samples
        self.size = size
        self.domain = domain

        # Open TIFFs and count frames (without loading data)
        self.n_raw_frames = self._count_tiff_pages(raw_tif_path)
        self.n_noise_frames = self._count_tiff_pages(noise_tif_path)

        if self.n_raw_frames == 0 or self.n_noise_frames == 0:
            raise ValueError("TIFF files must contain at least one frame.")

# Generate ALL candidate indices first
        all_indices = self._generate_sample_indices()

        # Apply num_samples limit if requested
        if num_samples is not None and len(all_indices) > num_samples:
            rng = random.Random(seed)  # For reproducibility
            self.sample_indices = rng.sample(all_indices, num_samples)
        else:
            self.sample_indices = all_indices

        print(f"[{domain}] Total candidates: {len(all_indices)}, Using: {len(self.sample_indices)}")

    def _count_tiff_pages(self, path):
        """Count number of pages in a multi-page TIFF."""
        if not os.path.isfile(path):
            raise FileNotFoundError(f"TIFF file not found: {path}")
        img = Image.open(path)
        n = 0
        while True:
            try:
                img.seek(n)
                n += 1
            except EOFError:
                break
        return n

    def _read_tiff_frame(self, path, frame_id):
        """Read a single frame from TIFF by index (lazy)."""
        img = Image.open(path)
        img.seek(frame_id)
        arr = np.array(img, dtype=np.float32)
        # Auto offset correction for int16/uint16 centered at 0
        if arr.max() > 32768:  # likely uint16 with DC offset
            arr = arr.astype(np.float32) - 32768.0
        elif arr.min() < 0 and arr.max() <= 32767:  # int16
            pass  # already signed
            
        # if arr.dtype in [np.uint16, np.int16]:
        #     if arr.max() > 32768:  # likely uint16 with DC offset
        #         arr = arr.astype(np.float32) - 32768.0
        #     elif arr.min() < 0 and arr.max() <= 32767:  # int16
        #         pass  # already signed
        return arr

    def _generate_sample_indices(self):
        indices = []
        # 使用 tifffile 读取 metadata，不加载图像数据
        with tifffile.TiffFile(self.raw_tif_path) as tif:
            print(f"Scanning {len(tif.pages)} frames for sample indices...")
            for frame_id, page in enumerate(tif.pages):
                h, w = page.shape  # ⚡ 直接从 metadata 获取 shape，不读像素！
                if h >= self.size:
                # 可用起始行数 = h - size + 1
                    num_rows = h - self.size + 1
                    for row in range(num_rows):
                        indices.append((frame_id, row))
                if frame_id % 100 == 0:
                    print(f"  Processed {frame_id} frames...", flush=True)
        print(f"Total candidate samples: {len(indices)}")
        return indices



    def __len__(self):
        return len(self.sample_indices)

    def __getitem__(self, idx):
        frame_id, row_id = self.sample_indices[idx]

        if self.domain == 'A':
            frame = self._read_tiff_frame(self.raw_tif_path, frame_id)
        else:
            frame = self._read_tiff_frame(self.noise_tif_path, frame_id)

        signal = frame[row_id].astype(np.float32)

        # Crop or pad to target size
        if len(signal) > self.size:
            start = random.randint(0, len(signal) - self.size)
            signal = signal[start:start + self.size]
        elif len(signal) < self.size:
            pad = np.zeros(self.size - len(signal), dtype=np.float32)
            signal = np.concatenate([signal, pad])

        # Reshape to [C, H, W] = [1, size, 1] for 2D CNN compatibility
        signal = signal.reshape(1, self.size, 1)
        return signal