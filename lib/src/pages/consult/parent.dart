import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neurossistant/src/localization/app_localizations.dart';
import 'package:neurossistant/src/pages/consult/consult.dart';

class ParentChatList extends StatelessWidget {
  const ParentChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'Parent')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error fetching Parents'),
          );
        }
        final List<Pengguna> parents = snapshot.data!.docs
            .map((doc) => Pengguna.fromFirestore(doc))
            .toList();
        return ListView.builder(
          itemCount: parents.length,
          itemBuilder: (context, index) {
            return ParentChatListItem(parents[index]);
          },
        );
      },
    );
  }
}

class ParentChatListItem extends StatelessWidget {
  final Pengguna parent;

  const ParentChatListItem(this.parent, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(parent.name),
      subtitle: Text(
          '${AppLocalizations.of(context)!.translate('consult_parent_nd_tags1') ?? 'Neurodivergent tags:'} ${parent.userTags.join(', ')}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParentChatScreen(parent),
          ),
        );
      },
    );
  }
}

class ParentChatScreen extends StatelessWidget {
  final Pengguna parent;

  const ParentChatScreen(this.parent, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${parent.name}'),
      ),
      body: const Center(
        child: Text('Chat UI goes here'),
      ),
    );
  }
}

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ParentNotifScreen extends StatelessWidget {
  const ParentNotifScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
