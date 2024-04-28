import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart'; // Import needed for input formatters

class ConfiguracoesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ConnectionSection(),
            ParametersSection(),
          ],
        ),
      ),
    );
  }
}

class ConnectionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.bluetooth),
            title: Text('Conectar à Base de Lançamento'),
            subtitle: Text('Status da conexão com a base: [DESATIVADO]'),
          ),
          ListTile(
            title: Text('Tempo de conexão: 5 ms'),
            subtitle: Text('Escanenado dispositivos...'),
          ),
        ],
      ),
    );
  }
}

class ParametersSection extends StatelessWidget {
  final TextEditingController inclinacaoController = TextEditingController();
  final TextEditingController pressaoController = TextEditingController();
  final ValueNotifier<bool> isButtonActive = ValueNotifier(false);

  ParametersSection() {
    inclinacaoController.addListener(updateButtonState);
    pressaoController.addListener(updateButtonState);
  }

  void updateButtonState() {
    final isAnyFieldNotEmpty = inclinacaoController.text.isNotEmpty &&
        pressaoController.text.isNotEmpty;
    isButtonActive.value = isAnyFieldNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: inclinacaoController,
              decoration: InputDecoration(labelText: 'Ângulo de Inclinação'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 10),
            TextField(
              controller: pressaoController,
              decoration: InputDecoration(labelText: 'Pressão Máxima'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: isButtonActive,
              builder: (context, isButtonActive, child) {
                return IconButton(
                  icon: Icon(Icons.check),
                  onPressed: isButtonActive
                      ? () {
                          // Logic to apply settings
                        }
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
