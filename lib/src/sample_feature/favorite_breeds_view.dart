import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/database_helper.dart';
import 'sample_item_details_view.dart';
import '../sample_feature/favorite_breed.dart';

class FavoriteBreedsView extends StatefulWidget {
  const FavoriteBreedsView({super.key});

  static const routeName = '/favorites';

  @override
  FavoriteBreedsViewState createState() => FavoriteBreedsViewState();
}

class FavoriteBreedsViewState extends State<FavoriteBreedsView> {
  late Future<List<FavoriteBreed>> futureFavorites;

  @override
  void initState() {
    super.initState();
    futureFavorites = DatabaseHelper().getFavorites();
  }

  Future<String> fetchBreedImage(String breed) async {
    final response = await http
        .get(Uri.parse('https://dog.ceo/api/breed/$breed/images/random'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['message'];
    } else {
      throw Exception('Failed to load breed image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Breeds'),
      ),
      body: FutureBuilder<List<FavoriteBreed>>(
        future: futureFavorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Display loading indicator while waiting
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Display errors
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            // Check if the data is empty
            return const Center(child: Text('No favorites added'));
          } else if (snapshot.hasData) {
            // Data exists and is not empty
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final breed = snapshot.data![index];
                return ListTile(
                  title: Text(breed.breedName),
                  leading: FutureBuilder<String>(
                    future: fetchBreedImage(breed.breedName.toLowerCase()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: const CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasData) {
                        return CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data!),
                        );
                      } else {
                        return CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: const Text(
                              "N/A"), // Example if no image is available
                        );
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SampleItemDetailsView(breedName: breed.breedName),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            // This block handles the scenario where data is not null but somehow not caught by other checks.
            return const Center(child: Text('No favorites added'));
          }
        },
      ),
    );
  }
}
