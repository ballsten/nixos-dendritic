# 0044: Mic noise suppression with RNNoise in a PipeWire filter-chain

- **Status:** Accepted, 2026-10-30

## Context

On `tiki-rig` the headset mic sounds worse in Teams in Brave than in the
native Teams app on Windows (#133). Teams uses the headset, not the Kiyo
webcam's 16 kHz mic, and Windows runs no SteelSeries Sonar processing, so
both systems start from the same raw signal. The difference is in the
processing: the native app uses its own noise suppression, while in the
browser the audio goes through Chromium's WebRTC processing (echo
cancellation, noise suppression, automatic gain control) and then Teams
web's.

Linux can clean the mic before it reaches the browser. The options are
EasyEffects or a PipeWire filter-chain, and the noise-suppression model is
RNNoise or DeepFilterNet.

## Decision

A PipeWire filter-chain module running RNNoise's LADSPA plugin
(`rnnoise-plugin`), declared in a `mic-noise-suppression` feature that
every workstation gets. It publishes a separate **Noise-suppressed mic**
source rather than replacing the default one, and Teams' own noise
suppression is turned off when it's used.

The Kiyo webcam's ALSA card is switched off on `tiki-rig` so the mic can't
be picked by mistake.

## Consequences

- Fully declarative: no app, no service, no presets to persist.
- Apps choose it by name. Apps that follow the default mic still get the
  raw one, so nothing changes until it's picked.
- The filter is passive, so it only runs while something records from it.
- Tuning (VAD threshold, grace period) means a rebuild; there's no GUI.
- Only noise suppression: no EQ, compressor or gate.

## Alternatives considered

- **EasyEffects:** a GUI with RNNoise, EQ, compressor and gate, and
  Noctalia can switch its presets. It's another user service that
  processes audio all the time, and its presets would have to be declared
  or persisted. Worth revisiting if EQ or compression turn out to be
  needed.
- **DeepFilterNet** in the filter-chain: better quality than RNNoise, but
  noticeably more CPU, which matters on the Surface's battery.
- **Making the filtered source the default:** every app would get it
  automatically, but the filter-chain records from the default source, so
  it would need pinning to a specific mic per host.
- **Only switching off WebRTC's processing in Brave:** Chromium has no
  setting for it, and Teams web adds its own anyway.
