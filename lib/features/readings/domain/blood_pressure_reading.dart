class BloodPressureReading {
  String? id; // UUID from Supabase
  late String userId; // Foreign key to auth.users
  late int systolic;
  late int diastolic;
  late DateTime measuredAt;

  BloodPressureReading();

  factory BloodPressureReading.fromJson(Map<String, dynamic> json) {
    return BloodPressureReading()
      ..id = json['id'] as String
      ..userId = json['user_id'] as String
      ..systolic = json['systolic'] as int
      ..diastolic = json['diastolic'] as int
      ..measuredAt = DateTime.parse(json['measured_at'] as String).toLocal();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      // We don't include 'id' here for inserts, Supabase generates it.
      // If updating, include it.
      'user_id': userId,
      'systolic': systolic,
      'diastolic': diastolic,
      'measured_at': measuredAt.toUtc().toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
