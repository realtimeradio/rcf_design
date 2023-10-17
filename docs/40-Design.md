# Design

Here, the preliminary design of the Radio Camera Frontent (RCF) is described and justified.

## Interfaces

The top-level RCF interfaces to other DSA2000 subsystems are shown in Figure \ref{fig:rcf-interfaces} and are as follows:

1. Analog Signal Path (ASP): 4096 RF signals (two polarizations from each of 2048 dishes) are delivered by ASP, which must be digitized and processed by RCF.
1. Timing and Synchronization (TS): RCF receives timing signals from TS, and uses them to ensure coherent digitization and accurate timestamping of data streams.
1. Central Control Network (CNW): A 1 Gb Ethernet network responsible for delivering control messages to RCF.
1. Monitor and Control (MC): RCF receives and acts on commands from MC, and must be able to report its health status to MC. These commands are delivered via CNW.
1. Facilities (FAC): FAC provide the space, power, and cooling infrastructure to support RCF.
1. Signal Data Network (SNW): SNW is a 25/100/400 Gb/s Ethernet network responsible for transporting high-speed digital data products from RCF to RCP and PT. In addition, SNW provides data transmission paths between different RCF processors.
1. Radio Camera Processor (RCP): RCP receives channelized voltages from RCF, via the SNW network, and uses them to produce images and transient event data products.
1. Pulsar Timing (PT): PT receives channelized beam voltages from RCF, via the SNW network, and uses them to produce pulsar timing data products.

![\label{fig:rcf-interfaces}Top-level interfaces to the RCF subsystem. Interfaces which are logical only (MC, whose control messages are delivered via CNW, and RCP, whose data are delivered via SNW) are indicated with dotted arrows.](images/rcf-interfaces.drawio.pdf)

The basic specifications for these interfaces are described in Section \ref{sec:dependencies}.

## Processing

The data products which must be produced by RCF are:

1. Channelized voltages, which are used by RCP for image processing and transient searching.
As discussed in Section \ref{sec:freq-res}, three different channelization products are required:
    1. Narrowband continuum (NC) channelized voltages, covering 700 - 2000 MHz, with a channel bandwidth of <146.8 kHz.
    2. Zoom band "A" (AC) channelized voltages, covering 1388 - 1422 MHz, with a channel bandwidth of <9.25 kHz.
    3. Zoom band "B" (BC) channelized voltages, covering 1419.93 - 1420.88 MHz, with a channel bandwidth of <1.42 kHz.
2. 4 channelized beams, which are used by PTS for pulsar timing. These should cover the band 700 - 2000 MHz, with a channel bandwidth of >2048 kHz.


## Hardware

RCF requires hardware to digitize and process the 4096 RF signals provided by ASP.
Since ASP is responsible for transporting all analog signals to a central processing facility, RCF is free to use a hardware architecture that requires that any number of signals be processed in each physical hardware module.
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

RCF has chosen the iW-RainboW-G35M SoM from iWave Systems Technologies[^iwave] (Figure \ref{fig:iwave-zu11}), populated with a Xilinx/AMD Zynq Ultrascale+ ZU11-EG System-on-Chip, which is, itself, a CPU and FPGA integrated into a single chip package.

![\label{fig:iwave-zu11}The top (left) and bottom (right) of the iW-RainboW-G35M system on module from iWave Systems Technologies.
The module incorporates a Xilinx/AMD Zynq Ultrascale+ System-on-Chip with power and RAM support infrastructure on an assembly designed to be mounted to a larger circuit board.
\emph{Image credit: iWave System Technologies}}](images/iwave-front-rear.png){width=100%}

The ZU11-EG is a mid-range FPGA, with 0.65 million logic cells, 2928 hardware DSP slices, and 43.6 Mb of dedicated on-chip RAM.

#### FPGA Station Module Carrier Board

With the FPGA SoM and ADC chip selected for RCF, a custom "carrier board" is required to host these components and provide physical interfaces to the other DSA2000 subsystems.

A block diagram of the FSM carrier is shown in Figure \ref{fig:rcf-fsm}.
The board has the following features:

1. Based around the 100 mm x 220 mm Eurocard form factor, which allows sufficient area for necessary components and can be vertically mounted in a 3U-high subrack of a standard 19" rack.
2. A backplane connector to allow power, timing reference signals (see [@ts-design]), and control and monitoring signals -- including a 1 Gb Ethernet connection -- to be delivered to the FSM over a backplane with no cables.
3. Blind-mate coaxial connectors to allow RF signals to be delivered from an analog receiver board to the FSM ADC without the need for cables.
4. Blind-mate connector carrying power and low-speed data (eg. I2C) to allow the FSM to supply power and a control and monioring interface to a connected analog reciever board (see [@asp-design]).
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


![\label{fig:rcf-rack}One of 26 racks in the RCF system servicing 80 DSA antennas. The rack comprises 8 3U subracks, each holding 10 FSM assemblies and an SRM board. Pairs of subracks are cooled bottom-to-top using 1U fan trays, with off-the-shelf air deflector trays redirecting airflow so that the rack-level cooling is from front to back. Discrete 1U multi-module power supplies are used to obtain N+1 redundancy and hot-swappability of power supply modules.](images/rack_layout.drawio.pdf)

RCF racks are designed to be used in a data center which privides front-to-back cooling.
Since the FSM subracks are cooled bottom-to-top, air deflectors and 1U fan trays are used to channel cold air from the front of the rack and upwards through the subracks, with hot air exhausted from the rear of the rack.
These deflectors and fan trays are off-the-shelf components, with the latter providing healt monitoring capablities.

12V DC power is provided to all subracks from a pair of 1U power supply units, which themselves contain multiple hot-swappable power supply modules configured to provide N+1 redundancy.
It is estimated that each FSM will dissipate approximately 75W of power (with a further 7.5W dissipated by the 12V power supplies owing to conversion inefficiencies).
This estimate is based on hardware tests of an iWave SoM and AD9081 ADC board[^adc-devboard], which yield a total power consumption of 50W in applications with similar requirements to RCF.
A 50\% margin is added to this figure to account for functionality not yet included in these tests, including the use of off-chip RAM and high-speed Ethernet interfaces.

[^adc-devboard]: The AD9082 part is similar to the AD9207, but also includes digital-to-analog conversion capabilities, which RCF does not require.
However, unlike the AD9207, the AD9082 is provided as a development board (AD9082-FMCA-EBZ, [https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/eval-ad9082.html](https://www.analog.com/en/design-center/evaluation-hardware-and-software/evaluation-boards-kits/eval-ad9082.html)) that can be used with iWave's off-the-shelf SoM evaluation kit.

The breakdown of power consumption in a fully-populated RCF rack is:

| Component | Quantity | Unit Power (W) | Total Power (W) | Notes |
| :------ | :-----: | :-----: | :-----: | :----------------------- |
| FSM | 80 | 75 | 6000 | Estimated from development hardware tests using representative firmware|
| FSM       | 80       | 75                   | 6000 | Estimated from hardware tests |
| SRM       | 8        | 10                   | 80   | Estimate | 
| Fan Tray  | 4        | 97                   | 388  | Model Schroff 10713-554 |
| Power Supply | 2     | 304                  | 608  | 10\% inefficiency when supplying FSMs and SRMs |
| 1 GbE switch | 1     | 24                   | 24   | Model FS S3910-24TF |
| 100 GbE switch | 1   | 600                  | 600  | Model FS N8560-64C | 
| **RACK TOTAL** |     |                      | **7700** | |


#### Beamformer Rack \label{sec:BeamformerRack}

There is one further rack in the RCF system, which is configured differently to the others.

As discussed further in Section \ref{sec:Firmware}, RCF performs beamforming in two stages.
The first stage beamforms signals from all dishes connected to a single rack.
This substantially reduces the amount of data which needs to transported outside the rack.
A second stage of beamforming is required to combine sub-array beams from each of the racks into full-array beams. 
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

| Component | Quantity | Unit Power (W) | Total Power (W) | Notes |
| :------ | :-----: | :-----: | :-----: | :----------------------- |
| FSM | 30 | 40 | 1200 | Estimated from development hardware tests using representative firmware|
| SRM | 3 | 10 | 30 | Estimate | 
| Fan Tray | 1 | 97 | 97 | Model Schroff 10713-554 |
| Power Supply | 1 | 123 | 123 | 10\% inefficiency when supplying FSMs and SRMs |
| 1 GbE switch | 1 | 24 | 24 | Model FS S3910-24TF |
| 100 GbE switch | 2 | 600 | 1200 | Model FS N8560-64C | 
| PT CPU/GPU Servers | 4 | 1500 | 6000 | Estimate |
| **RACK TOTAL** |  |  | **8644**| |

## Firmware \label{sec:Firmware}

In this section the digitization and processing methods used by the RCF firmware are described.

### Digitization

Since the DSA's science band of interest is 700 - 2000 MHz, the simplest digitization configuration is to direct-sample these signals at at least twice the highest RF frequency - i.e., sample at at least 4000 Msps.
The RCF design assumes that the samping rate will be 4800 Msps, which results in analog anti-aliasing filter requirements which should be easy to meet.

Rather than pass the entire digitized band from the ADC chip to FPGA, the RCF leverages the mixing, filtering, and decimation capabilities of the ADC to reduce the bandwidth of the digitized data as early as possible in the processing pipeline.
ADC signal processing configuration is shown in Figure \ref{fig:adc-config}.

![\label{fig:adc-config}The configuration of RCF's AD9207 data path. RF signals are sampled at 4800 Msps, before being mixed, filtered, and decimated to deliver a 1600 MHz Nyquist band centred at 1350 MHz.](images/rcf-adc-pipeline.drawio.pdf){width=70%}

Analog samples are initially digitized at 4800 Msps with 12 bits of resolution, and then mixed with a digitally generated oscillator, filtered, and decimated to produce a quadrature-sampled 1600 MHz Nyquist baseband centered at 0 Hz.
The AD9207's decimation filters have a usable passband -- defined as the region with better than 100 dB image rejection and less than $\pm 0.001$ dB of passband ripple -- of 81.4\% [@ad9207].
For a sampling rate of 1600 Msps, this corresponds to a passband of 1302.1 MHz, which is sufficient to cover the 700 - 2000 MHz band of interest.
This data is passed from ADC to FPGA as an 8-lane JESD204C interface running at 13.2 Gbps per lane.

### Signal Processing

Once ADC sample streams for a polarization pair are received by a JESD204C receiver in the FPGA, they enter a signal processing pipeline which implements the following functions:

1. Time stamping, where the time reference signals available to each FPGA are used to associate a precise timestamp with each ADC sample. This timestamp is used to label data which are transmitted to downstream processors, and is also used internally to ensure proper timekeeping in the delay and phase tracking system.
2. Coarse delay correction up to 81920 ADC sampled (up to 51.2 \textmu s at a sample rate of 1600 Msps).
3. First-stage Polyphase Filter Bank (PFB) generating 256 channels, each 8.33 MHz wide and overlapping by a factor of $\frac{4}{3}$.
4. Fine-Delay correction and phase-rotation, to allow the phase and delay of each signal path to be tracked as the sky rotates, and to allow small frequency shifts to be applied to each 8.33 MHz channel to allow potential compensation for any source doppler shift.
5. Four parallel second-stage filterbank pathways, generating channels at NC, AC, BC, and TC resolutions, and removing the $\frac{4}{3}$ overlap between channels.
6. Requantization of output data to 4+4 bit complex resolution.
7. Packetization of data into a stream of UDP packets output to the SNW system over a pair of 25 GbE connections.
8. Beamforming of TC data from 80 dishes, received via a 25GbE connection, to form 4 beams at 8+8 bit complex resolution. This data is transmitted back over 25 GbE to be summed by separate FPGAs in the beamformer rack (see Section \ref{sec:BeamformerRack})[^bf-fpgas].

[^bf-fpgas]: The firmware running on the FPGAs in the beamformer rack simply receives data from multiple FPGAs, sums it without any further processing, and transmits (via SNW) to the PT system. The firmware running on these FPGAs is not discussed further here.

This signal processing pipeline is shown in block diagram form in Figure \ref{fig:firmware}.
Each processing block is described in more detail below.

![\label{fig:firmware}The FPGA signal processing pipeline, for each dual-polarization pair of dish signals.](images/rcf-firmware.drawio.rot270.pdf)

#### Time Stamping

Network Time Protocol ensures that the CPU subsystem on each FPGA board agrees the time to a precision better than 1 ms. However, this is not sufficient for precisely assigning a time to each ADC sample such that data processed by multiple FPGAs can be coherently combined.
For this reason, the TS system provides a 375 Hz signal to each FPGA whose time of arrival is precisely controlled such that the ADC sample associated with an edge of the 375 Hz reference can be reliably identified.
Since edges of the 375 Hz reference occur at a larger separation than NTP precision, successive edges can be disambiguated using local system time, and all FPGAs can agree to associate a common time to the ADC sample associated with any given edge.

These timestamps are carried with ADC samples through the processin pipeline, so that processing blocks which need to know the time associated with a sample (eg, the fine delay correction and phase rotation block) can do so.

#### Coarse Delay Correction

On-chip *UltraRAM* blocks are used to implement a coarse delay buffer for each of the two signal paths. These buffers are 640 kiB deep, and allow compensation for delays of up to 81920 samples (51.2 \textmu s at a sample rate of 1600 Msps), satisfying requirement RcfR-0007.

#### First-Stage PFB

The first stage filterbank generates 256 channels, each 8.33 MHz wide and overlapping by a factor of $\frac{4}{3}$.
The filterband is 32-taps long, and uses a Hann window to generate channels with the response shown in Figure \ref{fig:stage1-response}.

![\label{fig:stage1-response}The PFB response of the 32-tap, Hann-windowed first stage filter, which is oversampled by a factor of 4/3. The frequency axis is normalized such that bins centers are separated by 1. Solid black verical lines indicate location of bin enters. Shaded regions, bounded by dashed black verical lines indicate the non-overlapping bin widths, which are 6.25 MHz wide. Dotted red vertical lines indicate the Nyquist boundaries of the overlapping bins, each of which is 8.33 MHz wide.](images/first_stage_pfb_response.pdf)

#### Fine Delay Correction and Phase Rotation

Fine delay correction and phase rotation are implemented as a multplication of each 8.33 MHz channel with a unit-magnitude complex exponential.

The phase of this exponential varies over time, and compensates for the changing path lengths from source to antenna, as well as the related effects of the upstream digital LO.

A tiered approach to time-keeping is used to ensure that phasors values may be updated sufficiently quickly without the need for high data-rate communication between the RCF and MC subsystems.

1. Messages from MC to RCF are sent at a rate of ~1 Hz, and contain a delay polynomial which specifies the delay to be applied to a given antenna at a given time.
2. Every ~100ms, a CPU-based delay control module calculates the delay, phase, and per-spectrum delay-increment and phase-increment which should be applied to a pipeline's signals. This delay, phase, delay-rate, and phase-rate are written to FPGA registers, and a new coarse delay is set. A timed trigger is used so that all new parameters are applied to data simultaneously.
3. Every ~1 \textmu s, the phasors to be applied to each 8.33 MHz channel are updated by the FPGA.

With this architecture, delays are updated at ~MHz rate, comfortably satisfying RcfR-0010.
Delay-correcting 8.33 MHz channels also satisfies RcfR-0009 -- that the phase error after delay application across a channel be $<1\circ$ -- since, at 1600 Msps -- the sub-sample component of delay is 0.625 ns, which represents a maximum phase deviation from the center of an 8.33 MHz channel of $\pm 0.9^\circ$.

#### Second-Stage PFB

Second stage filters are constructed to generate the appropriate NC, AC, BC, and TC channelization products.
The resolutions are shown below, and satisfy, respectively, RcfR-0001, RcfR-0002, RcfR-0003, and RcfR-0004.

| Data Product | Required bandwidth (MHz) | Channel Bandwidth (kHz) | Number of channels | Total bandwidth (MHz) |
|------------------------------------------|-------------------------|-------------------------|--------------------|-----------------------|
| NC | 1300                    | 130.2                   | 10000              | 1302.1                |
| AC | 34                      | 8.138                   | 4192               | 34.1                  |
| BC | 0.95                    | 1.017                   | 960                | 0.977                 |
| TC | 1300                    | 2083                   | 624                | 1300                  |
| TOTAL (excluding TC) | 1334.95 | -   | 15152 | 1337.2  |
| TOTAL         | 2634.95                 | -                       | 15776              | 2637.2                |

Second-stage PFBs for the NC, AC, and BC channels are all 8-tap, Hann-filtered, and have a response shown in Figure \ref{fig:stage2-response}.

![\label{fig:stage2-response}The PFB response of the second stage filters for NC, AC, and BC channelization products.](images/second_stage_pfb_response.pdf)

The length of these filters is limited to 8-taps in order to fit in available FPGA RAM resources.
The second stage TC filter is upchnnelises by only a factor of 4, and thus can be made longer while still fitting in a reasonable RAM footprint.
The TC filter has 24 taps, and a response shown in Figure \ref{fig:stage2tc-response}.

![\label{fig:stage2tc-response}The PFB response of the second stage filters for TC channelization products.](images/second_stage_pfb_tc_response_1xscale.pdf)

If necessary, it is easy to modify the shape of the TC filters to give better channel isolation at the expense of passband width, as shown in Figure \ref{fig:stage2tc-response-scale}.
This is a strategy which has been adopted by other pulsar timing experiements (see, for example, [@Bailes2020]).

![\label{fig:stage2tc-response-scale}A possible PFB response of the second stage filters for TC channelization products with the filter passbands set to 85% of their usual width.](images/second_stage_pfb_tc_response_0.85xscale.pdf)

#### Requantization

Requantization to complex sample with 4 bits of precision per real and imaginary component is used to reduce the data output rate of each FPGA.
Values are scaled using a frequency-dependent, runtime-programmable scaling factor, and then rounded, with saturation to value in the interval $[-7, 7]$.
Though a 4-bit two's complement representation is able to use the value -8, this value is prohibited in order to maintain a symmetric quantization scheme.
Instead, the 4 bit code "0b1000" is used to indicate that a value is flagged.
Flagging logic is still under design.

#### Packetization

Data are reordered and packetized into a stream of UDP packets. NC, AC, or BC data are transmitted over 25 GbE to destinations in the RCP system.
TC data are transmitted over 25 GbE to FPGAs within the same rack, such that each of 78 FPGAs in a rack receive 8 frequency channels of TC data from all dishes serviced by the rack.

Since data entering the packetization system has been quantized to 4+4-bit, it has substantially lower data rate than earlier in the system.
This allows reordering to be carried out in high-capacity off-chip DDR4 memory, meaning that large data transpose operations are possible.
This allows large packets (e.g. of 256 time samples and 16 frequency channels) to be generated and transmitted to RCP, reducing transmission and processing overheads.

In the case of TC packets, reordering in DDR4 memory means that there is a large amount of buffer space available to compensate for instrumental delays present in the analog system (RcfR-0008).

#### Beamforming

The beamformer subsystem receives 8 TC channels of data for 80 dual-polarization signals, and uses these to form 4 sub-array beams.

It would be easiest to simply multiply TC channels by an appropriate phase factor and sum them to form each beam.
Unfortunately, this results in an unacceptable level of frequency smearing, given the broad bandwidth of the TC channels and wide field of view of the DSA dishes (see Section \ref{sec:freq-res}).
Instead, the beamformer implements a 32-point fast-convolution filter on each TC channel, effectivey upchannelizing to 65 kHz, phase rotating, and then re-synthesizing 2.1 MHz channels.

Beam pointing delays are received from the MC subsystem and applied to data in a similar fashion to the fine delay correction and phase rotation module.
However, since the data input to the beamformer have already been phased to the direction the array is pointing, required delay and phase update rates are relatively low.

Since the beamforming processing combines signals from 80 dishes, output data precision of 8+8 bit is maintained, to allow for an increase in signal-to-noise.

This 8+8 bit data, which totals 2.13 Gb/s from each FPGA in a rack and represents 4 dual-polarization beams, is transmitted over 25 GbE to the beamformer rack, where it is summed with data from other racks to form a full array beam at 16+16-bit precision (see Figure \ref{fig:beamformer-arch}). 
### Resource Utilization
