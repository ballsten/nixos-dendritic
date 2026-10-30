_: {
  # A "Noise-suppressed mic" source: the default mic run through RNNoise in
  # a PipeWire filter-chain. Apps pick it like any other mic. Needs the
  # desktop feature for PipeWire.
  flake.modules.nixos.mic-noise-suppression =
    { pkgs, ... }:
    {
      services.pipewire.extraConfig.pipewire."90-mic-noise-suppression" = {
        "context.modules" = [
          {
            name = "libpipewire-module-filter-chain";
            args = {
              "node.description" = "Noise-suppressed mic";
              "media.name" = "Noise-suppressed mic";
              "filter.graph".nodes = [
                {
                  type = "ladspa";
                  name = "rnnoise";
                  plugin = "${pkgs.rnnoise-plugin.ladspa}/lib/ladspa/librnnoise_ladspa.so";
                  # Headset and laptop mics are mono or near enough, and
                  # mono halves the CPU use.
                  label = "noise_suppressor_mono";
                  control = {
                    # Frames RNNoise is less than 50% sure are voice are
                    # muted, after a 200 ms grace period so word endings
                    # aren't clipped (docs/features/mic-noise-suppression.md).
                    "VAD Threshold (%)" = 50.0;
                    "VAD Grace Period (ms)" = 200;
                    "Retroactive VAD Grace (ms)" = 0;
                  };
                }
              ];
              "capture.props" = {
                "node.name" = "capture.mic_noise_suppressed";
                # Only opens the real mic while something records from the
                # filter, so it costs nothing outside calls.
                "node.passive" = true;
                # RNNoise only works at 48 kHz.
                "audio.rate" = 48000;
              };
              "playback.props" = {
                "node.name" = "mic_noise_suppressed";
                "media.class" = "Audio/Source";
                "audio.rate" = 48000;
              };
            };
          }
        ];
      };
    };
}
