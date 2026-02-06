import 'dart:io';
import 'package:camera/camera.dart' as camera_plugin;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:win32audio/win32audio.dart';
import '../services/serial_service.dart';
import 'kvm_screen.dart';

import '../widgets/custom_title_bar.dart';

class DeviceSelectionScreen extends StatefulWidget {
  const DeviceSelectionScreen({super.key});

  @override
  State<DeviceSelectionScreen> createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  List<camera_plugin.CameraDescription> _cameras = [];
  camera_plugin.CameraDescription? _selectedCamera;
  String? _selectedSerialPort;
  bool _isLoading = false;

  // Audio Settings
  bool _enableAudio = false;
  List<AudioDevice> _audioDevices = [];
  AudioDevice? _selectedAudioDevice;

  // HDMI Standard Formats
  final List<VmResolution> _resolutions = [
    VmResolution(1920, 1080, "1080p"),
    VmResolution(1280, 720, "720p"),
    VmResolution(640, 480, "480p"),
  ];
  late VmResolution _selectedResolution;

  final List<int> _framerates = [60, 30, 24];
  int _selectedFps = 60;

  @override
  void initState() {
    super.initState();
    // Default 720p 30fps as requested
    _selectedResolution = _resolutions[1]; 
    _selectedFps = 30;
    _loadDevices();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  // ... (loadDevices is same, but let's just keep code concise, I won't replace loadDevices unless I need to hook into it, which I might to set default audio name)
  
  // Try to auto-select audio device based on video device name
  void _autoSelectAudioDevice() {
    if (_selectedCamera == null || _audioDevices.isEmpty) return;
    
    // Only auto-select if nothing is currently selected
    if (_selectedAudioDevice == null) {
      final cleanName = _selectedCamera!.name.split('<').first.trim();
      
      try {
        // Look for "Digital Audio Interface" or similar matching the camera name
        final match = _audioDevices.firstWhere(
           (device) => device.name.contains(cleanName) || device.name.contains("Digital Audio Interface"),
        );
        setState(() => _selectedAudioDevice = match);
      } catch (e) {
        // No match found, select first valid if available
        if (_audioDevices.isNotEmpty) {
           setState(() => _selectedAudioDevice = _audioDevices.first);
        }
      }
    }
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    
    // Load Audio Devices (Windows only)
    if (Platform.isWindows) {
      try {
        print("Loading audio devices...");
        final devices = await Audio.enumDevices(AudioDeviceType.input);
        setState(() {
          _audioDevices = devices ?? [];
        });
        print("Found ${_audioDevices.length} audio input devices.");
        for (var d in _audioDevices) {
           print(" - Audio: ${d.name} (${d.id})");
        }
      } catch (e) {
        print("Error loading audio devices: $e");
      }
    }

    try {
      print("Loading available cameras...");
      _cameras = await camera_plugin.availableCameras();
      
      print("Found ${_cameras.length} cameras:");
      for (var cam in _cameras) {
        print(" - Name: ${cam.name}");
      }

      if (_cameras.isNotEmpty) {
        // Default to first, but prefer "USB" or "Capture" device if available
        if (_selectedCamera == null || !_cameras.any((c) => c.name == _selectedCamera?.name)) {
          try {
            _selectedCamera = _cameras.firstWhere(
              (c) => c.name.contains("USB") || c.name.contains("Capture"),
            );
          } catch (e) {
            _selectedCamera = _cameras.first;
          }
        }
      } else {
        _selectedCamera = null;
      }
      
      _autoSelectAudioDevice();

    } catch (e) {
      print("Error loading cameras: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final serialService = Provider.of<SerialService>(context);
    final serialPorts = serialService.getAvailablePorts();

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // CUSTOM TITLE BAR
              const CustomTitleBar(title: "SimpleLocalKVM - Device Selection"),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                 IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: _loadDevices,
                                    tooltip: "Refresh Devices",
                                )
                              ],
                          ),

               
                 // SERIAL PORT
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Serial Port (Pico)"),
                  value: _selectedSerialPort,
                  items: serialPorts.map((port) {
                    return DropdownMenuItem(value: port, child: Text(port));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSerialPort = val),
                  onTap: () => setState(() {}),
                ),
                const SizedBox(height: 16),

                // VIDEO DEVICE
                DropdownButtonFormField<camera_plugin.CameraDescription>(
                  decoration: const InputDecoration(labelText: "Video Source (Capture Card)"),
                  value: _selectedCamera,
                  items: _cameras.map((cam) {
                    // Strip System ID for display: "Device Name <...>" -> "Device Name"
                    final cleanName = cam.name.split('<').first.trim();
                    return DropdownMenuItem(
                      value: cam,
                      child: Text(cleanName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCamera = val;
                      // Clear selected audio to force re-evaluation of default
                      _selectedAudioDevice = null;
                    });
                    _autoSelectAudioDevice();
                  },
                ),
                const SizedBox(height: 16),
                
                // AUDIO SETTINGS
                CheckboxListTile(
                  title: const Text("Enable Audio Capture"),
                  value: _enableAudio,
                  onChanged: (val) => setState(() => _enableAudio = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                
                if (_enableAudio)
                  DropdownButtonFormField<AudioDevice>(
                    decoration: const InputDecoration(
                      labelText: "Audio Input Device",
                      helperText: "Select the audio source (e.g. Digital Audio Interface)",
                    ),
                    isExpanded: true,
                    value: _selectedAudioDevice,
                    items: _audioDevices.map((device) {
                      return DropdownMenuItem(
                        value: device,
                        child: Text(
                          device.name, 
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedAudioDevice = val),
                  ),

                const SizedBox(height: 16),

                // RESOLUTION
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<VmResolution>(
                        decoration: const InputDecoration(labelText: "Resolution"),
                        value: _selectedResolution,
                        items: _resolutions.map((res) {
                          return DropdownMenuItem(
                            value: res,
                            child: Text("${res.width}x${res.height} (${res.label})"),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedResolution = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: "Refresh Rate"),
                        value: _selectedFps,
                        items: _framerates.map((fps) {
                          return DropdownMenuItem(
                            value: fps,
                            child: Text("$fps FPS"),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedFps = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: (_selectedCamera != null && _selectedSerialPort != null && !_isLoading)
                      ? () => _connect(serialService)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator() 
                    : const Text("CONNECT"),
                ),
              ],
            ),
          ), // SingleChild
         ), // Expanded
        ], // Column Children
       ), // Main Column

       // FOOTER
       // ... (Footer is same)
       Positioned(
         bottom: 16,
         right: 16,
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.end,
           children: [
             const Text(
               "made with love ❤️ from FoxLust",
               style: TextStyle(
                 fontSize: 12,
                 color: Colors.grey,
               ),
             ),
             const SizedBox(height: 4),
             InkWell(
               onTap: () async {
                 final Uri url = Uri.parse('https://foxlust.my.id');
                 if (!await launchUrl(url)) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Could not launch foxlust.my.id')),
                   );
                 }
               },
               child: const Text(
                 "https://foxlust.my.id",
                 style: TextStyle(
                   fontSize: 12,
                   color: Colors.blueAccent,
                   decoration: TextDecoration.underline,
                 ),
               ),
             ),
           ],
         ),
       ),
      ],
    ), // Stack 
  );
  }

  Future<void> _connect(SerialService serialService) async {
    print("Attempting to connect...");
    setState(() => _isLoading = true);
    try {
      if (_selectedSerialPort != null) {
        print("Connecting to serial port: $_selectedSerialPort");
        await serialService.connect(_selectedSerialPort!);
        print("Serial connected successfully.");
      }
      
      if (!mounted) return;
      
      final cleanName = _selectedCamera!.name.split('<').first.trim();
      print("Navigating to KvmScreen with device: $cleanName");
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => KvmScreen(
            deviceName: cleanName,
            width: _selectedResolution.width,
            height: _selectedResolution.height,
            fps: _selectedFps,
            audioDeviceName: (_enableAudio && _selectedAudioDevice != null) 
                ? _selectedAudioDevice!.name 
                : null,
          ),
        ),
      );
    } catch (e) {
      print("Connection failed with error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class VmResolution {
  final int width;
  final int height;
  final String label;
  
  VmResolution(this.width, this.height, this.label);
}
