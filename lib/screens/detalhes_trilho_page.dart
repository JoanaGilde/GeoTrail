import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
                  image: AssetImage(
                    trilho.nome.contains('Água') ? 'assets/trilhos/trilho2.jpg' :
                    trilho.nome.contains('Castelo') ? 'assets/trilhos/trilho3.jpg' :
                    trilho.nome.contains('Serra') ? 'assets/trilhos/trilho4.jpg' :
                    'assets/trilhos/trilho1.jpg'
                  ),
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

            // DESNÍVEL E GRÁFICO DE ALTIMETRIA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Altimetria",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "↑ ${trilho.desnivel} m",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurpleAccent.shade100,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('0km', style: TextStyle(fontSize: 10, color: Colors.grey));
                          if (value == trilho.distancia) return Text('${trilho.distancia.toInt()}km', style: const TextStyle(fontSize: 10, color: Colors.grey));
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: trilho.distancia,
                  minY: 0,
                  maxY: trilho.desnivel * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 0),
                        FlSpot(trilho.distancia * 0.2, trilho.desnivel * 0.3),
                        FlSpot(trilho.distancia * 0.4, trilho.desnivel * 0.8),
                        FlSpot(trilho.distancia * 0.6, trilho.desnivel * 0.6),
                        FlSpot(trilho.distancia * 0.8, trilho.desnivel * 1.0),
                        FlSpot(trilho.distancia, trilho.desnivel * 0.85),
                      ],
                      isCurved: true,
                      color: Colors.deepPurpleAccent,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.deepPurpleAccent.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

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
                  if (!context.mounted) return;
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
