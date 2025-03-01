<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: Copyright 2025 Sam Blenny -->

# zphqst-02

**WORK IN PROGRESS**

Plan:

1. [x] 3d printed stand for breadboard and display
2. [x] CircuitPython demo code to test display wiring
3. [x] Devicetree overlay for Feather header to EYESPI MIPI pin mapping
4. [x] Devicetree overlay for MIPI ST7789V display shield with EYESPI pins
5. [x] Some kind of Zephyr demo to demonstrate using the display
6. [x] Fritzing diagram
7. [ ] Photos


## Build & Run the Zephyr Display Sample

This is the bash shell command I use to build Zephyr's "display" sample with
the EYESPI and 2" TFT IPS display shields from this repo. The paths assume
that you have set up a zephyr workspace in the manner that I describe in my
Playground guides.

```
west build -b feather_rp2350/rp2350a/m33  \
  --shield eyespi_mipi                    \
  --shield adafruit_2in_tft_ips_display   \
  ../zephyr/samples/drivers/display       \
  -- -DBOARD_ROOT=$(pwd)
```

For more examples, check out the [Makefile](Makefile).


## Getting OpenOCD for RP2350

Until RP2350 support makes it into the upstream OpenOCD and downstream distro
packages, flashing an RP2350 board with the Raspberry Pi Debug Probe requires
using the Raspberry Pi fork of OpenOCD.

You can git clone and build the Raspberry Pi openocd like this (check openocd
README file for more details):

```
$ sudo apt install make libtool pkg-config \
    autoconf automake texinfo libusb-1.0-0-dev libhidapi-dev
$ cd ~/code/zephyr-workspace
$ git clone https://github.com/raspberrypi/openocd.git
$ cd openocd
$ ./bootstrap
$ ./configure --prefix=$(pwd)/build
$ make
$ make install
```

Those commands will put your new openocd binary in:
```
~/code/zephyr-workspace/openocd/build/bin/openocd
```

To make sure that `west flash` uses the correct openocd binary, you will need
to set the `OPENOCD` cmake variable when you do `west build`. For example, you
could put a `set(OPENOCD ...)` in CMakeLists.txt or do something like:
```
(.venv) $ cd ~/code/zephyr-workspace/zphqst-01
(.venv) $ west build ... -- -DOPENOCD=../openocd/build/bin/openocd
```


## License & Copying

Files in this repo use a mix of **Apache-2.0** and/or **MIT** licensing. Check
SPDX header comments for details.
