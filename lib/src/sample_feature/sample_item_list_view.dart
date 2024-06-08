import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../settings/settings_view.dart';
import '../sample_feature/favorite_breed.dart';
import 'data_search.dart';
import 'sample_item_details_view.dart';
import '../helpers/database_helper.dart';

class Breed {
  final String name;
  final String imageUrl;

  Breed({required this.name, required this.imageUrl});

  factory Breed.fromJson(String name, String imageUrl) {
    return Breed(name: name, imageUrl: imageUrl);
  }
}

class SampleItemListView extends StatefulWidget {
  const SampleItemListView({super.key});

  static const routeName = '/';

  @override
  _SampleItemListViewState createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  late Future<List<Breed>> futureBreeds;
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    futureBreeds = fetchBreeds();
  }

  Future<List<Breed>> fetchBreeds() async {
    final response =
        await http.get(Uri.parse('https://dog.ceo/api/breeds/list/all'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body)['message'];
      final List<Breed> breeds = [];

      for (var breed in data.keys) {
        final imageUrl = await fetchBreedImage(breed);
        breeds.add(Breed.fromJson(breed, imageUrl));
      }

      return breeds;
    } else {
      throw Exception('Failed to load breeds');
    }
  }

  Future<String> fetchBreedImage(String breed) async {
    final response = await http
        .get(Uri.parse('https://dog.ceo/api/breed/$breed/images/random'));

    if (response.statusCode == 200) {
      final String imageUrl = json.decode(response.body)['message'];
      return imageUrl;
    } else {
      throw Exception('Failed to load breed image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Breeds'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch(futureBreeds));
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Breed>>(
        future: futureBreeds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No breeds found'));
          } else {
            final breeds = snapshot.data!;
            return ListView.builder(
              restorationId: 'sampleItemListView',
              itemCount: breeds.length,
              itemBuilder: (context, index) {
                final breed = breeds[index];
                return ListTile(
                  title: Text(breed.name),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(breed.imageUrl),
                  ),
                  trailing: FutureBuilder<bool>(
                    future: dbHelper.isFavorite(breed.name),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else {
                        final isFavorite = snapshot.data ?? false;
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () async {
                            if (isFavorite) {
                              await dbHelper.deleteFavorite(breed.name);
                            } else {
                              await dbHelper.insertFavorite(
                                  FavoriteBreed(breedName: breed.name));
                            }
                            setState(() {}); // Rebuild to reflect changes
                          },
                        );
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SampleItemDetailsView(breedName: breed.name),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
