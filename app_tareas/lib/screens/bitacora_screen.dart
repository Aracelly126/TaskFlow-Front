import 'package:flutter/material.dart';
import '../services/bitacora_service.dart';
import '../widgets/bitacora_item.dart';
import '../widgets/menu.dart';

class BitacoraScreen extends StatefulWidget {
  const BitacoraScreen({super.key});

  @override
  State<BitacoraScreen> createState() => _BitacoraScreenState();
}

class _BitacoraScreenState extends State<BitacoraScreen> {
  List<Map<String, dynamic>> _notas = [];
  bool _cargando = true;

  String _mensajeDia = "¿Cómo te sientes hoy?";
  int? _emocionSeleccionada;

  final List<Map<String, dynamic>> _emociones = [
    {
      'gif': 'animations/happy.gif',
      'label': 'Feliz',
      'mensaje': '¡Qué alegría que te sientas feliz! Disfruta tu día 😊'
    },
    {
      'gif': 'animations/sad.gif',
      'label': 'Triste',
      'mensaje': 'Está bien sentirse triste. ¡Ánimo, todo mejora! 💜'
    },
    {
      'gif': 'animations/angry.gif',
      'label': 'Molesto/a',
      'mensaje': 'Respira profundo, deja ir lo que no puedes controlar. 💨'
    },
    {
      'gif': 'animations/love.gif',
      'label': 'Enamorado/a',
      'mensaje': '¡El amor es lo más bonito! Que tu día esté lleno de cariño. 💖'
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarNotas();
  }

  Future<void> _cargarNotas() async {
    setState(() => _cargando = true);
    final notas = await obtenerNotas();
    notas.sort((a, b) => (b['fecha'] ?? '').compareTo(a['fecha'] ?? ''));
    setState(() {
      _notas = notas;
      _cargando = false;
    });
  }

  Future<void> _mostrarFormulario({Map<String, dynamic>? nota}) async {
    final tituloController = TextEditingController(text: nota?['titulo'] ?? '');
    final contenidoController = TextEditingController(text: nota?['contenido'] ?? '');

    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nota == null ? 'Nueva Nota' : 'Editar Nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: contenidoController,
              decoration: const InputDecoration(labelText: 'Contenido'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (tituloController.text.isNotEmpty && contenidoController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'titulo': tituloController.text,
                  'contenido': contenidoController.text,
                });
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (resultado != null) {
      if (nota == null) {
        await crearNota(resultado['titulo']!, resultado['contenido']!);
      } else {
        await editarNota(nota['id'], resultado['titulo']!, resultado['contenido']!);
      }
      _cargarNotas();
    }
  }

  Future<void> _eliminarNota(int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Nota'),
        content: const Text('¿Estás seguro de que deseas eliminar esta nota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado == true) {
      await eliminarNota(id);
      _cargarNotas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    final tamanoAnimacion = anchoPantalla > 500 ? 90.0 : 60.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Bitácora')),
      drawer: const Menu(),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Card de emociones
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.surface
                        : const Color(0xFFF3F0FF),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _mensajeDia,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.primary
                                  : const Color(0xFF6C63FF),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 12,
                            children: List.generate(_emociones.length, (i) {
                              final emocion = _emociones[i];
                              final seleccionado = _emocionSeleccionada == i;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _emocionSeleccionada = i;
                                    _mensajeDia = "Hoy te sientes: ${emocion['label']}";
                                  });
                                  // Mostrar mensaje como SnackBar bonito y centrado
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              emocion['mensaje'],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Theme.of(context).colorScheme.surface,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                      ),
                                      duration: const Duration(seconds: 3),
                                      elevation: 8,
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: seleccionado
                                            ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        emocion['gif'],
                                        width: tamanoAnimacion,
                                        height: tamanoAnimacion,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      emocion['label'],
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Theme.of(context).colorScheme.primary
                                            : const Color(0xFF6C63FF),
                                        fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Bitácoras
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: _notas.isEmpty
                        ? const Center(child: Text('No hay notas aún.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _notas.length,
                            itemBuilder: (ctx, i) => GestureDetector(
                              onTap: () => _mostrarFormulario(nota: _notas[i]),
                              child: BitacoraItem(
                                titulo: _notas[i]['titulo'] ?? '',
                                contenido: _notas[i]['contenido'] ?? '',
                                fecha: (_notas[i]['fecha'] ?? '').toString().substring(0, 10),
                                onDelete: () async {
                                  await _eliminarNota(_notas[i]['id']);
                                },
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}