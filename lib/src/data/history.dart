import 'dart:collection';

final class History<EventTypeT extends Object> {
  final ListQueue<EventTypeT> undoStack = ListQueue<EventTypeT>();
  final ListQueue<EventTypeT> redoStack = ListQueue<EventTypeT>();
}
