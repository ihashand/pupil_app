import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_diary/src/providers/others_providers/app_user_provider.dart';
import 'package:pet_diary/src/providers/others_providers/friends_notifier_provider.dart';
import 'package:pet_diary/src/screens/friends_screens/friends_screen.dart';

class FriendRequestsCard extends ConsumerWidget {
  const FriendRequestsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendRequests = ref.watch(friendRequestsNotifierProvider);

    if (friendRequests.isEmpty) {
      return Container();
    }

    final displayedRequests = friendRequests.take(3).toList();
    final hasMoreRequests = friendRequests.length > 3;

    return Card(
      margin: const EdgeInsets.all(10.0),
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Friend request',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColorDark,
                      backgroundColor: const Color(0xff68a2b6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FriendsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'G o  t o  f r i e n d s',
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).primaryColorDark),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.secondary,
            ),
            for (var request in displayedRequests)
              Consumer(
                builder: (context, ref, child) {
                  final userAsyncValue =
                      ref.watch(appUserDetailsProvider(request.fromUserId));
                  return userAsyncValue.when(
                    data: (user) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(user.avatarUrl),
                        radius: 25,
                      ),
                      title: Text(
                        user.username,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        user.email,
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check),
                            color: Colors.green,
                            onPressed: () async {
                              ref
                                  .read(friendRequestsNotifierProvider.notifier)
                                  .acceptFriendRequest(
                                    request.fromUserId,
                                    request.toUserId,
                                  );
                            },
                          ),
                          const SizedBox(width: 15),
                          IconButton(
                            icon: const Icon(Icons.close),
                            color: Colors.red,
                            onPressed: () async {
                              ref
                                  .read(friendRequestsNotifierProvider.notifier)
                                  .declineFriendRequest(
                                    request.fromUserId,
                                    request.toUserId,
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  );
                },
              ),
            if (hasMoreRequests) ...[
              const Divider(),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColorDark,
                    backgroundColor: const Color(0xff68a2b6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FriendsScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'See all requests',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
