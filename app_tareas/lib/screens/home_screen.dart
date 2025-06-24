import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tarea_provider.dart';
import '../widgets/tarea_item.dart';
import 'agregar_tarea_screen.dart';
import '../widgets/menu.dart';
import '../models/categoria.dart';
import '../services/categorias_service.dart';
import '../models/tarea.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _cargando = true;
  List<Categoria> _categorias = [];
  Categoria? _categoriaSeleccionada;
  String _filtroFecha = 'todas';
  String _filtroEstado = 'todas';
  bool _mostrarFiltros = false;
  String _busqueda = '';
  final TextEditingController _busquedaController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _cargarTareas();
    _cargarCategorias();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    if (_mostrarFiltros) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _cargarTareas() async {
    try {
      await Provider.of<TareaProvider>(context, listen: false).fetchTareas();
    } catch (e) {
      print('Error loading tasks: $e');
    }
    setState(() => _cargando = false);
  }

  Future<void> _cargarCategorias() async {
    try {
      final cats = await obtenerCategorias();
      setState(() {
        _categorias = cats;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  List<Tarea> _filtrarTareas(List<Tarea> tareas) {
    DateTime hoy = DateTime.now();
    List<Tarea> filtradas = tareas;
    if (_busqueda.isNotEmpty) {
      filtradas = filtradas
          .where(
            (t) =>
                t.titulo.toLowerCase().contains(_busqueda.toLowerCase()) ||
                t.descripcion.toLowerCase().contains(_busqueda.toLowerCase()),
          )
          .toList();
    }
    if (_categoriaSeleccionada != null) {
      filtradas = filtradas
          .where((t) => t.categoriaId == _categoriaSeleccionada!.id)
          .toList();
    }
    if (_filtroEstado != 'todas') {
      if (_filtroEstado == 'completadas') {
        filtradas = filtradas.where((t) => t.completada).toList();
      } else if (_filtroEstado == 'no_completadas') {
        filtradas = filtradas.where((t) => !t.completada).toList();
      }
    }
    if (_filtroFecha != 'todas') {
      if (_filtroFecha == 'hoy') {
        filtradas = filtradas
            .where(
              (t) =>
                  t.fecha.year == hoy.year &&
                  t.fecha.month == hoy.month &&
                  t.fecha.day == hoy.day,
            )
            .toList();
      } else if (_filtroFecha == 'proximas') {
        filtradas = filtradas
            .where(
              (t) => t.fecha.isAfter(DateTime(hoy.year, hoy.month, hoy.day)),
            )
            .toList();
      } else if (_filtroFecha == 'completadas_hoy') {
        filtradas = filtradas
            .where(
              (t) =>
                  t.completada &&
                  t.fecha.year == hoy.year &&
                  t.fecha.month == hoy.month &&
                  t.fecha.day == hoy.day,
            )
            .toList();
      }
    }
    return filtradas;
  }

  void _resetFiltros() {
    setState(() {
      _categoriaSeleccionada = null;
      _filtroFecha = 'todas';
      _filtroEstado = 'todas';
      _busqueda = '';
      _busquedaController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tareas = Provider.of<TareaProvider>(context).tareas;
    final tareasFiltradas = _filtrarTareas(tareas);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        backgroundColor: const Color(0xFFF3F0FF),
        actions: [
          IconButton(
            icon: Icon(
              _mostrarFiltros ? Icons.filter_alt_off : Icons.filter_alt,
              color: const Color(0xFF6C63FF),
            ),
            onPressed: () {
              setState(() {
                _mostrarFiltros = !_mostrarFiltros;
                print('Filter toggled to: $_mostrarFiltros'); // Debug
                _mostrarFiltros
                    ? _animationController.forward()
                    : _animationController.reverse();
              });
            },
          ),
        ],
      ),
      drawer: const Menu(),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TextField(
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      hintText: 'Buscar tarea...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
                      suffixIcon: _busqueda.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Color(0xFF6C63FF)),
                              onPressed: () {
                                setState(() {
                                  _busqueda = '';
                                  _busquedaController.clear();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _busqueda = value;
                      });
                    },
                  ),
                ),
                // Filter Panel
                SizeTransition(
                  sizeFactor: _animation,
                  axis: Axis.vertical,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F0FF),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filtros',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: const Color(0xFF6C63FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Category Filter
                              Text(
                                'Categoría',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF6C63FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _categorias.isEmpty
                                  ? const Text(
                                      'No hay categorías disponibles',
                                      style: TextStyle(color: Colors.grey),
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _buildCategoryChip(
                                            label: 'Todas',
                                            isSelected: _categoriaSeleccionada == null,
                                            onTap: () {
                                              setState(() => _categoriaSeleccionada = null);
                                            },
                                          ),
                                          ..._categorias.map(
                                            (cat) => _buildCategoryChip(
                                              label: cat.nombre,
                                              isSelected: _categoriaSeleccionada?.id == cat.id,
                                              onTap: () {
                                                setState(() => _categoriaSeleccionada = cat);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              const SizedBox(height: 16),
                              // State Filter
                              Text(
                                'Estado',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF6C63FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment(
                                      value: 'todas',
                                      label: Text('Todas'),
                                      icon: Icon(Icons.all_inclusive),
                                    ),
                                    ButtonSegment(
                                      value: 'completadas',
                                      label: Text('Completadas'),
                                      icon: Icon(Icons.check_circle),
                                    ),
                                    ButtonSegment(
                                      value: 'no_completadas',
                                      label: Text('Pendientes'),
                                      icon: Icon(Icons.radio_button_unchecked),
                                    ),
                                  ],
                                  selected: {_filtroEstado},
                                  onSelectionChanged: (newSelection) {
                                    setState(() {
                                      _filtroEstado = newSelection.first;
                                    });
                                  },
                                  style: SegmentedButton.styleFrom(
                                    selectedBackgroundColor: const Color(0xFF6C63FF),
                                    selectedForegroundColor: Colors.white,
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Date Filter
                              Text(
                                'Fecha',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF6C63FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment(
                                      value: 'todas',
                                      label: Text('Todas'),
                                      icon: Icon(Icons.calendar_month),
                                    ),
                                    ButtonSegment(
                                      value: 'hoy',
                                      label: Text('Hoy'),
                                      icon: Icon(Icons.today),
                                    ),
                                    ButtonSegment(
                                      value: 'proximas',
                                      label: Text('Próximas'),
                                      icon: Icon(Icons.event),
                                    ),
                                    ButtonSegment(
                                      value: 'completadas_hoy',
                                      label: Text('Completadas Hoy'),
                                      icon: Icon(Icons.done_all),
                                    ),
                                  ],
                                  selected: {_filtroFecha},
                                  onSelectionChanged: (newSelection) {
                                    setState(() {
                                      _filtroFecha = newSelection.first;
                                    });
                                  },
                                  style: SegmentedButton.styleFrom(
                                    selectedBackgroundColor: const Color(0xFF6C63FF),
                                    selectedForegroundColor: Colors.white,
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Reset Filters Button
                              Center(
                                child: TextButton.icon(
                                  onPressed: _resetFiltros,
                                  icon: const Icon(Icons.refresh, color: Color(0xFF6C63FF)),
                                  label: const Text(
                                    'Limpiar Filtros',
                                    style: TextStyle(color: Color(0xFF6C63FF)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Task List
                Expanded(
                  child: tareasFiltradas.isEmpty
                      ? const Center(
                          child: Text('No hay tareas para este filtro.'),
                        )
                      : ListView.builder(
                          itemCount: tareasFiltradas.length,
                          itemBuilder: (ctx, i) => Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TareaItem(tarea: tareasFiltradas[i]),
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgregarTareaScreen()),
          ).then((_) => _cargarTareas());
        },
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFFF3F0FF),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF6C63FF),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}