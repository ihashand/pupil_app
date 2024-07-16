import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/app_user_model.dart';
import 'package:pet_diary/src/providers/friend_provider.dart';
import 'package:pet_diary/src/providers/app_user_provider.dart';
import 'package:pet_diary/src/providers/friend_search_provider.dart';
import 'package:pet_diary/src/providers/friends_notifier_provider.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  AppUserModel? _searchResult;

  @override
  void initState() {
    super.initState();
    ref.read(friendsProvider.notifier).loadFriends();
  }

  void _searchFriend() async {
    final email = _searchController.text.trim().toLowerCase();
    await ref.read(friendsSearchProvider.notifier).searchUserByEmail(email);
    setState(() {
      _searchResult = ref.read(friendsSearchProvider).isNotEmpty
          ? ref.read(friendsSearchProvider).first
          : null;
    });
  }

  void _sendFriendRequest(AppUserModel friend) async {
    await ref.read(friendsProvider.notifier).sendFriendRequest(friend.id);
    _searchController.clear();
    setState(() {
      _searchResult = null;
    });
  }

  void _acceptFriendRequest(String fromUserId, String toUserId) async {
    await ref
        .read(friendsProvider.notifier)
        .acceptFriendRequest(fromUserId, toUserId);
    ref.invalidate(friendRequestsStreamProvider);
    ref.invalidate(friendsStreamProvider);
  }

  void _declineFriendRequest(String fromUserId, String toUserId) async {
    await ref
        .read(friendsProvider.notifier)
        .declineFriendRequest(fromUserId, toUserId);
    ref.invalidate(friendRequestsStreamProvider);
  }

  void _removeFriend(String friendId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final shouldRemove = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove Friend'),
          content: const Text('Are you sure you want to remove this friend?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        ),
      );

      if (shouldRemove ?? false) {
        await ref.read(friendsProvider.notifier).removeFriend(friendId);
        ref.invalidate(friendsStreamProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendRequestsAsyncValue = ref.watch(friendRequestsStreamProvider);
    final friendsAsyncValue = ref.watch(friendsStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Friends'),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _searchController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: 'Search by email',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchFriend,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_searchResult != null) ...[
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(_searchResult!.avatarUrl),
                ),
                title: Text(
                  _searchResult!.username,
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
                subtitle: Text(
                  _searchResult!.email,
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () => _sendFriendRequest(_searchResult!),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (friendRequestsAsyncValue.when(
                data: (data) => data.isNotEmpty,
                loading: () => false,
                error: (error, stack) => false)) ...[
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Friend Requests',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    friendRequestsAsyncValue.when(
                      data: (friendRequests) => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: friendRequests.length,
                        itemBuilder: (context, index) {
                          final request = friendRequests[index];
                          return Consumer(
                            builder: (context, ref, child) {
                              final userAsyncValue = ref.watch(
                                  appUserDetailsProvider(request.fromUserId));
                              return userAsyncValue.when(
                                data: (user) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: AssetImage(user.avatarUrl),
                                  ),
                                  title: Text(user.username),
                                  subtitle: Text(user.email),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check),
                                        onPressed: () => _acceptFriendRequest(
                                            request.fromUserId,
                                            request.toUserId),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => _declineFriendRequest(
                                            request.fromUserId,
                                            request.toUserId),
                                      ),
                                    ],
                                  ),
                                ),
                                loading: () =>
                                    const CircularProgressIndicator(),
                                error: (error, stack) => Text('Error: $error'),
                              );
                            },
                          );
                        },
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Friends',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  friendsAsyncValue.when(
                    data: (friends) => friends.isEmpty
                        ? const Text(
                            'You have no friends yet. Use the search above to add friends.',
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: friends.length,
                            itemBuilder: (context, index) {
                              final friend = friends[index];
                              return Consumer(
                                builder: (context, ref, child) {
                                  final userAsyncValue = ref.watch(
                                      appUserDetailsProvider(friend.friendId));
                                  return userAsyncValue.when(
                                    data: (user) => ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            AssetImage(user.avatarUrl),
                                      ),
                                      title: Text(
                                        user.username[0].toUpperCase() +
                                            user.username.substring(1),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                      ),
                                      subtitle: Text(
                                        user.email,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorDark),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () =>
                                            _removeFriend(friend.friendId),
                                      ),
                                    ),
                                    loading: () =>
                                        const CircularProgressIndicator(),
                                    error: (error, stack) =>
                                        Text('Error: $error'),
                                  );
                                },
                              );
                            },
                          ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
