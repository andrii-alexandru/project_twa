import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SampleItemDetailsView extends StatefulWidget {
  final String breedName;

  const SampleItemDetailsView({super.key, required this.breedName});

  static const routeName = '/sample_item';

  @override
  _SampleItemDetailsViewState createState() => _SampleItemDetailsViewState();
}

class _SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  late Future<String> futureImageUrl;

  @override
  void initState() {
    super.initState();
    futureImageUrl = fetchBreedImage(widget.breedName);
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

  void refetchImage() {
    setState(() {
      futureImageUrl = fetchBreedImage(widget.breedName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.breedName.toUpperCase()),
      ),
      body: FutureBuilder<String>(
        future: futureImageUrl,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final imageUrl = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // resizing image
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit
                              .fill
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: refetchImage,
                    child: const Text('Fetch New Image'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No image found'));
          }
        },
      ),
    );
  }
}
