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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          title: Text(
            "Selected Services Page",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                _showClearListDialog();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Selected Services: ${widget.selectedServices.length}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _characteristicValuesList.length,
              itemBuilder: (context, index) {
                final serviceData = _characteristicValuesList[index];
                final deviceId = serviceData['deviceId'] ?? 'Unknown Device';

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          "Device ID: $deviceId",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...serviceData.entries
                          .where((entry) => entry.key != 'deviceId')
                          .map((entry) => ListTile(
                                title: Text("${entry.key}: ${entry.value}"),
                              ))
                          .toList(),
                    ],
                  ),
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
        service: widget.selectedServices[0],
        deviceId: deviceId,
      ),
    );

    return ServiceDefinitions.deviceNames[selectedServiceModel.deviceId] ??
        'Device ${widget.selectedServices.indexOf(selectedServiceModel.service) + 1}';
  }

  void _subscribeToCharacteristics() {
    for (var service in widget.selectedServices) {
      final serviceUuid = service.uuid.toString();
      final characteristicUuids =
          ServiceDefinitions.characteristicUuids[serviceUuid];

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

  void _showClearListDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Clear List"),
          content: Text("Do you want to clear the selected services list?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Diyalog kutusunu kapat

                setState(() {
                  // Listeyi temizle
                  widget.selectedServices.clear();
                });
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Diyalog kutusunu kapat
              },
              child: Text('No'),
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
