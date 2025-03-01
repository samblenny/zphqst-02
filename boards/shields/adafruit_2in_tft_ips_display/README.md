<!-- SPDX-FileCopyrightText: Copyright 2025 Sam Blenny -->
<!-- SPDX-License-Identifier: Apache-2.0 -->

# 2in TFT IPS Display

These are some notes on cross-referencing the Zephyr st7789v driver's required
Devicetree properties against the ST7789V datasheet.


## Transcription of CircuitPython Init Code from Logic Analyzer

| SPI  | CMD / Data | Delay | Description |
| ---- | ---------- | ----- | ----------- |
| 0x01 | SWRESET    | 150ms | software reset |
| 0x11 | SLPOUT     | 500ms | sleep out |
| 0x3A | COLMOD     |       | interface pixel format |
| 0x55 | (data)     |  10ms | 65K of RGB data (0b101) at 16bit/pixel (0b101) |
| 0x36 | MADCTL     |       | memory data access control |
| 0x08 | (data)     |  10ms | MY: top to bot, MX: L to R, MV: normal, ML: top to bot, RGB: BGR, MH: L to R |
| 0x21 | INVON      |  10ms | display inversion |
| 0x13 | NORON      |  10ms | partial off (normal) |
| 0x36 | MADCTL     |       | memory data access control |
| 0xC0 | (data)     |  10ms | MY: bot to top, MX: R to L, MV: normal, ML: top to bot, RGB: RGB, MH: L to R |
| 0x29 | DISPON     | 500ms | display on |


## Calculating PVGAMCTRL and NVGAMCTRL Parameters

The required properties for positive (pvgam-param) and negative (nvgam-param)
gamma calibration correspond to the datasheet's PVGAMCTRL and NVGAMCTRL MIPI
commands. Each of those takes an array of 14 parameter data bytes.

Unfortunately, the datasheet doesn't list default values for the 14 parameter
bytes. Instead, it gives a table of 18 gamma levels and a chart showing how the
18 values get packed as bitfields into 14 bytes. To calculate the array of
bytes to use with the Devicetree properties, I wrote two short programs to pack
the bitfields.

This Python code calculates the parameter byte array for PVGAMCTRL:

```
vp0 = 0
vp1 = 0
vp2 = 0x2
vp4 = 0x7
vp6 = 0xb
vp13 = 0xa
vp20 = 0x31
vp27 = 0x4
vp36 = 0x5
vp43 = 0x40
vp50 = 0x9
vp57 = 0x12
vp59 = 0x12
vp61 = 0x12
vp62 = 0x17
vp63 = 0xd
jp0 = 0x1
jp1 = 0x2
params = [
    (vp63 << 4) | vp0, vp1, vp2, vp4, vp6, (jp0 << 4) | vp13, vp20,
    (vp36 << 4) | vp27, vp43, (jp1 << 4) | vp50, vp57, vp59, vp61, vp62,
]
print("PVGAMCTRL params = [" + " ".join(['%02x' % p for p in params]) + "]")
#
# PVGAMCTRL params = [d0 00 02 07 0b 1a 31 54 40 29 12 12 12 17]
```

This Python code calculates the parameter byte array for NVGAMCTRL:

```
vn0 = 0x0
vn1 = 0x0
vn2 = 0x2
vn4 = 0x7
vn6 = 0x5
vn13 = 0x5
vn20 = 0x2d
vn27 = 0x4
vn36 = 0x4
vn43 = 0x44
vn50 = 0xc
vn57 = 0x18
vn59 = 0x16
vn61 = 0x1c
vn62 = 0x1d
vn63 = 0xd
jn0 = 0x2
jn1 = 0x1
params = [
    (vn63 << 4) | vn0, vn1, vn2, vn4, vn6, (jn0 << 4) | vn13, vn20,
    (vn36 << 4) | vn27, vn43, (jn1 << 4) | vn50, vn57, vn59, vn61, vn62,
]
print("NVGAMCTRL params = [" + " ".join(['%02x' % p for p in params]) + "]")
#
# NVGAMCTRL params = [d0 00 02 07 05 25 2d 44 44 1c 18 16 1c 1d]
```


## Table of Datasheet Defaults

Compared to the CircuitPython ST7789 driver, Zephyr's
[sitronix,st7789v](https://docs.zephyrproject.org/latest/build/dts/api/bindings/display/sitronix%2Cst7789v.html)
driver takes a different approach. The Zephyr driver requires many display
register values to be specified as Devicetree parameters, even if you don't
actually need to change the display's defaults. The driver hardcodes a sequence
of
[delays and MIPI commands](https://github.com/zephyrproject-rtos/zephyr/blob/v4.0.0/drivers/display/display_st7789v.c#L321-L339),
but the data parameter values come from Devicetree properties.

Many of the required Devicetree properties are not set by the CircuitPython
driver, so I had to look up default values in the
[ST7798V datasheet](https://newhavendisplay.com/content/datasheets/ST7789V.pdf).

To keep things organized and assist with cross-referencing, I created a table
of Devicetree properties, C struct field names, header file #define constants,
MIPI command hex values, and default values from the datasheet. The struct
fields and defined constants come from
[`display_st7789v.c`](https://github.com/zephyrproject-rtos/zephyr/blob/v4.1.0-rc3/drivers/display/display_st7789v.c)
and
[`display_st7789v.h`](https://github.com/zephyrproject-rtos/zephyr/blob/v4.1.0-rc3/drivers/display/display_st7789v.h)
in the Zephyr GitHub repository.

| Devicetree    | Struct          | Define                  | Hex  | Datasheet Default                         |
| ------------- | --------------- | ----------------------- | ---- | ----------------------------------------- |
| vcom          | .vcom           | ST7789V\_CMD\_VCOMS     | 0xbb | 0x20                                      |
| gctrl         | .gctrl          | ST7789V\_CMD\_GCTRL     | 0xb7 | 0x35                                      |
| mdac          | .mdac           | ST7789V\_CMD\_MADCTL    | 0x36 | use CircuitPython 0x0C                    |
| gamma         | .gamma          | ST7789V\_CMD\_GAMSET    | 0x26 | 0x01 (gamma 2.2)                          |
| colmod        | .colmod         | ST7789V\_CMD\_COLMOD    | 0x3a | use CircuitPython 0x55                    |
| lcm           | .lcm            | ST7789V\_CMD\_LCMCTRL   | 0xc0 | 0x2C                                      |
| porch-param   | .porch\_param   | ST7789V\_CMD\_PORCTRL   | 0xb2 | 0C 0C 00 33 33                            |
| cmd2en-param  | .cmd2en\_param  | ST7789V\_CMD\_CMD2EN    | 0xdf | 5A 69 02 00                               |
| pwctrl1-param | .pwctrl1\_param | ST7789V\_CMD\_PWCTRL1   | 0xd0 | A4 81                                     |
| pvgam-param   | .pvgam\_param   | ST7789V\_CMD\_PVGAMCTRL | 0xe0 | d0 00 02 07 0b 1a 31 54 40 29 12 12 12 17 |
| nvgam-param   | .nvgam\_param   | ST7789V\_CMD\_NVGAMCTRL | 0xe1 | d0 00 02 07 05 25 2d 44 44 1c 18 16 1c 1d |
| ram-param     | .ram\_param     | ST7789V\_CMD\_RAMCTRL   | 0xb0 | 00 f0                                     |
| rgb-param     | .rgb\_param     | ST7789V\_CMD\_RGBCTRL   | 0xb1 | 40 02 14                                  |
