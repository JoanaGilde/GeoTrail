import 'package:flutter/material.dart';
import 'package:flutter_geotrail/screens/detalhes_caminhada_page.dart';
import '../database/database_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class CaminhadaPage extends StatefulWidget {
  const CaminhadaPage({super.key});

  @override
  State<CaminhadaPage> createState() => _CaminhadaPageState();
}

class _CaminhadaPageState extends State<CaminhadaPage> {
  // GPS tracking
  
  List<Map<String, dynamic>> favoritos = [];
  List<Map<String, dynamic>> caminhadas = [];
  //GPS tracking
  StreamSubscription<Position>? positionSub;
  Position? ultimaPosicao;
  double distanciaTotal = 0.0;
  List<Position> rota = [];
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    favoritos = await DatabaseHelper.instance.getFavoritos();
    caminhadas = await DatabaseHelper.instance.getCaminhadas();
    setState(() {});
  }

  Future<void> _addFavorito() async {
    await DatabaseHelper.instance.insertFavorito({
      'id_trilho': 1,
      'id_utilizador': 1,
      'data_adicionado': DateTime.now().toString(),
    });
    _loadData();
  }

  Future<void> _addCaminhada() async {
    await DatabaseHelper.instance.insertCaminhada({
      'id_trilho': 1,
      'id_utilizador': 1,
      'data': DateTime.now().toString(),
      'distancia_total': 5.2,
      'velocidade_media': 4.1,
      'rota': '[]',
      'desnivel_acumulado': 120,
      'duracao': 3600,
    });
    _loadData();
  }
  // ativar o tracking real
  Future<bool> _checkPermissions() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return false;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  return permission == LocationPermission.always ||
         permission == LocationPermission.whileInUse;
}
// Iniciar caminhada (tracking contínuo)
void _iniciarCaminhada() async {
  bool ok = await _checkPermissions();
  if (!ok) return;

  distanciaTotal = 0.0;
  rota.clear();
  ultimaPosicao = null;

  positionSub = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 1,
    ),
  ).listen((pos) {
    if (ultimaPosicao != null) {
      distanciaTotal += Geolocator.distanceBetween(
        ultimaPosicao!.latitude,
        ultimaPosicao!.longitude,
        pos.latitude,
        pos.longitude,
      );
    }

    ultimaPosicao = pos;
    rota.add(pos);

    setState(() {});
  });
}
// Parar caminhada, guardar no SQLite e guardar rota ponto a ponto
void _pararCaminhada() async {
  await positionSub?.cancel();
  positionSub = null;

  // Se não houver pontos, ainda assim guardar caminhada
  if (rota.isEmpty) {
    int caminhadaId = await DatabaseHelper.instance.insertCaminhada({
      'id_trilho': 1,
      'id_utilizador': 1,
      'data': DateTime.now().toString(),
      'distancia_total': 0,
      'velocidade_media': 0,
      'rota': '',
      'desnivel_acumulado': 0,
      'duracao': 0.0,
    });

    _loadData();
    return;
  }

  // 1. Calcular duração
  final inicio = rota.first.timestamp!;
  final fim = rota.last.timestamp!;
  final duracaoSegundos = fim.difference(inicio).inSeconds;

  // 2. Calcular velocidade média
  final distanciaKm = distanciaTotal / 1000;
  final duracaoHoras = duracaoSegundos / 3600;
  final velocidadeMedia = duracaoHoras > 0 ? distanciaKm / duracaoHoras : 0;

  // 3. Inserir caminhada e obter ID
  int caminhadaId = await DatabaseHelper.instance.insertCaminhada({
    'id_trilho': 1,
    'id_utilizador': 1,
    'data': DateTime.now().toString(),
    'distancia_total': distanciaKm,
    'velocidade_media': velocidadeMedia,
    'rota': '', // já não usamos JSON
    'desnivel_acumulado': 0,
    'duracao': duracaoSegundos.toDouble(),
  });

  // 4. Inserir pontos da rota
  for (var p in rota) {
    await DatabaseHelper.instance.insertPontoRota({
      'id_caminhada': caminhadaId,
      'latitude': p.latitude,
      'longitude': p.longitude,
      'timestamp': p.timestamp?.toIso8601String(),
    });
  }

  _loadData();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teste BD")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _addFavorito,
            child: const Text("Adicionar Favorito"),
          ),
          ElevatedButton(
            onPressed: _addCaminhada,
            child: const Text("Adicionar Caminhada"),
          ),
          ElevatedButton(
            onPressed: _iniciarCaminhada,
            child: const Text("Iniciar Caminhada (GPS)"),
          ),
          ElevatedButton(
            onPressed: _pararCaminhada,
            child: const Text("Parar Caminhada (GPS)"),
          ),
          const SizedBox(height: 20),
          const Text("Favoritos:", style: TextStyle(fontSize: 20)),
          Expanded(
            child: ListView(
              children: favoritos
                  .map((f) => ListTile(
                        title: Text("Trilho: ${f['id_trilho']}"),
                        subtitle: Text("Data: ${f['data_adicionado']}"),
                      ))
                  .toList(),
            ),
          ),
          const Text("Caminhadas:", style: TextStyle(fontSize: 20)),
          Expanded(
            child: ListView(
              children: caminhadas
                  .map((c) => ListTile(
                        title: Text("Trilho: ${c['id_trilho']}"),
                        subtitle: Text("Distância: ${c['distancia_total']} km"),
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (_) => DetalhesCaminhadaPage(caminhada: c),
                            ),
                          );
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}