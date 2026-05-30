class AdoptionModel {
  final String id;
  final String userId;
  final String animalId;
  final String status;
  final String? message;

  AdoptionModel({
    required this.id,
    required this.userId,
    required this.animalId,
    required this.status,
    this.message,
  });

  factory AdoptionModel.fromMap(Map<String, dynamic> map) {
    return AdoptionModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      animalId: map['animal_id']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      message: map['message']?.toString(),
    );
  }
}
