# Introduction

The Radio Camera Frontend (RCF) is a Level 2 subsystem of the DSA2000.

The primary tasks of RCF are to digitize broadband analog signals from all DSA antennas, channelize these into a variety of higher resolution data products, and transmit this data to the Radio Camera Processor (RCP) subsystem for correlation and imaging.
RCF is also tasked with forming synthesized beams in multiple sky directions, which are transmitted to the Pulsar Timing (PT) subsystem.

This document describes the requirements of the RCF subsystem (Section \ref{sec:Requirements}) and details the preliminary design of RCF (Section \ref{sec:Design}).
The design description includes RCF's interfaces to other DSA subsystems (Section \ref{sec:Interfaces}), its processing tasks (Section \ref{sec:Processing}), as well as its hardware (Section \ref{sec:Hardware}) and software (Section \ref{sec:Firmware}) implementations.
Finally, this document lists the requirements placed on other DSA subsystems by the RCF design (Section \ref{sec:dependencies}).
