import 'package:flutter/material.dart';

import 'sample_item_details_view.dart';
import 'sample_item_list_view.dart';

class DataSearch extends SearchDelegate<String> {
  Future<List<Breed>> breeds;

  DataSearch(this.breeds);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, "Close");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Breed>>(
      future: breeds,
      builder: (BuildContext context, AsyncSnapshot<List<Breed>> snapshot) {
        if (snapshot.hasData) {
          final suggestionList = query.isEmpty
              ? snapshot.data
              : snapshot.data?.where((p) => p.name.startsWith(query)).toList();

          return ListView.builder(
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.pets),
              title: Text(suggestionList?[index].name ?? ""),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SampleItemDetailsView(
                        breedName: suggestionList?[index].name ?? ""),
                  ),
                );
              },
            ),
            itemCount: suggestionList?.length,
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return CircularProgressIndicator();
      },
    );
  }
}
