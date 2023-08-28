import 'package:ble_scanner/screens/devices_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SelectedServicesPage extends StatefulWidget {
  final List<BluetoothService> selectedServices;

  SelectedServicesPage({required this.selectedServices});

  @override
  _SelectedServicesPageState createState() => _SelectedServicesPageState();
}

class _SelectedServicesPageState extends State<SelectedServicesPage> {
  List<String> _availableMetrics = ['Count', 'Uptime', 'Freq', 'Temp'];
  Map<String, Map<String, BluetoothCharacteristic?>> _selectedCharacteristics =
      {};
  Map<String, Map<String, String>> _characteristicValues = {};

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
            "Selected Services",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                _showRemoveDevicesDialog();
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: widget.selectedServices.length,
        itemBuilder: (context, index) {
          final service = widget.selectedServices[index];
          final remoteId = service.remoteId.toString();

          if (!_selectedCharacteristics.containsKey(remoteId)) {
            _initializeDeviceData(remoteId);
          }

          return ExpansionTile(
            title: Text(
              'Device ID: $remoteId',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              service.uuid.toString(),
              style: TextStyle(fontSize: 12),
            ),
            children: _buildCharacteristicsList(service, remoteId),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[100],
        selectedFontSize: 13,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.scanner),
            label: 'Cihazlar',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Seçili Servisler',
          )
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeviceScanPage(),
              ),
            );
          }
        },
      ),
    );
  }

  void _initializeDeviceData(String remoteId) {
    _selectedCharacteristics[remoteId] = {};
    _characteristicValues[remoteId] = {};
    for (var metric in _availableMetrics) {
      _selectedCharacteristics[remoteId]![metric] = null;
      _characteristicValues[remoteId]![metric] = '';
    }
  }

  List<Widget> _buildCharacteristicsList(
      BluetoothService service, String remoteId) {
    return _availableMetrics.map(
      (metric) {
        BluetoothCharacteristic? selectedCharacteristic =
            _selectedCharacteristics[remoteId]![metric];
        String characteristicValue =
            _characteristicValues[remoteId]![metric] ?? '';

        return ListTile(
          title: Text(
            "$metric: $characteristicValue",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          trailing: Container(
            child: DropdownButton<BluetoothCharacteristic?>(
              value: selectedCharacteristic,
              onChanged: (newValue) {
                setState(
                  () {
                    _selectedCharacteristics[remoteId]![metric] = newValue;
                    _characteristicValues[remoteId]![metric] =
                        ''; // Reset the value when selecting a new characteristic
                  },
                );
              },
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
              ),
              items: service.characteristics.map(
                (characteristic) {
                  return DropdownMenuItem<BluetoothCharacteristic?>(
                    value: characteristic,
                    child: Text(characteristic.uuid.toString()),
                  );
                },
              ).toList(),
            ),
          ),
          onTap: () {
            if (selectedCharacteristic != null) {
              selectedCharacteristic.value.listen(
                (value) {
                  setState(
                    () {
                      _characteristicValues[remoteId]![metric] =
                          _convertToHex(value);
                    },
                  );
                },
              );
            }
          },
        );
      },
    ).toList();
  }

  String _convertToHex(List<int> value) {
    return '0x' +
        value.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');
  }

  void _showRemoveDevicesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Remove Devices"),
          content: Text("Are you sure you want to remove selected devices?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _removeSelectedDevices();
                Navigator.pop(context);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _removeSelectedDevices() {
    setState(() {
      widget.selectedServices.clear();
      _selectedCharacteristics.clear();
      _characteristicValues.clear();
    });
  }
}
