import 'package:flutter/material.dart';
import 'package:pinterest_clone/features/auth/presentation/widgets/pinterest_auth_widgets.dart';

// Message Model
class MessageModel {
  final String id;
  final String senderName;
  final String senderAvatar;
  final String messagePreview;
  final String timestamp;
  final bool isUnread;

  MessageModel({
    required this.id,
    required this.senderName,
    required this.senderAvatar,
    required this.messagePreview,
    required this.timestamp,
    this.isUnread = false,
  });
}

class InboxScreen extends StatelessWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            
            // Messages Section
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Messages'),
                    _buildMessagesList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Inbox',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 28),
            onPressed: () {
              print('Compose message tapped');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          TextButton(
            onPressed: () {
              print('See all tapped');
            },
            child: Row(
              children: const [
                Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: Colors.black,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    final messages = [
      MessageModel(
        id: '1',
        senderName: 'Pinterest India',
        senderAvatar: 'https://logo.clearbit.com/pinterest.com',
        messagePreview: 'Sent a Pin',
        timestamp: '4y',
        isUnread: false,
      ),
    ];

    return Column(
      children: [
        // Existing messages
        ...messages.map((message) => _buildMessageTile(message)).toList(),
        
        // Invite friends card
        _buildInviteFriendsCard(),
      ],
    );
  }

  Widget _buildMessageTile(MessageModel message) {
    return InkWell(
      onTap: () {
        print('Message ${message.id} tapped');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Avatar
           const PinterestAuthLogo(assetPath: 'assets/icons/pinterest svg icon.svg',),
            
            
            const SizedBox(width: 12),
            
            // Message details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.senderName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: message.isUnread ? FontWeight.bold : FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.messagePreview,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Timestamp
            Text(
              message.timestamp,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInviteFriendsCard() {
    return InkWell(
      onTap: () {
        print('Invite friends tapped');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_outlined,
                size: 28,
                color: Colors.grey[800],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invite your friends',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Connect to start chatting',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
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


