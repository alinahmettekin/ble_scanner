import 'package:ble_scanner/models/selected_service_model_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SelectedServicesPage extends StatefulWidget {
  final List<BluetoothService> selectedServices;

  SelectedServicesPage({required this.selectedServices});

  @override
  _SelectedServicesPageState createState() => _SelectedServicesPageState();
}

class _SelectedServicesPageState extends State<SelectedServicesPage> {
  List<Map<String, String>> _characteristicValuesList = [];
  List<SelectedServiceModel> _selectedServiceModels = [];

  final Map<String, String> _characteristicUuidsService1 = {
    'Count': 'deadbeef-0003-454d-bccc-4ad7a331d1bf',
    'Uptime': 'deadbeef-0004-4f34-bcc8-de1fcfdb5a9c',
    'Freq': 'deadbeef-0005-47fa-9c4f-42d19dc6eea6',
    'Temp': 'deadbeef-0006-456d-823d-2c857fa17003',
  };

  final Map<String, String> _characteristicUuidsService2 = {
    'Count': 'deadbeef-1003-454d-bccc-4ad7a331d1bf',
    'Uptime': 'deadbeef-1004-4f34-bcc8-de1fcfdb5a9c',
    'Freq': 'deadbeef-1005-47fa-9c4f-42d19dc6eea6',
    'Temp': 'deadbeef-1006-456d-823d-2c857fa17003',
  };

  final Map<String, String> _deviceNames = {
    'deadbeef-0001-4200-a1cb-d7399a4f2759': 'Server Health Service 2',
    'deadbeef-1001-4200-a1cb-d7399a4f2759': 'Server Health Service 3',
    // adding service uuid and name
  };

  @override
  void initState() {
    super.initState();
    _subscribeToCharacteristics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selected Services"),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              setState(() {
                widget.selectedServices.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _characteristicValuesList.length,
              itemBuilder: (context, index) {
                final serviceData = _characteristicValuesList[index];
                final deviceId = serviceData['deviceId'] ?? 'Unknown Device';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text("Device ID: $deviceId"),
                    ),
                    ...serviceData.entries
                        .where((entry) => entry.key != 'deviceId')
                        .map((entry) => ListTile(
                              title: Text("${entry.key}: ${entry.value}"),
                            ))
                        .toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _getServiceName(String deviceId) {
    return _deviceNames[deviceId];
  }

  String? _getDeviceName(String deviceId) {
    final selectedServiceModel = _selectedServiceModels.firstWhere(
      (model) => model.deviceId == deviceId,
      orElse: () => SelectedServiceModel(
        service: widget.selectedServices[0], // Varsayılan bir servis
        deviceId: deviceId,
      ),
    );

    return _deviceNames[selectedServiceModel.deviceId] ??
        'Device ${widget.selectedServices.indexOf(selectedServiceModel.service) + 1}';
  }

  void _subscribeToCharacteristics() {
    for (var service in widget.selectedServices) {
      if (service.uuid.toString() == 'deadbeef-0001-4200-a1cb-d7399a4f2759') {
        _subscribeToServiceCharacteristics(_characteristicUuidsService1,
            service.characteristics, service.remoteId.toString());
      } else if (service.uuid.toString() ==
          'deadbeef-1001-4200-a1cb-d7399a4f2759') {
        _subscribeToServiceCharacteristics(_characteristicUuidsService2,
            service.characteristics, service.remoteId.toString());
      }

      _selectedServiceModels.add(
        SelectedServiceModel(
          service: service,
          deviceId: service.remoteId.toString(),
        ),
      );
    }
  }

  void _showCharacteristicValuesDialog(int index) {
    final serviceData = _characteristicValuesList[index];
    final deviceId = serviceData['deviceId'];
    final deviceName = _getDeviceName(deviceId!) ?? 'Unknown';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Device: $deviceName"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: serviceData.entries
                .where((entry) => entry.key != 'deviceId')
                .map((entry) => ListTile(
                      title: Text("${entry.key}: ${entry.value}"),
                    ))
                .toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _subscribeToServiceCharacteristics(
      Map<String, String> characteristicUuids,
      List<BluetoothCharacteristic> serviceCharacteristics,
      String deviceId) {
    final characteristicValues = <String, String>{'deviceId': deviceId};
    for (var metric in characteristicUuids.keys) {
      final characteristicUuid = characteristicUuids[metric];
      final characteristic = serviceCharacteristics
          .firstWhere((c) => c.uuid.toString() == characteristicUuid);

      if (characteristic != null) {
        characteristic.value.listen((data) {
          setState(() {
            characteristicValues[metric] = data.toString();
          });
        });
      }
    }

    _characteristicValuesList.add(characteristicValues);
  }
}
