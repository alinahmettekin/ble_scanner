import 'package:ble_scanner/models/selected_service_model_page.dart';
import 'package:ble_scanner/screens/about_page.dart';
import 'package:ble_scanner/screens/selected_services_page.dart';
import 'package:ble_scanner/screens/services_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class DeviceScanPage extends StatefulWidget {
  @override
  _DeviceScanPageState createState() => _DeviceScanPageState();
}

class _DeviceScanPageState extends State<DeviceScanPage> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  Map<BluetoothDevice, bool> _connectionStatus = {}; // Bağlantı durumu
  int _currentIndex = 0; // Seçili olan bottom navigation bar tuşunun index'i

  @override
  void initState() {
    super.initState();

    _startScanning();
  }

  void _startScanning() {
    FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _devices = results.map((r) => r.device).toList();
      });
    });
    FlutterBluePlus.connectedDevices.asStream().listen((devices) =>
        _updateConnectionStatus(devices)); // Bağlı cihazları takip et
    setState(() {
      _isScanning = true;
    });
  }

  void _onToggleScan() {
    if (_isScanning) {
      _stopScanning();
    } else {
      _startScanning();
    }
  }

  void _stopScanning() {
    FlutterBluePlus.stopScan();
    setState(() {
      _isScanning = false;
    });
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  void _updateConnectionStatus(List<BluetoothDevice> devices) {
    for (var device in devices) {
      final isConnected = _connectionStatus[device] ?? false; // Bağlantı durumu
      setState(() {
        _connectionStatus[device] = isConnected; // Bağlantı durumu güncelle
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var selectedServicesProvider =
        Provider.of<SelectedServicesProvider>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          centerTitle: true,
          title: Text(
            "Scan Devices",
            style: TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          backgroundColor: Colors.blueAccent,
          actions: [
            GestureDetector(
              onTap: _onToggleScan,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Icon(
                  _isScanning ? Icons.stop : Icons.play_arrow,
                  color: Colors.white,
                  size: 24.0,
                ),
              ),
            ),
            SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.info, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutPage(), // Hakkında sayfasına git
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                final isConnected =
                    _connectionStatus[device] ?? false; // Bağlantı durumu
                return ListTile(
                  title: Text(
                    device.localName ?? 'Unknown Device',
                    style: TextStyle(
                      color: isConnected ? Colors.green : Colors.blue,
                    ),
                  ),
                  subtitle: Text(
                    device.remoteId.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: isConnected
                      ? Text("Connected", style: TextStyle(color: Colors.green))
                      : Text("Connect", style: TextStyle(color: Colors.blue)),
                  onTap: () async {
                    if (isConnected) {
                      // Cihaz zaten bağlıysa
                      // İşlemleri burada yönetin
                    } else {
                      await device.connect();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceListPage(device: device),
                        ),
                      );
                      _stopScanning();
                    }
                  },
                );
              },
            ),
          ),
        ],
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
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectedServicesPage(
                    selectedServices:
                        selectedServicesProvider.selectedServices),
              ),
            );
          }
          print(_devices);
        },
      ),
    );
  }
}
