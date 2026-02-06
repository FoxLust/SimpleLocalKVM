# SimpleLocalKVM Client

**SimpleLocalKVM** is a streamlined KVM (Keyboard, Video, Mouse) client designed for IT professionals and server administrators.

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
1.  **HDMI Capture Card** (USB 2.0/3.0) - Connects Target GPU -> Laptop USB.
2.  **Raspberry Pi Pico** (with CH9329 HID firmware or similar) - Connects Laptop USB -> Target USB.
3.  **Windows Laptop** (Host).

## 📖 How to Use
1.  Connect the **HDMI Capture Card** to your laptop and the target PC.
2.  Connect the **Pico/HID Device** to your laptop and the target PC.
3.  Run `SimpleLocalKVM_Portable.exe`.
4.  Select your **Video Source** (Capture Card).
5.  Select your **Serial Port** (Pico).
6.  (Optional) Enable **Audio Capture**.
7.  Click **CONNECT**.

## 🔜 Roadmap
-   [x] Windows Client (Complete)
-   [ ] **Android Client**: Use your tablet or phone as a KVM monitor (Coming Soon!)
-   [ ] MacOS Support

## ❤️ Credits
Made with love from **FoxLust**.
Visit [foxlust.my.id](https://foxlust.my.id)
