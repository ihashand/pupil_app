import 'package:pet_diary/src/models/dog_breed_model.dart';

List<DogBreedGroup> dogBreedGroups = [
  DogBreedGroup(
    groupName: "Grupa 0",
    sections: [
      DogBreedSection(
        sectionName: "Wielorasowce",
        breeds: [
          DogBreed(name: "Mieszaniec", group: "0", section: "0"),
          DogBreed(name: "Kundelek", group: "0", section: "0"),
          DogBreed(name: "Wielorasowiec", group: "0", section: "0"),
        ],
      ),
    ],
  ), //
  DogBreedGroup(
    groupName: "Grupa 1: Psy pasterskie i zaganiające",
    sections: [
      DogBreedSection(
        sectionName: "Sekcja 1: Psy pasterskie",
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
          DogBreed(name: "Owczarek Anatolijski", group: "1", section: "1"),
          DogBreed(name: "Owczarek Australijski", group: "1", section: "1"),
          DogBreed(name: "Owczarek Belgijski", group: "1", section: "1"),
          DogBreed(name: "Owczarek Chorwacki", group: "1", section: "1"),
          DogBreed(
              name: "Owczarek Francuski Beauceron", group: "1", section: "1"),
          DogBreed(name: "Owczarek Francuski Briard", group: "1", section: "1"),
          DogBreed(name: "Owczarek Niemiecki", group: "1", section: "1"),
          DogBreed(name: "Owczarek Nizinny Polski", group: "1", section: "1"),
          DogBreed(name: "Owczarek Podhalański", group: "1", section: "1"),
          DogBreed(name: "Owczarek Pikardyjski", group: "1", section: "1"),
          DogBreed(name: "Owczarek Shetlandzki", group: "1", section: "1"),
          DogBreed(name: "Puli", group: "1", section: "1"),
          DogBreed(name: "Schapendoes Holenderski", group: "1", section: "1"),
          DogBreed(name: "Szpic miniaturowy", group: "1", section: "1"),
          DogBreed(name: "Welsh Corgi Cardigan", group: "1", section: "1"),
          DogBreed(name: "Welsh Corgi Pembroke", group: "1", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Sekcja 2: Psy zaganiające",
        breeds: [
          DogBreed(name: "Australian Cattle Dog", group: "1", section: "2"),
          DogBreed(name: "Border Collie", group: "1", section: "2"),
          DogBreed(name: "Kelpie", group: "1", section: "2"),
        ],
      ),
    ],
  ), // Kontynuacja z poprzedniej grupy
  DogBreedGroup(
    groupName:
        "Grupa 2: Pinczery, sznaucery, molosy, szwajcarskie psy pasterskie i inne",
    sections: [
      DogBreedSection(
        sectionName: "Sekcja 1: Pinczery i sznaucery",
        breeds: [
          DogBreed(name: "Affenpinscher", group: "2", section: "1"),
          DogBreed(name: "Doberman", group: "2", section: "1"),
          DogBreed(name: "Miniature Pinscher", group: "2", section: "1"),
          DogBreed(name: "Pinczer", group: "2", section: "1"),
          DogBreed(name: "Schnaucer miniatura", group: "2", section: "1"),
          DogBreed(name: "Schnaucer olbrzymi", group: "2", section: "1"),
          DogBreed(name: "Schnaucer pośredni", group: "2", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Sekcja 2: Molosy",
        breeds: [
          DogBreed(name: "Bernardyn", group: "2", section: "2"),
          DogBreed(name: "Bokser", group: "2", section: "2"),
          DogBreed(name: "Buldog angielski", group: "2", section: "2"),
          DogBreed(name: "Buldog francuski", group: "2", section: "2"),
          DogBreed(name: "Dog argentyński", group: "2", section: "2"),
          DogBreed(name: "Dogo Canario", group: "2", section: "2"),
          DogBreed(name: "Fila Brasileiro", group: "2", section: "2"),
          DogBreed(name: "Hovawart", group: "2", section: "2"),
          DogBreed(name: "Leonberger", group: "2", section: "2"),
          DogBreed(name: "Mastiff angielski", group: "2", section: "2"),
          DogBreed(name: "Mastiff neapolitański", group: "2", section: "2"),
          DogBreed(name: "Perro Dogo Argentino", group: "2", section: "2"),
          DogBreed(name: "Presa Canario", group: "2", section: "2"),
          DogBreed(name: "Rottweiler", group: "2", section: "2"),
          DogBreed(name: "Saint Bernard", group: "2", section: "2"),
          DogBreed(name: "Tosa Inu", group: "2", section: "2"),
        ],
      ),
      DogBreedSection(
        sectionName: "Sekcja 3: Szwajcarskie psy pasterskie",
        breeds: [
          DogBreed(name: "Appenzeller Sennenhund", group: "2", section: "3"),
          DogBreed(name: "Entlebucher Mountain Dog", group: "2", section: "3"),
          DogBreed(
              name: "Grosser Schweizer Sennenhund", group: "2", section: "3"),
          DogBreed(
              name: "Kleiner Schweizer Sennenhund", group: "2", section: "3"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Grupa 3: Teriery",
    sections: [
      DogBreedSection(
        sectionName: "Sekcja 1: Teriery duże i średnie",
        breeds: [
          DogBreed(name: "Airedale Terrier", group: "3", section: "1"),
          DogBreed(
              name: "American Staffordshire Terrier", group: "3", section: "1"),
          DogBreed(name: "Bedlington Terrier", group: "3", section: "1"),
          DogBreed(name: "Border Terrier", group: "3", section: "1"),
          DogBreed(name: "Bullterrier", group: "3", section: "1"),
          DogBreed(name: "Cairn Terrier", group: "3", section: "1"),
          DogBreed(name: "Dandie Dinmont Terrier", group: "3", section: "1"),
          DogBreed(name: "Foxterrier", group: "3", section: "1"),
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
        sectionName: "Sekcja 2: Teriery małe",
        breeds: [
          DogBreed(name: "Australian Terrier", group: "3", section: "2"),
          DogBreed(
              name: "Border Terrier",
              group: "3",
              section: "2"), // Powtórzony z sekcji 1
          DogBreed(name: "Chihuahua", group: "3", section: "2"),
          DogBreed(name: "English Toy Terrier", group: "3", section: "2"),
          DogBreed(
              name: "Jack Russell Terrier",
              group: "3",
              section: "2"), // Powtórzony z sekcji 1
          DogBreed(
              name: "Manchester Terrier",
              group: "3",
              section: "2"), // Powtórzony z sekcji 1
          DogBreed(name: "Miniature Schnauzer", group: "3", section: "2"),
          DogBreed(name: "Pražský Krysařík", group: "3", section: "2"),
          DogBreed(name: "Shih Tzu", group: "3", section: "2"),
          DogBreed(name: "Yorkshire Terrier", group: "3", section: "2"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Grupa 4: Jamniki",
    sections: [
      DogBreedSection(
        sectionName: "Sekcja 1: Jamniki krótkowłose",
        breeds: [
          DogBreed(
              name: "Jamnik krótkowłosy standardowy", group: "4", section: "1"),
          DogBreed(
              name: "Jamnik krótkowłosy miniaturowy", group: "4", section: "1"),
          DogBreed(
              name: "Jamnik krótkowłosy króliczy", group: "4", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Sekcja 2: Jamniki długowłose",
        breeds: [
          DogBreed(
              name: "Jamnik długowłosy standardowy", group: "4", section: "2"),
          DogBreed(
              name: "Jamnik długowłosy miniaturowy", group: "4", section: "2"),
          DogBreed(
              name: "Jamnik długowłosy króliczy", group: "4", section: "2"),
        ],
      ),
      DogBreedSection(
        sectionName: "Sekcja 3: Jamniki szorstkowłose",
        breeds: [
          DogBreed(
              name: "Jamnik szorstkowłosy standardowy",
              group: "4",
              section: "3"),
          DogBreed(
              name: "Jamnik szorstkowłosy miniaturowy",
              group: "4",
              section: "3"),
          DogBreed(
              name: "Jamnik szorstkowłosy króliczy", group: "4", section: "3"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Grupa 5: Szpice i psy pierwotne",
    sections: [
      DogBreedSection(
        sectionName: "Sekcja 1: Szpice północne",
        breeds: [
          DogBreed(name: "Alaskan Malamute", group: "5", section: "1"),
          DogBreed(
              name: "Grönlandzki Pies Zaprzęgowy", group: "5", section: "1"),
          DogBreed(name: "Samojed", group: "5", section: "1"),
          DogBreed(name: "Siberian Husky", group: "5", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Sekcja 2: Szpice europejskie",
        breeds: [
          DogBreed(name: "Chow Chow", group: "5", section: "2"),
          DogBreed(name: "Eurasier", group: "5", section: "2"),
          DogBreed(name: "Finspitz", group: "5", section: "2"),
          DogBreed(name: "Keeshond", group: "5", section: "2"),
          DogBreed(name: "Kleinspitz", group: "5", section: "2"),
          DogBreed(name: "Mittelspitz", group: "5", section: "2"),
          DogBreed(name: "Pomeranian", group: "5", section: "2"),
          DogBreed(name: "Samoyed", group: "5", section: "2"),
          DogBreed(name: "Volpino Italiano", group: "5", section: "2"),
        ],
      ),
      DogBreedSection(
        sectionName: "Sekcja 3: Szpice azjatyckie i afrykańskie",
        breeds: [
          DogBreed(name: "Basenji", group: "5", section: "3"),
          DogBreed(name: "Saluki", group: "5", section: "3"),
          DogBreed(name: "Shiba Inu", group: "5", section: "3"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Grupa 6: Psy gończe i rasy pokrewne",
    sections: [
      DogBreedSection(
        sectionName: "Sekcja 1: Psy gończe",
        breeds: [
          DogBreed(name: "Beagle", group: "6", section: "1"),
          DogBreed(name: "Bloodhound", group: "6", section: "1"),
          DogBreed(name: "Dalmatian", group: "6", section: "1"),
          DogBreed(name: "Foxhound", group: "6", section: "1"),
          DogBreed(name: "Gończy polski", group: "6", section: "1"),
          DogBreed(name: "Harrier", group: "6", section: "1"),
          DogBreed(name: "Hygenhund", group: "6", section: "1"),
          DogBreed(name: "Jurajski Gończy", group: "6", section: "1"),
          DogBreed(name: "Rhodesian Ridgeback", group: "6", section: "1"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Grupa 7: Wyżły",
    sections: [
      DogBreedSection(
        sectionName: "Sekcja 1: Wyżły kontynentalne",
        breeds: [
          DogBreed(name: "Braque d'Auvergne", group: "7", section: "1"),
          DogBreed(name: "Braque du Bourbonnais", group: "7", section: "1"),
          DogBreed(
              name: "German Shorthaired Pointer", group: "7", section: "1"),
          DogBreed(name: "German Wirehaired Pointer", group: "7", section: "1"),
          DogBreed(name: "Griffon Korthalsa", group: "7", section: "1"),
          DogBreed(name: "Hungarian Vizsla", group: "7", section: "1"),
          DogBreed(name: "Italian Pointer", group: "7", section: "1"),
          DogBreed(name: "Pointer", group: "7", section: "1"),
          DogBreed(name: "Pudelpointer", group: "7", section: "1"),
          DogBreed(name: "Vizsla", group: "7", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Sekcja 2: Wyżły brytyjskie i irlandzkie",
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
    groupName: "Grupa 8: Aportery, płochacze i psy dowodne",
    sections: [
      DogBreedSection(
        sectionName: "Sekcja 1: Aportery",
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
        sectionName: "Sekcja 2: Płochacze",
        breeds: [
          DogBreed(name: "Clumber Spaniel", group: "8", section: "2"),
          DogBreed(name: "Cocker Spaniel angielski", group: "8", section: "2"),
          DogBreed(
              name: "Cocker Spaniel amerykański", group: "8", section: "2"),
          DogBreed(name: "English Springer Spaniel", group: "8", section: "2"),
          DogBreed(name: "Field Spaniel", group: "8", section: "2"),
          DogBreed(name: "Irish Water Spaniel", group: "8", section: "2"),
          DogBreed(name: "Sussex Spaniel", group: "8", section: "2"),
          DogBreed(name: "Welsh Springer Spaniel", group: "8", section: "2"),
        ],
      ),
      DogBreedSection(
        sectionName: "Sekcja 3: Psy dowodne",
        breeds: [
          DogBreed(name: "Barbet", group: "8", section: "3"),
          DogBreed(
              name: "Irish Water Spaniel",
              group: "8",
              section: "3"), // Powtórzenie z Sekcji 2
          DogBreed(name: "Portugalski Pies Wodny", group: "8", section: "3"),
          DogBreed(name: "Pudel", group: "8", section: "3"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Grupa 9: Psy ozdobne i do towarzystwa",
    sections: [
      DogBreedSection(
        sectionName: "Sekcja 1: Biszkoty i pudle",
        breeds: [
          DogBreed(name: "Bichon Frise", group: "9", section: "1"),
          DogBreed(name: "Bolognese", group: "9", section: "1"),
          DogBreed(name: "Coton de Tulear", group: "9", section: "1"),
          DogBreed(name: "Havanese", group: "9", section: "1"),
          DogBreed(name: "Maltańczyk", group: "9", section: "1"),
          DogBreed(name: "Pudle", group: "9", section: "1"),
          DogBreed(name: "Shih Tzu", group: "9", section: "1"),
          DogBreed(name: "Yorkshire Terrier", group: "9", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Sekcja 2: Psy miniaturowe",
        breeds: [
          DogBreed(name: "Affenpinscher", group: "9", section: "2"),
          DogBreed(name: "Chihuahua", group: "9", section: "2"),
          DogBreed(name: "English Toy Terrier", group: "9", section: "2"),
          DogBreed(name: "Griffon Brukselski", group: "9", section: "2"),
          DogBreed(name: "Havanese", group: "9", section: "2"),
          DogBreed(name: "Italian Greyhound", group: "9", section: "2"),
          DogBreed(name: "King Charles Spaniel", group: "9", section: "2"),
          DogBreed(name: "Kromfohrländer", group: "9", section: "2"),
          DogBreed(name: "Löwchen", group: "9", section: "2"),
          DogBreed(name: "Manchester Terrier", group: "9", section: "2"),
          DogBreed(name: "Miniature Pinscher", group: "9", section: "2"),
          DogBreed(name: "Mops", group: "9", section: "2"),
          DogBreed(name: "Pekińczyk", group: "9", section: "2"),
          DogBreed(name: "Pražský Krysařík", group: "9", section: "2"),
          DogBreed(name: "Pudel toy", group: "9", section: "2"),
          DogBreed(name: "Shih Tzu", group: "9", section: "2"),
          DogBreed(name: "Yorkshire Terrier", group: "9", section: "2"),
        ],
      ),
      DogBreedSection(
        sectionName: "Sekcja 3: Psy do towarzystwa",
        breeds: [
          DogBreed(name: "Bedlington Terrier", group: "9", section: "3"),
          DogBreed(name: "Bichon Frisé", group: "9", section: "3"),
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
          DogBreed(name: "Pekinese", group: "9", section: "3"),
          DogBreed(name: "Pomeranian", group: "9", section: "3"),
          DogBreed(name: "Poodle (Toy)", group: "9", section: "3"),
          DogBreed(name: "Pug", group: "9", section: "3"),
          DogBreed(name: "Shih Tzu", group: "9", section: "3"),
          DogBreed(name: "Tibetan Spaniel", group: "9", section: "3"),
          DogBreed(name: "Yorkshire Terrier", group: "9", section: "3"),
        ],
      ),
    ],
  ),
  DogBreedGroup(
    groupName: "Grupa 10: Psy gończe, posokowce i psy w typie pierwotnym",
    sections: [
      DogBreedSection(
        sectionName: "Sekcja 1: Psy gończe",
        breeds: [
          DogBreed(name: "Basenji", group: "10", section: "1"),
          DogBreed(name: "Bloodhound", group: "10", section: "1"),
          DogBreed(name: "Dalmatian", group: "10", section: "1"),
          DogBreed(name: "Pharaoh Hound", group: "10", section: "1"),
          DogBreed(name: "Rhodesian Ridgeback", group: "10", section: "1"),
        ],
      ),
      DogBreedSection(
        sectionName: "Sekcja 2: Posokowce",
        breeds: [
          DogBreed(name: "Basset Hound", group: "10", section: "2"),
          DogBreed(name: "Bavarian Mountain Hound", group: "10", section: "2"),
          DogBreed(
              name: "Bloodhound", group: "10", section: "2"), // Powtórzenie
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
          DogBreed(
              name: "Italian Greyhound",
              group: "10",
              section: "2"), // Potencjalnie błędna klasyfikacja
          DogBreed(name: "Norwegian Elkhound", group: "10", section: "2"),
          DogBreed(
              name: "Petit Basset Griffon Vendéen", group: "10", section: "2"),
          DogBreed(name: "Polish Hound", group: "10", section: "2"),
          DogBreed(name: "Portuguese Podengo", group: "10", section: "2"),
          DogBreed(
              name: "Rhodesian Ridgeback",
              group: "10",
              section: "2"), // Powtórzenie
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
