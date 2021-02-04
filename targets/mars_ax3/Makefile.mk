# mars_ax3 targets

ifneq ($(PLATFORM),mars_ax3)
	$(error "Platform should be mars_ax3 when using this file!?")
endif

# Settings
DEFAULT_TARGET = base
TARGET ?= $(DEFAULT_TARGET)

PROG_PORT ?= /dev/ttyUSB0
COMM_PORT ?= /dev/ttyUSB1
BAUD ?= 115200

# Image
image-flash-$(PLATFORM): image-flash-py
	@true

# Gateware
gateware-load-$(PLATFORM):
	#openocd -f board/digilent_$(PLATFORM).cfg -c "init; pld load 0 $(TARGET_BUILD_DIR)/gateware/$(PLATFORM).bit; exit"
	#openocd -f board/digilent_arty.cfg -c "init; pld load 0 $(TARGET_BUILD_DIR)/gateware/$(PLATFORM).bit; exit"
	#openocd -f interface/ftdi/digilent-hs2.cfg -c "init; pld load 0 $(TARGET_BUILD_DIR)/gateware/$(PLATFORM).bit; exit"
	openocd -f ./nick.cfg -c "init; pld load 0 $(TARGET_BUILD_DIR)/gateware/$(PLATFORM).bit; exit"

gateware-flash-$(PLATFORM): gateware-flash-py
	@true

# Firmware
firmware-load-$(PLATFORM):
	flterm --port=$(COMM_PORT) --kernel=$(FIRMWARE_FILEBASE).bin --speed=$(BAUD)


firmware-flash-$(PLATFORM): firmwage-flash-py
	@true

firmware-connect-$(PLATFORM):
	flterm --port=$(COMM_PORT) --speed=$(BAUD)

# Bios
bios-flash-$(PLATFORM):
	@echo "Unsupported."
	@false

# Extra commands
help-$(PLATFORM):
	@true

reset-$(PLATFORM):
	@echo "Unsupported."
	@false
