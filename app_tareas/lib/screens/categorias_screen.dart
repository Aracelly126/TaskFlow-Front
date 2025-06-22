import 'package:flutter/material.dart';
import '../services/categorias_service.dart';
import '../widgets/categoria_item.dart';
import '../models/categoria.dart'; // Importa el modelo

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  List<Categoria> categorias = []; // Tipado correcto
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    final cats = await obtenerCategorias();
    setState(() {
      categorias = cats;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : categorias.isEmpty
              ? const Center(child: Text('No hay categorías.'))
              : ListView.builder(
                  itemCount: categorias.length,
                  itemBuilder: (ctx, i) => CategoriaItem(
                    categoria: categorias[i],
                    onDelete: () async {
                      // await eliminarCategoria(categorias[i].id);
                      // await cargarCategorias();
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí puedes abrir un formulario para agregar una nueva categoría
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}