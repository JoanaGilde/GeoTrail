import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../database/database_helper.dart';

class AtividadePage extends StatefulWidget {
  final int idCaminhada;

  const AtividadePage({super.key, required this.idCaminhada});

  @override
  AtividadePageState createState() => AtividadePageState();
}

class AtividadePageState extends State<AtividadePage> {
  Position? _lastPos;
  StreamSubscription<Position>? _gpsStream;
  double distanciaTotal = 0.0;
  int segundos = 0;
  Timer? _timer;

  void _iniciarTempo() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        segundos++;
      });
    });
  }

  void _iniciarGPS() async {
    LocationPermission perm = await Geolocator.requestPermission();

    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return;
    }

    _gpsStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // só atualiza quando te moves 5 metros
      ),
    ).listen((pos) {
      _guardarPonto(pos);     // guarda na BD
      _atualizarDistancia(pos); // calcula distância
   });
  }

  void _guardarPonto(Position pos) async {
    final db = DatabaseHelper.instance;

    await db.insertPontoRota({
      'caminhada_id': widget.idCaminhada,
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _atualizarDistancia(Position pos) {
    if (_lastPos != null) {
      double metros = Geolocator.distanceBetween(
        _lastPos!.latitude,
        _lastPos!.longitude,
        pos.latitude,
        pos.longitude,
      );

      distanciaTotal += metros;
    }

    _lastPos = pos;

    setState(() {});
  }

  void _terminar() async {
    _gpsStream?.cancel();
    _timer?.cancel();

    final db = DatabaseHelper.instance;

    await db.update(
      'caminhada',
      {
        'distancia_total': distanciaTotal,
        'duracao': segundos.toDouble(),
        'velocidade_media': segundos == 0 ? 0 : distanciaTotal / segundos,
      },
      where: 'id_caminhada = ?',
      whereArgs: [widget.idCaminhada],
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _iniciarTempo();
    _iniciarGPS();
  }

  @override
  void dispose() {
    _gpsStream?.cancel();
    _timer?.cancel();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Atividade #${widget.idCaminhada}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Tempo: ${segundos}s",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              "Distância: ${(distanciaTotal / 1000).toStringAsFixed(2)} km",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              _lastPos == null
                  ? "À espera de GPS..."
                  : "Lat: ${_lastPos!.latitude}\nLon: ${_lastPos!.longitude}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _terminar,
                child: const Text("Terminar Caminhada"),
              ),
            ),
          ],
        ),
      ),


    );
  }
}

