import glob
import os
import scipy.io
from torch.utils.data import Dataset
import numpy as np
import torchvision.transforms as transforms
import re
def numeric_sort(value):
    numbers = re.findall(r'\d+', value)
    return int(numbers[1]) if numbers else value
class ImageDataset(Dataset):
    def __init__(self, root, transforms_=None, unaligned=False, mode='train'):
        self.transform = transforms.Compose(transforms_)
        self.unaligned = unaligned
        self.files_A = sorted(glob.glob(os.path.join(root, 'A') + '/*.*'),key=numeric_sort)

    def __getitem__(self, index):
        item_A = scipy.io.loadmat(self.files_A[index % len(self.files_A)])
        print('-----------------------------------------------------')
        print(self.files_A[index % len(self.files_A)])
        item_A = item_A['noisy'].astype(np.float32)
        item_A = self.transform(item_A)
        return {'A': item_A}

    def __len__(self):
        return len(self.files_A)