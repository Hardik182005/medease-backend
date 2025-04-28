class ReminderModel {
  final String? id;
  final String medicineName;
  final String unit;
  final String frequency;
  final List<String> times;
  final List<String> instructions;
  final int dose;
  final int? intervalHours;
  final List<String> daysOfWeek;
  final Map<String, int>? cyclicPattern;

  final int? cycleIntakeDays;
  final int? cyclePauseDays;

  final bool? remindInventory;
  final String? refillReminderDay;
  final String? treatmentDuration;
  final DateTime? treatmentEndDate;

  final String? status;
  final String? statusUpdatedAt;
  final String? createdAt;
  final String? updatedAt; // ✅ Optional new field for tracking changes

  final String? fcmToken;

  ReminderModel({
    this.id,
    required this.medicineName,
    required this.unit,
    required this.frequency,
    this.times = const [],
    this.instructions = const [],
    this.dose = 1,
    this.intervalHours,
    this.daysOfWeek = const [],
    this.cyclicPattern,
    this.cycleIntakeDays,
    this.cyclePauseDays,
    this.remindInventory,
    this.refillReminderDay,
    this.treatmentDuration,
    this.treatmentEndDate,
    this.status,
    this.statusUpdatedAt,
    this.createdAt,
    this.updatedAt,
    this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'unit': unit,
      'frequency': frequency,
      'times': times,
      'instructions': instructions,
      'dose': dose,
      'intervalHours': intervalHours,
      'daysOfWeek': daysOfWeek,
      'cyclicPattern': cyclicPattern,
      'cycleIntakeDays': cycleIntakeDays,
      'cyclePauseDays': cyclePauseDays,
      'remindInventory': remindInventory,
      'refillReminderDay': refillReminderDay,
      'treatmentDuration': treatmentDuration,
      'treatmentEndDate': treatmentEndDate?.toIso8601String(),
      'status': status,
      'statusUpdatedAt': statusUpdatedAt,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
      'updatedAt': updatedAt ?? DateTime.now().toIso8601String(), // ✅
      'fcmToken': fcmToken,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ReminderModel(
      id: id,
      medicineName: map['medicineName'] ?? '',
      unit: map['unit'] ?? '',
      frequency: map['frequency'] ?? '',
      times: map['times'] != null ? List<String>.from(map['times']) : [],
      instructions: map['instructions'] != null ? List<String>.from(map['instructions']) : [],
      dose: map['dose'] ?? 1,
      intervalHours: map['intervalHours'],
      daysOfWeek: map['daysOfWeek'] != null ? List<String>.from(map['daysOfWeek']) : [],
      cyclicPattern: map['cyclicPattern'] != null ? Map<String, int>.from(map['cyclicPattern']) : null,
      cycleIntakeDays: map['cycleIntakeDays'],
      cyclePauseDays: map['cyclePauseDays'],
      remindInventory: map['remindInventory'],
      refillReminderDay: map['refillReminderDay'],
      treatmentDuration: map['treatmentDuration'],
      treatmentEndDate: map['treatmentEndDate'] != null
          ? DateTime.tryParse(map['treatmentEndDate'])
          : null,
      status: map['status'],
      statusUpdatedAt: map['statusUpdatedAt'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'], // ✅
      fcmToken: map['fcmToken'],
    );
  }

  ReminderModel copyWith({
    String? id,
    String? medicineName,
    String? unit,
    String? frequency,
    List<String>? times,
    List<String>? instructions,
    int? dose,
    int? intervalHours,
    List<String>? daysOfWeek,
    Map<String, int>? cyclicPattern,
    int? cycleIntakeDays,
    int? cyclePauseDays,
    bool? remindInventory,
    String? refillReminderDay,
    String? treatmentDuration,
    DateTime? treatmentEndDate,
    String? status,
    String? statusUpdatedAt,
    String? createdAt,
    String? updatedAt, // ✅
    String? fcmToken,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      unit: unit ?? this.unit,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      instructions: instructions ?? this.instructions,
      dose: dose ?? this.dose,
      intervalHours: intervalHours ?? this.intervalHours,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      cyclicPattern: cyclicPattern ?? this.cyclicPattern,
      cycleIntakeDays: cycleIntakeDays ?? this.cycleIntakeDays,
      cyclePauseDays: cyclePauseDays ?? this.cyclePauseDays,
      remindInventory: remindInventory ?? this.remindInventory,
      refillReminderDay: refillReminderDay ?? this.refillReminderDay,
      treatmentDuration: treatmentDuration ?? this.treatmentDuration,
      treatmentEndDate: treatmentEndDate ?? this.treatmentEndDate,
      status: status ?? this.status,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt, // ✅
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
