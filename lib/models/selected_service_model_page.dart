import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SelectedServicesProvider extends ChangeNotifier {
  final List<BluetoothService> _selectedServices = [];

  List<BluetoothService> get selectedServices => _selectedServices;

  void addService(BluetoothService service) {
    if (!_selectedServices.contains(service)) {
      _selectedServices.add(service);
      notifyListeners();
    }
  }

  void removeService(BluetoothService service) {
    _selectedServices.remove(service);
    notifyListeners();
  }

  bool isServiceSelected(BluetoothService service) {
    try {
      return _selectedServices.contains(service);
    } catch (e) {
      print(e.toString());
    }
    return true;
  }
}

class SelectedServiceModel {
  final BluetoothService service;
  final String deviceId;

  SelectedServiceModel({
    required this.service,
    required this.deviceId,
  });
}
