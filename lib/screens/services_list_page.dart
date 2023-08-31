import 'package:ble_scanner/models/selected_service_model_page.dart';
import 'package:ble_scanner/screens/selected_services_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class ServiceListPage extends StatefulWidget {
  final BluetoothDevice device;

  ServiceListPage({required this.device});

  @override
  _ServiceListPageState createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  List<BluetoothService> _services = [];

  @override
  void initState() {
    super.initState();
    _discoverServices();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _discoverServices() async {
    try {
      await widget.device.connect();
      List<BluetoothService> services = await widget.device.discoverServices();
      setState(() {
        _services = services;
      });
      _subscribeToCharacteristicUpdates();
    } catch (e) {
      print('Error discovering services: $e');
    }
  }

  void _subscribeToCharacteristicUpdates() {
    for (var service in _services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.notify ||
            characteristic.properties.indicate) {
          characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            _updateCharacteristicValue(characteristic, value);
          });
        }
      }
    }
  }

  void _updateCharacteristicValue(
      BluetoothCharacteristic characteristic, List<int> value) {
    setState(() {
      characteristic.lastValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var selectedServicesProvider = Provider.of<SelectedServicesProvider>(
        context); // Provider'ı burada kullanıyoruz

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
            widget.device.localName,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return ExpansionTile(
            title: Text("Servis ${index + 1}"),
            subtitle: Text(
              service.uuid.toString(),
              style: TextStyle(color: Colors.blue, fontSize: 10),
            ),
            trailing: IconButton(
              icon: Icon(
                selectedServicesProvider.isServiceSelected(service)
                    ? Icons.remove
                    : Icons.add,
                color: selectedServicesProvider.isServiceSelected(service)
                    ? Colors.red
                    : Colors.green,
              ),
              onPressed: () {
                setState(() {
                  if (selectedServicesProvider.isServiceSelected(service)) {
                    selectedServicesProvider.removeService(service);
                  } else {
                    selectedServicesProvider.addService(service);
                  }
                });
              },
            ),
            children: service.characteristics.map((characteristic) {
              return ListTile(
                title: Text(
                  characteristic.uuid.toString(),
                  style: TextStyle(color: Colors.blue),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Value: ${characteristic.lastValue != null ? characteristic.lastValue.join(', ') : 'No Data'}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Hex Value: ${characteristic.lastValue != null ? '0x' + characteristic.lastValue.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('') : 'No Data'}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Unicode: ${characteristic.lastValue != null && characteristic.lastValue.isNotEmpty && characteristic.lastValue[0] >= 0 && characteristic.lastValue[0] <= 65535 ? String.fromCharCode(characteristic.lastValue[0]) : 'No Data'}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[100],
        selectedFontSize: 13,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'Servisler',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Seçili Servisler',
          )
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SelectedServicesPage(
                        selectedServices:
                            selectedServicesProvider.selectedServices,
                      )),
            );
          }
        },
      ),
    );
  }
}
