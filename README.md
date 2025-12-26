# Night Shift CLI

A simple command-line tool to toggle macOS Night Shift immediately.

## Installation & Build

This tool uses the private `CoreBrightness` framework found on macOS. To build it, you need to compile the Objective-C source file.

```bash
clang -framework Foundation -o nightshift nightshift.m
```

## Usage

Once compiled, you can use the binary to turn Night Shift on or off.

### Enable Night Shift
```bash
./nightshift on
```

### Disable Night Shift
```bash
./nightshift off
```

## Disclaimer

This tool uses a private API (`CoreBrightness.framework`), which is not documented by Apple. It may stop working in future macOS updates.
