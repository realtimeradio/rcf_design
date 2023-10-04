# Design

Here the preliminary design of the Radio Camera Frontent (RCF) is described.

## Interfaces

The top-level RCF interfaces are shown in Figure \ref{fig:rcf-interfaces}.

![\label{fig:rcf-interfaces}Top-level interfaces to the RCF subsystem. 4000 RF signals are delivered by ASP, which must be digitized and channelized before being passed to SNW. Some data (used for beamforming) is returned to RCF from SNW, beamformed, and then delivered back to SNW](images/rcf-interfaces.drawio.pdf)

The primary inputs to RCF are the 4000 RF signals (2000 dual-polarization) provided by the ASP subsystem.
The primary outputs of RCF are all digital data streams transmitted to SNW.
These outputs comprise both the channelized voltages used by RCP, as well a the beamformed voltages used by PTS.
RCF also receives data from SNW, in order to carry out beamformer processing, which is a task that is parallel by frequency, but not antenna, and therefore benefits from SNW's ability to perform frequency-antenna data transposition.

A major interface also exists between RCF and MNC in order to facilitate runtime control and health monitoring of the RCF system.

## RCF Logical System Breakdown

It is useful to further break down the RCF system into its constituent logical components, as shown in Figure \ref{fig:rcf-logical-components}.

![\label{fig:rcf-logical-components}Logical components of the RCF subsystem.](images/rcf-interfaces-logical.drawio.pdf)

## Specifications

### Frequency Channels

| Data Product | Required bandwidth (MHz) | Channel Bandwidth (kHz) | Number of channels | Total bandwidth (MHz) |
|------------------------------------------|-------------------------|-------------------------|--------------------|-----------------------|
| NC | 1300                    | 130.2                   | 10000              | 1302.1                |
| AC | 34                      | 8.138                   | 4192               | 34.1                  |
| BC | 0.95                    | 1.017                   | 960                | 0.977                 |
| TC | 1300                    | 2.083                   | 624                | 1300                  |
| TOTAL (excluding TC) | 1334.95 | -   | 15152 | 1337.2  |
| TOTAL         | 2634.95                 | -                       | 15776              | 2637.2                |


### Frequency Channel Response

![\label{fig:stage1-response}The PFB response of the first stage filter, which is oversampled by a factor of 4/3](images/first_stage_pfb_response.pdf)

![\label{fig:stage2-response}The PFB response of the second stage filters for NC, AC, and BC channelization products.](images/second_stage_pfb_response.pdf)

![\label{fig:stage2tc-response}The PFB response of the second stage filters for TC channelization products.](images/second_stage_pfb_tc_response_1xscale.pdf)

![\label{fig:stage2tc-response-scale}A possible PFB response of the second stage filters for TC channelization products with the filter passbands set to 85% of their usual width.](images/second_stage_pfb_tc_response_0.85xscale.pdf)

## Hardware

### Rack Layout

![](images/rack_layout.drawio.pdf)

## Firmware
### Processing Pipeline

![\label{fig:firmware}](images/rcf-firmware.drawio.rot270.pdf)

![\label{fig:adc-config}](images/rcf-adc-pipeline.drawio.pdf)

Figure \ref{fig:firmware}

