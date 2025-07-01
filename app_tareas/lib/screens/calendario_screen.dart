import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/tareas_service.dart';
import '../models/tarea.dart';
import '../widgets/tarea_item.dart';
import '../widgets/menu.dart';
import '../widgets/empty_state_widget.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  Map<DateTime, List<Tarea>> tareasPorFecha = {};
  List<Tarea> tareasDelDia = [];
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _focusedDay = DateTime(hoy.year, hoy.month, hoy.day);
    _selectedDay = _focusedDay;
    cargarTareas();
  }

  Future<void> cargarTareas() async {
    final tareas = await obtenerTareas();
    final map = <DateTime, List<Tarea>>{};
    for (var tarea in tareas) {
      final fecha = DateTime(tarea.fecha.year, tarea.fecha.month, tarea.fecha.day);
      map.putIfAbsent(fecha, () => []).add(tarea);
    }
    setState(() {
      tareasPorFecha = map;
      tareasDelDia = map[_selectedDay] ?? [];
      cargando = false;
    });
  }

  List<Tarea> _getTareasParaDia(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return tareasPorFecha[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const Menu(),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar<Tarea>(
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getTareasParaDia,
                  calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    final dia = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                    setState(() {
                      _selectedDay = dia;
                      _focusedDay = dia;
                      tareasDelDia = _getTareasParaDia(dia);
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tareas para el ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: tareasDelDia.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.event_note_outlined,
                          title: 'Sin tareas para este día',
                          message: 'No tienes tareas programadas para el ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}.\n¡Disfruta tu día libre!',
                        )
                      : ListView.builder(
                          itemCount: tareasDelDia.length,
                          itemBuilder: (ctx, i) => TareaItem(tarea: tareasDelDia[i]),
                        ),
                ),
              ],
            ),
    );
  }
}