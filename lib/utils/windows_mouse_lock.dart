import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class WindowsMouseLock {
  /// Confines the cursor to the current foreground window's CLIENT area (excluding title bar).
  static void lockToWindow() {
    final hwnd = GetForegroundWindow();
    final rect = calloc<RECT>();
    final point = calloc<POINT>();
    
    try {
      // Get client area dimensions (0,0 to width,height)
      GetClientRect(hwnd, rect);
      
      // Convert top-left (0,0) to screen coordinates
      point.ref.x = 0;
      point.ref.y = 0;
      ClientToScreen(hwnd, point);
      
      // Calculate screen rect
      final width = rect.ref.right;
      final height = rect.ref.bottom;
      
      rect.ref.left = point.ref.x;
      rect.ref.top = point.ref.y;
      rect.ref.right = point.ref.x + width;
      rect.ref.bottom = point.ref.y + height;

      ClipCursor(rect);
    } finally {
      free(rect);
      free(point);
    }
  }

  /// Moves the cursor to the center of the current foreground window.
  static void moveCursorToCenter() {
    final hwnd = GetForegroundWindow();
    final rect = calloc<RECT>();
    try {
      GetClientRect(hwnd, rect);
      final width = rect.ref.right;
      final height = rect.ref.bottom;
      
      final point = calloc<POINT>();
      try {
        // Center in client coordinates
        point.ref.x = width ~/ 2;
        point.ref.y = height ~/ 2;
        
        // Convert to screen coordinates
        ClientToScreen(hwnd, point);
        
        SetCursorPos(point.ref.x, point.ref.y);

        // Re-apply clip to ensure it stays locked (fixes Alt key release issue)
        rect.ref.left = point.ref.x - (width ~/ 2);
        rect.ref.top = point.ref.y - (height ~/ 2);
        rect.ref.right = rect.ref.left + width;
        rect.ref.bottom = rect.ref.top + height;
        ClipCursor(rect);

      } finally {
        free(point);
      }
    } finally {
      free(rect);
    }
  }

  /// Releases the cursor confinement.
  static void unlock() {
    ClipCursor(nullptr);
  }
}
