import board
import busio
import usb_hid
from adafruit_hid.keyboard import Keyboard
from adafruit_hid.mouse import Mouse

uart = busio.UART(board.GP0, board.GP1, baudrate=115200, timeout=0.01)

kbd = Keyboard(usb_hid.devices)
mouse = Mouse(usb_hid.devices)
last_mouse_btn = 0

def to_signed_byte(val):
    if val > 127:
        return val - 256
    return val

while True:
    if uart.in_waiting > 0:
        header = uart.read(1)

        if not header:
            continue

        head_val = header[0]

        if head_val == 0x01:
            data = uart.read(2)
            if data and len(data) == 2:
                status = data[0]
                keycode = data[1]

                try:
                    if status == 1:
                        kbd.press(keycode)
                    else:
                        kbd.release(keycode)
                except Exception:
                    pass

        elif head_val == 0x02:
            data = uart.read(4)
            if data and len(data) == 4:
                btn_mask = data[0]
                dx = to_signed_byte(data[1])
                dy = to_signed_byte(data[2])
                scroll = to_signed_byte(data[3])

                try:
                    mouse.move(x=dx, y=dy, wheel=scroll)
                except Exception:
                    pass

                if (btn_mask & 1) and not (last_mouse_btn & 1):
                    mouse.press(Mouse.LEFT_BUTTON)
                elif not (btn_mask & 1) and (last_mouse_btn & 1):
                    mouse.release(Mouse.LEFT_BUTTON)

                if (btn_mask & 2) and not (last_mouse_btn & 2):
                    mouse.press(Mouse.RIGHT_BUTTON)
                elif not (btn_mask & 2) and (last_mouse_btn & 2):
                    mouse.release(Mouse.RIGHT_BUTTON)

                if (btn_mask & 4) and not (last_mouse_btn & 4):
                    mouse.press(Mouse.MIDDLE_BUTTON)
                elif not (btn_mask & 4) and (last_mouse_btn & 4):
                    mouse.release(Mouse.MIDDLE_BUTTON)

                last_mouse_btn = btn_mask