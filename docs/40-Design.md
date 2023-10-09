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


[^ad9207]: See [https://www.analog.com/en/products/ad9207.html](https://www.analog.com/en/products/ad9207.html)

[^iwave]: See [https://www.iwavesystems.com/product/zu19-zu17-zu11-zynq-ultrascale-mpsocsom/](https://www.iwavesystems.com/product/zu19-zu17-zu11-zynq-ultrascale-mpsocsom/)

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

<!--
![\label{fig:iwave-zu11}The iW-RainboW-G35M system on module from iWave Systems Technologies incorporates a Xilinx/AMD Zynq Ultrascale+ System-on-Chip with power and RAM support infrastructure on a small module designed to be mounted to a larger circuit board. *Image credit: iWave System Technologies*](images/iwave-zu11.png){width=40%}
![](images/iwave-zu11.png){width=40%} ![](images/iwave-zu11-rear.png){width=40%}
-->
![](images/iwave-zu11.png){width=40%}  ![](images/iwave-zu11-rear.png){width=40%}
\begin{figure}[h]
\label{fig:iwave-zu11}
\caption{The top (left) and bottom (right) of the iW-RainboW-G35M system on module from iWave Systems Technologies.
The module incorporates a Xilinx/AMD Zynq Ultrascale+ System-on-Chip with power and RAM support infrastructure on a assembly designed to be mounted to a larger circuit board.
\emph{Image credit: iWave System Technologies}}
\end{figure}

The ZU11-EG is a mid-range FPGA, with 0.65 million logic cells, 2928 hardware DSP slices, and 43.6 Mb of dedicated on-chip RAM.

#### FPGA Station Module Carrier Board

With the FPGA SoM and ADC chip selected for RCF, a custom "carrier board" is required to host these components and provide physical interfaces to the other DSA2000 subsystems.

A block diagram of the FSM carrier is shown in Figure \ref{fig:rcf-fsm}.
The board has the following features:

1. Standard 3U Eurocard height (100 mm) and length (220 mm) to facilitate mounting multiple cards vertcally in a standard 19" subrack.
2. A backplane connector to allow power, timing reference signals (see [@ts-design]), and control and monitoring signals -- including a 1 Gb Ethernet connection -- to be delivered to the FSM over a backplane with no cables.
3. Push-on SMC coaxial connectors to allow RF signals to be delivered from an analog receiver board to the FSM ADC without the need for cables.
4. Push on power and low-speed data (I2C) connectors to allow the FSM to supply power and a control and monioring interface to a connected analog reciever board (see [@asp-design]).
5. Basic peripherals for use during development, including an SD card form which the SoM CPU may be booted, and a USB serial interface for debugging.
6. Two QSFP28 connectors, providing up to 200 Gb/s of digital IO to the SNW network. These ports may be configured as either 25 GbE or 100 GbE links.
7. An RJ45 1 Gb Ethernet connector, providing a simple control and monitoring interface to the FSM which does not require the use of the backplane. This is intended to be used during development.

Since the FSM carrier board is relatively simple, it can be designed and tested in a short timeframe at a relatively low cost.
Design of the carrier will likely be contracted to the SoM vendor, iWave Systems Technologies, who already have experience in designing carrier boards similar to that which RCF requires.

![\label{fig:rcf-fsm}The FSM board, which hosts an AD9207 ADC chip and iWave ZU11-based System-on-Module, connected with an 8-lane JESD204C interface. The board features a backplane connector, through which power, timing references, and contrl signals may be delivered. The board interfaces with an analog receiver (part of the ASP subsystem) via push on connectors, avoiding the use of coaxial cables](images/rcf-fsm.drawio.pdf)

### FSM 19" Subrack

It is desirable for FSMs - of which there are more than 2000 - to be mounted in a standard 19" equipment rack, in a manner that makes it as easy as possible to replace a faulty module.

FSMs are designed to be comptible with 19" subracks supporting the Eurocard standard.
Such subracks are readily available from a variety of vendors, and are readily configurable to accomodate cards of different lengths and widths, with backplanes either conforming to an industry standard, or custom-designed to suit the needs of the system.
An example of a 3U Eurocard subrack is shown in Figure \ref{fig:eurocard-rack}.

![\label{fig:eurocard-rack} A basic 3U eurocard chassis, with card guides installed to accommodate ten 1.6 inch (8HP) cards. *Image Credit: Leeman Geophysical LLC*](images/eurocard-rack-photo.png){width=50%}

Multiple FSMs are slotted vertically into a subrack, whose backplane provides power, timing signals, and control interfaces to the modules.
An analog receiver board can then be slotted in front of the FSM in the same card guide slots passing analog signals to the FSM via push-on connetors.

Analog inputs are provided to each board assembly via optical RF connections on the front of the analog receiver board.
Digital data exits the board assembly via QSFP28 connectors on the rear of the FSM.
To enable these connectors to be accessible, the rear of the subrack uses a backplane which only occupies the lower half of the subrack height.
On the rear of the backplane, a pair of coaxial connectors provide timing signals from the upstream TS system, and high amperage connectors supply 12V power from external power supply units.

Each FSM is fitted with a finned heat-sink, and air is blown through the subrack from bottom to top using external fan trays (See Section \ref{sec:RackLayout}).
With heat-sinks fitted, the FSMs are 1.6 inches (8HP) wide, and thus 10 FSMs may be mounted in a standard 84 HP subrack.

### Subrack Management Card

Since the RCF system contains more than 2000 FSMs, densely packed in a relatively small number of racks, it is desirable to avoid the need for each FSM to have a cabled 1 GbE control and monitoring connection.
To this end, a "Subrack Management Card" (SRM, Figure \ref{fig:srm}) is included in each subrack, which uses a 1 GbE switch chip to allow all FSMs in a subrack to be reached via a single RJ45 Ethernet connection, via the subrack backplane.
The SRM is not a critical part of the RCF design - all FSM boards have an RJ45 connector to allow each to be individually connected to the control network - but makes use of the fact that 4HP of spare space is available in each 10-FSM subrack.

![\label{fig:srm} A "Subrack Management Card", which implements 1Gb Ethernet switching functionality to allow all RCF boards in a rack to be reached via a single RJ45 Ethernet connection.](images/srm.drawio.pdf){width=70%}

The SRM also features a small CPU subsystem based on a single System-in-Package (SiP) chip, which facilitates connecting to the debug interfaces of the FSMs in the subrack.
This feature - somewhat similar to the "out-of-band" management often supported by rack-mounted CPU servers - is designed to allow remote, low-level diagnostics in the event of any software issues which may render the FSMs unresponsive to their usual Ethernet control interface.

### Rack Layout \label{sec:RackLayout}

The RCF design is based around an architecture which hosts 80 FSM boards in a standard height (42U) 19" equipment rack.
Each rack services 80 dishes in the DSA2000 array, and 26 such racks are required for the full system.
Since the number of dishes in the array is not a muliple of 80, one rack in the system will only be partially populated with 48 FSMs, leaving at least 11U of extra empty space in this rack.
It is anticipated that this space will be utilized by the TS subsystem [@ts-design].
A fully-populated RCF rack servicing 80 dishes is shown in Figure \ref{fig:rcf-rack}.


![\label{fig:rcf-rack}One of 26 racks in the RCF system servicing 80 DSA antennas. The rack comprises 8 3U subracks, each holding 10 FSM assemblies and an SRM board. Pairs of subracks are cooled bottom-to-top using 1U fan trays, with off-the-shelf air deflector trays redirecting airflow so that the rack-level cooling is from front to back. Disrete 1U multi-module power supplies are used to obtain N+1 redundancy and hot-swappability of power supply modules.](images/rack_layout.drawio.pdf)

RCF racks are designed to be used in a data center which privides front-to-back cooling.
Since the FSM subracks are cooled top-to-bottom, air deflectors and 1U fan trays are used to channel cold air from the front of the rack and upwards through the subracks, with hot air exhausted from the rear of the rack.
These deflectors and fan trays are off-the-shelf components, with the latter providing healt monitoring capablities.

12V DC power is provided to all subracks from a pair of 1U power supply units, which themselves contain multiple hot-swappable power supply modules configured to provide N+1 redundancy.
It is estimated that each FSM will dissipate approximately 75W of power (with a further 7.5W dissipated by the 12V power supplies owing to conversion inefficiencies).
This estimate is based on hardware tests of an iWave SoM and AD9081 ADC board[^adc-devboard], which yield a total power consumption of 50W in applications with similar requirements to RCF.
A 50\% margin is added to this figure to account for functionality not yet included in these tests, including the use of off-chip RAM and high-speed Ethernet interfaces.

[^adc-devboard]: The AD9082 part is similar to the AD9207, but also includes digital-to-analog conversion capabilities, which RCF does not require.
However, unlike the AD9207, the AD9082 is provided as a development board (AD9082-FMCA-EBZ, (https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/eval-ad9082.html)[https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/eval-ad9082.html]) that can be used with iWave's off-the-shelf SoM evaluation kit.

The breakdown of power consumption in a fully-populated RCF rack is:

| Component | Quantity | Unit Consumption (W) | Total Consumption (W) | Notes |
| ------- | ---- | ----- | ----- | -------------------------------------------------------------- |
| FSM | 80 | 75 | 6000 | Estimated from hardware tests |
| SRM | 8 | 10 | 80 | Estimate | 
| Fan Tray | 4 | 97 | 388 | Model Schroff 10713-554 |
| Power Supply | 2 | 304 | 608 | 10\% inefficiency when supplying FSMs and SRMs |
| 1 GbE switch | 1 | 24 | 24 | Model FS S3910-24TF |
| 100 GbE switch | 1 | 600 | 600 | Model FS N8560-64C | 
| **RACK TOTAL** |  |  | **7700**| |


#### Beamformer Rack

There is one further rack in the RCF system, which is configured differently to the others.

As discussed further in Section \ref{sec:Firmware}, RCF performs beamforming in two stages.
The first stage beamforms signals from all dishes connected to a single rack.
This substantially reduces the amount of data which needs to transported outside the rack.
A second stage of beamforming is required to combine beams from each of the racks into a full tied-array beams. 
This architecture is shown in Figure \ref{fig:beamformer-arch}, and requires a rack configured as shown in Figure \ref{fig:beamformer-rack}.

![\label{fig:beamformer-arch}The RCF beamforming hardware architecture forms "sub-array" beams in each of 26 racks, and transmits these to a final rack to be summed into a full array beam and delivered to the PT subsystem.](images/beamformer-arch.drawio.pdf)

![\label{fig:beamformer-rack}A dedicated beamformer rack holds networking hardware to receive beams formed in all the other racks in the RCF system, and further FSMs which act to sum these beams together. Final beam products are then output to servers which are part of the PT subsystem.](images/pulsar-timing-rack.drawio.pdf)

The architecture includes the provision of a small number of "hot" spares in each rack, so that beamforming performance degradation is limited to the loss of a single dish's input signals in the event that an FSM fails.

The signal processing required in the final beamforming stage is very simple, and involves simply summing the data received from each of the other racks.
This processing could be performed on any of several off-the-shelf hardware platforms, but using the same FSM hardware as is present in the rest of the system (without analog receiver cards) reduces the complexity of firmware development and operations.

In the final beamforming stage the quantity of hardware must be sufficient to sink 4.3 Tb/s of data.
Since each RCF has two 100 GbE interfaces, at least 22 boards are required for this task.
Since FSMs are hosted in subracks holding 10 boards, the beamforming rack holds 30 modules, providing several hot spares.

It is anticipated that each FSM in the beamforming rack will consume much less power than those in the other racks, since they have a much lower compute load.
For this reason, only a single fan tray is usd to cool three subrack enclosures.

Assuming a power budget of 40W per FSM, and 1500W for each PT server, the breakdown of power consumption in the beamforming rack is:

| Component | Quantity | Unit Consumption (W) | Total Consumption (W) | Notes |
| ------- | ---- | ----- | ----- | -------------------------------------------------------------- |
| FSM | 30 | 40 | 1200 | Estimate |
| SRM | 3 | 10 | 30 | Estimate | 
| Fan Tray | 1 | 97 | 97 | Model Schroff 10713-554 |
| Power Supply | 1 | 123 | 123 | 10\% inefficiency when supplying FSMs and SRMs |
| 1 GbE switch | 1 | 24 | 24 | Model FS S3910-24TF |
| 100 GbE switch | 2 | 600 | 1200 | Model FS N8560-64C | 
| PT CPU/GPU Servers | 4 | 1500 | 6000 | Estimate |
| **RACK TOTAL** |  |  | **8644**| |

## Firmware \label{sec:Firmware}



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


