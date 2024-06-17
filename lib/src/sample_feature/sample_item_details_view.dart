import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';

class SampleItemDetailsView extends StatefulWidget {
  final String breedName;

  const SampleItemDetailsView({super.key, required this.breedName});

  static const routeName = '/sample_item';

  @override
  SampleItemDetailsViewState createState() => SampleItemDetailsViewState();
}

class SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  late Future<List<String>> futureImageUrls;

  @override
  void initState() {
    super.initState();
    futureImageUrls = fetchBreedImages(widget.breedName, 5);
  }

  Future<List<String>> fetchBreedImages(String breed, int count) async {
    final response = await http.get(
      Uri.parse('https://dog.ceo/api/breed/$breed/images/random/$count'),
    );

    if (response.statusCode == 200) {
      final List<String> imageUrls = List<String>.from(json.decode(response.body)['message']);
      return imageUrls;
    } else {
      throw Exception('Failed to load breed images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.breedName.toUpperCase()),
      ),
      body: FutureBuilder<List<String>>(
        future: futureImageUrls,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final imageUrls = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: false,
                      enlargeCenterPage: true,
                      viewportFraction: 0.8,
                      //aspectRatio: 1.0,
                      //autoPlayInterval: Duration(seconds: 3),
                    ),
                    items: imageUrls.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: 300, // Set width to 300 pixels
                            height: 300, // Set height to 300 pixels
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(url),
                                fit: BoxFit.fill, // will fill the widthxheight box; may distort images
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      futureImageUrls = fetchBreedImages(widget.breedName, 5);
                    }),
                    child: const Text('Fetch New Images'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No images found'));
          }
        },
      ),
    );
  }
}