import 'package:application/app/theme/app_colors.dart';
import 'package:application/services/ai_controller.dart';
import 'package:application/services/auth_api_client.dart';
import 'package:application/state/cloud_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Full-screen AI chat, similar to wellness apps.
class ChatAiPage extends StatefulWidget {
  const ChatAiPage({super.key});

  @override
  State<ChatAiPage> createState() => _ChatAiPageState();
}

class _ChatAiPageState extends State<ChatAiPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <({String role, String text})>[];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final controller = context.read<AiController>();
    final cloud = context.read<CloudController>();
    final session = cloud.session;
    if (session == null) return;

    setState(() {
      _messages.add((role: 'user', text: text));
      _messageController.clear();
    });
    _scrollToBottom();

    var ok = await controller.sendChat(
      baseUrl: apiBaseUrl(),
      accessToken: session.accessToken,
      message: text,
    );
    if (!ok && controller.state == AiState.consentRequired) {
      final granted = await controller.enableConsent(
        baseUrl: apiBaseUrl(),
        accessToken: session.accessToken,
      );
      if (granted) {
        ok = await controller.sendChat(
          baseUrl: apiBaseUrl(),
          accessToken: session.accessToken,
          message: text,
        );
      }
    }
    if (!mounted) return;
    setState(() {
      if (ok && controller.lastReply != null) {
        _messages.add((role: 'ai', text: controller.lastReply!));
      } else {
        final detail = controller.errorDetail ?? '';
        final errorMsg = controller.state == AiState.paymentRequired
            ? "This feature requires a Pro subscription."
            : controller.state == AiState.consentRequired
                ? 'To use the chat, you must enable AI consent.'
                : 'An error occurred (${controller.errorCode ?? 'unknown'})${detail.isNotEmpty ? ': $detail' : ''}. Please try again.';
        _messages.add((role: 'ai', text: errorMsg));
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat AI')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Talk to your wellness assistant.\n'
                            'Ask for advice, vent or explore your thoughts.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textFaint),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final m = _messages[i];
                          final isUser = m.role == 'user';
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * (MediaQuery.of(context).size.width > 800 ? 0.6 : 0.8),
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? AppColors.accent.withValues(alpha: 0.2)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                m.text,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          autofocus: true,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Type a message…',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filled(
                        onPressed: _send,
                        icon: const Icon(Icons.send_rounded),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
