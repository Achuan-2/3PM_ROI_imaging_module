# ROI imaging module

## Introduction

Three-photon microscopy (3PM) has extended optical imaging beyond the reach of two-photon microscopy (2PM), but its practical depth remains far below theoretical predictions because of low photon efficiency and severe noise contamination. Here we present an integrated hardware and software solution that addresses these limitations. We developed a plug-and-play region-of-interest (ROI) imaging module that selectively excites neuron-occupied regions to improve power efficiency and reduce photothermal stress. The module incorporates frame-partitioned accumulative (FPA) imaging for high signal-to-noise ratio (SNR) structural acquisition, automated neuron segmentation, and motion-robust registration for stable recordings. Complementing this, OptiCal is a cascaded deep-learning framework that removes mixed noise including periodic, motion-induced, and random components. Together, these innovations enable high-fidelity imaging to 1.7 mm depth, extending the practical limit of 3PM by about 400 µm while maintaining low excitation power. Our results reveal reliable calcium activity and behavior-correlated dynamics in deep medial prefrontal cortex of awake mice.

![](https://fastly.jsdelivr.net/gh/Achuan-2/PicBed/assets/20260106170508-2026-01-06.png)

![](https://fastly.jsdelivr.net/gh/Achuan-2/PicBed/assets/20260106170556-2026-01-06.png)

## Configuration and usage guides

1. **Hardware configuration**: [ROI imaging module hardware setup guide](ROI_imaging_module_hardware/README.md)
   
   ![](https://fastly.jsdelivr.net/gh/Achuan-2/PicBed/assets/20260106165957-2026-01-06.png)
2. **Software installation and usage**: [ROI imaging module software installation and user manual](ROI_imaging_module_software/README.md)

## Citation

If you use the ROI imaging module or any code in your research, please cite the [paper](https://www.biorxiv.org/content/10.64898/2026.01.02.697343v1):

> Su, J., Liu, S., Yang, S., Zhu, Y., Gu, X., Zhao, Y., Li, C., Zhang, M., Chen, A., Yu, H., & Li, B. (2026). A plug-and-play ROI imaging module and deep-learning denoising framework extend three-photon microscopy to 1.7 mm depth. [https://doi.org/10.64898/2026.01.02.697343](https://doi.org/10.64898/2026.01.02.697343)
