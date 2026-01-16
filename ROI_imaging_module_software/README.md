# ROI imaging module software installation and user manual

## Software installation

### Requirements

- **Hardware**

  - AWG: NI PXI-5421 + NI PXIe-PCIe8361
  - For specific hardware configuration, see the [ROI imaging module hardware setup guide](../ROI_imaging_module_hardware/README.md).
- **Imaging System**

  - Uses ScanImage as the three-photon imaging system.
- **Matlab** >= R2022b (we use Matlab R2023b)  
  The following toolboxes are required:

  - Instrument Control Toolbox
  - Parallel Computing Toolbox
  - [IVI and VXIplug&play Driver Support from Instrument Control Toolbox](https://www.mathworks.com/hardware-support/ivi-vxiplug-play-instrument-driver.html)
- **Python** v3.10

### Configure Python environment

Install a [miniforge](https://github.com/conda-forge/miniforge) distribution of Python.

Create a new environment.

```bash
# create environment
conda create --name ROI_Imaging_Module python=3.10
conda activate ROI_Imaging_Module
```

Install Pytorch: please select the correct Pytorch version that matches your CUDA version from [https://pytorch.org/get-started/previous-versions/](https://pytorch.org/get-started/previous-versions/)

```bash
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
```

Install Cellpose-SAM

```bash
python -m pip install cellpose[gui]
```

Install dependencies for OptiCal model

```bash
pip install numpy scipy pillow tifffile visdom scikit-image tqdm timm einops matplotlib
```

Open Matlab and configure the Python environment to the path of your cellpose environment.

```matlab
pyenv('Version', "C:\Users\Achuan-2\miniforge3\envs\ROI_Imaging_Module\python.exe", 'ExecutionMode', 'OutOfProcess')
```

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260107224534-ok2cvs6.png" />

### Install ROI imaging module software

Download this repository from GitHub to a local folder.

Open Matlab, navigate to the `3PM_ROI_imaging_module\ROI_imaging_module_software` folder, and run the following command in the command window to launch the software:

```matlab
roi_imaging_module
```

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106130949-69hhtgd.png" />

## Basic configuration of the ROI imaging module

### AWG parameter configuration

Click on <kbd>Settings → AWG Settings</kbd> in the top menu bar.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106131003-bw1hazw.png" />

​`AWG Settings` interface:

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105170950-azxn5fs.png" />

- ​`Device ID`: Can be obtained from the NI MAX software, typically 'Dev1' by default.
- ​`Trigger mode`​: No need to set manually. Options include Continuous, Single, Burst, Stepped. For detailed differences, please refer to the [AWG documentation](https://www.ni.com/en/support/documentation/supplemental/06/advanced-arbitrary-waveform-generator-features.html).

  - Stepped mode will be used for ROI imaging and FPA imaging.
  - Continuous mode will be used for Regular imaging to keep the laser continuously on.
- ​`Sampling clock`: Defaults to External, using the synchronization clock from the laser input via the ClkIn port.
- ​`External trigger`: Defaults to On. Uses the start-of-frame signal from the vDAQ, input via the PFI0 port, to trigger the AWG's output for each frame.
- ​`Gain (V)`: Defaults to 3.3V.
- ​`Offset (V)`: Defaults to 0.
- ​`Sampling rate (Hz)`: Defaults to 1e6. Should be set to the laser's repetition rate.
- ​`Delay (ns)`: Defaults to 0.

### AWG connection

Click the <kbd>Connect</kbd> button to connect.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106131019-q1unte6.png" />

If you are running this software on a test computer without a connected AWG and want to test the software's functionality, you can use <kbd>AWG Simulate Mode</kbd>.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106131030-qpfsu5a.png" />

A <kbd>🎮</kbd>​ button will appear to the right of the <kbd>Connect</kbd> button. This indicates you are in Simulate mode, allowing you to connect to a virtual AWG and perform functions like waveform output.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106131054-y6jm55n.png" />

After successfully connecting to the virtual AWG, the software will default to `Conventional imaging` mode.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106131110-4ev9yxe.png" />

If you want to test custom waveform output with the AWG, you can click <kbd>Utilities → AWG Control</kbd>.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106131127-xb3356i.png" />

​`AWG Control` interface:

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105172427-2pkcvnw.png" />

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105172440-pc4tb8b.png" />

### Configure scanner parameters

Click the <kbd>ScanImage</kbd> button to connect to the ScanImage software and retrieve all imaging scan parameters.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106131222-ayzsw4m.png" />

Click on <kbd>Settings → Scanner Settings</kbd> in the top menu bar.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106131245-rv2wod1.png" />

​`Scanner Settings` interface:

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105172757-qdur0xk.png" />

- ​`Trigger type`: Defaults to Frame Clock. Options are Frame Clock/Line Clock.
- ​`Image size`: The pixel dimensions of the image saved by the imaging system.
- ​`Pulse per pixel`: Defaults to 1, representing the number of laser pulses per pixel.
- ​`Wait (pixels)`: The initial wait time before scanning begins.
- ​`Turnaround left*2 (pixels)`​ / `Turnaround right*2 (pixels)`​: The turnaround time for the bidirectional scanner to reverse direction at the end of each line. `*2` represents the total turnaround time between two lines.

Click the <kbd>Update</kbd>​ button to automatically read the scan parameters from ScanImage and configure `Image size`​, `Pulse per pixel`​, `Turnaround left*2(pixels)`​, and `Turnaround right*2(pixels)`.

However, `Wait (pixels)` needs to be determined through imaging tests.

You can click <kbd>Utilities → ROI imaging Simulator</kbd>​ in the top menu bar to use the `ROI imaging Simulator`​ to understand the effect of `Turnaround`​ and `Wait` parameters on ROI imaging.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106131259-6mtmasz.png" />

​`ROI imaging Simulator` interface:

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105173731-4p34f3u.png" />

When a vertical black and white stripe pattern is used as the ROI mask, an incorrect `Turnaround` setting will result in a skewed diamond pattern.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105173846-irsgyn4.png" />

If `Turnaround`​ is correct but `Wait` is incorrect, the vertical stripes in the output pattern will have jagged edges.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105174220-2uunfzs.png" />

### Loading and saving configurations

Once the parameters in `AWG Settings`​ and `Scanner Settings`​ are configured, you can click <kbd>File → Save Config</kbd> to save the settings.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106131316-d915otk.png" />

To load a saved configuration, there are two methods:

- click <kbd>File → Load Config</kbd> .

  <img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106131551-ivc7ye7.png" />
- click the <kbd>...</kbd>​ button next to `Configuration`.

  <img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106131603-btl04r4.png" />


## ROI imaging module functionality tutorial

### FPA imaging

For three-photon deep-tissue imaging, FPA imaging can achieve higher SNR images with lower power compared to conventional imaging.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105212107-j6tqj2h.png" />

Click the <kbd>FPA imaging</kbd> button to enter FPA imaging mode with a single click.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260106131618-h8ii81x.png" />

It also features an automatic reconstruction function, which reconstructs the complete image every 10 frames.

<img alt="FPA_imaging2" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/FPA_imaging2-20260105213035-hqu35iz.gif" />

### Cell segmentation

##### Automatic segmentation

After acquiring high-SNR images using FPA imaging, you can use the Cellpose-SAM model to automatically identify neurons with a single click.

<img alt="cell_segmentation" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/cell_segmentation-20260105221002-uj8uj1a.gif" />

- **norm_blocksize**: Handles uneven illumination in images by adjusting contrast in blocks.
- **threshold**: Balances detection sensitivity and false positive rate. Set higher to get more cells, in a range from (0, 3].

##### Manual correction

If you are not satisfied with the automatic segmentation results, you can manually adjust them.

- Select a cell and press **Delete** to remove it.
- Use the **mouse wheel** to zoom in and out of the image.
- **Right-click** to draw and select neurons.
- Use the **arrow keys** to move the entire mask.

<img alt="manual_correction" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/manual_correction-20260105221343-t9jy7r7.gif" />

##### Adjust ROI mask

Click the <kbd>⚙️</kbd> button to open the ROI Mask Settings window, which has the following functions:

- Set mask color
- Choose whether to display ROI IDs
- Add rectangular/circular ROIs
- Adjust ROI functions

  - Sort ROIs
  - Drag ROIs
  - Delete ROIs in batch
  - Delete all ROIs

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105221502-3tyvgxe.png" />

##### Dilate ROI mask

Set the dilate value. The resulting masks are dilated to accommodate minor tissue displacements.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105221522-23evc7o.png" />

##### Save mask and load mask

Click <kbd>Save mask</kbd> to save the mask. Supported formats: tif, mat, ImageJ ROI.zip.

Click <kbd>Load mask</kbd> to load a mask. Supported formats: png, tif, csv, mat, ImageJ ROI.zip.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105222748-8e4818v.png" />

### ROI imaging

Click the <kbd>ROI imaging</kbd> button to start ROI imaging with one click.

Click the <kbd>Abort</kbd> button to cancel ROI imaging mode and turn off the laser.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105223945-6a9my1j.png" />

<img alt="ROI_imaging" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/ROI_imaging-20260105224349-okk3ep1.gif" />

### Real-time registration

Click the <kbd>Real-time registration</kbd> button to send the reference image to ScanImage for real-time registration.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105225202-2z5ltqz.png" />

How to use RIMA for Real-time registration:

Copy `+RIMA\scanimage_onlinereg\RIMAMotionEstimator.m`​ to the `+scanimage\+components\+motionEstimators` folder within your ScanImage installation directory.

Click <kbd>Select Estimator</kbd>​ and choose `RIMAMotionEstimator.m`.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260105225453-yjqb397.png" />

## Post-imaging data processing

### Channel separation, noise removal, and registration

After data acquisition via ROI imaging, the `Tiff Process`​ software can be opened from the top menu bar of the ROI imaging module (<kbd>Data-process → Tiff Process</kbd>​) or by entering `TiffProcess` in the terminal.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260108204834-h6zlw4y.png" />

The Tiff Process software includes the following features:

- Periodic denoising
- FPA imaging reconstruction
- Scanphase correction (corrects the misalignment between odd and even rows caused by bidirectional scanning)
- Registration
- Random denoising

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260108205422-qat41v3.png" />

Registration is performed using the RIMA algorithm.

Registration parameters:

- ​`ref_img`: Whether to use an external reference image for registration.
- ​`nimg_init`: The number of initial frames used to generate the reference image.
- ​`batch_size`: The number of frames to register per batch.
- ​`smooth_sigma`: Sigma for image smoothing to reduce noise.
- ​`maxregshift`: The maximum allowed offset size.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260108205807-i85oxkx.png" />

The Registration panel also supports manual registration.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260108210250-p9mwi50.png" />

The features of Manual Image Registration:

- Set a reference image or right-click to select an ROI, then scroll the frame slider to check for any misaligned frames.
- Apply translations and transformations to a single frame.
- Supports applying transformations to all frames in a batch.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260107171623-kiekxbh.png" />

### Calcium signal extraction

After the data has been registered and denoised, the `Calcium Signal Extraction`​ software can be opened from the top menu bar of the ROI imaging module (<kbd>Data-process → Signal Extraction</kbd>​) or by entering `CalciumSignalExtraction` in the terminal.

Software features:

- Load and display Tiff files, adjust contrast, and view the content of different frames.
- Automatic cell segmentation and manual ROI selection. Supports saving and loading ROI masks, and importing ROI.zip files from ImageJ.
- Extract neuronal ΔF/F signals and plot their traces and heatmaps.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260107173727-8wyf3f8.png" />

Saved files:

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260107173802-yl5bxvx.png" />
