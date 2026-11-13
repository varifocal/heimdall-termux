# heimdall-termux

Heimdall 2.2.2, patched to run in Termux on non-rooted Android. Instead of
scanning USB buses, it uses termux-usb to reach your device.

<img width="800" height="500" alt="download" src="https://github.com/user-attachments/assets/4ebe509e-1e18-4a09-8bf3-25e652b6ab5a" />


This repository is a fork of
[Benjamin-Dobell/Heimdall](https://github.com/Benjamin-Dobell/Heimdall),
stacked on top of
[Henrik Grimler's Termux packaging](https://git.sr.ht/~grimler/Heimdall).

## Why this fork exists

Heimdall discovers devices by enumerating the USB bus with libusb. Stock
Android does not let regular apps read `/dev/bus/usb`, so inside Termux the
enumeration comes up empty and every command fails. That is not something
you can configure your way out of; the access is simply not there without
root.

The patch changes one thing: how Heimdall gets to the device. termux-usb
asks Android for permission and hands over an open file descriptor, and the
patched code passes that descriptor to libusb with
`libusb_wrap_sys_device()` instead of scanning buses. Everything you type
is exactly the same as upstream Heimdall.

## Requirements

- [Termux](https://f-droid.org/packages/com.termux/) from F-Droid or the
  GitHub builds
- The [Termux:API](https://f-droid.org/packages/com.termux.api/) app from
  F-Droid, plus the `termux-api` package inside Termux
- An aarch64 device
- A USB-C OTG cable, or a USB-A adapter and cable
- A Samsung device in download mode

## Install

Download the release files, verify the checksum, and run the installer:

```sh
curl -LO https://github.com/varifocal/heimdall-termux/releases/download/v2.2.2-termux1/heimdall-termux-aarch64.tar.gz
curl -LO https://github.com/varifocal/heimdall-termux/releases/download/v2.2.2-termux1/SHA256SUMS
curl -LO https://github.com/varifocal/heimdall-termux/releases/download/v2.2.2-termux1/install.sh
sha256sum -c SHA256SUMS
bash install.sh
```

The installer pulls in the dependencies, unpacks the tarball, and installs
`heimdall` into `$PREFIX/bin`.

## Usage

Put the phone in download mode, plug in the cable, and use Heimdall the
same way you would on a desktop:

```sh
heimdall detect
heimdall print-pit
heimdall flash --RECOVERY recovery.img --no-reboot
```

If several devices are attached, the wrapper picks the first one termux-usb
reports. Set `HD_DEV` to choose a different one:

```sh
HD_DEV=/dev/bus/usb/001/003 heimdall detect
```

## How it works

termux-usb asks Android for permission, then starts the wrapper with an
open file descriptor for the device. The wrapper puts that descriptor in
the `USB_FD` environment variable and runs the patched binary. Inside
`BridgeManager`, the descriptor is wrapped with `libusb_wrap_sys_device()`,
libusb is initialized with `LIBUSB_OPTION_NO_DEVICE_DISCOVERY`, and the
usual interface claiming stays as it is in upstream.

The whole patch lives in
[heimdall/source/BridgeManager.cpp](heimdall/source/BridgeManager.cpp) and
[heimdall/source/BridgeManager.h](heimdall/source/BridgeManager.h); every
other file is stock Heimdall. The full diff against upstream is attached to
the release as `heimdall-termux.patch`.

## Tested

`heimdall detect` and `heimdall print-pit` both work on a Samsung SM-A127F
(Exynos 850), driven from a tablet running Termux. Flashing has not been
tested, so treat it as unverified.

## Limitations

- Termux on aarch64 only. The binary links against Termux's libusb and
  libc++.
- Without `HD_DEV`, the first device termux-usb lists is used.
- `--wait` will not do much here, because the descriptor comes from
  termux-usb rather than a live device watch.
- Large images such as `super` can be slow, and might not be reliable.
- One session per call: use `--no-reboot`, then `--resume` for the next
  one.

## Building from source

```sh
git clone https://github.com/varifocal/heimdall-termux.git
cd heimdall-termux
bash termux/build.sh
```

`termux/build.sh` installs the toolchain, configures CMake with
`-DDISABLE_FRONTEND=ON`, and runs make. You will find the binary at
`build/bin/heimdall`.

## Credits

- Heimdall was written by [Benjamin Dobell (Glass Echidna)](https://glassechidna.com.au/)
  and lives at [Benjamin-Dobell/Heimdall](https://github.com/Benjamin-Dobell/Heimdall).
- [Henrik Grimler's fork](https://git.sr.ht/~grimler/Heimdall) provides the
  Termux packaging this builds on.
- [termux-usb and Termux:API](https://github.com/termux/termux-api) make the
  USB access possible.
- The Termux patch and wrapper are by [varifocal](https://github.com/varifocal).

## License

MIT, same as upstream. See [LICENSE](LICENSE).

## Disclaimer

Flashing firmware can brick a device. Back up your PIT before you flash,
never touch BOOTLOADER, EFS, or KEYSTORAGE without a verified backup, and
use this software at your own risk.
