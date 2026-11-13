Heimdall 2.2.2 for Termux on aarch64 Android. Skips USB enumeration,
wraps the termux-usb fd with libusb_wrap_sys_device(); no root needed.

Tested: detect and print-pit on Samsung SM-A127F (Exynos 850) from a
tablet running Termux. Flashing is not tested.

Requires Termux, Termux:API app, aarch64, USB-C/OTG cable, download mode.

Full diff against upstream attached as heimdall-termux.patch; see the
README limitations before flashing.
