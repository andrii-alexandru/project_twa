class FavoriteBreed {
  final int id;
  final String breedName;

  FavoriteBreed({required this.id, required this.breedName});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'breedName': breedName,
    };
  }
}
