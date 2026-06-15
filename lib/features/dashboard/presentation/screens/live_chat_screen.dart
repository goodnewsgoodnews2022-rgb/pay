// ignore_for_file: deprecated_member_use, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MessageModel {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? attachmentName;
  final IconData? attachmentIcon;

  MessageModel({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.attachmentName,
    this.attachmentIcon,
  });
}

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Simulated Agent Configuration
  final bool _isAgentOnline = true;
  final String _agentName = 'Sarah (Fintech Support)';

  // Store Chat History state
  final List<MessageModel> _chatHistory = [
    MessageModel(
      text: "Hello! Welcome to Pay Fintech Support. How can I help you manage your funds today?",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    MessageModel(
      text: "Hi, my transfer to account card *8921 is still showing pending since yesterday.",
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
  ];

  void _sendMessage({String? attachmentName, IconData? attachmentIcon}) {
    if (_messageController.text.trim().isEmpty && attachmentName == null) return;

    setState(() {
      _chatHistory.add(
        MessageModel(
          text: _messageController.text,
          isUser: true,
          timestamp: DateTime.now(),
          attachmentName: attachmentName,
          attachmentIcon: attachmentIcon,
        ),
      );
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulated Automated Agent Response system loop after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _chatHistory.add(
          MessageModel(
            text: "Thank you for the update. I am checking the status of transaction linked to card ending in 8921 directly on our payment ledger right now. One moment please.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentOptions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF151424) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Attach Verification Evidence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
              ),
              Divider(height: 1, color: theme.dividerColor),
              ListTile(
                leading: Icon(Icons.image_outlined, color: theme.colorScheme.primary),
                title: const Text('Upload Screenshot / Image'),
                onTap: () {
                  Navigator.pop(context);
                  _sendMessage(attachmentName: 'screenshot_receipt.png', attachmentIcon: Icons.image);
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf_outlined, color: Colors.redAccent),
                title: const Text('Upload Bank Statement Document'),
                onTap: () {
                  Navigator.pop(context);
                  _sendMessage(attachmentName: 'bank_statement.pdf', attachmentIcon: Icons.picture_as_pdf);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accentPrimaryColor = theme.colorScheme.primary != theme.scaffoldBackgroundColor 
        ? theme.colorScheme.primary 
        : const Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accentPrimaryColor.withOpacity(0.12),
                  child: Icon(Icons.support_agent_rounded, color: accentPrimaryColor, size: 20),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _isAgentOnline ? const Color(0xFF10B981) : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: isDark ? const Color(0xFF0A0A10) : Colors.white, width: 1.5),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_agentName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 2),
                  Text(
                    _isAgentOnline ? 'Online • Response within 2 mins' : 'Offline',
                    style: TextStyle(fontSize: 11, color: _isAgentOnline ? const Color(0xFF10B981) : Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF151424) : Colors.grey[50],
      ),
      body: Column(
        children: [
          // Chat View History Module Panel Container
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final message = _chatHistory[index];
                return _buildChatBubble(message, theme, isDark, accentPrimaryColor);
              },
            ),
          ),
          
          // Sticky Input Console Field Component
          _buildMessageInputConsole(theme, isDark, accentPrimaryColor),
        ],
      ),
    );
  }

  Widget _buildChatBubble(MessageModel msg, ThemeData theme, bool isDark, Color primary) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: msg.isUser 
              ? primary 
              : (isDark ? const Color(0xFF151424) : Colors.grey[100]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
          border: msg.isUser ? null : Border.all(color: isDark ? const Color(0xFF26243C) : Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (msg.attachmentName != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: msg.isUser ? Colors.black : theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(msg.attachmentIcon, size: 18, color: msg.isUser ? Colors.white : primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        msg.attachmentName!,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: msg.isUser ? Colors.white : theme.colorScheme.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (msg.text.isNotEmpty)
              Text(
                msg.text,
                style: TextStyle(
                  color: msg.isUser ? Colors.white : theme.colorScheme.onSurface,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputConsole(ThemeData theme, bool isDark, Color primary) {
    final consoleBg = isDark ? const Color(0xFF151424) : Colors.white;
    final inputFieldBg = isDark ? const Color(0xFF0A0A10) : Colors.grey[100];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: consoleBg,
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF26243C) : Colors.grey[200]!)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_circle_outline_rounded, color: primary, size: 26),
              onPressed: _showAttachmentOptions, // Fire Attachment Sheet Engine
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: inputFieldBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Type your support request...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: primary,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                onPressed: () => _sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}