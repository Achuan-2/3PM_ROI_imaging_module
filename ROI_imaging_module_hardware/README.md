The core hareware is an Arbitrary Waveform Generator (AWG; PXI-5421, National Instruments), housed in a PXIe chassis (PXIe-1062Q, National Instruments). The control computer interfaces with the PXI chassis via a [PXIe-PCIe8361](https://www.ni.com/zh-cn/support/model.pcie-8361.html) remote controller, allowing custom scripts to directly command the AWG.

## Configuration of AWG
1. Install the PXIe-PCIe8361 remote controller (hardware) in the computer

   <img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20230323164032-ljserzn.png" style="width: 177px;" />
2. Install the NI driver (software) on the computer：[NiFGen driver v21.8](https://www.ni.com/zh-cn/support/downloads/drivers/download.ni-fgen.html#445928)

   <img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20260104162008-6ggz4zs.png" />
3. Connect the hardware and verify the connection.

   - Connect the PXIe-PCIe8361 to the AWG using an NI MXI Express cable
   - Please note the correct power-on sequence for the system. Power on the PXIe chassis first, and then boot up your computer.
   - If the connection is successful, the two lights on the left (PWR and Link) will illuminate, and the PXI-5421 will be visible in the "Devices and Interfaces" section of the NI MAX software.

   <img alt="d0397d56ce13adbe4f3edfa1772e7bb" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/d0397d56ce13adbe4f3edfa1772e7bb-20250626180154-kc0w8jg.jpg" style="width: 520px;" />

   <img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20250626222407-11kpmyr.png" style="width: 519px;" />
4. Configure synchronization connections.

   To ensure precise synchronization, the system was configured as follows.

   1. First, the clock input (CLK IN) of the AWG was connected to the 1-MHz master clock output of the laser system, synchronizing the AWG sample rate with the laser repetition rate for one-pulse-per-pixel imaging.
   2. Second, the programmable function interface (PFI0) of the AWG was connected to the “Frame Start Trigger” output of the ScanImage vDAQ system, ensuring that waveform generation began precisely at the start of each acquisition frame.
   3. Finally, the AWG channel 0 (CH0) output was connected to the analog modulation input of the laser’s integrated acousto optic modulator (AOM). The AOM was configured for active-low logic, where a 0 V signal from the AWG activated the laser, and a 3.3 V signal suppressed the laser.

   <img alt="f91ebfff1d25ca6631d39e0d359d7e6" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/f91ebfff1d25ca6631d39e0d359d7e6-20250626215108-xu8j5jt.jpg" style="width: 519px;" />

## Configuration of laser modulation

The lasers we use, Carbide-CB3 (Light Conversion) and CRONUS-3P (Light Conversion), both have built-in AOMs. Using the CARBIDE software, you can configure the system to use "Trigger external" mode to receive signals from the AWG for fast laser switching.

<img alt="image" src="https://fastly.jsdelivr.net/gh/Achuan-2/PicBed@pic/assets/image-20250627235741-hrchyc1.png" />


