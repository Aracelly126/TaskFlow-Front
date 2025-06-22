import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tarea_provider.dart';
import '../widgets/tarea_item.dart';
import 'agregar_tarea_screen.dart';
import 'categorias_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tareas = Provider.of<TareaProvider>(context).tareas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 229, 200, 247)),
              child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Categorías'),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriasScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar sesión'),
              onTap: () {
               
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: tareas.isEmpty
          ? const Center(child: Text('No hay tareas aún.'))
          : ListView.builder(
              itemCount: tareas.length,
              itemBuilder: (ctx, i) => TareaItem(tarea: tareas[i]),
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