// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_diary/src/models/others/app_user_model.dart';
import 'package:pet_diary/src/models/others/friend_request_model.dart';
import 'package:pet_diary/src/models/others/friend_model.dart';
import 'package:pet_diary/src/providers/others_providers/friend_provider.dart';
import 'package:pet_diary/src/providers/others_providers/friend_search_provider.dart';
import 'package:pet_diary/src/providers/others_providers/app_user_provider.dart';
import 'package:pet_diary/src/providers/others_providers/friends_notifier_provider.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  AppUserModel? _searchResult;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchFriend(BuildContext context) async {
    final email = _searchController.text.trim().toLowerCase();
    await ref.read(friendsSearchProvider.notifier).searchUserByEmail(email);

    setState(() {
      _searchResult = ref.read(friendsSearchProvider).isNotEmpty
          ? ref.read(friendsSearchProvider).first
          : null;
    });
  }

  void _sendFriendRequest(AppUserModel friend) async {
    await ref
        .read(friendsNotifierProvider.notifier)
        .sendFriendRequest(friend.id);
    _searchController.clear();
    setState(() {
      _searchResult = null;
    });
  }

  void _cancelFriendRequest(String toUserId) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'Cancel Friend Request',
      'Are you sure you want to cancel this friend request?',
    );
    if (confirmed) {
      await ref.read(friendsNotifierProvider.notifier).cancelFriendRequest(
            FirebaseAuth.instance.currentUser!.uid,
            toUserId,
          );
    }
  }

  void _acceptFriendRequest(String fromUserId, String toUserId) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'Accept Friend Request',
      'Are you sure you want to accept this friend request?',
    );
    if (confirmed) {
      await ref
          .read(friendsNotifierProvider.notifier)
          .acceptFriendRequest(fromUserId, toUserId);
      ref.invalidate(friendRequestsStreamProvider);
      ref.invalidate(friendsStreamProvider);
    }
  }

  void _removeFriend(String friendId) async {
    final confirmed = await _showConfirmationDialog(
      context,
      'Remove Friend',
      'Are you sure you want to remove this friend?',
    );
    if (confirmed) {
      await ref.read(friendsNotifierProvider.notifier).removeFriend(friendId);
      ref.invalidate(friendsStreamProvider);
    }
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String title, String content) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              title,
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
            content: Text(
              content,
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
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
                  'Confirm',
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
              ),
            ],
          ),
        ) ??
        false;
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
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColorDark,
          size: 20,
        ),
        toolbarHeight: 50,
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildSearchResults(),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  friendsAsyncValue.when(
                    data: (friends) => _buildFriendsContainer(friends),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error: $error',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ),
                  friendRequestsAsyncValue.when(
                    data: (friendRequests) =>
                        _buildRequestsContainer(friendRequests),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error: $error',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: _searchResult != null || _searchController.text.isNotEmpty
            ? BorderRadius.zero
            : const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 15, right: 8),
        child: TextField(
          controller: _searchController,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: 'Search by email',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.search,
                size: 30,
              ),
              onPressed: () => _searchFriend(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return _searchResult != null
        ? _buildSearchResult()
        : (_searchController.text.isNotEmpty
            ? _buildNoResultMessage()
            : const SizedBox.shrink());
  }

  Widget _buildSearchResult() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          Divider(
            color: Theme.of(context).colorScheme.surface,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(
                _searchResult!.avatarUrl,
              ),
              radius: 30.0,
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
        ],
      ),
    );
  }

  Widget _buildNoResultMessage() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          Divider(
            color: Theme.of(context).colorScheme.surface,
          ),
          ListTile(
            leading: const Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.red,
            ),
            title: Text(
              'No user found.',
              style: TextStyle(color: Theme.of(context).primaryColorDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsContainer(List<Friend> friends) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friends',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.surface,
            thickness: 1.0,
          ),
          friends.isNotEmpty
              ? Column(
                  children: friends
                      .map((friend) => Consumer(
                            builder: (context, ref, child) {
                              final userAsyncValue = ref.watch(
                                  appUserDetailsProvider(friend.friendId));
                              return userAsyncValue.when(
                                data: (user) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: AssetImage(user.avatarUrl),
                                  ),
                                  title: Text(
                                    user.username,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    user.email,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeFriend(user.id),
                                  ),
                                ),
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (error, stack) => Text(
                                  'Error: $error',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              );
                            },
                          ))
                      .toList(),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'You have no friends yet!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRequestsContainer(List<FriendRequest> friendRequests) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final incomingRequests =
        friendRequests.where((req) => req.toUserId == currentUserId).toList();
    final outgoingRequests =
        friendRequests.where((req) => req.fromUserId == currentUserId).toList();

    return Column(
      children: [
        _buildRequestSection('Incoming Requests', incomingRequests, false),
        _buildRequestSection('Outgoing Requests', outgoingRequests, true),
      ],
    );
  }

  Widget _buildRequestSection(
      String title, List<FriendRequest> requests, bool isOutgoing) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.surface,
            thickness: 1.0,
          ),
          requests.isNotEmpty
              ? Column(
                  children: requests.map((request) {
                    final userId =
                        isOutgoing ? request.toUserId : request.fromUserId;
                    return Consumer(
                      builder: (context, ref, child) {
                        final userAsyncValue =
                            ref.watch(appUserDetailsProvider(userId));
                        return userAsyncValue.when(
                          data: (user) => ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(user.avatarUrl),
                            ),
                            title: Text(
                              user.username,
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              user.email,
                              style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 12,
                              ),
                            ),
                            trailing: isOutgoing
                                ? IconButton(
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () =>
                                        _cancelFriendRequest(user.id),
                                  )
                                : Row(
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
                                        onPressed: () => _cancelFriendRequest(
                                            request.fromUserId),
                                      ),
                                    ],
                                  ),
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Text(
                            'Error: $error',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      isOutgoing
                          ? 'No outgoing requests'
                          : 'No incoming requests',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
