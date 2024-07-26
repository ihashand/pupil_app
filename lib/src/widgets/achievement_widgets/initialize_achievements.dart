import 'package:pet_diary/src/models/achievement.dart';

const String _avatarUrl = 'assets/images/dog_avatar_06.png';

// ids
const String _id10kSteps = '1a2b3c4d-0000-0000-0000-000000000001';
const String _id25kSteps = '1a2b3c4d-0000-0000-0000-000000000002';
const String _id50kSteps = '1a2b3c4d-0000-0000-0000-000000000003';
const String _id100kSteps = '1a2b3c4d-0000-0000-0000-000000000004';
const String _idMarathon = '1a2b3c4d-0000-0000-0000-000000000005';
const String _idSuezCanal = '1a2b3c4d-0000-0000-0000-000000000006';
const String _idRoute66 = '1a2b3c4d-0000-0000-0000-000000000007';
const String _idFellowshipOfTheRing = '1a2b3c4d-0000-0000-0000-000000000008';
const String _id250kSteps = '1a2b3c4d-0000-0000-0000-000000000009';
const String _id500kSteps = '1a2b3c4d-0000-0000-0000-000000000010';
const String _id750kSteps = '1a2b3c4d-0000-0000-0000-000000000011';
const String _id1MSteps = '1a2b3c4d-0000-0000-0000-000000000012';
const String _id2MSteps = '1a2b3c4d-0000-0000-0000-000000000013';
const String _id5MSteps = '1a2b3c4d-0000-0000-0000-000000000014';
const String _id10MSteps = '1a2b3c4d-0000-0000-0000-000000000015';
const String _id20MSteps = '1a2b3c4d-0000-0000-0000-000000000016';
const String _id30MSteps = '1a2b3c4d-0000-0000-0000-000000000017';
const String _id50MSteps = '1a2b3c4d-0000-0000-0000-000000000018';
const String _id75MSteps = '1a2b3c4d-0000-0000-0000-000000000019';
const String _id100MSteps = '1a2b3c4d-0000-0000-0000-000000000020';
const String _id150MSteps = '1a2b3c4d-0000-0000-0000-000000000021';
const String _id200MSteps = '1a2b3c4d-0000-0000-0000-000000000022';
const String _id250MSteps = '1a2b3c4d-0000-0000-0000-000000000023';
const String _idAmazonRiver = '1a2b3c4d-0000-0000-0000-000000000024';
const String _idGreatWallOfChina = '1a2b3c4d-0000-0000-0000-000000000025';
const String _idNileRiver = '1a2b3c4d-0000-0000-0000-000000000026';
const String _idHimalayas = '1a2b3c4d-0000-0000-0000-000000000027';
const String _idGrandCanyon = '1a2b3c4d-0000-0000-0000-000000000028';
const String _idPacificCrestTrail = '1a2b3c4d-0000-0000-0000-000000000029';
const String _idAppalachianTrail = '1a2b3c4d-0000-0000-0000-000000000030';
const String _idKilimanjaro = '1a2b3c4d-0000-0000-0000-000000000031';
const String _idSaharaDesert = '1a2b3c4d-0000-0000-0000-000000000032';
const String _idAntarctica = '1a2b3c4d-0000-0000-0000-000000000033';
const String _idMountEverest = '1a2b3c4d-0000-0000-0000-000000000034';
const String _idRockyMountains = '1a2b3c4d-0000-0000-0000-000000000035';
const String _idSerengeti = '1a2b3c4d-0000-0000-0000-000000000036';
const String _idPatagonia = '1a2b3c4d-0000-0000-0000-000000000037';
const String _idAndesMountains = '1a2b3c4d-0000-0000-0000-000000000038';
const String _idJourneyToMordor = '1a2b3c4d-0000-0000-0000-000000000039';
const String _idHogwartsExpress = '1a2b3c4d-0000-0000-0000-000000000040';
const String _idWesteros = '1a2b3c4d-0000-0000-0000-000000000041';
const String _idMiddleEarth = '1a2b3c4d-0000-0000-0000-000000000042';
const String _idNarnia = '1a2b3c4d-0000-0000-0000-000000000043';
const String _idWonderland = '1a2b3c4d-0000-0000-0000-000000000044';
const String _idOz = '1a2b3c4d-0000-0000-0000-000000000045';
const String _idCamelot = '1a2b3c4d-0000-0000-0000-000000000046';
const String _idAtlantis = '1a2b3c4d-0000-0000-0000-000000000047';
const String _idNeverland = '1a2b3c4d-0000-0000-0000-000000000048';
const String _idValhalla = '1a2b3c4d-0000-0000-0000-000000000049';
const String _idEmeraldCity = '1a2b3c4d-0000-0000-0000-000000000050';
const String _idShangriLa = '1a2b3c4d-0000-0000-0000-000000000051';
const String _idPandora = '1a2b3c4d-0000-0000-0000-000000000052';
const String _idRivendell = '1a2b3c4d-0000-0000-0000-000000000053';

List<Achievement> achievements = [
  Achievement(
    id: _id10kSteps,
    name: '10,000 Steps',
    description: 'Walk 6.75 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 10000,
  ),
  Achievement(
    id: _id25kSteps,
    name: '25,000 Steps',
    description: 'Walk 16.88 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 25000,
  ),
  Achievement(
    id: _id50kSteps,
    name: '50,000 Steps',
    description: 'Walk 33.75 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 50000,
  ),
  Achievement(
    id: _id100kSteps,
    name: '100,000 Steps',
    description: 'Walk 67.5 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 100000,
  ),
  Achievement(
    id: _id250kSteps,
    name: '250,000 Steps',
    description: 'Walk 168.75 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 250000,
  ),
  Achievement(
    id: _id500kSteps,
    name: '500,000 Steps',
    description: 'Walk 337.5 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 500000,
  ),
  Achievement(
    id: _id750kSteps,
    name: '750,000 Steps',
    description: 'Walk 506.25 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 750000,
  ),
  Achievement(
    id: _id1MSteps,
    name: '1 Million Steps',
    description: 'Walk 675 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 1000000,
  ),
  Achievement(
    id: _id2MSteps,
    name: '2 Million Steps',
    description: 'Walk 1350 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 2000000,
  ),
  Achievement(
    id: _id5MSteps,
    name: '5 Million Steps',
    description: 'Walk 3375 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 5000000,
  ),
  Achievement(
    id: _id10MSteps,
    name: '10 Million Steps',
    description: 'Walk 6750 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 10000000,
  ),
  Achievement(
    id: _id20MSteps,
    name: '20 Million Steps',
    description: 'Walk 13500 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 20000000,
  ),
  Achievement(
    id: _id30MSteps,
    name: '30 Million Steps',
    description: 'Walk 20250 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 30000000,
  ),
  Achievement(
    id: _id50MSteps,
    name: '50 Million Steps',
    description: 'Walk 33750 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 50000000,
  ),
  Achievement(
    id: _id75MSteps,
    name: '75 Million Steps',
    description: 'Walk 50625 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 75000000,
  ),
  Achievement(
    id: _id100MSteps,
    name: '100 Million Steps',
    description: 'Walk 67500 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 100000000,
  ),
  Achievement(
    id: _id150MSteps,
    name: '150 Million Steps',
    description: 'Walk 101250 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 150000000,
  ),
  Achievement(
    id: _id200MSteps,
    name: '200 Million Steps',
    description: 'Walk 135000 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 200000000,
  ),
  Achievement(
    id: _id250MSteps,
    name: '250 Million Steps',
    description: 'Walk 168750 km.',
    avatarUrl: _avatarUrl,
    category: 'steps',
    stepsRequired: 250000000,
  ),
  Achievement(
    id: _idMarathon,
    name: 'Marathon',
    description: 'Walk 28.35 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 42000,
  ),
  Achievement(
    id: _idSuezCanal,
    name: 'Suez Canal',
    description: 'Walk 135 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 200000,
  ),
  Achievement(
    id: _idRoute66,
    name: 'Route 66',
    description: 'Walk 2700 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 4000000,
  ),
  Achievement(
    id: _idAmazonRiver,
    name: 'Amazon River',
    description: 'Walk 4725 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 7000000,
  ),
  Achievement(
    id: _idGreatWallOfChina,
    name: 'Great Wall of China',
    description: 'Walk 14310 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 21196000,
  ),
  Achievement(
    id: _idNileRiver,
    name: 'Nile River',
    description: 'Walk 4488.75 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 6650000,
  ),
  Achievement(
    id: _idHimalayas,
    name: 'Himalayas',
    description: 'Walk 1620 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 2400000,
  ),
  Achievement(
    id: _idGrandCanyon,
    name: 'Grand Canyon',
    description: 'Walk 301.05 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 446000,
  ),
  Achievement(
    id: _idPacificCrestTrail,
    name: 'Pacific Crest Trail',
    description: 'Walk 2882.25 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 4270000,
  ),
  Achievement(
    id: _idAppalachianTrail,
    name: 'Appalachian Trail',
    description: 'Walk 2362.5 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 3500000,
  ),
  Achievement(
    id: _idKilimanjaro,
    name: 'Kilimanjaro',
    description: 'Walk 3991.125 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 5895000,
  ),
  Achievement(
    id: _idSaharaDesert,
    name: 'Sahara Desert',
    description: 'Walk 6210 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 9200000,
  ),
  Achievement(
    id: _idAntarctica,
    name: 'Antarctica',
    description: 'Walk 9450 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 14000000,
  ),
  Achievement(
    id: _idMountEverest,
    name: 'Mount Everest',
    description: 'Walk 5970.6 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 8848000,
  ),
  Achievement(
    id: _idRockyMountains,
    name: 'Rocky Mountains',
    description: 'Walk 3240 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 4800000,
  ),
  Achievement(
    id: _idSerengeti,
    name: 'Serengeti',
    description: 'Walk 20250 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 30000000,
  ),
  Achievement(
    id: _idPatagonia,
    name: 'Patagonia',
    description: 'Walk 675 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 1000000,
  ),
  Achievement(
    id: _idAndesMountains,
    name: 'Andes Mountains',
    description: 'Walk 4725 km.',
    avatarUrl: _avatarUrl,
    category: 'nature',
    stepsRequired: 7000000,
  ),
  Achievement(
    id: _idFellowshipOfTheRing,
    name: 'Fellowship of the Ring',
    description: 'Walk 1282.5 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 1900000,
  ),
  Achievement(
    id: _idJourneyToMordor,
    name: 'Journey to Mordor',
    description: 'Walk 1890 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 2800000,
  ),
  Achievement(
    id: _idHogwartsExpress,
    name: 'Hogwarts Express',
    description: 'Walk 4387.5 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 6500000,
  ),
  Achievement(
    id: _idWesteros,
    name: 'Westeros',
    description: 'Walk 3375 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 5000000,
  ),
  Achievement(
    id: _idMiddleEarth,
    name: 'Middle Earth',
    description: 'Walk 2700 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 4000000,
  ),
  Achievement(
    id: _idNarnia,
    name: 'Narnia',
    description: 'Walk 2025 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 3000000,
  ),
  Achievement(
    id: _idWonderland,
    name: 'Wonderland',
    description: 'Walk 1012.5 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 1500000,
  ),
  Achievement(
    id: _idOz,
    name: 'Oz',
    description: 'Walk 1350 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 2000000,
  ),
  Achievement(
    id: _idCamelot,
    name: 'Camelot',
    description: 'Walk 3037.5 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 4500000,
  ),
  Achievement(
    id: _idAtlantis,
    name: 'Atlantis',
    description: 'Walk 5062.5 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 7500000,
  ),
  Achievement(
    id: _idNeverland,
    name: 'Neverland',
    description: 'Walk 1687.5 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 2500000,
  ),
  Achievement(
    id: _idValhalla,
    name: 'Valhalla',
    description: 'Walk 5400 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 8000000,
  ),
  Achievement(
    id: _idEmeraldCity,
    name: 'Emerald City',
    description: 'Walk 2362.5 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 3500000,
  ),
  Achievement(
    id: _idShangriLa,
    name: 'Shangri-La',
    description: 'Walk 6075 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 9000000,
  ),
  Achievement(
    id: _idPandora,
    name: 'Pandora',
    description: 'Walk 3712.5 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 5500000,
  ),
  Achievement(
    id: _idRivendell,
    name: 'Rivendell',
    description: 'Walk 2835 km.',
    avatarUrl: _avatarUrl,
    category: 'fantasy',
    stepsRequired: 4200000,
  ),
];
