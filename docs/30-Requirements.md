# Requirements

## Frequency Resolutions and Spans

A number of requirements directly relating to frequency coverage and channel resolutions are present in DSA2000 science requirements.

These are:

 1. ScR-0004: Frequency coverage from 0.7 to 2.0 GHz
 1. ScR-0026 [High-z continuum]: HI velocity resolution of $<60$ km/s for galaxies $>-1000$ km/s and $z<1$
 1. ScR-0027 [Zoom A]: HI velocity resolution <2 km/s for galaxies >-500 km/s and distance $<100$ Mpc.
 1. ScR-0028 [Zoom B]: HI velocity resolution <0.3 km/s for galactic HI, covering HI emission between -100 km/s and +100 km/s.
 1. ScR-0029 [Tunability]: Zoom bands A and B should be tunable.
 1. ScR-0022 [Pulsar Timing]: Pulsar-phase coherent folding with $\geq 2048$ phase bins for pulsars with periods > 1 ms.

 > At present, some of these requirements also explicitly state how many frequency channels are expected to cover the target bands.
 > ScR-0026, ScR-0027, and ScR-0028 require 5600, 4096, and 2048 channels, respectively, in their target bands.
 > In this document these requirements are ignored (in the expectation they will ultimately be removed) for requirements ScR-0026 and ScR-0027 and instead the desired observing bands and velocity resolutions are used to determine channel counts.
 > For ScR-0028 the $\pm100$ km/s requirement is the result of recent discussion.


From these requirements, the following resolutions and bandwidths are inferred:

 1. ScR-0004: Total coverage 0.7 to 2.0 GHz
 1. ScR-0026 [High-z continuum]: Coverage from 0.71 to 1.425  GHz, at $<142$ kHz resolution at 0.71 GHz and $< 285$ kHz resolution at 1.425 GHz.
 1. ScR-0027 [Zoom A]: Coverage from 1.388 to 1.422 GHz, at $<9.25$ kHz (at 1.388  GHz).\footnote{The minimum frequency is computed by converting 100 Mpc to a redshift, using a Hubble constant of 70 $\frac{\mathrm{km/s}}{\mathrm{Mpc}}$.}
 1. ScR-0028 [Zoom B]: Coverage of 1419.93 -- 1420.88 MHz with a channel width $<1.42$ kHz.
 1. ScR-0029: Center frequency of Zoom A and Zoom B windows is arbitrarily tunable within the 0.7 -- 2.0 GHz band, with resolution and bandwidth set by ScR-0027 and ScR-0028.
 1. ScR-0022 [Pulsar Timing]: Coverage from 0.7 to 2.0 GHz at $\geq$ 2.048 MHz resolution.\footnote{This assumes a critically-sampled channelized data stream, with at least 2048 spectra produced every 1 ms.}

There is no science requirement on frequency resolution above 1.425 GHz. Here, the maximum channel bandwidth is likely to be limited by frequency smearing effects.
For an array with maximum baseline length of 15 km, and a phase center referenced to the center of the array, a signal received 1.5 degrees from boresight (the FWHM of the DSA2000 dish is expected to be approximately 3 degrees at 1.35 GHz) has a maximum delay relative to a boresight signal of
\begin{equation}
    \sin \left( 1.5^{\circ} \right) \times \frac{7.5 \mathrm{km}}{c} = 654 \mathrm{ns} .
\end{equation}

This implies that the frequency channel width, $\Delta f$ at 1.35 GHz should satisfy
\begin{equation}
    \Delta f \ll (654 \mathrm{ns})^{-1}  ,
\end{equation}
i.e.,
\begin{equation}
    \Delta f \ll 1529 \mathrm{kHz} .
\end{equation}

There is no explicit requirement on how much smearing is tolerable, but, noting that the most stringent ScR-0026 frequency resolution requirement demands a channel width of less than 142 kHz at 0.71 GHz, this width is taken as a minimum requirement over the entire band.

 > The memory footprint of RCF processing is strongly dependent on the frequency resolution of channels which may be generated -- narrow channel bandwidth requires more memory.
 > Downstream RCP processing is also strongly dependent on the number of frequency channels which need to be imaged -- more numerous, narrower channels require more processing.
 > These factors both mean that a relaxing of minimum channel bandwidth over some fraction of the 0.7 to 2.0 GHz observing band may potentially make RCF implementation easier, and reduce the size (and cost) of RCP.

The following table summarises the inferred bandwidth and resolution requirements which satisfy all science requirements:

\begin{center}
\begin{tabular}{cccc}
  \hline
  Data Product & Frequency Range (MHz) & Bandwidth (MHz) & $\Delta f$ (kHz) \\
  \hline \hline
  Full band & 700 -- 2000 & $\geq 1300$ & $< 142$ \\
  %High-z Continuum & 710 -- 1425 & 715 & $< 142$ \\
  Zoom A & Tunable & $\geq 34$ & $< 9.25$ \\
  Zoom B & Tunable & $\geq 0.95$ & $< 1.42$ \\
  Pulsar Timing & 700 -- 2000 & 1300 & $<2048$ \\
  \hline
\end{tabular}
\end{center}

<!--
\subsubsection{Doppler Tracking}

The maximum doppler correction due to the orbit of the Earth is approximately 30 km/s, which is a shift of 200 kHz at 2 GHz. This velocity also represents a differential shift of 0.1 kHz over 1 MHz of bandwidth.

Assuming that the DSA RCF implements a two-stage filterbank, the consequence of the shift at 2 GHz is that the edge 200 kHz (at the high-frequency end of the band) of each first-stage frequency channel is unusable.

The consequence of the differential shift is that, even it the first-stage filterbank channels are Doppler tracked, some residual frequency shift will persist over the width of these channels.
If the extent of this shift is unacceptable, it may be necessary to track some first-stage channels to multiple Doppler velocities, and then ...
-->

## Delay & Phase tracking

In order that DSA2000's imaging system is able to correlate and integrate signals from multiple antennas for 

### Coarse Delay

The maximum geometric delay between antennas in an array -- i.e., the maximum difference in arrival times of a common wavefront at two different antennas -- is given by:
\begin{equation}
    \tau = \frac{B_{\textrm{max}}}{c}  ,
\end{equation}

where $c$ is the speed of light, and $B_{\textrm{max}}$ is the maximum baseline length.
For the DSA, $B_{\textrm{max}} = 15$ km and \textbf{the maximum geometric delay is 50 usec}.

Assuming that digitization of signals from all antennas occurs in a central location, further inter-antenna delays are introduced by analog cabling (and, to a lesser extent, other instrumentation) between the antennas and digitizers.
Assuming that cable length differences are of length $\sim B_{\textrm{max}}$, and the speed of light in a cable is $\sim \frac{2}{3}c$, \textbf{instrumental inter-antenna delays for the DSA2000 will be $\sim$75 usec.}

Compensation of both geometric and instrumental delays is achieved in a radio telescope by using memory buffers to delay the earliest arriving data streams such that they may be coherently combined with the latest arriving.
The practical implementation of this scheme may utilize buffering in either, or both, of  RCF and RCP.
For the purposes of producing a viable RCF design, the following requirements are used:

 1. RCF shall have sufficient time delay buffers to compensate for DSA2000's maximum geometric delay, 50 usec
 1. Where RCF is required to generate beams from multiple antenna elements, it must be capable of compensating for both instrumental and geometric delays, totalling 125 usec.

Implicit in the first requirement is a statement that RCF need not use time-delay buffers to compensate for all instrumental delays before emitting data to RCP.
It is assumed that large - and mostly stable - instrumental delays corresponding to multiples of the channelized sample period may be absorbed into the RCP buffering system.

### Fine Delay

For any digital system which implements time-domain delay compensation using a simple sample buffer, the precision of this correction is limited by the system sample rate.
Errors of 1 sample in the delay applied to a data stream equate to residual phase errors over the Nyquist band being processed of up to $\pi$ radians.
In principle, this residual phase slope across the observing band may corrected in downstream processing. However, this requires that 
, frequency-channel-based processing them in a frequency-dependent manner.

Nevertheless, processing is simplified if RCF 



## Fringe Rate
Maximum fringe rate $f_{max}$ is given by:
\begin{equation}
    f_{max} = \Omega_{e} \frac{B}{\lambda}
\end{equation}

Where $\Omega_{e} = 7.27 \times 10^{-5}$ radians/second is the angular speed of the Earth, $B$ is the maximum baseline length, and $\lambda$ is the minimum observing wavelength.

For DSA2000, $B=15$ km, $\lambda=15$ cm, giving a \textbf{maximum fringe rate of 7.3 Hz}.

## Frequency Channel Response
