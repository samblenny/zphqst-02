# SPDX-License-Identifier: Apache-2.0 OR MIT
# SPDX-FileCopyrightText: Copyright 2025 Sam Blenny

# CAUTION: Using OpenOCD with the RP2350 requires a recent version of openocd
# with RP2350 support. At the time I'm writing this, (Feb 9, 2025), you need to
# build the Raspberry Pi openocd fork from source. You will also need to be
# sure that the west OPENOCD cmake variable gets set correctly in a
# board.cmake, CMakeLists.txt, or command line argument.


# Uncomment the next line if you want extra debug info from cmake
#_CMAKE_ECHO=-DCMAKE_EXECUTE_PROCESS_COMMAND_ECHO=STDERR
_OPENOCD=-DOPENOCD=../openocd/build/bin/openocd

# Build Zephyr shell for Feather RP2350 with OpenOCD and Pi Debug Probe.
shell:
	west build -b feather_rp2350/rp2350a/m33         \
		--shield eyespi_mipi                         \
		--shield adafruit_2in_tft_ips_display        \
		../zephyr/samples/subsys/shell/shell_module/ \
		-- -DBOARD_ROOT=$$(pwd) ${_OPENOCD} ${_CMAKE_ECHO}

# Build Zephyr shell for display using character framebuffer
# This (cfb init from shell prompt) doesn't work because of an error:
# "Failed to set required pixel format: -134"
# When I turn on Debug logging, it says:
# "<err> display_st7789v: Pixel format change not implemented
cfb_shell:
	west build -b feather_rp2350/rp2350a/m33         \
		--shield eyespi_mipi                         \
		--shield adafruit_2in_tft_ips_display        \
		../zephyr/samples/subsys/display/cfb_shell   \
		-- -DBOARD_ROOT=$$(pwd) ${_OPENOCD} ${_CMAKE_ECHO}

# Build the "display" sample that draws a white background with red, green,
# blue and gray boxes in the corners. The gray box animates in a cycle of
# fading gray from black to white.
display:
	west build -b feather_rp2350/rp2350a/m33         \
		--shield eyespi_mipi                         \
		--shield adafruit_2in_tft_ips_display        \
		../zephyr/samples/drivers/display            \
		-- -DBOARD_ROOT=$$(pwd) ${_OPENOCD} ${_CMAKE_ECHO}

# Interactively modify config from previous build
menuconfig:
	west build -t menuconfig

# Flash previously built firmware
flash:
	west flash

# Connect to board's serial console using Pi Debug Probe UART interface
# This works for me on Debian 12 with one and only 1 Pi Debug Probe plugged
# in. You may need to use a different device path for other system setups.
uart:
	@screen -fn /dev/serial/by-id/*Pi_Debug* 115200

# If west build chokes on the dts file, it will give an uninformative numeric
# error code instead of dtc's stderr/stdout. But, it does leave behind a
# build/zephyr/zephyr.dts file with the preprocessed and merged output of all
# the various dts files. In zephyr/cmake/modules/dts.cmake, on about line 404,
# there is an `execute_process(COMMAND ${DTC} ...)` command. If you edit that
# command to include the ECHO_OUTPUT_VARIABLE and ECHO_ERROR_VARIABLE args, it
# will echo dtc's error message explaining what went wrong. You can also do
# `west build ... -- -DCMAKE_EXECUTE_PROCESS_COMMAND_ECHO=STDERR` to see the
# command cmake uses to invoke dtc. (that's where the invocation below came
# from)
dtc:
	@dtc -O dts -o - -b 0 -E unit_address_vs_reg \
		-Wno-unique_unit_address                 \
		-Wunique_unit_address_if_enabled         \
		build/zephyr/zephyr.dts

# This may help diagnose errors during gen_edt.py script (after dtc)
gen_edt:
	python3 ../zephyr/scripts/dts/gen_edt.py         \
		--dts build/zephyr/zephyr.dts.pre            \
		--dtc-flags ''                               \
		--bindings-dirs ../zephyr/dts/bindings       \
		--dts-out build/zephyr/zephyr.dts.new        \
		--edt-pickle-out build/zephyr/edt.pickle.new \
		--vendor-prefixes ../zephyr/dts/bindings/vendor-prefixes.txt

# This is for use by .github/workflows/buildbundle.yml GitHub Actions workflow
bundle:
	@mkdir -p build-cp
	python3 bundle_builder.py

# On Debian, you can mount CIRCUITPY with:
#    pmount `readlink -f /dev/disk/by-label/CIRCUITPY` CIRCUITPY
# and unmount with:
#    pumount CIRCUITPY

# Name of top level folder in project bundle zip file should match repo name
REV_DIR = $(shell basename `git rev-parse --show-toplevel`)

# Sync current code and libraries to CIRCUITPY drive on Debian.
sync: bundle
	rsync -rcvO 'build-cp/${REV_DIR}/CircuitPython 9.x/' /media/CIRCUITPY
	sync

# Debian serial monitor: 9999 line scrollback, no flow control, 115200 baud
usbtty:
	screen -h 9999 -fn /dev/serial/by-id/usb-Adafruit_* 115200

clean:
	rm -rf build build-cp

.PHONY: shell menuconfig flash uart dtc gen_edt bundle sync usbtty clean
