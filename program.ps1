﻿Remove-Item .\main.o, .\usiTwiSlave.o, .\main.elf, .\main.hex, .\main.bin -ErrorAction SilentlyContinue

avr-gcc -Os -DF_CPU=8000000UL -mmcu=attiny85 -c main.c usiTwiSlave.c
avr-gcc -mmcu=attiny85 -o main.elf main.o usiTwiSlave.o
avr-objcopy -O ihex -R .eeprom main.elf main.hex
avr-objcopy -I ihex main.hex -O binary main.bin

avrdude -p t85 -c usbasp -P usb -U lfuse:w:0xe2:m -U hfuse:w:0xdd:m -U efuse:w:0xff:m -U flash:w:main.hex

Remove-Item .\main.o, .\usiTwiSlave.o, .\main.elf, .\main.hex, .\main.bin -ErrorAction SilentlyContinue