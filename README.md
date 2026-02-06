# Klien SimpleLocalKVM

**SimpleLocalKVM** adalah klien KVM (Keyboard, Video, Mouse) yang sederhana menggunakan koneksi kabel-ke-kabel langsung.

## 🎯 Tujuan
Apakah Anda sering harus menginstal server atau memperbaiki komputer di mana Anda memerlukan monitor, keyboard, dan mouse tambahan, tetapi hanya membawa laptop?

**SimpleLocalKVM** mengatasi masalah ini dengan mengubah **Laptop** Anda menjadi konsol KVM.
-   **Video**: Menggunakan HDMI Capture Card (USB) untuk menampilkan layar komputer target.
-   **Input**: Menggunakan Raspberry Pi Pico (HID) untuk mengirimkan input Keyboard dan Mouse laptop Anda ke komputer target.

Sangat cocok untuk pemeliharaan "bersebelahan" tanpa perlu membawa perangkat tambahan yang berat.

## 🚀 Fitur
-   **Video Latensi Rendah**: Dioptimalkan untuk pengalaman desktop yang lancar.
-   **HID Passthrough**: Kontrol Keyboard dan Mouse penuh.
-   **Audio Capture**: Mendengarkan audio dari server target melalui laptop Anda.
-   **Portabel**: Satu file executable (Windows), tanpa perlu instalasi.
-   **Deteksi Cerdas**: Otomatis mendeteksi Capture Card, Audio Interface, dan Serial Port.

## 🛠️ Kebutuhan Perangkat Keras
1.  **HDMI Capture Card** (USB 2.0/3.0)
2.  **Raspberry Pi Pico** (dengan Firmware CircuitPython HID)
3.  **Adapter USB to TTL Serial apa saja** (CP2102, CH340, dll)
4.  **Laptop Windows** (Host).

## 🔌 Diagram Kabel (Wiring)
1. **Diagram Pin**
   Anda hanya membutuhkan 3 kabel jumper untuk menghubungkan USB-to-TTL Adapter ke Raspberry Pi Pico.

   **Koneksi:**
   - **USB-to-TTL (TX)** -> Hubungkan ke -> **Pico (GP1 / UART0 RX)**
   - **USB-to-TTL (GND)** -> Hubungkan ke -> **Pico (GND)**
   - **USB-to-TTL (RX)** -> (Opsional) -> **Pico (GP0 / UART0 TX)**
   - **USB-to-TTL (5V)** -> **JANGAN HUBUNGKAN** (Biarkan Pico menyala dari USB PC Remote agar aman).

## 📖 Cara Penggunaan
1.  Flash Firmware CircuitPython (https://circuitpython.org/board/raspberry_pi_pico/).
2.  Salin Library `Adafruit_CircuitPython_HID` ke folder `/lib` di Pico.
3.  Salin `code.py` ke Pico.
4.  (Opsional) Salin `boot.py` ke Pico. (jika ingin menonaktifkan mode drive USB)
5.  Hubungkan **HDMI Capture Card** ke laptop Anda dan PC target.
6.  Hubungkan **USB to TTL Serial adapter** ke laptop Anda.
7.  Hubungkan **Kabel Pico** ke PC target.
8.  Jalankan `SimpleLocalKVM_Portable.exe`.
9.  Pilih **Sumber Video** (Capture Card).
10. Pilih **Serial Port** (USB to TTL Serial adapter).
11. (Opsional) Aktifkan **Audio Capture**.
12. Klik **CONNECT**.

## 🔜 Rencana Pengembangan (Roadmap)
-   [x] Klien Windows (Selesai)
-   [ ] **Klien Android**: Gunakan tablet atau ponsel Anda sebagai monitor KVM (Segera Hadir!)

## ❤️ Kredit
Dibuat dengan cinta oleh **FoxLust**.
Kunjungi [foxlust.my.id](https://foxlust.my.id)
