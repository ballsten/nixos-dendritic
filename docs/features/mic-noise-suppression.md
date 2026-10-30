# mic-noise-suppression

A **Noise-suppressed mic** source: the default mic run through
[RNNoise](https://github.com/werman/noise-suppression-for-voice) in a
PipeWire filter-chain.

| | |
|---|---|
| Module | `modules/features/mic-noise-suppression.nix` |
| Aspects | `nixos.mic-noise-suppression` |
| Hosts | All, through `workstation` |
| Inputs | None |
| Persists | Nothing |
| Secrets | None |

It adds to the PipeWire set up by the [desktop](desktop.md) feature. See
[0044](../decisions/0044-mic-noise-suppression.md) for why it's a
filter-chain and not EasyEffects.

## Using it

Pick **Noise-suppressed mic** as the microphone in the app, for example
Teams' Settings → Devices. The filter records from whatever the default
mic is (the headset on `tiki-rig`, the built-in mics on `surface-laptop`)
and outputs one mono channel.

Turn off the app's own noise suppression while using it (in Teams:
Settings → Devices → Noise suppression → Off). Otherwise the voice is
processed twice, which makes it sound thin.

The filter only opens the real mic while something records from it
(`node.passive`), so it uses no CPU outside calls. RNNoise adds about
10 ms of latency.

## Tuning

RNNoise rates each 10 ms frame by how likely it is to be voice. Frames
under the **VAD threshold** (50%) are muted, and the **grace period**
(200 ms) keeps the mic open after speech so word endings aren't clipped.
If quiet speech is cut off, lower the threshold; if background noise gets
through between words, raise it. Both are in the module's `control` set.

## Checking it

`wpctl status` lists it under Sources. During a call, `pw-top` shows
`capture.mic_noise_suppressed` running and which app records from
`mic_noise_suppressed`.

To compare raw and filtered audio:

```sh
pw-record --target mic_noise_suppressed filtered.wav
pw-record raw.wav
```
