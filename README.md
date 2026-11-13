# heimdall-termux

Heimdall 2.2.2 patched to run in Termux on non-rooted Android, using termux-usb.

## Why

Heimdall lists USB devices through libusb enumeration. Stock Android
does not let normal apps read /dev/bus/usb, so enumeration returns
nothing and every action fails in Termux without root. This fork skips
enumeration and talks to the device through a file descriptor that
termux-usb opens with permission.

## Requirements

- [Termux](https://f-droid.org/packages/com.termux/) from F-Droid or the
  GitHub builds
- The [Termux:API](https://f-droid.org/packages/com.termux.api/) app from
  F-Droid, installed alongside the termux-api package
- An aarch64 device
- A USB-C OTG cable (or a USB-A OTG adapter plus cable)
- The Samsung device in download mode

## Install

Download the release files, verify the checksum, run the installer:

```sh
curl -LO https://github.com/varifocal/heimdall-termux/releases/download/v2.2.2-termux1/heimdall-termux-aarch64.tar.gz
curl -LO https://github.com/varifocal/heimdall-termux/releases/download/v2.2.2-termux1/SHA256SUMS
curl -LO https://github.com/varifocal/heimdall-termux/releases/download/v2.2.2-termux1/install.sh
sha256sum -c SHA256SUMS
bash install.sh
```

## Usage

Put the phone in download mode, connect the cable, then:

```sh
heimdall detect
heimdall print-pit
heimdall flash --RECOVERY recovery.img --no-reboot
```

If several devices are attached, the first one listed by termux-usb is
used. Set HD_DEV to choose another:

```sh
HD_DEV=/dev/bus/usb/001/003 heimdall detect
```

## How it works

termux-usb asks Android for permission and runs the wrapper with an open
file descriptor for the device. The wrapper stores that descriptor in
the USB_FD environment variable and runs the patched heimdall binary.
BridgeManager reads USB_FD and wraps the descriptor with
libusb_wrap_sys_device() instead of calling libusb_get_device_list(),
then keeps the usual descriptor parsing and interface claiming. libusb
is initialised with LIBUSB_OPTION_NO_DEVICE_DISCOVERY, so no bus scan
happens. The patch lives in
[heimdall/source/BridgeManager.cpp](heimdall/source/BridgeManager.cpp)
and [heimdall/source/BridgeManager.h](heimdall/source/BridgeManager.h).

## Tested

Detect and print-pit confirmed on Samsung SM-A127F (Exynos 850) from a
tablet running Termux. Flashing is not tested.

## Limitations

- Termux on aarch64 only.
- The binary links against Termux's libusb and libc++ dynamically.
- The first listed device is used unless HD_DEV is set.
- `--wait` does nothing useful with the wrapper; the descriptor comes
  from termux-usb, which does not watch for replugs.
- Large images such as super may be slow or unreliable.
- One session per call. Use `--no-reboot`, then `--resume` for the next
  call.

## Building from source

```sh
git clone https://github.com/varifocal/heimdall-termux.git
cd heimdall-termux
bash termux/build.sh
```

build.sh installs the build dependencies, configures cmake with
`-DDISABLE_FRONTEND=ON`, and runs make. The binary ends up in
`build/bin/heimdall`.

## Credits

- Heimdall by [Benjamin Dobell (Glass Echidna)](https://glassechidna.com.au/).
- Maintained fork by [Henrik Grimler](https://git.sr.ht/~grimler/Heimdall).
- [termux-usb and Termux:API](https://github.com/termux/termux-api) provide
  the USB access.
- Termux patch and wrapper by [varifocal](https://github.com/varifocal).

## License

MIT, same as upstream. See [LICENSE](LICENSE).

## Disclaimer

Flashing can brick a device. Use it at your own risk. Back up your PIT
before flashing, and never flash BOOTLOADER, EFS or KEYSTORAGE without a
verified backup.
