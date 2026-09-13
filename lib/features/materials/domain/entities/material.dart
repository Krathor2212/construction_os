class Material {
  const Material({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    this.description,
    this.isActive = true,
  });

  final String id;
  final String name;
  final MaterialCategory category;
  final MaterialUnit unit;
  final String? description;
  final bool isActive;
}

enum MaterialCategory {
  cement,
  steel,
  sand,
  aggregate,
  bricks,
  blocks,
  electrical,
  plumbing,
  flooring,
  paint,
  wood,
  hardware,
  other,
}

enum MaterialUnit {
  kg,
  tonne,
  bag,
  piece,
  cubicMeter,
  squareMeter,
  liter,
  meter,
  box,
  set,
  other,
}