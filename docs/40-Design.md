# Design

Here, the preliminary design of the Radio Camera Frontent (RCF) is described and justified.

## Interfaces

The top-level RCF interfaces to other DSA2000 subsystems are shown in Figure \ref{fig:rcf-interfaces} and are as follows:

1. Analog Signal Path (ASP): 4096 RF signals (two polarizations from each of 2048 dishes) are delivered by ASP, which must be digitized and processed by RCF.
1. Timing and Synchronization (TS): RCF receives timing signals from TS, and uses them to ensure coherent digitization and accurate timestamping of data streams.
1. Central Control Network (CNW): A 1 Gb Ethernet network responsible for delivering control messages to RCF.
1. Monitor and Control (MNC): RCF receives and acts on commands from MNC, and must be able to report its health status to MNC. These commands are delivered via CNW.
1. Facilities (FAC): FAC provide the space, power, and cooling infrastructure to support RCF.
1. Signal Data Network (SNW): SNW is a 25/100/400 Gb/s Ethernet network responsible for transporting high-speed digital data products from RCF to RCP and PT. In addition, SNW provides data transmission paths between different RCF processors.
1. Radio Camera Processor (RCP): RCP receives channelized voltages from RCF, via the SNW network, and uses them to produce images and transient event data products.
1. Pulsar Timing (PT): PT receives channelized tied-array beam voltages from RCF, via the SNW network, and uses them to produce pulsar timing data products.

![\label{fig:rcf-interfaces}Top-level interfaces to the RCF subsystem. Interfaces which are logical only (MNC, whose control messages are delivered via CNW, and RCP, whose data are delivered via SNW) are indicated with dotted arrows.](images/rcf-interfaces.drawio.pdf)

The basic specifications for these interfaces are described in Section \ref{sec:dependencies}.

## Processing

The data products which must be produced by RCF are:

1. Channelized voltages, which are used by RCP for image processing and transient searching.
As discussed in Section \ref{sec:freq-res}, three different channelization products are required:
    1. Narrowband continuum (NC) channelized voltages, covering 700 - 2000 MHz, with a channel bandwidth of <146.8 kHz.
    2. Zoom band "A" (AC) channelized voltages, covering 1388 - 1422 MHz, with a channel bandwidth of <9.25 kHz.
    3. Zoom band "B" (BC) channelized voltages, covering 1419.93 - 1420.88 MHz, with a channel bandwidth of <1.42 kHz.
2. 4 channelized tied-array beams, which are used by PTS for pulsar timing. These should cover the band 700 - 2000 MHz, with a channel bandwidth of >2048 kHz.


## Hardware

RCF requires hardware to digitize and process the 4096 RF signals provided by ASP.
Since ASP is responsible for transporting all analog signals back to a central processing facility, RCF is free to use a hardware architecture that requires that any number of signals be processed in each physical hardware module.
However, for simplicity and modularity, the chosen RCF architecture is one which uses a separate ``FPGA Station Module'' (FSM) to process a dual-polarization pair of signals from a single DSA antenna.
This architecture thus requires 2048 FSMs (plus some provision of spares) to process signals from the full DSA telescope.
Though this results in a larger number of modules than an equivalent architecture where multiple antennas are processed on common hardware, this design has the following beneficial features:

1. Manufacture of FSMs may make use of economies of scale, and leverage high unit-count component purchases.
2. Dependencies between signal paths from multiple antennas are removed, avoinding system control side effects - for example, the maintenance of one antenna's signal path affecting another.
3. Each FSM has a lower power-disipation than a module which is tasked with processing signals from multiple antennas, simplifying thermal management.
4. FSMs need not use the most powerful FPGA components available, decreasing prototyping costs, and increasing production cost-efficiency, since more powerful FPGAs often have a higher cost-to-performance ratio than smaller parts.

The main drawbacks of such a system are

1. The increased number of endpoints which the monitor and control system must support.
2. The increased number of endpoints to which the timing distribution system must deliver timing signals.
3. The larger physical footprint of the system.

The first of these drawbacks is mitigated by the choice to use a control and monitoring system designed with scalability in mind.
The second is not a significant issue, since the timing distribution system is not a major cost-driver of DSA2000 even in the case of distribution to 2048 endpoints.
Finally, as is discussed in Section \ref{sec:RackLayout}, the physical size of the RCF system is no a major cost driver for DSA2000.
Further, a more compact architecture involving modules processing signals from mulitple antennas would likely dissipate enough power per module that any significant compute-density savings could only be realised if significant engineering and infrastructure effort was invested in supporting water-cooling of the RCF system.

### FPGA Station Module Design

The primary components of the FSM are an analog-to-digital converter (ADC), and a field-programmable gate array (FPGA) system-on-module (SOM).
The former is responsible for digitizing the analog signals, and the latter is responsible for processing the digitized data and packaging them in Ethernet frames for transmission to SNW.


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

![\label{fig:iwave-zu11}The iW-RainboW-G35M system on module from iWave Systems Technologies incorporates a Xilinx/AMD Zynq Ultrascale+ System-on-Chip with power and RAM support infrastructure on a small module designed to be mounted to a larger circuit board. *Image credit: iWave System Technologies*](images/iwave-zu11.png){width=40%}

The ZU11-EG is a mid-range FPGA, with 0.65 million logic cells, 2928 hardware DSP slices, and 43.6 Mb of dedicated on-chip RAM.

#### FPGA Station Module Carrier Board

With the FPGA SoM and ADC chip selected for RCF, a custom board is required to host these components and provide physical interfaces to the other DSA2000 subsystems.

A block diagram of the FSM "carrier board" is shown in Figure \ref{fig:rcf-fsm}.
The board has the following features:

1. Standard 3U Eurocard height (100 mm) and length (220 mm) to facilitate mounting multiple cards vertcally in a standard 19" subrack.
2. A backplane connector to allow power, timing reference signals (see [@ts-design]), and control and monitoring signals -- including a 1 Gb Ethernet connection -- to be delivered to the FSM over a backplane with no cables.
3. 

![\label{fig:rcf-fsm}](images/rcf-fsm.drawio.pdf)



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

![](images/pulsar-timing-rack.drawio.pdf)

### Processing Pipeline

![\label{fig:firmware}](images/rcf-firmware.drawio.rot270.pdf)

![\label{fig:adc-config}](images/rcf-adc-pipeline.drawio.pdf)

Figure \ref{fig:firmware}

# Dependencies \label{sec:dependencies}

Dependencies of RCF on other DSA2000 subsystems are as follows:

1. Analog Signal Path (ASP): ASP must deliver 4096 RF signals to RCF, with a bandwidth of 700 - 2000 MHz, and a maximum power of -30 dBm.
2. Timing and Synchronization (TS): TS must deliver timing signals to RCF, with a jitter of <1 ns.
3. Central Control Network (CNW): CNW must deliver control messages to RCF, with a latency of <1 ms.
4. Monitor and Control (MNC): MNC must deliver control messages to RCF, with a latency of <1 ms.
5. Facilities (FAC): FAC must provide power and cooling to RCF, with a power budget of 10 kW and a cooling capacity of 34 kW.
6. Signal Data Network (SNW): SNW must deliver data from RCF to RCP and PT, with a bandwidth of 25/100/400 Gb/s.
7. Radio Camera Processor (RCP): RCP must receive data from RCF, with a bandwidth of 25/100/400 Gb/s.
8. Pulsar Timing (PT): PT must receive data from RCF, with a bandwidth of 25/100/400 Gb/s.


