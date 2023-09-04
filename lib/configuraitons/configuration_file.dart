class ServiceDefinitions {
  static const Map<String, String> deviceNames = {
    'deadbeef-0001-4200-a1cb-d7399a4f2759': 'Server Health Service 2',
    'deadbeef-1001-4200-a1cb-d7399a4f2759': 'Server Health Service 3',
    // Add more service UUIDs and names here
  };

  static const Map<String, Map<String, String>> characteristicUuids = {
    'deadbeef-0001-4200-a1cb-d7399a4f2759': {
      'Count': 'deadbeef-0003-454d-bccc-4ad7a331d1bf',
      'Uptime': 'deadbeef-0004-4f34-bcc8-de1fcfdb5a9c',
      'Freq': 'deadbeef-0005-47fa-9c4f-42d19dc6eea6',
      'Temp': 'deadbeef-0006-456d-823d-2c857fa17003',
    },
    'deadbeef-1001-4200-a1cb-d7399a4f2759': {
      'Count': 'deadbeef-1003-454d-bccc-4ad7a331d1bf',
      'Uptime': 'deadbeef-1004-4f34-bcc8-de1fcfdb5a9c',
      'Freq': 'deadbeef-1005-47fa-9c4f-42d19dc6eea6',
      'Temp': 'deadbeef-1006-456d-823d-2c857fa17003',
    },
    // Add more service UUIDs and their characteristic UUIDs here
  };
}
