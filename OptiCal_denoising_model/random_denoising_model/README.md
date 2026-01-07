> Base on SRDTrans: [https://github.com/cabooster/SRDTrans]

## 🔧 Install

### Dependencies 
  - Python >= 3.6 
  - PyTorch >= 1.7 
    
### Install

Create a virtual environment and install PyTorch and other dependencies. **In the 3rd step**, please select the correct Pytorch version that matches your CUDA version from [https://pytorch.org/get-started/previous-versions/](https://pytorch.org/get-started/previous-versions/). 

```bash
conda create -n ROI_Imaging_Module python=3.10
conda activate ROI_Imaging_Module
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install tifffile einops timm tqdm scikit-image matplotlib
```


## 💻 Training 

### 1. Prepare the data  

You can use your own data or download one of the demo data below (*.tif file). The raw low-SNR files should be put into `./datasets/noisy/`.


### 2. Start training

```bash
# Simulated SMLM & Simulated Calcium imaging data at 30hz
python train.py --datasets_folder noisy --n_epochs 20 --GPU 0,1 --train_datasets_size 6000  --patch_x 160 --patch_t 160

# Key parameters:
--datasets_folder: the folder containing your training data (one or more *.tif stacks)
--n_epochs: the number of training epochs
--GPU: specify the GPU(s) used for training. (e.g., '0', '0,1', '0,1,2')
--train_datasets_size: how many patches will be extracted for training
--patch_x, --patch_t: patch size in three dimensions (xy and t), should be divisible by 8.
```

* In the vast majority of cases, good denoising models can be trained with these default parameters. **If not necessary, you do not need to modify these parameters**. You just need to change `--datasets_folder` or `--GPU`. 

* The folders containing training files are in `./datasets`. The checkpoint (model) of each epoch will be saved in `./pth`.

* **Hyperstacks** with multiple channels and even one channel should be split and saved into single-channel stacks. Otherwise, the following error  may occur (`ValueError: num_samples should be a positive integer value, but got num_samples=0`).
 

## ⚡ Inference
### 1. Prepare models

Before inference, you should have trained your own model or downloaded our pre-trained model.

### 2. Test models

```bash
# Simulated calcium imaging data sampled at 0.3 Hz
python test.py --input './datasets/noisy/file_00020_ch1_deripple.tif' --output './datasets/noisy/file_00020_ch1_deripple_denoise.tif' --denoise_model 3PM --GPU 0 --patch_x 128 --patch_t 128

# Key parameters:
--input: input filepath
--output: output filepath
--denoise_model: the subfolder (under pth/) containing pre-trained models (e.g., ad_03hz).
--GPU: specify the GPU(s) used for inference. (e.g., '0', '0,1', '0,1,2')
--patch_x, --patch_t: patch size in three dimensions (xy and t), should be divisible by 8.
```

* In the vast majority of cases, good denoising results can be obtained with these default parameters. **If not necessary, you do not need to modify these parameters**. You just need to change `--datasets_folder`, `--denoise_model` or `--GPU`. 

* For testing, **the patch size in t (`--patch_t`) should be consistent with that used for training**.

* The denoising results will be saved in `./results`. If there are multiple models in `--denoise_model`, only the last one will be used for denoising.
