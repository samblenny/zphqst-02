# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright 2025 Sam Blenny

from board import SPI, D5, D6, D9
from displayio import Bitmap, Group, Palette, TileGrid, release_displays
from fourwire import FourWire
from terminalio import FONT
from time import sleep

from adafruit_display_text.label import Label
from adafruit_st7789 import ST7789


ZOOM = 3

# Initialize 320x240 ST7789 IPS display with scaling for better readability
release_displays()
bus = FourWire(SPI(), chip_select=D5, command=D6, reset=D9)
display = ST7789(bus, width=320, height=240, rotation=270)
grp = Group(scale=ZOOM)
display.root_group = grp

# Set background color
bg = Bitmap((320 // ZOOM), (240 // ZOOM), 1)
pal = Palette(1)
pal[0] = 0x330033
bg.fill(0)
grp.append(TileGrid(bg, pixel_shader=pal))

# Add some text
lbl = Label(font=FONT, color=0xFF5555,
    text="CircuitPython\nWiring Test:\n Feather RP2350 \n  + ST7789",
    anchor_point=(0, 0),
    anchored_position=(8, 10))
grp.append(lbl)

# Spin so the supervisor doesn't change the display
while True:
    sleep(1)
