import 'package:flutter/material.dart';

class NotaForm extends StatefulWidget {
  final String? tituloInicial;
  final String? contenidoInicial;

  const NotaForm({super.key, this.tituloInicial, this.contenidoInicial});

  @override
  State<NotaForm> createState() => _NotaFormState();
}

class _NotaFormState extends State<NotaForm> {
  late TextEditingController _tituloController;
  late TextEditingController _contenidoController;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.tituloInicial ?? '');
    _contenidoController = TextEditingController(text: widget.contenidoInicial ?? '');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tituloInicial == null ? 'Nueva Nota' : 'Editar Nota'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _tituloController,
            decoration: const InputDecoration(labelText: 'Título'),
          ),
          TextField(
            controller: _contenidoController,
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
            if (_tituloController.text.isNotEmpty && _contenidoController.text.isNotEmpty) {
              Navigator.pop(context, {
                'titulo': _tituloController.text,
                'contenido': _contenidoController.text,
              });
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}