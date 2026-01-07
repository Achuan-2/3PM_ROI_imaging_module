# Inference_periodic_denoise.py
import os
import argparse
import numpy as np
from PIL import Image
from tifffile import TiffFile, TiffWriter
import torch
from model.models_periodic_denoise import Generator
def auto_dc_correct(arr):
    """Auto subtract offset for int16/uint16 centered signals."""
    if arr.dtype == np.uint16:
        # Assume 0~65535 with DC at 32768
        return arr.astype(np.float32) - 32768.0
    elif arr.dtype == np.int16:
        # Already signed, no shift needed
        return arr.astype(np.float32)
    else:
        return arr.astype(np.float32)
@torch.no_grad()
def infer_frame(model, frame, device, block_size=128):
    """
    Process multiple rows at once (batched inference) for speed.
    Input frame: [H, W]
    Output: [H, W] deripple
    """
    H, W = frame.shape
    model.eval()
    deripple = np.empty_like(frame)

    with torch.no_grad():
        for start_row in range(0, H, block_size):
            end_row = min(start_row + block_size, H)
            num_rows = end_row - start_row

            # [num_rows, W] → [num_rows, 1, W, 1]
            batch_signal = torch.from_numpy(frame[start_row:end_row]).float().to(device)  # [R, W]
            batch_signal = batch_signal.unsqueeze(1).unsqueeze(-1)                       # [R, 1, W, 1]

            ripple_pred = model(batch_signal)  # [R, 1, W, 1]

            ripple_np = ripple_pred.squeeze(-1).squeeze(1).cpu().numpy()  # [R, W]
            deripple[start_row:end_row] = frame[start_row:end_row] - ripple_np

    return deripple
def main():
    # 检查是否从 pyrunfile 调用（全局变量存在）
    if 'input' in globals():
        input_file = globals()['input']
        output_file = globals()['output']
        model_path = globals()['model']
        block_size_val = int(globals()['block_size'])
        device_str = globals()['device']
    else:
        # 命令行参数解析
        parser = argparse.ArgumentParser(description="Periodic denoising inference")
        parser.add_argument('--input', type=str, default='./datasets/file_00020_ch1.tif', help='Input multi-page TIFF file')
        parser.add_argument('--output', type=str, default='./results/file_00020_ch1_deripple.tif', help='Output deripple TIFF file')
        parser.add_argument('--model', type=str, default='./train_out/periodic_denoising_model/net_dependent_noise_G20.pth', help='Path to generator_A2B .pth file')
        parser.add_argument('--block_size', type=int, default=128, help='Number of rows per GPU block')
        parser.add_argument('--device', type=str, default='cuda' if torch.cuda.is_available() else 'cpu')
        opt = parser.parse_args()
        input_file = opt.input
        output_file = opt.output
        model_path = opt.model
        block_size_val = opt.block_size
        device_str = opt.device

    device = torch.device(device_str)
    print(f"Using device: {device}")

    # Load model
    netG = Generator(input_nc=1, output_nc=1)
    netG.load_state_dict(torch.load(model_path, map_location=device))
    netG.to(device).eval()
    print("Model loaded.")

    # Open input TIFF
    with TiffFile(input_file) as tif_in:
        n_frames = len(tif_in.pages)
        print(f"Processing {n_frames} frames from {input_file}")

        # Get first frame to determine shape and dtype
        first_page = tif_in.pages[0]
        sample_frame = first_page.asarray()
        H, W = sample_frame.shape
        input_dtype = sample_frame.dtype
        # Determine output dtype (usually same as input, but signed)
        if input_dtype == np.uint16:
            output_dtype = np.int16
            output_offset = 32768
        elif input_dtype == np.int16:
            output_dtype = np.int16
            output_offset = 0
        else:
            output_dtype = input_dtype
            output_offset = 0

        # Write output TIFF
        with TiffWriter(output_file) as tif_out:
            for i in range(n_frames):
                print(f"\rProcessing frame {i+1}/{n_frames}", end="", flush=True)
                # Read frame
                frame = tif_in.pages[i].asarray()
                frame_float = auto_dc_correct(frame)  # [H, W] float32
                # Inference
                deripple_float = infer_frame(netG, frame_float, device, block_size=block_size_val)
                # Convert back to integer
                if output_offset != 0:
                    deripple_int = np.clip(deripple_float + output_offset, 0, 65535).astype(output_dtype)
                else:
                    # For int16, clip to valid range
                    deripple_int = np.clip(deripple_float, -32768, 32767).astype(output_dtype)
                # Write frame
                tif_out.write(deripple_int, contiguous=True)

    print(f"\n Done! Output saved to: {output_file}")
if __name__ == '__main__':
    main()