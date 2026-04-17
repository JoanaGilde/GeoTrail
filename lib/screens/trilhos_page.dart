import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/trilho.dart';
import 'detalhes_trilho_page.dart';


class TrilhosPage extends StatefulWidget {
  const TrilhosPage({super.key});

  @override
  State<TrilhosPage> createState() => _TrilhosPageState();
}

class _TrilhosPageState extends State<TrilhosPage> {
  List<Trilho> trilhos = [];

  @override
  void initState() {
    super.initState();
    carregarTrilhos();
  }

  Future<void> carregarTrilhos() async {
    final data = await DatabaseHelper.instance.getTrilhos();
    setState(() => trilhos = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trilhos")),
      body: trilhos.isEmpty
          ? const Center(
        child: Text(
          "Ainda não há trilhos disponíveis.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: trilhos.length,
        itemBuilder: (context, index) {
          final t = trilhos[index];

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            child: ListTile(
              leading: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.landscape, size: 40),
              ),
              title: Text(t.nome),
              subtitle: Text(
                "${t.distancia.toStringAsFixed(2)} km • ${t.dificuldade}",
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetalhesTrilhoPage(trilho: t),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

