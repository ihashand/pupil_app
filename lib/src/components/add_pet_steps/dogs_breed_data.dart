import 'package:pet_diary/src/models/dog_breed_model.dart';

List<DogBreedGroup> dogBreedGroups = [
  DogBreedGroup(
    groupName: "Group 0: Mixed Breeds",
    sections: [
      DogBreedSection(
        sectionName: "Mixed Breeds",
        breeds: [
          DogBreed(name: "Mixed Breed", group: "0", section: "0"),
          DogBreed(name: "Mongrel", group: "0", section: "0"),
          DogBreed(name: "Multi-breed", group: "0", section: "0"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Group 1: Herding Dogs",
    sections: [
      DogBreedSection(
        sectionName: "Section 1: Sheepdogs",
        breeds: [
          DogBreed(name: "Bearded Collie", group: "1", section: "1"),
          DogBreed(name: "Border Collie", group: "1", section: "1"),
          DogBreed(name: "Bouvier des Flandres", group: "1", section: "1"),
          DogBreed(name: "Briard", group: "1", section: "1"),
          DogBreed(name: "Collie", group: "1", section: "1"),
          DogBreed(name: "Entlebucher Mountain Dog", group: "1", section: "1"),
          DogBreed(name: "Komondor", group: "1", section: "1"),
          DogBreed(name: "Kuvasz", group: "1", section: "1"),
          DogBreed(name: "Mudi", group: "1", section: "1"),
          DogBreed(name: "Anatolian Shepherd", group: "1", section: "1"),
          DogBreed(name: "Australian Shepherd", group: "1", section: "1"),
          DogBreed(name: "Belgian Shepherd", group: "1", section: "1"),
          DogBreed(name: "Croatian Sheepdog", group: "1", section: "1"),
          DogBreed(name: "Beauceron", group: "1", section: "1"),
          DogBreed(name: "Briard", group: "1", section: "1"),
          DogBreed(name: "German Shepherd", group: "1", section: "1"),
          DogBreed(name: "Polish Lowland Sheepdog", group: "1", section: "1"),
          DogBreed(name: "Polish Tatra Sheepdog", group: "1", section: "1"),
          DogBreed(name: "Picardy Shepherd", group: "1", section: "1"),
          DogBreed(name: "Shetland Sheepdog", group: "1", section: "1"),
          DogBreed(name: "Puli", group: "1", section: "1"),
          DogBreed(name: "Dutch Schapendoes", group: "1", section: "1"),
          DogBreed(name: "Miniature Spitz", group: "1", section: "1"),
          DogBreed(name: "Welsh Corgi Cardigan", group: "1", section: "1"),
          DogBreed(name: "Welsh Corgi Pembroke", group: "1", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 2: Cattle Dogs",
        breeds: [
          DogBreed(name: "Australian Cattle Dog", group: "1", section: "2"),
          DogBreed(name: "Border Collie", group: "1", section: "2"),
          DogBreed(name: "Kelpie", group: "1", section: "2"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName:
        "Group 2: Pinschers, Schnauzers, Molossoids, and Swiss Mountain Dogs",
    sections: [
      DogBreedSection(
        sectionName: "Section 1: Pinschers and Schnauzers",
        breeds: [
          DogBreed(name: "Affenpinscher", group: "2", section: "1"),
          DogBreed(name: "Doberman", group: "2", section: "1"),
          DogBreed(name: "Miniature Pinscher", group: "2", section: "1"),
          DogBreed(name: "Pinscher", group: "2", section: "1"),
          DogBreed(name: "Miniature Schnauzer", group: "2", section: "1"),
          DogBreed(name: "Giant Schnauzer", group: "2", section: "1"),
          DogBreed(name: "Standard Schnauzer", group: "2", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 2: Molossers",
        breeds: [
          DogBreed(name: "Saint Bernard", group: "2", section: "2"),
          DogBreed(name: "Boxer", group: "2", section: "2"),
          DogBreed(name: "English Bulldog", group: "2", section: "2"),
          DogBreed(name: "French Bulldog", group: "2", section: "2"),
          DogBreed(name: "Argentine Dogo", group: "2", section: "2"),
          DogBreed(name: "Dogo Canario", group: "2", section: "2"),
          DogBreed(name: "Fila Brasileiro", group: "2", section: "2"),
          DogBreed(name: "Hovawart", group: "2", section: "2"),
          DogBreed(name: "Leonberger", group: "2", section: "2"),
          DogBreed(name: "English Mastiff", group: "2", section: "2"),
          DogBreed(name: "Neapolitan Mastiff", group: "2", section: "2"),
          DogBreed(name: "Argentinian Mastiff", group: "2", section: "2"),
          DogBreed(name: "Presa Canario", group: "2", section: "2"),
          DogBreed(name: "Rottweiler", group: "2", section: "2"),
          DogBreed(name: "Saint Bernard", group: "2", section: "2"),
          DogBreed(name: "Tosa Inu", group: "2", section: "2"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 3: Swiss Mountain Dogs",
        breeds: [
          DogBreed(name: "Appenzeller Mountain Dog", group: "2", section: "3"),
          DogBreed(name: "Entlebucher Mountain Dog", group: "2", section: "3"),
          DogBreed(
              name: "Greater Swiss Mountain Dog", group: "2", section: "3"),
          DogBreed(name: "Bernese Mountain Dog", group: "2", section: "3"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Group 3: Terriers",
    sections: [
      DogBreedSection(
        sectionName: "Section 1: Large and Medium Terriers",
        breeds: [
          DogBreed(name: "Airedale Terrier", group: "3", section: "1"),
          DogBreed(
              name: "American Staffordshire Terrier", group: "3", section: "1"),
          DogBreed(name: "Bedlington Terrier", group: "3", section: "1"),
          DogBreed(name: "Border Terrier", group: "3", section: "1"),
          DogBreed(name: "Bull Terrier", group: "3", section: "1"),
          DogBreed(name: "Cairn Terrier", group: "3", section: "1"),
          DogBreed(name: "Dandie Dinmont Terrier", group: "3", section: "1"),
          DogBreed(name: "Fox Terrier", group: "3", section: "1"),
          DogBreed(name: "Irish Terrier", group: "3", section: "1"),
          DogBreed(name: "Jack Russell Terrier", group: "3", section: "1"),
          DogBreed(name: "Kerry Blue Terrier", group: "3", section: "1"),
          DogBreed(name: "Lakeland Terrier", group: "3", section: "1"),
          DogBreed(name: "Manchester Terrier", group: "3", section: "1"),
          DogBreed(name: "Parson Russell Terrier", group: "3", section: "1"),
          DogBreed(
              name: "Staffordshire Bull Terrier", group: "3", section: "1"),
          DogBreed(name: "Welsh Terrier", group: "3", section: "1"),
          DogBreed(
              name: "West Highland White Terrier", group: "3", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 2: Small Terriers",
        breeds: [
          DogBreed(name: "Australian Terrier", group: "3", section: "2"),
          DogBreed(
              name: "Border Terrier",
              group: "3",
              section: "2"), // Duplicate from Section 1
          DogBreed(name: "Chihuahua", group: "3", section: "2"),
          DogBreed(name: "English Toy Terrier", group: "3", section: "2"),
          DogBreed(
              name: "Jack Russell Terrier",
              group: "3",
              section: "2"), // Duplicate from Section 1
          DogBreed(
              name: "Manchester Terrier",
              group: "3",
              section: "2"), // Duplicate from Section 1
          DogBreed(name: "Miniature Schnauzer", group: "3", section: "2"),
          DogBreed(name: "Pražský Krysařík", group: "3", section: "2"),
          DogBreed(name: "Shih Tzu", group: "3", section: "2"),
          DogBreed(name: "Yorkshire Terrier", group: "3", section: "2"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Group 4: Dachshunds",
    sections: [
      DogBreedSection(
        sectionName: "Section 1: Short-haired Dachshunds",
        breeds: [
          DogBreed(
              name: "Standard Smooth-haired Dachshund",
              group: "4",
              section: "1"),
          DogBreed(
              name: "Miniature Smooth-haired Dachshund",
              group: "4",
              section: "1"),
          DogBreed(
              name: "Rabbit Smooth-haired Dachshund", group: "4", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 2: Long-haired Dachshunds",
        breeds: [
          DogBreed(
              name: "Standard Long-haired Dachshund", group: "4", section: "2"),
          DogBreed(
              name: "Miniature Long-haired Dachshund",
              group: "4",
              section: "2"),
          DogBreed(
              name: "Rabbit Long-haired Dachshund", group: "4", section: "2"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 3: Wire-haired Dachshunds",
        breeds: [
          DogBreed(
              name: "Standard Wire-haired Dachshund", group: "4", section: "3"),
          DogBreed(
              name: "Miniature Wire-haired Dachshund",
              group: "4",
              section: "3"),
          DogBreed(
              name: "Rabbit Wire-haired Dachshund", group: "4", section: "3"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Group 5: Spitz and Primitive Types",
    sections: [
      DogBreedSection(
        sectionName: "Section 1: Northern Spitz",
        breeds: [
          DogBreed(name: "Alaskan Malamute", group: "5", section: "1"),
          DogBreed(name: "Greenland Dog", group: "5", section: "1"),
          DogBreed(name: "Samoyed", group: "5", section: "1"),
          DogBreed(name: "Siberian Husky", group: "5", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 2: European Spitz",
        breeds: [
          DogBreed(name: "Chow Chow", group: "5", section: "2"),
          DogBreed(name: "Eurasier", group: "5", section: "2"),
          DogBreed(name: "Finnish Spitz", group: "5", section: "2"),
          DogBreed(name: "Keeshond", group: "5", section: "2"),
          DogBreed(name: "Kleinspitz", group: "5", section: "2"),
          DogBreed(name: "Mittelspitz", group: "5", section: "2"),
          DogBreed(name: "Pomeranian", group: "5", section: "2"),
          DogBreed(name: "Samoyed", group: "5", section: "2"),
          DogBreed(name: "Volpino Italiano", group: "5", section: "2"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 3: Asian and African Spitz",
        breeds: [
          DogBreed(name: "Basenji", group: "5", section: "3"),
          DogBreed(name: "Saluki", group: "5", section: "3"),
          DogBreed(name: "Shiba Inu", group: "5", section: "3"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Group 6: Scent Hounds and Related Breeds",
    sections: [
      DogBreedSection(
        sectionName: "Section 1: Scent Hounds",
        breeds: [
          DogBreed(name: "Beagle", group: "6", section: "1"),
          DogBreed(name: "Bloodhound", group: "6", section: "1"),
          DogBreed(name: "Dalmatian", group: "6", section: "1"),
          DogBreed(name: "Foxhound", group: "6", section: "1"),
          DogBreed(name: "Polish Hound", group: "6", section: "1"),
          DogBreed(name: "Harrier", group: "6", section: "1"),
          DogBreed(name: "Hygenhund", group: "6", section: "1"),
          DogBreed(name: "Jura Hound", group: "6", section: "1"),
          DogBreed(name: "Rhodesian Ridgeback", group: "6", section: "1"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Group 7: Pointing Dogs",
    sections: [
      DogBreedSection(
        sectionName: "Section 1: Continental Pointing Dogs",
        breeds: [
          DogBreed(name: "Braque d'Auvergne", group: "7", section: "1"),
          DogBreed(name: "Braque du Bourbonnais", group: "7", section: "1"),
          DogBreed(
              name: "German Shorthaired Pointer", group: "7", section: "1"),
          DogBreed(name: "German Wirehaired Pointer", group: "7", section: "1"),
          DogBreed(name: "Griffon Korthals", group: "7", section: "1"),
          DogBreed(name: "Hungarian Vizsla", group: "7", section: "1"),
          DogBreed(name: "Italian Pointer", group: "7", section: "1"),
          DogBreed(name: "Pointer", group: "7", section: "1"),
          DogBreed(name: "Pudelpointer", group: "7", section: "1"),
          DogBreed(name: "Vizsla", group: "7", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 2: British and Irish Pointing Dogs",
        breeds: [
          DogBreed(name: "English Setter", group: "7", section: "2"),
          DogBreed(name: "Gordon Setter", group: "7", section: "2"),
          DogBreed(name: "Irish Setter", group: "7", section: "2"),
          DogBreed(name: "Irish Red Setter", group: "7", section: "2"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Group 8: Retrievers, Flushing Dogs, and Water Dogs",
    sections: [
      DogBreedSection(
        sectionName: "Section 1: Retrievers",
        breeds: [
          DogBreed(name: "American Water Spaniel", group: "8", section: "1"),
          DogBreed(name: "Chesapeake Bay Retriever", group: "8", section: "1"),
          DogBreed(name: "Curly Coated Retriever", group: "8", section: "1"),
          DogBreed(name: "Flat Coated Retriever", group: "8", section: "1"),
          DogBreed(name: "Golden Retriever", group: "8", section: "1"),
          DogBreed(name: "Labrador Retriever", group: "8", section: "1"),
          DogBreed(
              name: "Nova Scotia Duck Tolling Retriever",
              group: "8",
              section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 2: Flushing Dogs",
        breeds: [
          DogBreed(name: "Clumber Spaniel", group: "8", section: "2"),
          DogBreed(name: "English Cocker Spaniel", group: "8", section: "2"),
          DogBreed(name: "American Cocker Spaniel", group: "8", section: "2"),
          DogBreed(name: "English Springer Spaniel", group: "8", section: "2"),
          DogBreed(name: "Field Spaniel", group: "8", section: "2"),
          DogBreed(name: "Irish Water Spaniel", group: "8", section: "2"),
          DogBreed(name: "Sussex Spaniel", group: "8", section: "2"),
          DogBreed(name: "Welsh Springer Spaniel", group: "8", section: "2"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 3: Water Dogs",
        breeds: [
          DogBreed(name: "Barbet", group: "8", section: "3"),
          DogBreed(
              name: "Irish Water Spaniel",
              group: "8",
              section: "3"), // Duplicate from Section 2
          DogBreed(name: "Portuguese Water Dog", group: "8", section: "3"),
          DogBreed(name: "Poodle", group: "8", section: "3"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Group 9: Companion and Toy Dogs",
    sections: [
      DogBreedSection(
        sectionName: "Section 1: Bichons and Poodles",
        breeds: [
          DogBreed(name: "Bichon Frise", group: "9", section: "1"),
          DogBreed(name: "Bolognese", group: "9", section: "1"),
          DogBreed(name: "Coton de Tulear", group: "9", section: "1"),
          DogBreed(name: "Havanese", group: "9", section: "1"),
          DogBreed(name: "Maltese", group: "9", section: "1"),
          DogBreed(name: "Poodle", group: "9", section: "1"),
          DogBreed(name: "Shih Tzu", group: "9", section: "1"),
          DogBreed(name: "Yorkshire Terrier", group: "9", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 2: Miniature Dogs",
        breeds: [
          DogBreed(name: "Affenpinscher", group: "9", section: "2"),
          DogBreed(name: "Chihuahua", group: "9", section: "2"),
          DogBreed(name: "English Toy Terrier", group: "9", section: "2"),
          DogBreed(name: "Brussels Griffon", group: "9", section: "2"),
          DogBreed(name: "Havanese", group: "9", section: "2"),
          DogBreed(name: "Italian Greyhound", group: "9", section: "2"),
          DogBreed(name: "King Charles Spaniel", group: "9", section: "2"),
          DogBreed(name: "Kromfohrlander", group: "9", section: "2"),
          DogBreed(name: "Lowchen", group: "9", section: "2"),
          DogBreed(name: "Manchester Terrier", group: "9", section: "2"),
          DogBreed(name: "Miniature Pinscher", group: "9", section: "2"),
          DogBreed(name: "Pug", group: "9", section: "2"),
          DogBreed(name: "Pekingese", group: "9", section: "2"),
          DogBreed(name: "Pražský Krysařík", group: "9", section: "2"),
          DogBreed(name: "Toy Poodle", group: "9", section: "2"),
          DogBreed(name: "Shih Tzu", group: "9", section: "2"),
          DogBreed(name: "Yorkshire Terrier", group: "9", section: "2"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 3: Companion Dogs",
        breeds: [
          DogBreed(name: "Bedlington Terrier", group: "9", section: "3"),
          DogBreed(name: "Bichon Frise", group: "9", section: "3"),
          DogBreed(name: "Bolognese", group: "9", section: "3"),
          DogBreed(
              name: "Cavalier King Charles Spaniel", group: "9", section: "3"),
          DogBreed(name: "Chihuahua", group: "9", section: "3"),
          DogBreed(name: "Chinese Crested", group: "9", section: "3"),
          DogBreed(name: "English Toy Terrier", group: "9", section: "3"),
          DogBreed(name: "Havanese", group: "9", section: "3"),
          DogBreed(name: "Italian Greyhound", group: "9", section: "3"),
          DogBreed(name: "Japanese Chin", group: "9", section: "3"),
          DogBreed(name: "King Charles Spaniel", group: "9", section: "3"),
          DogBreed(name: "Maltese", group: "9", section: "3"),
          DogBreed(name: "Papillon", group: "9", section: "3"),
          DogBreed(name: "Pekingese", group: "9", section: "3"),
          DogBreed(name: "Pomeranian", group: "9", section: "3"),
          DogBreed(name: "Toy Poodle", group: "9", section: "3"),
          DogBreed(name: "Pug", group: "9", section: "3"),
          DogBreed(name: "Shih Tzu", group: "9", section: "3"),
          DogBreed(name: "Tibetan Spaniel", group: "9", section: "3"),
          DogBreed(name: "Yorkshire Terrier", group: "9", section: "3"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Group 10: Sighthounds and Primitive Breeds",
    sections: [
      DogBreedSection(
        sectionName: "Section 1: Sighthounds",
        breeds: [
          DogBreed(name: "Basenji", group: "10", section: "1"),
          DogBreed(name: "Bloodhound", group: "10", section: "1"),
          DogBreed(name: "Dalmatian", group: "10", section: "1"),
          DogBreed(name: "Pharaoh Hound", group: "10", section: "1"),
          DogBreed(name: "Rhodesian Ridgeback", group: "10", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Section 2: Scenthounds",
        breeds: [
          DogBreed(name: "Basset Hound", group: "10", section: "2"),
          DogBreed(name: "Bavarian Mountain Hound", group: "10", section: "2"),
          DogBreed(name: "Bloodhound", group: "10", section: "2"), // Duplicate
          DogBreed(name: "Black and Tan Coonhound", group: "10", section: "2"),
          DogBreed(name: "Dachshund", group: "10", section: "2"),
          DogBreed(name: "English Foxhound", group: "10", section: "2"),
          DogBreed(name: "Finnish Hound", group: "10", section: "2"),
          DogBreed(name: "French Basset Hound", group: "10", section: "2"),
          DogBreed(
              name: "Grand Basset Griffon Vendéen", group: "10", section: "2"),
          DogBreed(name: "Greek Harehound", group: "10", section: "2"),
          DogBreed(name: "Harrier", group: "10", section: "2"),
          DogBreed(
              name: "Istrian Coarse-haired Hound", group: "10", section: "2"),
          DogBreed(name: "Italian Greyhound", group: "10", section: "2"),
          DogBreed(name: "Norwegian Elkhound", group: "10", section: "2"),
          DogBreed(
              name: "Petit Basset Griffon Vendéen", group: "10", section: "2"),
          DogBreed(name: "Polish Hound", group: "10", section: "2"),
          DogBreed(name: "Portuguese Podengo", group: "10", section: "2"),
          DogBreed(
              name: "Rhodesian Ridgeback",
              group: "10",
              section: "2"), // Duplicate
          DogBreed(name: "Serbian Hound", group: "10", section: "2"),
          DogBreed(name: "Slovenský Kopov", group: "10", section: "2"),
          DogBreed(name: "Smaland Hound", group: "10", section: "2"),
          DogBreed(name: "Swiss Hound", group: "10", section: "2"),
          DogBreed(name: "Treeing Walker Coonhound", group: "10", section: "2"),
        ],
      ),
    ],
  ),
];
