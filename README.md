# SimpleLocalKVM Client

**SimpleLocalKVM** is a streamlined KVM (Keyboard, Video, Mouse) client with direct cable to cable connection.

## 🎯 Purpose
Do you often find yourself installing servers or troubleshooting computers where you need a monitor, keyboard, and mouse, but only have your laptop?

**SimpleLocalKVM** solves this by turning your **Laptop** into a KVM console.
-   **Video**: Uses an HDMI Capture Card (USB) to display the target computer's screen.
-   **Input**: Uses a Raspberry Pi Pico (HID) to send your laptop's Keyboard and Mouse input to the target computer.

Perfect for "side-by-side" maintenance without lugging around extra peripherals.

## 🚀 Features
-   **Low Latency Video**: Optimized for smooth desktop experience.
-   **HID Passthrough**: Full Keyboard and Mouse control.
-   **Audio Capture**: Hear the target server's audio through your laptop.
-   **Portable**: Single executable file (Windows), no installation required.
-   **Smart Detection**: Auto-detects Capture Cards, Audio Interfaces, and Serial Ports.

## 🛠️ Hardware Requirements
1.  **HDMI Capture Card** (USB 2.0/3.0)
2.  **Raspberry Pi Pico** (with CircuitPython HID Firmware)
3.  **Any USB to TTL Serial adapter** (CP2102, CH340, etc)
4.  **Windows Laptop** (Host).

## 🔌 Wiring Diagram
1. **Diagram Pin (Wiring)**
   Anda hanya membutuhkan 3 kabel jumper untuk menghubungkan USB-to-TTL Adapter ke Raspberry Pi Pico.

   **Koneksi:**
   - **USB-to-TTL (TX)** -> Hubungkan ke -> **Pico (GP1 / UART0 RX)**
   - **USB-to-TTL (GND)** -> Hubungkan ke -> **Pico (GND)**
   - **USB-to-TTL (RX)** -> (Opsional) -> **Pico (GP0 / UART0 TX)**
   - **USB-to-TTL (5V)** -> **JANGAN HUBUNGKAN** (Biarkan Pico menyala dari USB PC Remote agar aman).

## 📖 How to Use
1.  Flash CircuitPython Firmware (https://circuitpython.org/board/raspberry_pi_pico/).
2.  Copy Adafruit_CircuitPython_HID Library to /lib folder on Pico.
3.  Copy code.py to Pico.
4.  (Optional) Copy boot.py to Pico. (if you want to disable drive mode)
5.  Connect the **HDMI Capture Card** to your laptop and the target PC.
6.  Connect the **Pico/HID Device** to your laptop and the target PC.
7.  Run `SimpleLocalKVM_Portable.exe`.
8.  Select your **Video Source** (Capture Card).
9.  Select your **Serial Port** (Pico).
10. (Optional) Enable **Audio Capture**.
11. Click **CONNECT**.

## 🔜 Roadmap
-   [x] Windows Client (Complete)
-   [ ] **Android Client**: Use your tablet or phone as a KVM monitor (Coming Soon!)

## ❤️ Credits
Made with love from **FoxLust**.
Visit [foxlust.my.id](https://foxlust.my.id)
