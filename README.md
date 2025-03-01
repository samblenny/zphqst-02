<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: Copyright 2025 Sam Blenny -->

# zphqst-02

This is a companion repo for my 
[Zephyr Quest: ST7789 Display with Feather RP2350](https://adafruit-playground.com/u/SamBlenny/pages/zephyr-quest-st7789-display-with-feather-rp2350)
playground guide. The guide explains how to use an Adafruit 2" TFT IPS display
breakout with a Feather RP2350 dev board.


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
