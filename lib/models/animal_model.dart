class AnimalModel {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final int age;
  final String gender;
  final String description;
  final String? imageUrl;
  final String status;
  final bool isSpayed; // YENİ EKLENDİ

  AnimalModel({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    required this.age,
    required this.gender,
    required this.description,
    this.imageUrl,
    this.status = 'available',
    this.isSpayed = false, // YENİ EKLENDİ
  });

  factory AnimalModel.fromMap(Map<String, dynamic> map) {
    return AnimalModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      species: map['species']?.toString() ?? '',
      breed: map['breed']?.toString(),
      age: int.tryParse(map['age']?.toString() ?? '0') ?? 0,
      gender: map['gender']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      imageUrl: map['image_url']?.toString(),
      status: map['status']?.toString() ?? 'available',
      isSpayed: map['is_spayed'] == true, // YENİ EKLENDİ
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'gender': gender,
      'description': description,
      'image_url': imageUrl,
      'status': status,
      'is_spayed': isSpayed, // YENİ EKLENDİ
    };
  }
}
