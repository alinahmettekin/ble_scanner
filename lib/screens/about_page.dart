import 'package:ble_scanner/configuraitons/configuration_file.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
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
            "About Page",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text(
            "Service Definitions",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          for (var serviceUuid in ServiceDefinitions.characteristicUuids.keys)
            ServiceInfoCard(
              serviceUuid: serviceUuid,
              characteristics:
                  ServiceDefinitions.characteristicUuids[serviceUuid]!,
            ),
        ],
      ),
    );
  }
}

class ServiceInfoCard extends StatelessWidget {
  final String serviceUuid;
  final Map<String, String> characteristics;

  ServiceInfoCard({required this.serviceUuid, required this.characteristics});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Service UUID: $serviceUuid",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            for (var entry in characteristics.entries)
              CharacteristicInfo(
                characteristicName: entry.key,
                characteristicUuid: entry.value,
              ),
          ],
        ),
      ),
    );
  }
}

class CharacteristicInfo extends StatelessWidget {
  final String characteristicName;
  final String characteristicUuid;

  CharacteristicInfo({
    required this.characteristicName,
    required this.characteristicUuid,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Characteristic Name: $characteristicName",
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Characteristic UUID: $characteristicUuid",
          style: TextStyle(fontSize: 14.0),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
