// lancamento_automatico_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:base_apollodi/widgets/pressure_display.dart';

class LancamentoAutomaticoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lançamento Automático'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            PressureDisplay(),
            AutomaticControlSection(),
          ],
        ),
      ),
    );
  }
}

class AutomaticControlSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly, // Espalha os botões uniformemente
          children: <Widget>[
            buildSquareButton(
                context, 'NOVO LANÇAMENTO', Colors.green, Icons.add),
            buildSquareButton(
                context, 'INICIAR LANÇAMENTO', Colors.green, Icons.start),
            buildSquareButton(context, 'ABORTAR', Colors.red, Icons.cancel),
          ],
        ),
      ),
    );
  }

  Widget buildSquareButton(
      BuildContext context, String title, Color color, IconData icon) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$title ATIVADO'),
          duration: Duration(seconds: 1),
        ));
      },
      child: Container(
        width: 180, // Mantém a largura de 100
        height: 100, // Mantém a altura de 100
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(
              10), // Adiciona padding para o layout interno
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinha o texto à esquerda
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 50),
              Expanded(
                // Utiliza o widget Expanded para permitir que o texto ocupe o espaço restante
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight
                        .bold, // Torna o texto negrito para melhor visibilidade
                  ),
                  overflow: TextOverflow
                      .ellipsis, // Adiciona elipse se o texto for muito longo
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
