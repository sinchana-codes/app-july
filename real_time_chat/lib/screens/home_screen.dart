import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),

        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = userSnapshot.data!.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('messages')
                .orderBy('time', descending: true)
                .snapshots(),

            builder: (context, messageSnapshot) {
              if (!messageSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final messages = messageSnapshot.data!.docs;

              // Find users with whom current user has chatted
              final recentUserIds = <String>[];

              for (var message in messages) {
                final sender = message['senderId'];
                final receiver = message['receiverId'];

                if (sender == currentUser!.uid) {
                  if (!recentUserIds.contains(receiver)) {
                    recentUserIds.add(receiver);
                  }
                }

                if (receiver == currentUser.uid) {
                  if (!recentUserIds.contains(sender)) {
                    recentUserIds.add(sender);
                  }
                }
              }

              return ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Recent Chats",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (recentUserIds.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("No recent chats"),
                    ),

                  ...recentUserIds.map((userId) {
                    final matchingUsers = users
                        .where((user) => user.id == userId)
                        .toList();

                    if (matchingUsers.isEmpty) {
                      return const SizedBox();
                    }

                    final user = matchingUsers.first;

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(user['name']),
                      subtitle: Text(user['email']),
                      trailing: const Icon(Icons.chat),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              userId: user.id,
                              userName: user['name'],
                            ),
                          ),
                        );
                      },
                    );
                  }),

                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Available Users",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ...users.map((user) {
                    // Don't show yourself
                    if (user.id == currentUser!.uid) {
                      return const SizedBox();
                    }

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(user['name']),
                      subtitle: Text(user['email']),
                      trailing: const Icon(Icons.chat),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              userId: user.id,
                              userName: user['name'],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}