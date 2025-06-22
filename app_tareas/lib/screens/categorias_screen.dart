import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../services/categorias_service.dart';

// Listas de colores e íconos sugeridos
final List<Color> coloresDisponibles = [
  Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.brown, Colors.yellow, Colors.grey
];

final List<IconData> iconosDisponibles = [
  Icons.category, Icons.star, Icons.work, Icons.home, Icons.school, Icons.favorite, Icons.shopping_cart, Icons.pets
];

// Función para parsear color seguro
Color _parseColor(String colorStr) {
  try {
    return Color(int.parse(colorStr.replaceFirst('#', '0xff')));
  } catch (_) {
    return Colors.blue; // Color por defecto si hay error
  }
}

// Función para parsear ícono seguro
IconData _parseIcon(String iconStr) {
  try {
    return IconData(int.parse(iconStr), fontFamily: 'MaterialIcons');
  } catch (_) {
    return Icons.category; // Ícono por defecto si hay error
  }
}

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  List<Categoria> categorias = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    categorias = await obtenerCategorias();
    setState(() => loading = false);
  }

  void _mostrarDialogoCategoria({Categoria? categoria}) {
    final nombreController = TextEditingController(text: categoria?.nombre ?? '');
    Color colorSeleccionado = categoria != null
        ? _parseColor(categoria.color)
        : coloresDisponibles.first;
    IconData iconoSeleccionado = categoria != null
        ? _parseIcon(categoria.icono)
        : iconosDisponibles.first;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(categoria == null ? 'Nueva Categoría' : 'Editar Categoría'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                // Selector de color
                Wrap(
                  spacing: 8,
                  children: coloresDisponibles.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => colorSeleccionado = color);
                      },
                      child: CircleAvatar(
                        backgroundColor: color,
                        child: colorSeleccionado == color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                // Selector de ícono
                Wrap(
                  spacing: 8,
                  children: iconosDisponibles.map((icono) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => iconoSeleccionado = icono);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: Icon(
                          icono,
                          color: iconoSeleccionado == icono ? Colors.blue : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nombreController.text.isEmpty) return;
                final colorHex = '#${colorSeleccionado.value.toRadixString(16).substring(2)}';
                final iconoStr = iconoSeleccionado.codePoint.toString();
                if (categoria == null) {
                  await crearCategoria(nombreController.text, colorHex, iconoStr);
                } else {
                  await editarCategoria(categoria.id, nombreController.text, colorHex, iconoStr);
                }
                Navigator.pop(context);
                cargarCategorias();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _eliminarCategoria(int id) async {
    final ok = await eliminarCategoria(id);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede eliminar la categoría (puede tener tareas)')),
      );
    }
    cargarCategorias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categorias.length,
              itemBuilder: (ctx, i) {
                final cat = categorias[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _parseColor(cat.color),
                    child: Icon(
                      _parseIcon(cat.icono),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(cat.nombre),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _mostrarDialogoCategoria(categoria: cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _eliminarCategoria(cat.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCategoria(),
        child: const Icon(Icons.add),
      ),
    );
  }
}