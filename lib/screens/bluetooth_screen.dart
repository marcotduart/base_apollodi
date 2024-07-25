import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothScreen extends StatefulWidget {
  static BluetoothCharacteristic? targetCharacteristic;
  static BluetoothCharacteristic? targetPressureCharacteristic;
  static BluetoothCharacteristic? targetAngleCharacteristic;

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
} // Criando tela Bluetooth

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  bool isScanning = false;
  final Duration scanInterval = Duration(seconds: 15);
  final TextEditingController angleController = TextEditingController(); // Adicionando componente de adicionar texto para ângulo
  final TextEditingController pressureController = TextEditingController();  // Adicionando componente de adicionar texto para ângulo
  String receivedPressureData = ''; // Definindo varíavel para dados de pressão recebidos
  String receivedAngleData = ''; // Definindo varíavel para dados de ângulo recebidos
  String receivedData = ''; // Definindo varíavel para dados recebidos

  @override
  void initState() {
    super.initState();
    requestPermissions();
    scanForDevicesPeriodically();
  } // Inicializand funções da tela

  Future<void> requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.location.request();
  } // Função para requisitar permissões

  void scanForDevices() async {
    if (isScanning || connectedDevice != null) return; // Função para escanear dispositivo 

    setState(() {
      isScanning = true; // Definindo variável booleando para estado do Scan
      devicesList.clear(); // Limpando lista e dispostiviso Bluetooth
    }); 

    FlutterBluePlus.startScan(timeout: Duration(seconds: 5)); // Iniciando scan

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        devicesList = results.map((r) => r.device).toList();
      });
    }); // Construindo lista dos dispositivos Bluetooth pareáveis a partir dos resultados do Scan

    await Future.delayed(Duration(seconds: 5));
    FlutterBluePlus.stopScan();
    setState(() {
      isScanning = false;
    });
  } // Função para parar Scan a cada 5 segundos

  void scanForDevicesPeriodically() async {
    if (connectedDevice == null) {
      scanForDevices();
      await Future.delayed(scanInterval);
      scanForDevicesPeriodically();
    }
  } // Função para iniciar Scan periodicamente 

  void connectToDevice(BluetoothDevice device) async {
     await device.connect();
    setState(() {
      connectedDevice = device;
      isScanning = false; 
    }); // Função para conectar dispositivo selecionado da lista
    FlutterBluePlus.stopScan(); 
    discoverServices(device);

    sendCommand('L10'); // Desligar IGNITAR
  sendCommand('L20'); // Desligar AGITAR
  sendCommand('L30'); // Desligar INCLINAR
  sendCommand('L40'); // Desligar ALERTAR
  sendCommand('L50'); // Desligar DISPARAR
  sendCommand('L60'); // Desligar ABORTAR
  } // Função para enviar comando de desligar todos os botões após conectado

  void disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null;
        BluetoothScreen.targetCharacteristic = null;
        BluetoothScreen.targetPressureCharacteristic = null;
        BluetoothScreen.targetAngleCharacteristic = null;
        receivedData = ''; 
        receivedPressureData = '';
        receivedAngleData = '';
      });
    }
  } // Função para desconectar dispositivo

void discoverPressaoAnguloServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() == '0972EF8C-7613-4075-AD52-756F33D4DA91') {
          setState(() {
            BluetoothScreen.targetPressureCharacteristic = characteristic;
          });
          characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            setState(() {
              receivedPressureData = String.fromCharCodes(value);
            });
          });
        } else if (characteristic.uuid.toString() == '0f1d2df9-f709-4633-bb27-0c52e13f748a') {
          setState(() {
            BluetoothScreen.targetAngleCharacteristic = characteristic;
          });
          characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            setState(() {
              receivedAngleData = String.fromCharCodes(value);
            });
          });
        }
      }
    }
  }

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          setState(() {
            BluetoothScreen.targetCharacteristic = characteristic;
          });
        }
        if (characteristic.properties.notify) {
          characteristic.setNotifyValue(true);
          characteristic.value.listen((value) {
            setState(() {
              receivedData = String.fromCharCodes(value);
            });
          });
        }
      }
    }
  } // Função para identificar características Bluetooth 

  void sendCommand(String data) async {
    if (BluetoothScreen.targetCharacteristic != null) {
      await BluetoothScreen.targetCharacteristic!.write(data.codeUnits);
    }
  } // Função para enviar comando para o via Bluetooth

  void applySettings() {
    String angle = angleController.text;
    String pressure = pressureController.text;
    sendCommand('ANGLE: $angle');
    sendCommand('PRESSURE: $pressure');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('As configurações foram aplicadas'),
      duration: Duration(seconds: 2),
    ));
  } // Função para aplicar configuração enviando comandos via Bluetooth

  Widget buildBluetoothDeviceList() {
    if (isScanning) {
      return Center(child: CircularProgressIndicator());
    } else if (devicesList.isEmpty) {
      return Center(child: Text('Nenhum dispositivo encontrado'));
    } else {
      return ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          BluetoothDevice device = devicesList[index];
          return ListTile(
            title: Text(
                device.name.isNotEmpty ? device.name : 'Dispositivo desconhecido'),
            subtitle: Text(device.id.toString()),
            trailing: ElevatedButton(
              onPressed: () => connectToDevice(device),
              child: Text('Conectar', style: TextStyle(color: Colors.black)),
            ),
          );
        },
      );
    }
  } // Função para criar widget com lista dos dipositivos Bluetooth e botões para conexão

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: connectedDevice != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              
                children: [
                  Row(
                    children: [Icon(Icons.bluetooth, size:40),
                  SizedBox(height: 20,),
                  Text("Bluetooth", style: TextStyle(fontSize: 24))]),
                  Text('Conectado a ${connectedDevice!.name}', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  TextField(
                    controller: angleController,
                    decoration: InputDecoration(labelText: 'Ângulo de Inclinação'),
                  ),
                  TextField(
                    controller: pressureController,
                    decoration: InputDecoration(labelText: 'Pressão Máxima'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: applySettings,
                    child: Text('Aplicar'),
                  ),
                ],
              )
            : Expanded(child: buildBluetoothDeviceList()),
      ),
      floatingActionButton: connectedDevice != null
          ? FloatingActionButton(
              onPressed: disconnectFromDevice,
              child: Icon(Icons.bluetooth_disabled),
              tooltip: 'Desconectar',
            )
          : null,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BluetoothScreen(),
  ));
}
