import 'dart:typed_data';

class ProtocolEncoder {
  static const int headerKeyboard = 0x01;
  static const int headerMouse = 0x02;

  /// Encodes a keyboard event packet.
  /// [isDown] true for key press, false for release.
  /// [hidKeycode] The HID usage ID of the key.
  static Uint8List encodeKeyboardPacket(bool isDown, int hidKeycode) {
    final builder = BytesBuilder();
    builder.addByte(headerKeyboard);
    builder.addByte(isDown ? 1 : 0);
    // Ensure keycode fits in a byte. 
    // Note: Standard HID codes for basic keys are < 255.
    builder.addByte(hidKeycode & 0xFF); 
    return builder.toBytes();
  }

  /// Encodes a mouse event packet.
  /// [buttons] Bitmask of buttons (1=Left, 2=Right, 4=Middle).
  /// [dx] Delta X (-127 to 127).
  /// [dy] Delta Y (-127 to 127).
  /// [scroll] Scroll delta (-127 to 127).
  static Uint8List encodeMousePacket(int buttons, int dx, int dy, int scroll) {
    final builder = BytesBuilder();
    builder.addByte(headerMouse);
    builder.addByte(buttons & 0xFF);
    
    // Helper to clamp and cast to signed byte representation if needed,
    // but here we send raw bytes. The python code expects signed bytes.
    // Python: if val > 127: val - 256. 
    // Meaning we should send 0-255 where 255 maps to -1.
    // So we need to map Dart int to 8-bit two's complement.
    builder.addByte(_toByte(dx));
    builder.addByte(_toByte(dy));
    builder.addByte(_toByte(scroll));
    
    return builder.toBytes();
  }

  static int _toByte(int value) {
    // Clamp to valid range if necessary, though ideally input is already delta
    int clamped = value.clamp(-127, 127);
    return clamped & 0xFF;
  }
}
