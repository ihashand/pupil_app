import 'package:flutter/material.dart';
import 'package:pet_diary/src/models/others/dog_breed_model.dart';

class BreedSelectionScreen extends StatefulWidget {
  final List<DogBreedGroup> dogBreedGroups;
  final Function(String) onBreedSelected;

  const BreedSelectionScreen(
      {super.key, required this.dogBreedGroups, required this.onBreedSelected});

  @override
  createState() => _BreedSelectionScreenState();
}

class _BreedSelectionScreenState extends State<BreedSelectionScreen> {
  final TextEditingController searchController = TextEditingController();
  List<DogBreedGroup> filteredGroups = [];

  @override
  void initState() {
    super.initState();
    filteredGroups = widget.dogBreedGroups;
  }

  void _filterBreeds(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredGroups = widget.dogBreedGroups;
      } else {
        filteredGroups = widget.dogBreedGroups
            .map((group) {
              var matchingSections = group.sections
                  .map((section) {
                    var matchingBreeds = section.breeds
                        .where((breed) => breed.name
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList();
                    return DogBreedSection(
                        sectionName: section.sectionName,
                        breeds: matchingBreeds);
                  })
                  .where((section) => section.breeds.isNotEmpty)
                  .toList();

              return DogBreedGroup(
                  groupName: group.groupName, sections: matchingSections);
            })
            .where((group) => group.sections.isNotEmpty)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'S E L E C T  B R E E D',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColorDark),
      ),
      body: Column(
        children: [
          _buildSearchContainer(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filteredGroups.length,
              itemBuilder: (context, groupIndex) {
                final group = filteredGroups[groupIndex];
                return _buildGroupContainer(context, group);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(22), bottomRight: Radius.circular(22)),
      ),
      child: Column(
        children: [
          Divider(
            color: Theme.of(context).colorScheme.surface,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                icon: Icon(Icons.search,
                    color: Theme.of(context).primaryColorDark),
                hintText: 'Search breeds...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(context).primaryColorDark.withOpacity(0.6),
                ),
              ),
              onChanged: _filterBreeds,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupContainer(BuildContext context, DogBreedGroup group) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            group.groupName,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
                fontSize: 16),
          ),
          children: group.sections
              .map((section) => _buildSectionContainer(context, section))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context, DogBreedSection section) {
    return Container(
      width: MediaQuery.of(context).size.width - 30,
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 8),
            child: Text(
              section.sectionName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
          ),
          SizedBox(
            height: 65,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: section.breeds
                  .map((breed) => _buildBreedChip(context, breed))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreedChip(BuildContext context, DogBreed breed) {
    return GestureDetector(
      onTap: () {
        widget.onBreedSelected(breed.name);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Text(
                breed.name,
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
