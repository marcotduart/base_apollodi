import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    scanForDevices();
  }

  void scanForDevices() async {
    setState(() {
      isScanning = true;
      devicesList.clear();
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        devicesList = results.map((r) => r.device).toList();
      });
    });

    await Future.delayed(Duration(seconds: 4));
    FlutterBluePlus.stopScan();
    setState(() {
      isScanning = false;
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });
  }

  void disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth'),
      ),
      body: Column(
        children: <Widget>[
          if (isScanning)
            Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView.builder(
                itemCount: devicesList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(devicesList[index].name),
                    subtitle: Text(devicesList[index].id.toString()),
                    onTap: () {
                      connectToDevice(devicesList[index]);
                    },
                  );
                },
              ),
            ),
          if (connectedDevice != null)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Conectado a ${connectedDevice!.name}'),
                  ElevatedButton(
                    onPressed: disconnectFromDevice,
                    child: Text('Desconectar'),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: scanForDevices,
        child: Icon(Icons.search),
      ),
    );
  }
}
