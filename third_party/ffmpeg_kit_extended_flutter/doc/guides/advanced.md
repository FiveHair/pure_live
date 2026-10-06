# Advanced Usage Guide

This guide covers advanced integration scenarios and power-user features of FFmpeg Kit Extended.

## Table of Contents

- [FFmpeg Pipes](#ffmpeg-pipes)
- [Subtitles and Fonts](#subtitles-and-fonts)
- [Environment Variables](#environment-variables)
- [Signal Handling](#signal-handling)
- [Direct Handle Access](#direct-handle-access)

## FFmpeg Pipes

Pipes allow you to feed data into FFmpeg or receive output without using physical files on disk. This is useful for streaming or processing in-memory data.

### Registering a Pipe

```dart
String? pipePath = FFmpegKitConfig.registerNewFFmpegPipe();

if (pipePath != null) {
  // Use 'pipePath' in your FFmpeg command as an input or output
  FFmpegKit.execute('-i $pipePath -vcodec copy output.mp4');
  
  // Later, close it
  FFmpegKitConfig.closeFFmpegPipe(pipePath);
}
```

## Subtitles and Fonts

When using filters like `drawtext` or `subtitles`, FFmpeg needs to know where your font files are located.

### Setting Font Directory

```dart
FFmpegKitConfig.setFontDirectory('/path/to/my/fonts', mapping: 'MyFontName');
```

### Multiple Font Directories

```dart
FFmpegKitConfig.setFontDirectoryList(
  ['/assets/fonts', '/system/fonts'],
  {'CustomFont': 'Roboto-Regular.ttf'}
);
```

## Environment Variables

Some FFmpeg plugins or encoders rely on specific environment variables (e.g., `FONTCONFIG_FILE` or path variables).

```dart
FFmpegKitConfig.setEnvironmentVariable('MY_VAR', 'value');
```

## Signal Handling

You can control how the underlying FFmpeg process handles system signals.

```dart
// Ignore the SIGINT signal (Ctrl+C equivalent)
FFmpegKitConfig.ignoreSignal(Signal.sigint);
```

## Direct Handle Access

For expert users who want to interact with the native FFmpeg Kit C++ layer directly via FFI, you can retrieve the raw pointer from any session.

```dart
final session = FFmpegKit.execute(command);
Pointer<Void> rawHandle = session.handle;

// Now you can pass this handle to your own custom native functions
```

## Best Practices for Advanced Usage

1. **Clean Up Pipes**: Always call `closeFFmpegPipe` when you are done to prevent resource leaks and hung processes.
2. **Path Encoding**: FFmpeg internally uses UTF-8. On Windows, ensure your paths are handled correctly if they contain non-ASCII characters.
3. **Threading**: Remember that `execute` blocks the current thread. Even though it's on a worker thread in the native layer, the Dart side will block until completion. Use `executeAsync` for non-blocking UI behavior.
4. **Memory Management**: When accessing raw pointers, you are responsible for ensuring the session object remains in scope (not garbage collected) while the native code is using the handle.
