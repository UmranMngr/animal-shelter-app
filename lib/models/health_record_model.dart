class HealthRecordModel {
  final String id;
  final String animalId;
  final String description;
  final DateTime? treatmentDate;

  HealthRecordModel({
    required this.id,
    required this.animalId,
    required this.description,
    this.treatmentDate,
  });

  factory HealthRecordModel.fromMap(Map<String, dynamic> map) {
    return HealthRecordModel(
      id: map['id']?.toString() ?? '',
      animalId: map['animal_id']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      treatmentDate:
          map['treatment_date'] != null
              ? DateTime.tryParse(map['treatment_date'].toString())
              : null,
    );
  }
}
