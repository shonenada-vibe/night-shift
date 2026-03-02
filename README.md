# Night Shift CLI

A simple command-line tool to toggle macOS Night Shift immediately.

## Installation & Build

This tool uses the private `CoreBrightness` framework found on macOS. To build it, you need to compile the Objective-C source file.

```bash
clang -framework Foundation -framework Cocoa -o nightshift nightshift.m
```

## Usage

### Menu Bar App (default)

Run without arguments to launch the menu bar app:

```bash
./nightshift
```

A 🌙 (enabled) or ☀️ (disabled) icon appears in the menu bar. Click it to toggle Night Shift or quit.

### CLI Mode

Pass `on` or `off` to toggle directly from the terminal:

```bash
./nightshift on
./nightshift off
```

## Disclaimer

This tool uses a private API (`CoreBrightness.framework`), which is not documented by Apple. It may stop working in future macOS updates.
