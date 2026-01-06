This repository implements a CycleGAN-based framework for removing periodic artifacts (e.g., stripe noise) from 1D signal images stored in multi-page TIFF format. Designed for scientific imaging applications such as fluorescence microscopy, it learns to separate structured periodic noise from underlying clean signals without paired ground-truth data.



## Requirements

**Hardware**

- A CUDA-capable GPU (recommended but not required)
- ≥8 GB RAM (≥16 GB recommended for large TIFFs)



**Software**

- Windows 10/11
- Anaconda or Miniconda (Python ≥ 3.8)



## Installation (Windows + Anaconda)

Follow these steps to set up the environment on Windows using Anaconda:

**1. Create a new conda environment**

```bash
conda create -n periodic_denoise python=3.9

conda activate periodic_denoise
```

**2. Install PyTorch with CUDA support (or CPU-only)**

```bash
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

**3. Install dependencies**

```bash
pip install numpy scipy pillow tifffile visdom
```

**4. (Optional) Start Visdom server for training monitoring**

```bash
conda activate periodic\_denoise
python -m visdom.server -port 10000
```


**Project Structure**

```

├── datasets/
│   ├── sample_raw.tif             # Noisy input (multi-page TIFF)
│   └── sample_ripple.tif          # Corresponding periodic noise (aligned)
├── model/
│   └── models_periodic_denoise.py # Generator/Discriminator definitions
├── Train_periodic_denoising.py    # Training script
├── Inference_periodic_denoise.py  # Inference script
├── train_out/                     # Model checkpoints (auto-created)
└── results/                       # Output directory (create manually or auto)

```

## Usage

**1. Training(Example)**

Open Anaconda Prompt, activate your environment, and run:

```bash
conda activate periodic_denoise

python Train_periodic_denoising.py

  --raw_tif ./datasets/sample_raw.tif
  --noise_tif ./datasets/sample_ripple.tif
  --datanum 10000
  --batchSize 10
  --n_epochs 30
  --size 512
  --lr 0.0001
  --decay_epoch 20
  --trainoutput ./train_out/periodic_denoise_pth_model
  --visdom_port 10000
  --seed 2
  --cuda
```

**2. Inference(Example)**

```
python Inference_periodic_denoise.py
  --input ./datasets/sample_raw.tif
  --output ./results/sample_deripple.tif
  --model ./train_out/periodic_denoising_model/net_deperiodic_denoise_G30.pth
  --block_size 128
  --device cuda
```



**Important Notes**

1. Memory Efficiency: The dataset uses lazy loading—entire TIFFs are not loaded into RAM.

2. Input Shape: Internally reshapes 1D signals to [B, 1, 512, 1] for CNN compatibility.

3. Visdom Requirement: Training will fail if Visdom server isn’t running (unless disabled in code).

4. Reproducibility: Use --seed to fix random states for data sampling and training.



## Downstream Processing in OptiCal

After periodic noise removal, the de-periodic output can be further refined through the next processing modules:

1. RIMA Module: To correct motion-induced artifacts and blur (e.g., from sample drift or stage instability).

2. Random Noise Suppression Module: Such as SRDTrans (https://github.com/cabooster/SRDTrans) to suppress stochastic noise while preserving fine structural details.

This modular pipeline enables comprehensive restoration of scientific imaging data—first removing structured periodic interference, then addressing motion blur and random noise in sequence.



























