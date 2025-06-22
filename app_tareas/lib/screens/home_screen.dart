import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tarea_provider.dart';
import '../widgets/tarea_item.dart';
import 'agregar_tarea_screen.dart';
import '../widgets/menu.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tareas = Provider.of<TareaProvider>(context).tareas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
      ),
      drawer: const Menu(), 
      body: tareas.isEmpty
          ? const Center(child: Text('No hay tareas aún.'))
          : ListView.builder(
              itemCount: tareas.length,
              itemBuilder: (ctx, i) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 4,
                child: TareaItem(tarea: tareas[i]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgregarTareaScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}