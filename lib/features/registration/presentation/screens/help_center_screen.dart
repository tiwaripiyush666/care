import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book a caregiver?',
      'answer': 'Go to the Home dashboard, tap on any care category, select a provider profile, choose your slot details, and complete the payment.'
    },
    {
      'question': 'How can I apply a promo code?',
      'answer': 'On the login/signup screen, toggle the "Have a referral code?" checkbox, enter your code (e.g. WELCOME100 or SNABBIT250), and click Apply. The discount will automatically apply at checkout.'
    },
    {
      'question': 'What are the payment methods supported?',
      'answer': 'We support UPI (Instant verification), Credit/Debit Cards, and Cash on Delivery (COD).'
    },
    {
      'question': 'How does live tracking work?',
      'answer': 'Once a caregiver is en route to your location, you can view their real-time coordinates, path, and updated ETA on the Track Booking map.'
    },
  ];

  void _openChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return const _FAQChatbotSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryContainer),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: AppTheme.primaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppTheme.roundedLg),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 48, color: AppTheme.primaryContainer),
                    const SizedBox(height: 12),
                    const Text(
                      'Have Questions?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Search our FAQs below or start a live support conversation with our automated assistant CareBot.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. FAQs Accordion Title
              const Text(
                'FREQUENTLY ASKED QUESTIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              // Accordions
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _faqs.length,
                itemBuilder: (context, index) {
                  final faq = _faqs[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                      side: const BorderSide(color: AppTheme.outlineVariant),
                    ),
                    child: ExpansionTile(
                      shape: const Border(),
                      title: Text(
                        faq['question']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      iconColor: AppTheme.primaryContainer,
                      collapsedIconColor: AppTheme.outline,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                          child: Text(
                            faq['answer']!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // 3. Contact Support Directly
              const Text(
                'DIRECT CHANNELS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.email_outlined, size: 18),
                      label: const Text('Email Us'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryContainer,
                        side: const BorderSide(color: AppTheme.outlineVariant),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone_outlined, size: 18),
                      label: const Text('Call Helpline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryContainer,
                        side: const BorderSide(color: AppTheme.outlineVariant),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.roundedMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: AppTheme.background,
        child: ElevatedButton.icon(
          onPressed: _openChatbot,
          icon: const Icon(Icons.support_agent, color: Colors.white),
          label: const Text(
            'Chat with CareBot',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryContainer,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.roundedMd),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }
}

class _FAQChatbotSheet extends StatefulWidget {
  const _FAQChatbotSheet();

  @override
  State<_FAQChatbotSheet> createState() => _FAQChatbotSheetState();
}

class _FAQChatbotSheetState extends State<_FAQChatbotSheet> {
  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'text': 'Hello! I\'m CareBot, your support assistant. Choose a popular topic below or ask me any question directly.'
    }
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

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

  void _sendUserMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate Bot response matching keywords
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final responseText = _getResponse(text);
      setState(() {
        _messages.add({'sender': 'bot', 'text': responseText});
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  String _getResponse(String input) {
    final clean = input.toLowerCase();
    if (clean.contains('promo') || clean.contains('discount') || clean.contains('referral') || clean.contains('code')) {
      return 'We offer two promo codes:\n• WELCOME100: Get ₹100 discount on your booking.\n• SNABBIT250: Get ₹250 discount on your booking.\nYou can type and apply these during signup!';
    }
    if (clean.contains('pay') || clean.contains('payment') || clean.contains('upi') || clean.contains('cash') || clean.contains('cod')) {
      return 'You can pay instantly via UPI, Credit/Debit cards, or choose Cash on Delivery (COD) to pay after the care visit.';
    }
    if (clean.contains('address') || clean.contains('location') || clean.contains('home') || clean.contains('work')) {
      return 'Manage your coordinates in "Settings -> Saved Addresses". You can add new locations, detect them via GPS, or edit existing ones.';
    }
    if (clean.contains('human') || clean.contains('agent') || clean.contains('support') || clean.contains('help')) {
      return 'For human support, you can email us at support@caresphere.com or call our helpline at +91 99999 99999.';
    }
    return 'I\'m sorry, I couldn\'t find specific details for that query. Try asking about "Promo Codes", "Payments", "Addresses", or type "Human" to get support contacts.';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.roundedLg)),
          ),
          child: Column(
            children: [
              // Pull Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.support_agent, color: AppTheme.primaryContainer),
                    SizedBox(width: 8),
                    Text(
                      'CareBot Assistant',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: AppTheme.outlineVariant),

              // Message Thread List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isBot = msg['sender'] == 'bot';

                    return Align(
                      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isBot ? Colors.white : AppTheme.primaryContainer,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isBot ? const Radius.circular(0) : const Radius.circular(16),
                            bottomRight: isBot ? const Radius.circular(16) : const Radius.circular(0),
                          ),
                          border: isBot ? Border.all(color: AppTheme.outlineVariant) : null,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 2, offset: const Offset(0, 1)),
                          ],
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: Text(
                          msg['text']!,
                          style: TextStyle(
                            color: isBot ? AppTheme.onSurface : Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Option Chips Row
              if (!_isTyping)
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildChip('Promo Codes'),
                      _buildChip('Payments'),
                      _buildChip('Addresses'),
                      _buildChip('Human Support'),
                    ],
                  ),
                ),

              // Typings Indicator
              if (_isTyping)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'CareBot is typing...',
                      style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),

              // Input field
              Container(
                padding: const EdgeInsets.only(left: 16, right: 8, bottom: 24, top: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppTheme.outlineVariant)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppTheme.outline),
                        ),
                        style: const TextStyle(fontSize: 14, color: AppTheme.onSurface),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final txt = _controller.text.trim();
                        if (txt.isNotEmpty) {
                          _sendUserMessage(txt);
                          _controller.clear();
                        }
                      },
                      icon: const Icon(Icons.send, color: AppTheme.primaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryContainer),
        ),
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppTheme.outlineVariant),
        onPressed: () => _sendUserMessage(text),
      ),
    );
  }
}
