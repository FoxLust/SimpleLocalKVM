import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialService extends ChangeNotifier {
  SerialPort? _port;
  String? _connectedPortName;

  bool get isConnected => _port != null && _port!.isOpen;
  String? get connectedPortName => _connectedPortName;

  List<String> getAvailablePorts() {
    return SerialPort.availablePorts;
  }

  Future<void> connect(String address) async {
    if (isConnected) {
      await disconnect();
    }

    try {
      final port = SerialPort(address);
      if (!port.openReadWrite()) {
        throw Exception("Failed to open port $address. It might be in use or inaccessible.");
      }

      final config = SerialPortConfig();
      config.baudRate = 115200;
      config.bits = 8;
      config.stopBits = 1;
      config.parity = SerialPortParity.none;
      port.config = config;

      _port = port;
      _connectedPortName = address;
      notifyListeners();
    } catch (e) {
      print("Error connecting to serial port: $e");
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_port != null) {
      _port!.close();
      _port!.dispose();
      _port = null;
      _connectedPortName = null;
      notifyListeners();
    }
  }

  void sendData(Uint8List data) {
    if (!isConnected || _port == null) return;
    try {
      final bytesWritten = _port!.write(data);
      if (bytesWritten != data.length) {
        print("Warning: Only wrote $bytesWritten/${data.length} bytes");
      }
    } catch (e) {
      print("Error writing to serial port: $e");
      disconnect(); 
    }
  }
  
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
