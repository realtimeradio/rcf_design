# Requirements

A number of science requirements are defined for the DSA2000 system, each designated by a unique identifier of the form "ScR-XXXX".

Here we consider the requirements which are relevant to the design of the RCF, and derive a set of subsystem requirements with designations "RcfR-XXXX".

## Frequency Resolutions and Spans \label{sec:freq-res}

A number of requirements directly relating to frequency coverage and channel resolutions are present in DSA2000 science requirements.

These are:

 1. ScR-0004: Frequency coverage from 0.7 to 2.0 GHz
 1. ScR-0026 [High-z continuum]: HI velocity resolution of $<62$ km/s for galaxies $>-1000$ km/s and $z<1$
 1. ScR-0027 [Zoom A]: HI velocity resolution <2 km/s for galaxies >-500 km/s and distance $<100$ Mpc.
 1. ScR-0028 [Zoom B]: HI velocity resolution <0.3 km/s for galactic HI, covering HI emission between -100 km/s and +100 km/s.
 1. ScR-0029 [Tunability]: Zoom bands A and B should be tunable.
 1. ScR-0022 [Pulsar Timing]: Pulsar-phase coherent folding with $\geq 2048$ phase bins for pulsars with periods > 1 ms.


From these requirements, the following resolutions and bandwidths are inferred:

 1. ScR-0004: Total coverage 0.7 to 2.0 GHz
 1. ScR-0026 [High-z continuum]: Coverage from 0.71 to 1.425  GHz, at $<146.8$ kHz resolution at 0.71 GHz and $< 294.5$ kHz resolution at 1.425 GHz.
 1. ScR-0027 [Zoom A]: Coverage from 1.388 to 1.422 GHz, at $<9.25$ kHz (at 1.388  GHz).\footnote{The minimum frequency is computed by converting 100 Mpc to a redshift, using a Hubble constant of 70 $\frac{\mathrm{km/s}}{\mathrm{Mpc}}$.}
 1. ScR-0028 [Zoom B]: Coverage of 1419.93 -- 1420.88 MHz with a channel width $<1.42$ kHz.
 1. ScR-0029: Center frequency of Zoom A and Zoom B windows is arbitrarily tunable within the 0.7 -- 2.0 GHz band, with resolution and bandwidth set by ScR-0027 and ScR-0028.
 1. ScR-0022 [Pulsar Timing]: Coverage from 0.7 to 2.0 GHz at $\geq$ 2.048 MHz resolution.\footnote{This assumes a critically-sampled channelized data stream, with at least 2048 spectra produced every 1 ms.}

There is no science requirement on frequency resolution above 1.425 GHz. Here, the maximum channel bandwidth is likely to be limited by frequency smearing effects.
For an array with maximum baseline length of 15 km, and a phase center referenced to the center of the array, a signal received 1.5 degrees from boresight (the FWHM of the DSA2000 dish is expected to be approximately 3 degrees at 1.35 GHz) has a maximum delay relative to a boresight signal of
$$
\sin \left( 1.5^{\circ} \right) \times \frac{7.5 \mathrm{km}}{c} = 654 \mathrm{ns} .
$$
This implies that the frequency channel width, $\Delta f$ at 1.35 GHz should satisfy
$$
    \Delta f \ll (654 \mathrm{ns})^{-1}  ,
$$
i.e.,
$$
    \Delta f \ll 1529 \mathrm{kHz} .
$$

There is no explicit requirement on how much smearing is tolerable, but, noting that the most stringent ScR-0026 frequency resolution requirement demands a channel width of less than 146.8 kHz at 0.71 GHz, this width is taken as a minimum requirement over the entire band.

 > The memory footprint of RCF processing is strongly dependent on the frequency resolution of channels which may be generated -- narrow channel bandwidth requires more memory.
 > Downstream RCP processing is also strongly dependent on the number of frequency channels which need to be imaged -- more numerous, narrower channels require more processing.
 > These factors both mean that a relaxing of minimum channel bandwidth over some fraction of the 0.7 to 2.0 GHz observing band may potentially make RCF implementation easier, and reduce the size (and cost) of RCP.


The following table summarises *RcfR-0001* through *RcfR-0004*, the bandwidth and resolution requirements which satisfy all science requirements:

| Requirement | RCF Product Abbreviation| Frequency Range (MHz) | Bandwidth (MHz) | $\Delta f$ (kHz) |
| ----------- | ------------ | --------------------- | --------------- | ---------------- |
| *RcfR-0001* | NC | $700 - 2000$           | $\geq 1300$     | $< 146.8$          |
| *RcfR-0002* | AC | $1388 - 1422$          | $\geq 34$       | $< 9.25$         |
| *RcfR-0003* | BC | $1419.93 - 1420.88$    | $\geq 0.95$     | $< 1.42$         |
| *RcfR-0004* | TC | $700 - 2000$           | $1300$            | $\geq 2048$          |



## Frequency Channel Response

RCF is required to generate multiple narrow-band frequency channels from a single wide-band input signal.
It is not possible for each generated channel to have a perfectly flat response nor infinite out-of-band rejection.
In general, constructing channels with responses approaching that of an ideal "brick-wall" filter requires increasing computational resources.

There is currently only one science requirement from which a channel response requirement may be derived, and it may be directly mapped into *RcfR-0005*:

 1. ScR-0041 / *RcfR-0005*: Attenuation from the center of one channel to an adjacent channel shall be $\geq 60$ dB.

> Other requirements may be useful in further specifing channel response, for example:

> - Maximum allowed passband ripple
> - Minimum attenuation at >1 channel offset

## Doppler Tracking

The velocity of the Earth, relative to observed radio sources, changes over the course of time, primarily because of the planet's rotational and orbital motion.
Therefore, a time-varying Doppler adjustment is required to convert the observed frequency of a source into a source velocity relative to a Local Standard of Rest (LSR) frame.

Science requirement ScR-0032 states:

- ScR-0032: [The DSA2000 system shall be capable of] correction for all motion relative to LSR with accuracy $< 0.01$ km/s.

Such adjustment may be carried out after correlation or image-making, by interpolating the frequency channels of a given data set onto a standard velocity frame.
Alternatively, the center frequency of each frequency channel may be adjusted in real time to track the Doppler shift of a source.
Whatever the mechanism, adjustment must be applied before summing together data from time periods over which the center frequency of a frequency channel moves significantly.

For DSA-2000, it is useful to be able to track the Doppler shift in real time over the coarse of a mosaic observation, which may last for $10 - 100$ hours.
This means that the RCP system does not need to add Doppler shift processing to its pipeline prior to writing data to the archiving system.

The following requirement aims to explicitly ensure this is enabled by the RCF design:

- *RcfR-0006*: Over a period of 100 hours, when measured in the solar barycenter rest frame, the center frequency of any RCF frequency channel shall not shift by $>10\%$ of the channel width.

<!--
\subsubsection{Doppler Tracking}

The maximum Doppler correction due to the orbit of the Earth is approximately 30 km/s, which is a shift of 200 kHz at 2 GHz. This velocity also represents a differential shift of 0.1 kHz over 1 MHz of bandwidth.

Assuming that the DSA RCF implements a two-stage filterbank, the consequence of the shift at 2 GHz is that the edge 200 kHz (at the high-frequency end of the band) of each first-stage frequency channel is unusable.

The consequence of the differential shift is that, even it the first-stage filterbank channels are Doppler tracked, some residual frequency shift will persist over the width of these channels.
If the extent of this shift is unacceptable, it may be necessary to track some first-stage channels to multiple Doppler velocities, and then ...
-->

## Delay & Phase tracking

In order that DSA2000's imaging system is able to correlate and integrate signals from multiple antennas for ~seconds, it is necessary that the signals from each antenna are delayed and phase-aligned to a common reference.
The delay and phase which needs to be applied to an antenna signal is a function of the direction of the source being observed, and thus changes over time.

Here the size of the delays which need to be applied to signals from each antenna are considered, as well as the rate at which they are expected to change.

### Coarse Delay

The maximum geometric delay between antennas in an array -- i.e., the maximum difference in arrival times of a common wavefront at two different antennas -- is given by:

$$
    \tau = \frac{B_{\textrm{max}}}{c}  ,
$$

where $c$ is the speed of light, and $B_{\textrm{max}}$ is the maximum baseline length.
For the DSA, $B_{\textrm{max}} = 15$ km and **the maximum geometric delay is 50 \textmu s.**

Assuming that digitization of signals from all antennas occurs in a central location, further inter-antenna delays are introduced by analog cabling (and, to a lesser extent, other instrumentation) between the antennas and digitizers.
Assuming that cable length differences are of length $\sim B_{\textrm{max}}$, and the speed of light in a cable is $\sim \frac{2}{3}c$, **instrumental inter-antenna delays for the DSA2000 will be approximately 75 \textmu s.**

Compensation of both geometric and instrumental delays is achieved in a radio telescope's digital processing by using memory buffers to delay the earliest arriving data streams such that they may be coherently combined with the latest arriving.
The practical implementation of this scheme may utilize buffering in either, or both, of  RCF and RCP.
For the purposes of producing a viable RCF design, the following requirements are used:

 - *RcfR-0007*: RCF shall have sufficient time delay buffers to compensate for DSA2000's maximum geometric delay, 50 \textmu s
 - *RcfR-0008*: Where RCF is required to generate beams from multiple antenna elements, it must be capable of compensating for both instrumental and geometric delays, totalling 125 \textmu s.

Implicit in the first requirement is a statement that RCF need not use time-delay buffers to compensate for all instrumental delays before emitting data to RCP.
It is assumed that large - and mostly stable - instrumental delays corresponding to multiples of the channelized sample period may be absorbed into the RCP buffering system.

### Fine Delay

For any digital system which implements time-domain delay compensation using a simple sample buffer, the precision of this correction is limited by the system sample rate.
Errors of 0.5 samples in the delay applied to a complex data stream equate to residual phase errors over the Nyquist band being processed of up to $\frac{\pi}{2}$ radians (or $\frac{\pi}{4}$ for a real signal).
In principle, this residual phase slope across the observing band may corrected in downstream processing outside of RCF. However, this requires that the downstream processor knows the delay applied to the data stream (and its resulting error) at any given time.

Processing is simplified if RCF implements a *fine-delay* - that is, a sub-sample delay which is applied as a phase to each frequency channel - within its processing pipeline.

A requirement is created to ensure that RCF implements a fine delay:

- *RcfR-0009*: RCF shall ensure that, after applying a delay correction to a data stream to phase it to a particular sky position, the residual error across any frequency channel shall be $<1^\circ$.

### Fringe Rate

The delays required to phase-align signals from multiple antennas to a common reference are a function of the direction of the source being observed and thus changes with time.

The maximum rate at which RCF needs to update the delay applied to each antenna signal may be computed by considering the array's maximum *fringe rate*.
This is the maximum rate at which the relative phases of signals from two antennas in the array changes through a phase of $2\pi$ radians.

Maximum fringe rate $f_{\textrm{max}}$ is given by:
$$
    f_{\textrm{max}} = \Omega_{e} \frac{B}{\lambda}
$$

Where $\Omega_{e} = 7.27 \times 10^{-5}$ radians/second is the angular speed of the Earth, $B$ is the maximum baseline length, and $\lambda$ is the minimum observing wavelength.

For DSA2000, $B=15$ km, $\lambda=15$ cm, giving a **maximum fringe rate of 7.3 Hz**.

In order that, after correction, the relative phase of two antenna signals not change by more than $1^\circ$ over time, delays must be updated at least 360 times every $\frac{1}{7.3}$ seconds.
This yields the further requirement:

- *RcfR-0010*: RCF shall be capable of updating the delay applied to each antenna signal at least 2628 times per second.

## Beamforming

*ScR-0025* states that the DSA2000 system shall be capable of simultaneously forming beams with 4 different phase centers within the primary beam, and coherently dedispersing these time-streams.
De-dispersion is the purview of the PT subsystem and is outside the scope of RCF. However, with the following requirement the formation of beams is explicity made part of the RCF system:

- *RcfR-0011*: RCF shall form 4 dual-polarization voltage streams, using the *TC* data products defined by *RcfR-0004*.


## Summary


The following table summarises the derived RCF requirements:

| Subsystem Requirement| Description |
| --------------------- | ------------------------------------------------- |
| *RcfR-0001* | RCF shall generate channels with width $< 146.8$ kHz over the frequency range 0.7 to 2.0 GHz. |
| *RcfR-0002* | RCF shall generate channels with width $< 9.25$ kHz over a tunable band with bandwidth $\geq 34$ MHz between 0.7 and 2.0 GHz|
| *RcfR-0003* | RCF shall generate channels with width $< 1.42$ kHz over a tunable band with bandwidth $\geq 0.95$ MHz between 0.7 and 2.0 GHz|
| *RcfR-0004* | RCF shall generate channels with width $\geq 2.048$ MHz over the frequency range 0.7 to 2.0 GHz. |
| *RcfR-0005* | RCF shall generate channels which attenuate a signal at the center of an adjacent channel by $\geq 60$ dB. |
| *RcfR-0006* | Over a period of 100 hours, the center frequency of any RCF frequency channel shall not shift by $>10\%$ of the channel width. |
| *RcfR-0007* | RCF shall have sufficient time delay buffers to compensate for up to 50 \textmu s delay in the time-domain for all data products. |
| *RcfR-0008* | Where RCF is required to generate beams from multiple antenna elements, it must be capable of compensating for delays up to 125 \textmu s. |
| *RcfR-0009* | RCF shall ensure that, after applying a delay correction to a data stream to phase it to a particular sky position, the residual error across any frequency channel shall be $<1^\circ$. |
| *RcfR-0010* | RCF shall be capable of updating the delay applied to each antenna signal at least 2628 times per second. |
| *RcfR-0011* | RCF shall form 4 dual-polatization voltage streams, using the *TC* data products defined by *RcfR-0004*. |
