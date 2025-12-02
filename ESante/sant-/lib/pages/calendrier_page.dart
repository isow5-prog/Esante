import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendrierPage extends StatefulWidget {
  final DateTime? initialDate;
  final String? eventType; // 'consultation', 'vaccin', 'examen'

  const CalendrierPage({
    super.key,
    this.initialDate,
    this.eventType,
  });

  @override
  State<CalendrierPage> createState() => _CalendrierPageState();
}

enum _ViewMode { calendar, past, upcoming }

class _CalendrierPageState extends State<CalendrierPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  _ViewMode _currentView = _ViewMode.calendar;

  // Événements du calendrier (créés par l'agent de santé)
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    // RDV précédents (2025 - passés, dates plus anciennes pour être sûrs qu'elles sont passées)
    DateTime(2025, 3, 5): [
      {
        'id': 1,
        'title': 'CPN 1',
        'time': '10:00',
        'type': 'consultation',
        'color': Colors.blue,
        'lieu': 'Centre de santé de Dakar',
        'confirme': true,
      },
    ],
    DateTime(2025, 3, 15): [
      {
        'id': 2,
        'title': 'Vaccin 1',
        'time': '14:00',
        'type': 'vaccin',
        'color': Colors.orange,
        'lieu': 'Centre de santé de Dakar',
        'confirme': true,
      },
    ],
    DateTime(2025, 4, 10): [
      {
        'id': 3,
        'title': 'Échographie 1',
        'time': '09:00',
        'type': 'examen',
        'color': Colors.purple,
        'lieu': 'Hôpital Principal',
        'confirme': true,
      },
    ],
    DateTime(2025, 4, 25): [
      {
        'id': 4,
        'title': 'CPN 2',
        'time': '11:00',
        'type': 'consultation',
        'color': Colors.blue,
        'lieu': 'Centre de santé de Dakar',
        'confirme': true,
      },
    ],
    // RDV prochains (2026 - futurs)
    DateTime(2026, 1, 5): [
      {
        'id': 5,
        'title': 'CPN 3',
        'time': '10:00',
        'type': 'consultation',
        'color': Colors.blue,
        'lieu': 'Centre de santé de Dakar',
        'confirme': false,
      },
    ],
    DateTime(2026, 1, 15): [
      {
        'id': 6,
        'title': 'Vaccin 2',
        'time': '15:30',
        'type': 'vaccin',
        'color': Colors.orange,
        'lieu': 'Centre de santé de Dakar',
        'confirme': false,
      },
    ],
    DateTime(2026, 1, 28): [
      {
        'id': 7,
        'title': 'Échographie 2',
        'time': '10:30',
        'type': 'examen',
        'color': Colors.purple,
        'lieu': 'Hôpital Principal',
        'confirme': false,
      },
    ],
    DateTime(2026, 2, 10): [
      {
        'id': 8,
        'title': 'CPN 4',
        'time': '09:00',
        'type': 'consultation',
        'color': Colors.blue,
        'lieu': 'Centre de santé de Dakar',
        'confirme': false,
      },
    ],
  };

  void _confirmerPresence(int eventId) {
    setState(() {
      // Trouver l'événement dans tous les jours
      for (var dayEvents in _events.values) {
        for (var event in dayEvents) {
          if (event['id'] == eventId) {
            event['confirme'] = true;
            break;
          }
        }
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Présence confirmée'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Si une date initiale est fournie, l'utiliser, sinon utiliser aujourd'hui
    final initialDate = widget.initialDate ?? DateTime.now();
    _focusedDay = initialDate;
    _selectedDay = initialDate;
    
    // Si un type d'événement est spécifié, trouver la date correspondante
    if (widget.eventType != null) {
      _findAndSelectEventDate(widget.eventType!);
    }
  }

  void _findAndSelectEventDate(String eventType) {
    // Chercher la date correspondant au type d'événement dans les RDV PROCHAINS uniquement
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Chercher uniquement dans les événements futurs (RDV prochains en 2026)
    // Ne pas chercher dans les événements passés (RDV précédents en 2025)
    for (var entry in _events.entries) {
      final eventDate = DateTime(entry.key.year, entry.key.month, entry.key.day);
      // Ne prendre que les événements futurs (>= aujourd'hui)
      if (eventDate.compareTo(today) >= 0) {
        for (var event in entry.value) {
          if (event['type'] == eventType) {
            setState(() {
              _selectedDay = entry.key;
              _focusedDay = entry.key;
              // Basculer sur la vue calendrier pour voir l'événement
              _currentView = _ViewMode.calendar;
            });
            return;
          }
        }
      }
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  // Obtenir tous les événements passés
  List<Map<String, dynamic>> _getPastEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> pastEvents = [];

    for (var entry in _events.entries) {
      final eventDate = DateTime(entry.key.year, entry.key.month, entry.key.day);
      // Comparer les dates normalisées (sans heures/minutes/secondes)
      final comparison = eventDate.compareTo(today);
      // Si la date est < aujourd'hui, c'est un événement passé
      if (comparison < 0) {
        for (var event in entry.value) {
          pastEvents.add({
            ...event,
            'date': entry.key,
          });
        }
      }
    }

    // Trier par date décroissante (plus récent en premier)
    pastEvents.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      final normalizedA = DateTime(dateA.year, dateA.month, dateA.day);
      final normalizedB = DateTime(dateB.year, dateB.month, dateB.day);
      return normalizedB.compareTo(normalizedA);
    });

    return pastEvents;
  }

  // Obtenir tous les événements à venir
  List<Map<String, dynamic>> _getUpcomingEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<Map<String, dynamic>> upcomingEvents = [];

    for (var entry in _events.entries) {
      final eventDate = DateTime(entry.key.year, entry.key.month, entry.key.day);
      // Comparer les dates normalisées (sans heures/minutes/secondes)
      final comparison = eventDate.compareTo(today);
      // Si la date est >= aujourd'hui, c'est un événement à venir
      if (comparison >= 0) {
        for (var event in entry.value) {
          upcomingEvents.add({
            ...event,
            'date': entry.key,
          });
        }
      }
    }

    // Trier par date croissante (plus proche en premier)
    upcomingEvents.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      final normalizedA = DateTime(dateA.year, dateA.month, dateA.day);
      final normalizedB = DateTime(dateB.year, dateB.month, dateB.day);
      return normalizedA.compareTo(normalizedB);
    });

    return upcomingEvents;
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        backgroundColor: const Color(0xFF0A7A33),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Calendrier',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: Colors.white),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            tooltip: "Aujourd'hui",
          ),
        ],
      ),
      body: Column(
        children: [
          // Boutons de navigation
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _ViewButton(
                    label: 'Calendrier',
                    icon: Icons.calendar_today,
                    isActive: _currentView == _ViewMode.calendar,
                    onTap: () {
                      setState(() {
                        _currentView = _ViewMode.calendar;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ViewButton(
                    label: 'RDV précédents',
                    icon: Icons.history,
                    isActive: _currentView == _ViewMode.past,
                    onTap: () {
                      setState(() {
                        _currentView = _ViewMode.past;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ViewButton(
                    label: 'RDV prochains',
                    icon: Icons.upcoming,
                    isActive: _currentView == _ViewMode.upcoming,
                    onTap: () {
                      setState(() {
                        _currentView = _ViewMode.upcoming;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Calendrier (affiché seulement en mode calendrier)
          if (_currentView == _ViewMode.calendar)
            Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.red[300]),
                selectedDecoration: BoxDecoration(
                  color: const Color(0xFF0A7A33),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF1AAA42).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: const Color(0xFF0A7A33),
                  borderRadius: BorderRadius.circular(8),
                ),
                formatButtonTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF0A7A33),
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF0A7A33),
                ),
                titleTextStyle: const TextStyle(
                  color: Color(0xFF0A7A33),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),

          // Liste des événements selon la vue
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _buildEventsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    if (_currentView == _ViewMode.calendar) {
      final selectedEvents = _getEventsForDay(_selectedDay);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A7A33).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event,
                    color: Color(0xFF0A7A33),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDay.day == DateTime.now().day &&
                          _selectedDay.month == DateTime.now().month &&
                          _selectedDay.year == DateTime.now().year
                      ? "Aujourd'hui"
                      : _getFormattedDate(_selectedDay),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun événement prévu',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = selectedEvents[index];
                      return _EventCard(
                        event: event,
                        onConfirmer: () => _confirmerPresence(event['id'] as int),
                      );
                    },
                  ),
          ),
        ],
      );
    } else if (_currentView == _ViewMode.past) {
      final pastEvents = _getPastEvents();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mes RDV précédents (${pastEvents.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: pastEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun rendez-vous passé',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: pastEvents.length,
                    itemBuilder: (context, index) {
                      final event = pastEvents[index];
                      return _EventCardWithDate(
                        event: event,
                        eventDate: event['date'] as DateTime,
                        onConfirmer: () => _confirmerPresence(event['id'] as int),
                      );
                    },
                  ),
          ),
        ],
      );
    } else {
      // _ViewMode.upcoming
      final upcomingEvents = _getUpcomingEvents();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1AAA42).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.upcoming,
                    color: Color(0xFF1AAA42),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mes RDV prochains (${upcomingEvents.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: upcomingEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun rendez-vous à venir',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: upcomingEvents.length,
                    itemBuilder: (context, index) {
                      final event = upcomingEvents[index];
                      return _EventCardWithDate(
                        event: event,
                        eventDate: event['date'] as DateTime,
                        onConfirmer: () => _confirmerPresence(event['id'] as int),
                      );
                    },
                  ),
          ),
        ],
      );
    }
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onConfirmer;

  const _EventCard({
    required this.event,
    required this.onConfirmer,
  });

  @override
  Widget build(BuildContext context) {
    final color = event['color'] as Color;
    
    IconData icon;
    if (event['type'] == 'consultation') {
      icon = Icons.medical_services;
    } else if (event['type'] == 'vaccin') {
      icon = Icons.vaccines;
    } else {
      icon = Icons.medical_information;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      event['time'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Inter',
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (event['lieu'] != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event['lieu'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getTypeLabel(event['type'] as String),
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Inter',
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    if (event['confirme'] == true) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 12, color: Colors.green),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Confirmé',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (event['confirme'] == false)
            Flexible(
              child: ElevatedButton(
                onPressed: onConfirmer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirmer',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          else
            Icon(Icons.check_circle, color: Colors.green, size: 24),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'consultation':
        return 'Consultation';
      case 'vaccin':
        return 'Vaccin';
      case 'examen':
        return 'Examen';
      case 'rappel':
        return 'Rappel';
      default:
        return type;
    }
  }
}

// Widget pour les boutons de navigation entre les vues
class _ViewButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF0A7A33)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontFamily: 'Inter',
                  color: isActive ? Colors.white : Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour les cartes d'événements avec date (pour les listes passées/prochaines)
class _EventCardWithDate extends StatelessWidget {
  final Map<String, dynamic> event;
  final DateTime eventDate;
  final VoidCallback onConfirmer;

  const _EventCardWithDate({
    required this.event,
    required this.eventDate,
    required this.onConfirmer,
  });

  String _getFormattedDate(DateTime date) {
    final months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = event['color'] as Color;
    
    IconData icon;
    if (event['type'] == 'consultation') {
      icon = Icons.medical_services;
    } else if (event['type'] == 'vaccin') {
      icon = Icons.vaccines;
    } else {
      icon = Icons.medical_information;
    }

    final isPast = eventDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getFormattedDate(eventDate),
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Inter',
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event['time'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Inter',
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (event['lieu'] != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event['lieu'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getTypeLabel(event['type'] as String),
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'Inter',
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    if (event['confirme'] == true) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, size: 12, color: Colors.green),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Confirmé',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (event['confirme'] == false && !isPast)
            Flexible(
              child: ElevatedButton(
                onPressed: onConfirmer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirmer',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          else if (event['confirme'] == true)
            Icon(Icons.check_circle, color: Colors.green, size: 24),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'consultation':
        return 'Consultation';
      case 'vaccin':
        return 'Vaccin';
      case 'examen':
        return 'Examen';
      case 'rappel':
        return 'Rappel';
      default:
        return type;
    }
  }
}

