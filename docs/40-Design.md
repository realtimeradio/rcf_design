# Design

Here, the preliminary design of the Radio Camera Frontent (RCF) is described and justified.

## Interfaces

The top-level RCF interfaces are shown in Figure \ref{fig:rcf-interfaces}.

![\label{fig:rcf-interfaces}Top-level interfaces to the RCF subsystem. 4000 RF signals are delivered by ASP, which must be digitized and channelized before being passed to SNW. Some data (used for beamforming) is returned to RCF from SNW, beamformed, and then delivered back to SNW.](images/rcf-interfaces.drawio.pdf)

The primary inputs to RCF are the 4000 RF signals (2000 dual-polarization) provided by the ASP subsystem.
The primary outputs of RCF are all digital data streams transmitted to SNW.
These outputs comprise both the channelized voltages used by RCP, as well a the beamformed voltages used by PTS.
RCF also receives data from SNW, in order to carry out beamformer processing, which is a task that is parallel by frequency, but not antenna, and therefore benefits from SNW's ability to perform frequency-antenna data transposition.

A major interface also exists between RCF and MNC in order to facilitate runtime control and health monitoring of the RCF system.

## RCF Logical System Breakdown

It is useful to further break down the RCF system into its constituent logical components, as shown in Figure \ref{fig:rcf-logical-components}.

![\label{fig:rcf-logical-components}Logical components of the RCF subsystem.](images/rcf-interfaces-logical.drawio.pdf)

## Hardware

RCF requires hardware to digitize and process the 4000 RF signals provided by ASP.
Since ASP is responsible for transporting all analog signals back to a central processing facility, RCF is free to use a hardware architecture that requires that any number of signals be processed in each physical hardware module.
However, for simplicity and modularity, the chosen RCF architecture is one which uses a separate ``FPGA Station Module'' (FSM) to process a dual-polarization pair of signals from a single DSA antenna.
This architecture thus requires 2048 FSMs (plus some provision of spares) to process signals from the full DSA telescope.
Though this is a large number of modules, this architecture has the following beneficial features:

1. Manufacture of FSMs may make use of economies of scale, and leverage high unit-count component purchases.
2. Dependencies between signal paths from multiple antennas are removed, avoinding system control side effects - for example, the maintenance of one antenna's signal path affecting another.
3. Each FSM has a lower power-disipation than a module which is tasked with processing signals from multiple antennas, simplifying thermal management.
4. FSMs need not use the most powerful FPGA components available, incresing cost-efficiency, since more powerful FPGAs often have a higher cost-to-performance ratio than smaller parts.

The main drawbacks of such a system are

1. The increased number of endpoints which the monitor and control system must support.
2. The increased number of endpoints to which the timing distribution system must deliver timing signals.
3. The larger physical footprint of the system.

The first of these drawbacks is mitigated by the choice to use a control and monitoring system designed with scalability in mind.
The second is not a significant issue, since the timing distribution system is not a major cost-driver of DSA2000 even in the case of distribution to 2048 endpoints.
Finally, as is discussed in Section \ref{sec:RackLayout}, the physical size of the RCF system is no a major cost driver for DSA2000.
Further, a more compact architecture involving modules processing signals from mulitple antennas would likely dissipate enough power per module that any significant compute-density savings could only be realised if significant engineering and infrastructure effort was invested in supporting water-cooling of the RCF system.

### FPGA Station Module Components

The primary components of the FSM are an analog-to-digital converter (ADC), and a field-programmable gate array (FPGA) system-on-module (SOM).
The former is responsible for digitizing the analog signals, and the latter is responsible for processing the digitized data and packaging it in Ethernet frames for transmission to SNW.

#### Analog-to-Digital Converter

The selected digitizer is the ADI AD9207[^ad9207], which is a 12-bit ADC capable of sampling a pair of analog signals at up to 6 GS/s.

As well as simple digitization, the AD9207 has a variety of signal processing capabilities, including digital down-conversion and decimation [@ad9207].
These are leveraged by the RCF system in order that downstream DSP may operate on only the frequency range of interest, and at a lower sample rate. 
This is discussed in more detail in Section \ref{sec:Firmware}.

The AD9207 outputs digitized data using the industry-standard JESD204C interface, which is a high-speed serial interface capable of transporting data on up to 16 data lanes at up to 32 Gbps per lane.
The AD9207 configuration required by RCF utilises a JESD204C interface to an FPGA on the FSM with 8 data lanes, and a lane rate of 13.2 Gb/s per lane.

#### FPGA System-on-Module

FPGAs at a vast array of price points and peformance levels and may be purchased in a variety of form factors.
These include:
1. A packaged chip, for integration onto a custom board assembly
2. A System-on-module (SoM), which is a small board assembly designed to be integrated into a larger system, typically containing an FPGA and critical support infrastructure such as power supply circuitry and memory modules.
3. Complete processing platforms, ready to be deployed in the field.

The DSA2000 project places a high priority on rapid development and deployment, and for this reason the design of a completely custom FPGA board from scratch is not preferable.
However, the project also has a very large number of signal paths, and thus needs to leverage custom interfaces (including backplanes and board-to-board connectors) in order to maximise the system density and minimise the number of cables needed to connect different system components.
For this reason, the use of an off-the-shelf processing platform is also not preferable.

The compromise chosen is to use an FPGA SoM hosted on a custom carrier board.
This provides the customisability of a dedicated board purpo:w
se-built for the DSA2000 project, while also leveraging the significant design and testing effort that has gone into the SoM designed commercially.

RCF has chosen the iW-RainboW-G35M SoM from iWave Systems Technologies[^iwave] (Figure \ref{figLiwave-zu11}), populated with a Xilinx/AMD Zynq Ultrascale+ ZU11-EG System-on-Chip, which is, itself, a CPU and FPGA integrated into a single chip package.

![\label{fig:iwave-zu11}The iW-RainboW-G35M system on module from iWave Systems Technologies incorporates a Xilinx/AMD Zynq Ultrascale+ System-on-Chip with power and RAM support infrastructure on a small module designed to be mounted to a larger circuit board. *Image credit: iWave Systes Technologies*](images/iwave-zu11.png){width=40%}

The ZU11-EG is a mid-range FPGA, with 0.65 million logic cells, 2928 hardware DSP slices, and 43.6 Mb of dedicated on-chip RAM.


## Firmware \label{sec:Firmware}


[^ad9207]: See [https://www.analog.com/en/products/ad9207.html](https://www.
analog.com/en/products/ad9207.html)
[^iwave]: See [https://www.iwavesystems.com/product/zu19-zu17-zu11-zynq-ultrascale-mpsocsom/](https://www.iwavesystems.com/product/zu19-zu17-zu11-zynq-ultrascale-mpsocsom/)

### Frequency Channels

| Data Product | Required bandwidth (MHz) | Channel Bandwidth (kHz) | Number of channels | Total bandwidth (MHz) |
|------------------------------------------|-------------------------|-------------------------|--------------------|-----------------------|
| NC | 1300                    | 130.2                   | 10000              | 1302.1                |
| AC | 34                      | 8.138                   | 4192               | 34.1                  |
| BC | 0.95                    | 1.017                   | 960                | 0.977                 |
| TC | 1300                    | 2083                   | 624                | 1300                  |
| TOTAL (excluding TC) | 1334.95 | -   | 15152 | 1337.2  |
| TOTAL         | 2634.95                 | -                       | 15776              | 2637.2                |


### Frequency Channel Response

![\label{fig:stage1-response}The PFB response of the first stage filter, which is oversampled by a factor of 4/3](images/first_stage_pfb_response.pdf)

![\label{fig:stage2-response}The PFB response of the second stage filters for NC, AC, and BC channelization products.](images/second_stage_pfb_response.pdf)

![\label{fig:stage2tc-response}The PFB response of the second stage filters for TC channelization products.](images/second_stage_pfb_tc_response_1xscale.pdf)

![\label{fig:stage2tc-response-scale}A possible PFB response of the second stage filters for TC channelization products with the filter passbands set to 85% of their usual width.](images/second_stage_pfb_tc_response_0.85xscale.pdf)


### Rack Layout

![](images/rack_layout.drawio.pdf)

## Firmware
### Processing Pipeline

![\label{fig:firmware}](images/rcf-firmware.drawio.rot270.pdf)

![\label{fig:adc-config}](images/rcf-adc-pipeline.drawio.pdf)

Figure \ref{fig:firmware}

