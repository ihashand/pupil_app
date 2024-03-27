import 'package:hive/hive.dart';

part 'dog_breed_model.g.dart';

@HiveType(typeId: 9)
class DogBreed {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String group;
  @HiveField(2)
  final String section;

  DogBreed({required this.name, required this.group, required this.section});
}

class DogBreedGroup {
  final String groupName;
  final List<DogBreedSection> sections;

  DogBreedGroup({required this.groupName, required this.sections});
}

class DogBreedSection {
  final String sectionName;
  final List<DogBreed> breeds;

  DogBreedSection({required this.sectionName, required this.breeds});
}
