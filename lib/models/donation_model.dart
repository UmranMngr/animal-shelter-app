class DonationModel {
  final String id;
  final String userId;
  final String donationType;
  final double amount;
  final int count;
  final String? animalName; // YENİ EKLENDİ

  DonationModel({
    required this.id,
    required this.userId,
    required this.donationType,
    required this.amount,
    required this.count,
    this.animalName, // YENİ EKLENDİ
  });

  factory DonationModel.fromMap(Map<String, dynamic> map) {
    return DonationModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      donationType: map['donation_type']?.toString() ?? '',
      amount: double.tryParse(map['amount'].toString()) ?? 0,
      count: int.tryParse(map['count'].toString()) ?? 1,
      animalName: map['animal_name']?.toString(), // YENİ EKLENDİ
    );
  }
}
