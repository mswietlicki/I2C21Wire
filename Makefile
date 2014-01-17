# Name: Makefile
# Author: <insert your name here>
# Copyright: <insert your copyright message here>
# License: <insert your license reference here>

# This is a prototype Makefile. Modify it according to your needs.
# You should at least check the settings for
# DEVICE ....... The AVR device you compile for
# CLOCK ........ Target AVR clock rate in Hertz
# OBJECTS ...... The object files created from your source files. This list is
#                usually the same as the list of source files with suffix ".o".
# PROGRAMMER ... Options to avrdude which define the hardware you use for
#                uploading to the AVR and the interface where this hardware
#                is connected.
# FUSES ........ Parameters for avrdude to flash the fuses appropriately.

#############################
# Begin configuration section
#
DEVICE     = attiny85
CLOCK      = 8000000
ONEWIRE_USE_MACROS = 0
ONEWIRE_PORTIN = PINB
ONEWIRE_PORT = PORTB
ONEWIRE_IO_CTL = DDRB
ONEWIRE_PIN = 1
#
# End configuration section
#############################

PROGRAMMER = -c usbasp -P usb
OBJECTS    = main.o usiTwiSlave.o OneWire/lib1wire.a
FUSES      = -U lfuse:w:0xe2:m -U hfuse:w:0xdd:m -U efuse:w:0xff:m

# Tune the lines below only if you know what you are doing:

AVRDUDE = avrdude $(PROGRAMMER) -p $(DEVICE)
COMPILE = avr-gcc -std=c99 -g -Wall -Os \
    -IOneWire \
	-DF_CPU=$(CLOCK) \
	-mmcu=$(DEVICE) \
    -DONEWIRE_CHECK_CRC=1 \
    -DONEWIRE_USE_MACROS=$(ONEWIRE_USE_MACROS) \
	-DONEWIRE_PORTIN=$(ONEWIRE_PORTIN) \
	-DONEWIRE_PORT=$(ONEWIRE_PORT) \
	-DONEWIRE_IO_CTL=$(ONEWIRE_IO_CTL) \
	-DONEWIRE_PIN=$(ONEWIRE_PIN)

# symbolic targets:
all:	main.hex

.c.o:
	$(COMPILE) -std=c99 -c $< -o $@

.S.o:
	$(COMPILE) -x assembler-with-cpp -c $< -o $@
# "-x assembler-with-cpp" should not be necessary since this is the default
# file type for the .S (with capital S) extension. However, upper case
# characters are not always preserved on Windows. To ensure WinAVR
# compatibility define the file type manually.

.c.s:
	$(COMPILE) -S $< -o $@

OneWire/lib1wire.a:
	make -C OneWire ONEWIRE_USE_MACROS=$(ONEWIRE_USE_MACROS) \
        ONEWIRE_PORTIN=$(ONEWIRE_PORTIN)\
        ONEWIRE_PORT=$(ONEWIRE_PORT)\
        ONEWIRE_IO_CTL=$(ONEWIRE_IO_CTL)\
        ONEWIRE_PIN=$(ONEWIRE_PIN)\
        CLOCK=$(CLOCK)\
        DEVICE=$(DEVICE)

flash:	all
	$(AVRDUDE) -U flash:w:main.hex:i

fuse:
	$(AVRDUDE) $(FUSES)

# Xcode uses the Makefile targets "", "clean" and "install"
install: flash fuse

# if you use a bootloader, change the command below appropriately:
load: all
	bootloadHID main.hex

clean:
	make -C OneWire clean
	rm -f main.hex main.elf main.bin $(OBJECTS)

# file targets:
main.elf: $(OBJECTS)
	$(COMPILE) -o main.elf $(OBJECTS)

main.hex: main.elf
	rm -f main.hex
	avr-objcopy -j .text -j .data -O ihex main.elf main.hex
	avr-objcopy -j .text -j .data -O binary main.elf main.bin
	ls -l main.bin
# If you have an EEPROM section, you must also create a hex file for the
# EEPROM and add it to the "flash" target.

# Targets for code debugging and analysis:
disasm:	main.elf
	avr-objdump -d main.elf

cpp:
	$(COMPILE) -E main.c
