import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/components/home_screen/home_screen_cards/reminder_carusele_card.dart';
import 'package:pet_diary/src/helpers/others/helper_show_avatar_selection.dart';
import 'package:pet_diary/src/models/others/app_user_model.dart';
import 'package:pet_diary/src/providers/home_providers/home_preferences_provider.dart';
import 'package:pet_diary/src/providers/others_providers/app_user_provider.dart';
import 'package:pet_diary/src/providers/others_providers/friend_provider.dart';
import 'package:pet_diary/src/components/home_screen/home_screen_cards/active_walk_card.dart';
import 'package:pet_diary/src/components/home_screen/home_screen_cards/friend_request_card.dart';
import 'package:pet_diary/src/components/home_screen/home_screen_cards/walk_card.dart';
import 'package:pet_diary/src/components/home_screen/home_screen_others/home_screen_animal_section.dart';
import 'package:pet_diary/src/components/home_screen/home_screen_others/home_screen_shake_animation.dart';
import 'package:pet_diary/src/providers/others_providers/user_provider.dart';
import 'package:pet_diary/src/screens/friends_screens/friend_profile_screen.dart';

/// A ConsumerStatefulWidget that represents the home screen of the application.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  AppUserModel? _appUser;
  bool showWelcomeText = true; // State to toggle "Welcome back" visibility

  @override
  void initState() {
    super.initState();
    final userId = ref.read(userIdProvider);
    if (userId != null) {
      ref.read(appUserServiceProvider).getAppUserById(userId).then((user) {
        if (mounted) {
          setState(() {
            _appUser = user;
          });
        }
      });
    }
    // Trigger the welcome text to disappear after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showWelcomeText = false;
        });
      }
    });
  }

  String capitalizeFirstLetter(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final appUser = _appUser;
    final homePreferences = ref.watch(homePreferencesProvider);
    final homePreferencesNotifier = ref.read(homePreferencesProvider.notifier);
    final friendRequestsAsyncValue = ref.watch(friendRequestsStreamProvider);

    return SafeArea(
      child: Material(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 25.0, left: 22.0, right: 22.0, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, right: 10.0, bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 700),
                          opacity: showWelcomeText ? 1 : 0,
                          child: const Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'San Francisco',
                            ),
                          ),
                        ),
                        Text(
                          appUser?.username != null
                              ? capitalizeFirstLetter(appUser!.username)
                              : 'No information available for the user',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'San Francisco',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (appUser != null)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FriendProfileScreen(
                              userId: appUser.id,
                            ),
                          ),
                        );
                      },
                      onLongPress: () {
                        showAvatarSelectionDialog(
                          context: context,
                          onAvatarSelected: (String path) async {
                            final user = FirebaseAuth.instance.currentUser;

                            if (user != null) {
                              final updatedUser = appUser.copyWith(
                                avatarUrl: path,
                              );
                              await ref
                                  .read(appUserServiceProvider)
                                  .updateAppUser(updatedUser);
                              setState(() {
                                _appUser = updatedUser;
                              });
                            }
                          },
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage(appUser.avatarUrl),
                        radius: 35,
                      ),
                    ),
                ],
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.secondary,
              thickness: 1.2,
            ),
            Expanded(
              child: ReorderableListView.builder(
                proxyDecorator: (child, index, animation) {
                  return Material(
                    elevation: 8,
                    color: Colors.transparent,
                    child: child,
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex -= 1;

                  setState(() {
                    final item =
                        homePreferences.sectionOrder.removeAt(oldIndex);
                    homePreferences.sectionOrder.insert(newIndex, item);
                  });

                  // Zapisz nową kolejność do Firebase
                  homePreferencesNotifier
                      .updateSectionOrder(homePreferences.sectionOrder);
                },
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: homePreferences.sectionOrder.length,
                itemBuilder: (context, index) {
                  final section = homePreferences.sectionOrder[index];
                  switch (section) {
                    case 'AnimalCard':
                      return const HomeScreenAnimalSection(
                          key: ValueKey('AnimalCard'));
                    case 'WalkCard':
                      return const Padding(
                        key: ValueKey('WalkCard'),
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: WalkCard(),
                      );
                    case 'ActiveWalkCard':
                      return const Padding(
                        key: ValueKey('ActiveWalkCard'),
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: ActiveWalkCard(),
                      );
                    case 'ReminderCard':
                      return const Padding(
                        key: ValueKey('ReminderCard'),
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: ReminderCardCarousel(),
                      );
                    case 'FriendRequestsCard':
                      return Padding(
                        key: const ValueKey('FriendRequestsCard'),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: friendRequestsAsyncValue.when(
                          data: (friendRequests) => friendRequests.isNotEmpty
                              ? const HomeScreenShakeAnimation(
                                  child: FriendRequestsCard(),
                                )
                              : Container(),
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) => Text('Error: $error'),
                        ),
                      );
                    default:
                      return Container(key: ValueKey(section));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
