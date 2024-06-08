class FavoriteBreed {
  final String breedName;

  FavoriteBreed({required this.breedName});

  Map<String, dynamic> toMap() {
    return {
      'breedName': breedName,
    };
  }
}
