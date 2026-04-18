import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/trilho.dart';
import 'atividade_page.dart';

class DetalhesTrilhoPage extends StatelessWidget {
  final Trilho trilho;

  const DetalhesTrilhoPage({super.key, required this.trilho});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trilho.nome),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // FOTO DO TRILHO (placeholder)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: MemoryImage(trilho.imagem),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // NOME
            Text(
              trilho.nome,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // DISTÂNCIA + DIFICULDADE
            Row(
              children: [
                Icon(Icons.route, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text("${trilho.distancia.toStringAsFixed(2)} km"),

                const SizedBox(width: 20),

                Icon(Icons.flag, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(trilho.dificuldade),
              ],
            ),

            const SizedBox(height: 20),

            // DESCRIÇÃO
            const Text(
              "Descrição",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              trilho.descricao,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // DESNÍVEL
            const Text(
              "Desnível",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "${trilho.desnivel} m",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // COORDENADAS
            const Text(
              "Coordenadas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              trilho.coordenadas,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            // BOTÃO INICIAR TRILHO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text("Iniciar Trilho"),
                onPressed: () async {
                  final db = DatabaseHelper.instance;

                  // 1. Criar nova caminhada
                  int idCaminhada = await db.insertCaminhada({
                    'id_trilho': trilho.id,
                    'id_utilizador': 1, // ou o ID real do utilizador
                    'data': DateTime.now().toIso8601String(),
                    'distancia_total': 0.0,
                    'velocidade_media': 0.0,
                    'rota': '',
                    'desnivel_acumulado': 0.0,
                    'duracao': 0.0,
                  });

                  // 2. Abrir página de atividade passando o ID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AtividadePage(idCaminhada: idCaminhada),
                    ),
                  );
                },

              ),
            ),
          ],
        ),
      ),
    );
  }
}
