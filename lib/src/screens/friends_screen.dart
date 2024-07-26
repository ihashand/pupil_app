import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/app_user_model.dart';
import 'package:pet_diary/src/providers/friend_provider.dart';
import 'package:pet_diary/src/providers/app_user_provider.dart';
import 'package:pet_diary/src/providers/friend_search_provider.dart';
import 'package:pet_diary/src/providers/friends_notifier_provider.dart';
import 'package:pet_diary/src/screens/friend_profile_screen.dart';

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
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Remove',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'F R I E N D S',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).primaryColorDark, size: 20),
        toolbarHeight: 50,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: _searchResult == null
                            ? const Radius.circular(12)
                            : const Radius.circular(0),
                        bottomRight: _searchResult == null
                            ? const Radius.circular(12)
                            : const Radius.circular(0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Divider(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10, top: 5),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_searchResult != null) ...[
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Divider(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(_searchResult!.avatarUrl),
                      ),
                      title: Text(
                        _searchResult!.username,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark),
                      ),
                      subtitle: Text(
                        _searchResult!.email,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorDark),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: () => _sendFriendRequest(_searchResult!),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (friendRequestsAsyncValue.when(
                data: (data) => data.isNotEmpty,
                loading: () => false,
                error: (error, stack) => false)) ...[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 10.0, top: 15, bottom: 10),
                          child: Text(
                            'F R I E N D   R E Q U E S T S',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Divider(
                          color: Theme.of(context).colorScheme.surface,
                        ),
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
                                      appUserDetailsProvider(
                                          request.fromUserId));
                                  return userAsyncValue.when(
                                    data: (user) => ListTile(
                                      leading: GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FriendProfileScreen(
                                              userId: user.id,
                                            ),
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          backgroundImage:
                                              AssetImage(user.avatarUrl),
                                        ),
                                      ),
                                      title: Text(user.username),
                                      subtitle: Text(user.email),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check),
                                            onPressed: () =>
                                                _acceptFriendRequest(
                                                    request.fromUserId,
                                                    request.toUserId),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () =>
                                                _declineFriendRequest(
                                                    request.fromUserId,
                                                    request.toUserId),
                                          ),
                                        ],
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
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: 10, right: 10, bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 15, bottom: 5),
                      child: Text(
                        'Friend list',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    friendsAsyncValue.when(
                      data: (friends) => friends.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'You have no friends yet. Use the search above to find your friends.',
                              ),
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
                                        appUserDetailsProvider(
                                            friend.friendId));
                                    return userAsyncValue.when(
                                      data: (user) => ListTile(
                                        leading: GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FriendProfileScreen(
                                                userId: user.id,
                                              ),
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            backgroundImage:
                                                AssetImage(user.avatarUrl),
                                          ),
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
            ),
          ],
        ),
      ),
    );
  }
}
