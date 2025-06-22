import 'package:flutter/material.dart';
import '../models/categoria.dart';

class CategoriaItem extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback? onDelete;

  const CategoriaItem({
    super.key,
    required this.categoria,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(int.parse(categoria.color.replaceFirst('#', '0xff'))),
        child: Icon(Icons.category),
      ),
      title: Text(categoria.nombre),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
      ),
    );
  }
}