import 'package:flutter/material.dart';

class PressureDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              'Pressão (psi)',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              '353',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            // Placeholder for the actual graph
            Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(child: Text('Gráfico de Pressão')),
            ),
          ],
        ),
      ),
    );
  }
}
