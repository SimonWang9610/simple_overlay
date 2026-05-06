final class ZIndexManager {
  static const _lowest = -1;

  final Map<Object, int> _zIndices = {};
  List<Object>? _zIndexOrder;

  int _highest = 0;
  int _next() => ++_highest;

  bool _dirty = false;

  bool atTop(Object id) {
    return _zIndices[id] == _highest;
  }

  bool upgrade(Object id) {
    final current = _zIndices[id];
    if (current == _highest) return false;

    _zIndices[id] = _next();
    _dirty = true;

    return true;
  }

  bool downgrade(Object id) {
    final current = _zIndices[id];
    if (current == _lowest) return false;

    _zIndices[id] = _lowest;
    _dirty = true;

    return true;
  }

  bool remove(Object id) {
    final removed = _zIndices.remove(id);

    if (removed == null) return false;

    if (removed == _highest) {
      _highest = _zIndices.values.fold(0, (prev, element) => element > prev ? element : prev);
    }

    _dirty = true;
    return true;
  }

  void reset() {
    _dirty = false;
    _zIndexOrder = null;
    _zIndices.clear();
    _highest = 0;
  }

  bool hasValidIndex(Object id) => _zIndices.containsKey(id) && _zIndices[id]! > _lowest;

  Iterable<Object> get ordered {
    if (!_dirty && _zIndexOrder != null) {
      return _zIndexOrder!;
    }

    final entries = _zIndices.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
    _zIndexOrder = List.unmodifiable(entries.map((e) => e.key));

    _dirty = false;

    return _zIndexOrder!;
  }
}
