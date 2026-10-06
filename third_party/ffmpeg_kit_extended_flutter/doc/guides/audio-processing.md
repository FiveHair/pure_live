# Audio Processing Guide

This guide covers common audio manipulation tasks using FFmpeg Kit Extended.

## Table of Contents

- [Audio Extraction](#audio-extraction)
- [Format Conversion](#format-conversion)
- [Audio Compression](#audio-compression)
- [Volume Adjustment](#volume-adjustment)
- [Audio Mixing](#audio-mixing)
- [Trimming Audio](#trimming-audio)
- [Audio Effects](#audio-effects)

## Audio Extraction

Extract audio from a video file without re-encoding:

```dart
// Original audio format (e.g., AAC from MP4)
FFmpegKit.execute('-i input.mp4 -vn -acodec copy output.aac');

// Convert to MP3 during extraction
FFmpegKit.execute('-i input.mp4 -vn -ar 44100 -ac 2 -b:a 192k output.mp3');
```

## Format Conversion

Convert between different audio formats:

```dart
// WAV to MP3
FFmpegKit.execute('-i input.wav -codec:a libmp3lame -qscale:a 2 output.mp3');

// M4A to WAV
FFmpegKit.execute('-i input.m4a output.wav');

// OGG to MP3
FFmpegKit.execute('-i input.ogg -c:a libmp3lame output.mp3');
```

## Audio Compression

Reduce audio file size by lowering the bitrate:

```dart
// Compress MP3 to 128kbps
FFmpegKit.execute('-i input.mp3 -ab 128k output.mp3');

// Variable Bitrate (VBR) compression
FFmpegKit.execute('-i input.wav -codec:a libmp3lame -q:a 4 output.mp3');
```

## Volume Adjustment

Change the volume of an audio file:

```dart
// Double the volume
FFmpegKit.execute('-i input.mp3 -filter:a "volume=2.0" output.mp3');

// Reduce volume by half
FFmpegKit.execute('-i input.mp3 -filter:a "volume=0.5" output.mp3');

// Increase volume by dB
FFmpegKit.execute('-i input.mp3 -filter:a "volume=5dB" output.mp3');
```

## Audio Mixing

Mix two audio files together:

```dart
// Simple mix
FFmpegKit.execute('-i input1.mp3 -i input2.mp3 -filter_complex amix=inputs=2:duration=first output.mp3');

// Mix with volume control
FFmpegKit.execute(
  '-i music.mp3 -i voice.mp3 '
  '-filter_complex "[0:a]volume=0.5[a1];[1:a]volume=2.0[a2];[a1][a2]amix=inputs=2:duration=longest" '
  'mixed.mp3'
);
```

## Trimming Audio

Cut a specific portion of an audio file:

```dart
// Extract first 30 seconds
FFmpegKit.execute('-i input.mp3 -t 30 -c copy output.mp3');

// Extract from 1 minute to 2 minutes
FFmpegKit.execute('-i input.mp3 -ss 00:01:00 -to 00:02:00 -c copy output.mp3');
```

## Audio Effects

### Fade In / Fade Out

```dart
// 5-second fade in and 5-second fade out
// Assuming 30-second audio
FFmpegKit.execute('-i input.mp3 -filter:a "afade=t=in:ss=0:d=5,afade=t=out:st=25:d=5" output.mp3');
```

### Change Playback Speed

```dart
// 1.5x speed
FFmpegKit.execute('-i input.mp3 -filter:a "atempo=1.5" output.mp3');

// 0.5x speed (slow)
FFmpegKit.execute('-i input.mp3 -filter:a "atempo=0.5" output.mp3');
```

### Reverse Audio

```dart
FFmpegKit.execute('-i input.mp3 -filter_complex areverse output.mp3');
```

## Best Practices

1. **Use `-acodec copy`**: When just trimming or changing containers, use `copy` to avoid quality loss and speed up the process.
2. **Normalize Audio**: For consistent volume, consider using the `loudnorm` filter for professional applications.
3. **Monitor Sample Rates**: Converting between different sample rates (e.g., 44.1kHz to 48kHz) can sometimes introduce artifacts; be intentional about `-ar` settings.
