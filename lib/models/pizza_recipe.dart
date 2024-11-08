enum PizzaType { neapolitan, pan }
enum YeastType { active, instant }
enum PrefermentType {
  biga('A stiff pre-ferment with 50-55% hydration, great for natural sweetness'),
  poolish('A liquid pre-ferment with 100% hydration, enhances extensibility');

  final String description;
  const PrefermentType(this.description);

  String get displayName {
    switch (this) {
      case PrefermentType.biga:
        return 'Biga';
      case PrefermentType.poolish:
        return 'Poolish';
    }
  }
}

class PizzaDoughRecipe {
  final int? id;
  String name;
  final int doughBalls;
  final int ballWeight;
  final int hydration;
  final double saltPercentage;
  final double yeastPercentage;
  final double? sugarPercentage;
  final double? fatPercentage;
  final double roomTemp;
  final int roomTempHours;
  final double? controlledTemp;
  final int? controlledTempHours;
  final bool isMultiStage;
  final bool hasSugar;
  final bool hasFat;
  final YeastType yeastType;
  final bool hasPreferment;
  final PrefermentType prefermentType;
  final int prefermentPercentage;
  final int prefermentHours;
  final bool hasTangzhong;
  final PizzaType pizzaType;
  final String notes;

  PizzaDoughRecipe({
    this.id,
    required this.name,
    required this.doughBalls,
    required this.ballWeight,
    required this.hydration,
    required this.saltPercentage,
    this.yeastPercentage = 0.3,
    this.sugarPercentage,
    this.fatPercentage,
    required this.roomTemp,
    required this.roomTempHours,
    this.controlledTemp,
    this.controlledTempHours,
    required this.isMultiStage,
    required this.hasSugar,
    required this.hasFat,
    required this.yeastType,
    required this.hasPreferment,
    required this.prefermentType,
    required this.prefermentPercentage,
    required this.prefermentHours,
    required this.hasTangzhong,
    required this.pizzaType,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'doughBalls': doughBalls,
      'ballWeight': ballWeight,
      'hydration': hydration,
      'saltPercentage': saltPercentage,
      'yeastPercentage': yeastPercentage,
      'sugarPercentage': sugarPercentage,
      'fatPercentage': fatPercentage,
      'roomTemp': roomTemp,
      'roomTempHours': roomTempHours,
      'controlledTemp': controlledTemp,
      'controlledTempHours': controlledTempHours,
      'isMultiStage': isMultiStage ? 1 : 0,
      'hasSugar': hasSugar ? 1 : 0,
      'hasFat': hasFat ? 1 : 0,
      'yeastType': yeastType.index,
      'hasPreferment': hasPreferment ? 1 : 0,
      'prefermentType': prefermentType.index,
      'prefermentPercentage': prefermentPercentage,
      'prefermentHours': prefermentHours,
      'hasTangzhong': hasTangzhong ? 1 : 0,
      'pizzaType': pizzaType.index,
      'notes': notes,
    };
  }

  factory PizzaDoughRecipe.fromMap(Map<String, dynamic> map) {
    return PizzaDoughRecipe(
      id: map['id'],
      name: map['name'],
      doughBalls: map['doughBalls'],
      ballWeight: map['ballWeight'],
      hydration: map['hydration'],
      saltPercentage: map['saltPercentage'],
      yeastPercentage: map['yeastPercentage'],
      sugarPercentage: map['sugarPercentage'],
      fatPercentage: map['fatPercentage'],
      roomTemp: map['roomTemp'],
      roomTempHours: map['roomTempHours'],
      controlledTemp: map['controlledTemp'],
      controlledTempHours: map['controlledTempHours'],
      isMultiStage: map['isMultiStage'] == 1,
      hasSugar: map['hasSugar'] == 1,
      hasFat: map['hasFat'] == 1,
      yeastType: YeastType.values[map['yeastType']],
      hasPreferment: map['hasPreferment'] == 1,
      prefermentType: PrefermentType.values[map['prefermentType']],
      prefermentPercentage: map['prefermentPercentage'],
      prefermentHours: map['prefermentHours'],
      hasTangzhong: map['hasTangzhong'] == 1,
      pizzaType: PizzaType.values[map['pizzaType']],
      notes: map['notes'],
    );
  }
}