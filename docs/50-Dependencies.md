
# Dependencies and Assumptions \label{sec:dependencies}

Dependencies of RCF on other DSA2000 subsystems are as follows:

## Analog Signal Path (ASP)

1. ASP must deliver 4096 RF signals to RCF, with a bandwidth of 700 - 2000 MHz, compatible with a Nyquist bandwidth of 4800 Msps.
2. It is assumed that ASP will package optical receiver boards so that they are compatible with push-on connection to the FSM 3U Eurocard boards.

## Timing and Synchronization (TS)

1. TS should deliver a time reference signal (assumed to be a 375 Hz square wave with fast edges) which is resolvable at the precision of NTP.
2. TS distribution hardware is integrated into the FSM subrack backplane, and includes PLLs on the FSM carrier board. These need to be designed in collaboration with the RCF FSM system, which assumes that this backplane also delivers power and control signals.

## Central Control Network (CNW)

1. CNW is assumed to provide a 1 GbE network switch with at least 24 RJ45 ports in each of the 27 RCF 19" equipment racks.

## Monitor and Control (MC)

1. It is assumed that MC will deliver delay polynomials to RCF at a period of ~1 Hz.
2. It is assumed that MC protocols will be carried over the 1 GbE network provided by CNW.

## Facilities (FAC)

1. 27 standard height (42U) 19" equipment racks are required by RCF.
2. Cooling is required for 26 these racks dissipating 7.7 kW each, and 1 rack estimated to dissipate 8.6 kW (including 6kW of PT equipment).
3. Cooling is assumed to be front to back, with "cold aisles" at the front of the racks and "hot aisles" at the back.

## Signal Data Network (SNW)

1. SNW must provide a network switch to each of 26 racks capable of linking:
    1. 160 25 GbE links (to FSM boards)
    2. 2 100 GbE links (to RCF beamforming rack)
    2. at least 20 100 GbE links (or similar bandwidth; to RCP)
2. SNW must provide one rack with two switches, each having at least 58 100 GbE ports.

## Radio Camera Processor (RCP)

1. RCP is expected to receive UDP packets from RCF over an Ethernet network.
2. These packets hold 4+4-bit complex-valued samples in a format described in @icd-rcf-rcp.

## Pulsar Timing (PT)

1. PT is expected to receive UDP packets from RCF over an Ethernet network.
2. These packets contain 16+16-bit complex-valued beam voltages, in a format yet to be defined.
