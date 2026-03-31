import 'package:flutter/material.dart';
import 'app_navigator.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GeoTrail"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _menuButton(context, Icons.home, "Início", 0),
            const SizedBox(height: 20),
            _menuButton(context, Icons.map, "Trilhos", 1),
            const SizedBox(height: 20),
            _menuButton(context, Icons.directions_walk, "Atividade", 2),
            const SizedBox(height: 20),
            _menuButton(context, Icons.person, "Perfil", 3),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, IconData icon, String label, int index) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 32),
      label: Text(label, style: const TextStyle(fontSize: 22)),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 70),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppNavigator(startIndex: index),
          ),
        );
      },
    );
  }
}
