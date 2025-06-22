import 'package:flutter/material.dart';
import '../services/bitacora_service.dart';
import '../widgets/bitacora_item.dart';

class BitacoraScreen extends StatefulWidget {
  const BitacoraScreen({super.key});

  @override
  State<BitacoraScreen> createState() => _BitacoraScreenState();
}

class _BitacoraScreenState extends State<BitacoraScreen> {
  List<Map<String, dynamic>> _notas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarNotas();
  }

  Future<void> _cargarNotas() async {
    final notas = await obtenerNotas();
    setState(() {
      _notas = notas;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitácora')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _notas.isEmpty
              ? const Center(child: Text('No hay notas aún.'))
              : ListView.builder(
                  itemCount: _notas.length,
                  itemBuilder: (ctx, i) => BitacoraItem(
                    titulo: _notas[i]['titulo'] ?? '',
                    contenido: _notas[i]['contenido'] ?? '',
                    fecha: _notas[i]['fecha'] ?? '',
                    onDelete: () async {
                     
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}