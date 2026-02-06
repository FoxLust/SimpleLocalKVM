import storage
import board
import digitalio
import usb_cdc

maintenance_pin = digitalio.DigitalInOut(board.GP14)
maintenance_pin.direction = digitalio.Direction.INPUT
maintenance_pin.pull = digitalio.Pull.UP

if maintenance_pin.value:
    storage.disable_usb_drive()
    usb_cdc.disable()