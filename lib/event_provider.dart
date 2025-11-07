import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String date;
  final String location;
  final String image;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.image,
  });
}

class EventProvider extends ChangeNotifier {
  final List<Event> _events = [];

  List<Event> get events => _events;

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void deleteEvent(Event event) {
    _events.remove(event);
    notifyListeners();
  }

  void updateEvent(Event updatedEvent) {
    final index = _events.indexWhere((event) => event.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
    }
  }
}

final eventProvider = EventProvider();