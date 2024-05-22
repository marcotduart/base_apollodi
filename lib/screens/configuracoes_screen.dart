import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bluetooth_screen.dart';

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
            BluetoothScreen(),
            ParametersSection(),
          ],
        ),
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
              decoration: InputDecoration(
                labelText: 'Ângulo de Inclinação (º)',
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.trending_up, color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 10),
            TextField(
              controller: pressaoController,
              decoration: InputDecoration(
                labelText: 'Pressão Máxima (psi)',
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.speed, color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: isButtonActive,
              builder: (context, isButtonActive, child) {
                return IconButton(
                  icon: Icon(Icons.check),
                  onPressed: isButtonActive ? () {} : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
