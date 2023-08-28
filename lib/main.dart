import 'package:ble_scanner/models/selected_service_model_page.dart';
import 'package:ble_scanner/screens/devices_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SelectedServicesProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Explorer',
      theme: ThemeData(
        primaryColor: Colors.blueGrey, // Ana renk gri tonu
        hintColor: Colors.blue, // Vurgu rengi mavi
      ),
      home: DeviceScanPage(),
    );
  }
}
