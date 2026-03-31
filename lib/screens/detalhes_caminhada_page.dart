import 'package:flutter/material.dart';

class DetalhesCaminhadaPage extends StatelessWidget {
  final Map<String, dynamic> caminhada;

  const DetalhesCaminhadaPage({super.key, required this.caminhada});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalhes da Caminhada")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Data: ${caminhada['data']}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            Text("Distância: ${caminhada['distancia_total'].toStringAsFixed(2)} km",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            Text("Duração: ${_formatarDuracao(caminhada['duracao'])}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),

            Text("Velocidade Média: ${caminhada['velocidade_media'].toStringAsFixed(2)} km/h",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // vamos implementar o mapa no próximo passo
              },
              child: const Text("Ver rota no mapa"),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarDuracao(int segundos) {
    final h = segundos ~/ 3600;
    final m = (segundos % 3600) ~/ 60;
    final s = segundos % 60;
    return "${h}h ${m}m ${s}s";
  }
}
