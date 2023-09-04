import 'package:ble_scanner/configuraitons/configuration_file.dart';
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

  String? _getDeviceName(String deviceId) {
    final selectedServiceModel = _selectedServiceModels.firstWhere(
      (model) => model.deviceId == deviceId,
      orElse: () => SelectedServiceModel(
        service: widget.selectedServices[0], // Varsayılan bir servis
        deviceId: deviceId,
      ),
    );

    return ServiceDefinitions.deviceNames[selectedServiceModel.deviceId] ??
        'Device ${widget.selectedServices.indexOf(selectedServiceModel.service) + 1}';
  }

  void _subscribeToCharacteristics() {
    for (var service in widget.selectedServices) {
      final serviceUuid = service.uuid.toString();
      final characteristicUuids = ServiceDefinitions.characteristicUuids[serviceUuid];

      if (characteristicUuids != null) {
        _subscribeToServiceCharacteristics(
          characteristicUuids,
          service.characteristics,
          service.remoteId.toString(),
        );
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
