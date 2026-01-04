# ROI imaging module

Three-photon microscopy (3PM) has extended optical imaging beyond the reach of two-photon microscopy (2PM), but its practical depth remains far below theoretical predictions because of low photon efficiency and severe noise contamination. Here we present an integrated hardware and software solution that addresses these limitations. We developed a plug-and-play region-of-interest (ROI) imaging module that selectively excites neuron-occupied regions to improve power efficiency and reduce photothermal stress. The module incorporates frame-partitioned accumulative (FPA) imaging for high signal-to-noise ratio (SNR) structural acquisition, automated neuron segmentation, and motion-robust registration for stable recordings. Complementing this, OptiCal is a cascaded deep-learning framework that removes mixed noise including periodic, motion-induced, and random components. Together, these innovations enable high-fidelity imaging to 1.7 mm depth, extending the practical limit of 3PM by about 400 µm while maintaining low excitation power. Our results reveal reliable calcium activity and behavior-correlated dynamics in deep medial prefrontal cortex of awake mice.



## Installation

1. ROI imaging module hardware installation instructions : [click here](ROI_imaging_hardware_setup/README.md)
2. ROI imaging module software installation instructions:  [click here](ROI_imaging_control_software/README.md)
