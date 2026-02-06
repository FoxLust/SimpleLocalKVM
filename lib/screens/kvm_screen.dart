import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../services/serial_service.dart';
import '../services/protocol_encoder.dart';
import '../utils/key_mapping.dart';
import '../utils/windows_mouse_lock.dart';
import 'dart:io';

import 'package:window_manager/window_manager.dart';
import '../widgets/custom_title_bar.dart';

class KvmScreen extends StatefulWidget {
  final String deviceName;
  final int width;
  final int height;
  final int fps; // Add audioDeviceName optional
  final String? audioDeviceName;

  const KvmScreen({
    super.key,
    required this.deviceName,
    required this.width,
    required this.height,
    required this.fps,
    this.audioDeviceName,
  });

  @override
  State<KvmScreen> createState() => _KvmScreenState();
}

class _KvmScreenState extends State<KvmScreen> {
  late final Player _player;
  late final VideoController _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _setAspectRatio();
    
    // Auto-request focus and lock
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _toggleCapture(true);
    });
  }

  Future<void> _setAspectRatio() async {
    double ratio = widget.width / widget.height;
    await windowManager.setAspectRatio(ratio);
  }

  Future<void> _initializePlayer() async {
    print("Initializing Player...");
    _player = Player();
    _controller = VideoController(_player);
    
    _player.stream.error.listen((event) {
      print("PLAYER ERROR: $event");
    });
    _player.stream.log.listen((event) {
      // Filter out some spammy mjpeg warnings if needed
      if (!event.text.contains("No JPEG data found")) {
         print("PLAYER LOG: ${event.text}"); 
      }
    });

    // Name is already sanitized by DeviceSelectionScreen
    final deviceName = widget.deviceName;
    final audioDevice = widget.audioDeviceName;
    
    String inputUrl;
    if (audioDevice != null && audioDevice.isNotEmpty) {
      // Audio + Video Capture
      inputUrl = 'av://dshow:video=$deviceName:audio=$audioDevice';
    } else {
      // Video Only
      inputUrl = 'av://dshow:video=$deviceName';
    }
    
    // Increased buffer size (rtbufsize) to 200M to help with MJPEG drops
    final demuxerOptions = 'video_size=${widget.width}x${widget.height},framerate=${widget.fps},pixel_format=mjpeg,rtbufsize=200M';
    
    print("Opening input: $inputUrl");
    print("Options: $demuxerOptions");

    try {
      await _player.open(
        Media(
          inputUrl,
          extras: {
            'demuxer-lavf-o': demuxerOptions,
            'profile': 'low-latency',
            'untimed': 'yes',
          },
        ),
        play: true,
      );
      print("Player open command sent.");
    } catch (e) {
      print("Error opening player: $e");
    }
  }

  @override
  void dispose() {
    // Reset aspect ratio constraint when leaving specific KVM screen
    windowManager.setAspectRatio(0);
    
    if (Platform.isWindows) {
      WindowsMouseLock.unlock();
    }
    _player.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _isCapturing = false;
  bool _hostCapsLock = false;
  final FocusNode _focusNode = FocusNode();
  int _mouseButtons = 0;
  final Set<int> _pressedKeys = {}; // Track pressed HID codes
  bool _ignoreNextMouse = false; // Flag to ignore synthetic moves

  void _handleKey(RawKeyEvent event) {
    // Update Caps Lock state on every key event for accuracy
    final isCaps = HardwareKeyboard.instance.lockModesEnabled.contains(KeyboardLockMode.capsLock);
    if (_hostCapsLock != isCaps && mounted) {
      setState(() {
        _hostCapsLock = isCaps;
      });
    }

    if (event is RawKeyDownEvent) {
      // GLOBAL HOTKEY: Ctrl + Alt + Shift + Q
      if (event.logicalKey == LogicalKeyboardKey.keyQ &&
          event.isControlPressed &&
          event.isAltPressed &&
          event.isShiftPressed) {
            print("Hotkey pressed! Disconnecting...");
            _disconnectAndExit();
            return;
      }
      // GLOBAL HOTKEY: Ctrl + Alt + Shift + E -> Unlock Mouse/Keyboard
      if (event.logicalKey == LogicalKeyboardKey.keyE &&
          event.isControlPressed &&
          event.isAltPressed &&
          event.isShiftPressed) {
            print("Hotkey E pressed! Toggling capture...");
            _toggleCapture(!_isCapturing);
            return;
      }
    }

    if (!_isCapturing) return;
    
    final isDown = event is RawKeyDownEvent;
    
    // Debug logging to help identify missing keys
    // print("Key Event: Logical=${event.logicalKey.keyLabel}, Physical=${event.physicalKey.debugName}");

    int? hidCode = KeyMapping.getHidCode(event.logicalKey);
    // Fallback to physical key if logical mapping fails (e.g. Caps Lock)
    hidCode ??= KeyMapping.getHidCodePhysical(event.physicalKey);

    final serialService = Provider.of<SerialService>(context, listen: false);

    if (hidCode != null) {
      if (isDown) {
        _pressedKeys.add(hidCode);
      } else {
        _pressedKeys.remove(hidCode);
      }
      final packet = ProtocolEncoder.encodeKeyboardPacket(isDown, hidCode);
      serialService.sendData(packet);
    }
  }

  void _toggleCapture(bool enable) {
    if (!enable) {
      // Capture state to release LATER
      final keysToRelease = Set<int>.from(_pressedKeys);
      final buttonsToRelease = _mouseButtons;

      // Clear current state IMMEDIATELY so UI/Logic thinks we are done
      _pressedKeys.clear();
      _mouseButtons = 0;
      
      if (Platform.isWindows) {
        WindowsMouseLock.unlock();
      }

      final count = keysToRelease.length;
      if (count > 0 || buttonsToRelease != 0) {
         _showSnackBar("Unlocked! Releasing $count keys in 1 second...");
      } else {
         _showSnackBar("Unlocked!");
      }

      // 1 Second Delay before actually sending the release packets
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return; // distinct check if widget is still around
        _releaseInputsSnapshot(keysToRelease, buttonsToRelease);
      });
    } else {
      _showSnackBar("Input Captured");
    }

    setState(() {
      _isCapturing = enable;
      if (_isCapturing) {
        FocusScope.of(context).requestFocus(_focusNode);
        if (Platform.isWindows) {
          // Initial lock and center
          WindowsMouseLock.lockToWindow();
          WindowsMouseLock.moveCursorToCenter();
          _ignoreNextMouse = true; // reset flag
        }
      }
    });
  }

  /// Sends release packets for a specific set of keys/buttons
  Future<void> _releaseInputsSnapshot(Set<int> keys, int buttons) async {
     final serialService = Provider.of<SerialService>(context, listen: false);
     
     if (keys.isNotEmpty) {
       print("Delayed Release: Releasing ${keys.length} tracked keys...");
     }

     // Sequential Release: 500ms delay per key
     for (final hidCode in keys) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 500));
        
        print("Releasing key HID: $hidCode");
        final packet = ProtocolEncoder.encodeKeyboardPacket(false, hidCode);
        serialService.sendData(packet);
     }

     // 2. Release mouse buttons
     if (buttons != 0) {
       if (!mounted) return;
       // Also give mouse buttons a slot in the sequence
       await Future.delayed(const Duration(milliseconds: 500));
       
       print("Delayed Release: Releasing mouse buttons...");
       final packet = ProtocolEncoder.encodeMousePacket(0, 0, 0, 0); // 0 buttons = release all
       serialService.sendData(packet);
     }
  }

  // Kept for other immediate release needs (like disconnect)
  void _releaseAllInputs() {
     final keysCopy = Set<int>.from(_pressedKeys);
     final buttonsCopy = _mouseButtons;
     _pressedKeys.clear();
     _mouseButtons = 0;
     _releaseInputsSnapshot(keysCopy, buttonsCopy);
  }

  Future<void> _disconnectAndExit() async {
     print("Hotkey Quit pressed! Starting delayed release sequence...");
     
     // 1. Snapshot State
     final keysToRelease = Set<int>.from(_pressedKeys);
     final buttonsToRelease = _mouseButtons;

     // 2. Clear Local State & Unlock immediately
     setState(() {
       _isCapturing = false;
       _pressedKeys.clear();
       _mouseButtons = 0;
     });
     
     if (Platform.isWindows) {
       WindowsMouseLock.unlock();
     }

     if (keysToRelease.isNotEmpty || buttonsToRelease != 0) {
        _showSnackBar("Quitting... Cleanup keys in 1s...");
     } else {
        _showSnackBar("Quitting...");
     }

     // 3. Wait Initial Delay (1s)
     if (keysToRelease.isNotEmpty || buttonsToRelease != 0) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        
        // 4. Perform Sequential Release
        await _releaseInputsSnapshot(keysToRelease, buttonsToRelease);
     }

     if (!mounted) return;

     // 5. Finally Disconnect
     final serialService = Provider.of<SerialService>(context, listen: false);
     serialService.disconnect();
     Navigator.of(context).pop();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serialService = Provider.of<SerialService>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          // CENTER VIDEO (Full Screen)
          Positioned.fill(
             child: Center(
               child: Video(controller: _controller),
             ),
          ),
          
          // INPUT OVERLAY
          Positioned.fill(
             // Use FocusScope to trap keys
             child: Focus(
                focusNode: _focusNode,
                autofocus: true,
                onKey: (node, event) {
                   _handleKey(event);
                   return KeyEventResult.handled;
                },
                child: Listener(
                  onPointerDown: (event) {
                    if (!_isCapturing) {
                       _toggleCapture(true);
                    }
                    if (!_isCapturing) return;
                    _updateMouseButtons(event.buttons);
                    _sendMouseUpdate(serialService, 0, 0, 0);
                  },
                  onPointerUp: (event) {
                     if (!_isCapturing) return;
                    _updateMouseButtons(event.buttons);
                    _sendMouseUpdate(serialService, 0, 0, 0);
                  },
                  onPointerMove: (event) => _handleMouseMove(event, serialService),
                  onPointerHover: (event) => _handleMouseMove(event, serialService),
                  onPointerSignal: (event) {
                     if (!_isCapturing) return;
                    if (event is PointerScrollEvent) {
                      int scroll = -(event.scrollDelta.dy / 20).round().clamp(-127, 127);
                      if (scroll != 0) {
                        _sendMouseUpdate(serialService, 0, 0, scroll);
                      }
                    }
                  },
                  child: MouseRegion(
                    cursor: _isCapturing ? SystemMouseCursors.none : SystemMouseCursors.basic,
                    child: Container(color: Colors.transparent),
                  ),
                ),
             ),
          ),

          // OVERLAY TITLE BAR (Top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: !_isCapturing 
              ? CustomTitleBar(
                  title: "SimpleLocalKVM - ${widget.deviceName}",
                  isTransparent: true, // Semi-transparent overlay
                  onBackPressed: _disconnectAndExit,
                )
              : const SizedBox.shrink(), 
          ),
          
          // UI CONTROLS (Caps Lock Indicator + Lock Icon)
          Positioned(
            top: 40,
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Caps Lock Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hostCapsLock ? Colors.blueAccent : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.keyboard_capslock, 
                        color: _hostCapsLock ? Colors.blueAccent : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "CAPS",
                        style: TextStyle(
                          color: _hostCapsLock ? Colors.blueAccent : Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                // Toggle Capture Button
                FloatingActionButton(
                  mini: true,
                  child: Icon(_isCapturing ? Icons.lock_open : Icons.lock),
                  onPressed: () {
                    _toggleCapture(!_isCapturing);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _handleMouseMove(PointerEvent event, SerialService service) {
    if (!_isCapturing) return;
    
    // Ignore synthetic move caused by re-centering
    if (_ignoreNextMouse) {
      _ignoreNextMouse = false;
      return;
    }

    int dx = event.localDelta.dx.toInt();
    int dy = event.localDelta.dy.toInt();

    // If no movement, ignore
    if (dx == 0 && dy == 0) return;

    _sendMouseUpdate(service, dx.clamp(-127, 127), dy.clamp(-127, 127), 0);

    // Re-center mouse to allow infinite scrolling
    if (Platform.isWindows) {
       WindowsMouseLock.moveCursorToCenter();
       _ignoreNextMouse = true;
    }
  }

  void _updateMouseButtons(int flutterButtons) {
    _mouseButtons = flutterButtons;
  }

  void _sendMouseUpdate(SerialService service, int dx, int dy, int scroll) {
    final packet = ProtocolEncoder.encodeMousePacket(_mouseButtons, dx, dy, scroll);
    service.sendData(packet);
  }
}
