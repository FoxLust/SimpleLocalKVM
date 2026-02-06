import 'package:flutter/services.dart';

class KeyMapping {
  // Mapping based on generic HID Usage Tables
  // https://usb.org/sites/default/files/hut1_2.pdf
  static final Map<LogicalKeyboardKey, int> _flutterToHid = {
    LogicalKeyboardKey.keyA: 0x04,
    LogicalKeyboardKey.keyB: 0x05,
    LogicalKeyboardKey.keyC: 0x06,
    LogicalKeyboardKey.keyD: 0x07,
    LogicalKeyboardKey.keyE: 0x08,
    LogicalKeyboardKey.keyF: 0x09,
    LogicalKeyboardKey.keyG: 0x0A,
    LogicalKeyboardKey.keyH: 0x0B,
    LogicalKeyboardKey.keyI: 0x0C,
    LogicalKeyboardKey.keyJ: 0x0D,
    LogicalKeyboardKey.keyK: 0x0E,
    LogicalKeyboardKey.keyL: 0x0F,
    LogicalKeyboardKey.keyM: 0x10,
    LogicalKeyboardKey.keyN: 0x11,
    LogicalKeyboardKey.keyO: 0x12,
    LogicalKeyboardKey.keyP: 0x13,
    LogicalKeyboardKey.keyQ: 0x14,
    LogicalKeyboardKey.keyR: 0x15,
    LogicalKeyboardKey.keyS: 0x16,
    LogicalKeyboardKey.keyT: 0x17,
    LogicalKeyboardKey.keyU: 0x18,
    LogicalKeyboardKey.keyV: 0x19,
    LogicalKeyboardKey.keyW: 0x1A,
    LogicalKeyboardKey.keyX: 0x1B,
    LogicalKeyboardKey.keyY: 0x1C,
    LogicalKeyboardKey.keyZ: 0x1D,
    
    LogicalKeyboardKey.digit1: 0x1E,
    LogicalKeyboardKey.digit2: 0x1F,
    LogicalKeyboardKey.digit3: 0x20,
    LogicalKeyboardKey.digit4: 0x21,
    LogicalKeyboardKey.digit5: 0x22,
    LogicalKeyboardKey.digit6: 0x23,
    LogicalKeyboardKey.digit7: 0x24,
    LogicalKeyboardKey.digit8: 0x25,
    LogicalKeyboardKey.digit9: 0x26,
    LogicalKeyboardKey.digit0: 0x27,
    
    LogicalKeyboardKey.enter: 0x28,
    LogicalKeyboardKey.escape: 0x29,
    LogicalKeyboardKey.backspace: 0x2A,
    LogicalKeyboardKey.tab: 0x2B,
    LogicalKeyboardKey.space: 0x2C,
    
    LogicalKeyboardKey.minus: 0x2D,
    LogicalKeyboardKey.equal: 0x2E,
    LogicalKeyboardKey.bracketLeft: 0x2F,
    LogicalKeyboardKey.bracketRight: 0x30,
    LogicalKeyboardKey.backslash: 0x31,
    LogicalKeyboardKey.semicolon: 0x33,
    LogicalKeyboardKey.quote: 0x34,
    LogicalKeyboardKey.backquote: 0x35,
    LogicalKeyboardKey.comma: 0x36,
    LogicalKeyboardKey.period: 0x37,
    LogicalKeyboardKey.slash: 0x38,
    
    LogicalKeyboardKey.capsLock: 0x39,
    LogicalKeyboardKey.f1: 0x3A,
    LogicalKeyboardKey.f2: 0x3B,
    LogicalKeyboardKey.f3: 0x3C,
    LogicalKeyboardKey.f4: 0x3D,
    LogicalKeyboardKey.f5: 0x3E,
    LogicalKeyboardKey.f6: 0x3F,
    LogicalKeyboardKey.f7: 0x40,
    LogicalKeyboardKey.f8: 0x41,
    LogicalKeyboardKey.f9: 0x42,
    LogicalKeyboardKey.f10: 0x43,
    LogicalKeyboardKey.f11: 0x44,
    LogicalKeyboardKey.f12: 0x45,
    
    LogicalKeyboardKey.printScreen: 0x46,
    LogicalKeyboardKey.scrollLock: 0x47,
    LogicalKeyboardKey.pause: 0x48,
    LogicalKeyboardKey.insert: 0x49,
    LogicalKeyboardKey.home: 0x4A,
    LogicalKeyboardKey.pageUp: 0x4B,
    LogicalKeyboardKey.delete: 0x4C,
    LogicalKeyboardKey.end: 0x4D,
    LogicalKeyboardKey.pageDown: 0x4E,
    LogicalKeyboardKey.arrowRight: 0x4F,
    LogicalKeyboardKey.arrowLeft: 0x50,
    LogicalKeyboardKey.arrowDown: 0x51,
    LogicalKeyboardKey.arrowUp: 0x52,
    
    LogicalKeyboardKey.controlLeft: 0xE0,
    LogicalKeyboardKey.shiftLeft: 0xE1,
    LogicalKeyboardKey.altLeft: 0xE2,
    LogicalKeyboardKey.metaLeft: 0xE3, // GUI/Windows key
    LogicalKeyboardKey.controlRight: 0xE4,
    LogicalKeyboardKey.shiftRight: 0xE5,
    LogicalKeyboardKey.altRight: 0xE6,
    LogicalKeyboardKey.metaRight: 0xE7,
  };

  static int? getHidCode(LogicalKeyboardKey key) {
    return _flutterToHid[key];
  }

  static final Map<PhysicalKeyboardKey, int> _physicalToHid = {
    PhysicalKeyboardKey.capsLock: 0x39,
  };

  static int? getHidCodePhysical(PhysicalKeyboardKey key) {
    return _physicalToHid[key];
  }

  /// Returns all known HID codes for force-release cycles
  static Iterable<int> get allHidCodes => _flutterToHid.values;
}
