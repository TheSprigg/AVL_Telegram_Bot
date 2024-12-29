enum GarbageType { yellow, paper, other, glass, bio }

class GarbageTypeName {
  static final Map<GarbageType, String> _garbageTypeName = {
    GarbageType.yellow: 'Gelber Sack',
    GarbageType.paper: 'Papier',
    GarbageType.glass: 'Glas',
    GarbageType.other: 'Restmüll',
    GarbageType.bio: 'Biomüll'
  };

  static String getName(GarbageType type) {
    return _garbageTypeName[type] ?? 'Typ nicht gefunden';
  }
}
