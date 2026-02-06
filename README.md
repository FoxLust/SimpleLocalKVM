# SimpleLocalKVM

**SimpleLocalKVM** adalah klien KVM (Keyboard, Video, Mouse) yang sederhana menggunakan koneksi kabel-ke-kabel langsung.

## 🎯 Tujuan
Apakah Anda sering harus menginstal server atau memperbaiki komputer di mana Anda memerlukan monitor, keyboard, dan mouse tambahan, tetapi hanya membawa laptop?

**SimpleLocalKVM** mengatasi masalah ini dengan mengubah **Laptop** Anda menjadi konsol KVM.
-   **Video**: Menggunakan HDMI Capture Card (USB) untuk menampilkan layar komputer target.
-   **Input**: Menggunakan Raspberry Pi Pico (HID) untuk mengirimkan input Keyboard dan Mouse laptop Anda ke komputer target.

## 🚀 Fitur
-   **Video Latensi Rendah**: Dioptimalkan untuk pengalaman desktop yang lancar.
-   **HID Passthrough**: Kontrol Keyboard dan Mouse penuh.
-   **Audio Capture**: Mendengarkan audio dari server target melalui laptop Anda.
-   **Portabel**: Satu file executable (Windows), tanpa perlu instalasi.
-   **Deteksi Cerdas**: Otomatis mendeteksi Capture Card, Audio Interface, dan Serial Port.

## 🛠️ Kebutuhan Perangkat Keras
1.  **HDMI Capture Card** (USB 2.0/3.0)
2.  **Raspberry Pi Pico** (dengan Firmware CircuitPython)
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

## ⚙️ Persiapan Raspberry Pi Pico
1.  **Flash Firmware CircuitPython**
    -   Unduh firmware terbaru dari [CircuitPython.org](https://circuitpython.org/board/raspberry_pi_pico/).
    -   Tahan tombol BOOTSEL pada Pico saat menghubungkannya ke PC.
    -   Salin file `.uf2` yang diunduh ke dalam drive `RPI-RP2`.

2.  **Instalasi Library HID**
    -   Unduh [Adafruit_CircuitPython_HID](https://github.com/adafruit/Adafruit_CircuitPython_HID).
    -   Salin folder `adafruit_hid` dari dalam zip ke folder `/lib` di drive `CIRCUITPY` Pico Anda.

3.  **Unggah Script Utama**
    -   Salin file `code.py` (tersedia di folder `RaspberryPiCo` pada repositori ini) ke root drive `CIRCUITPY`.

4.  **Konfigurasi Boot (Opsional)**
    -   Salin `boot.py` ke Pico jika Anda ingin menonaktifkan mode USB Drive (agar Pico hanya terdeteksi sebagai Keyboard/Mouse di PC target).
    -   *Catatan: Jika digunakan, Anda perlu menjumper GP14 ke GND saat boot untuk mengedit file kembali.*

### 📂 Struktur File di Pico
Pastikan isi drive `CIRCUITPY` Anda terlihat seperti ini:

```text
CIRCUITPY/
├── lib/
│   └── adafruit_hid/    <-- (Folder berisi keyboard.mpy, mouse.mpy, dll)
├── code.py              <-- (Script utama dari repo ini)
├── boot.py              <-- (Opsional)
└── boot_out.txt
```

## 📖 Cara Penggunaan
1.  Hubungkan **HDMI Capture Card** ke laptop Anda dan PC target.
2.  Hubungkan **USB to TTL Serial adapter** ke laptop Anda.
3.  Hubungkan **Kabel Pico** ke PC target.
4.  Jalankan `SimpleLocalKVM_Portable.exe`.
5.  Pilih **Sumber Video** (Capture Card).
6.  Pilih **Serial Port** (USB to TTL Serial adapter).
7.  (Opsional) Aktifkan **Audio Capture**.
8.  Klik **CONNECT**.

## 🔜 Rencana Pengembangan (Roadmap)
-   [x] Klien Windows (Selesai)
-   [ ] **Klien Android**: Gunakan tablet atau ponsel Anda sebagai monitor KVM (Segera Hadir!)

## ❤️ Kredit
Dibuat dengan cinta oleh **FoxLust**.
Kunjungi [foxlust.my.id](https://foxlust.my.id)
