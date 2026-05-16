import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../services/ai_service.dart';
import '../services/voice_service.dart';
import '../services/stt_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isListening = false;
  String _voiceText = '';
  late AnimationController _dotCtrl;

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<GameProvider>();
      _messages.add(_ChatMessage(
        text: p.t(
          'Сәлем! Мен Бота, сенің көмекшіңмін. Қазақстан туралы не білгің келеді?',
          'Привет! Я Бота, твой помощник. Что ты хочешь узнать о Казахстане?',
        ),
        isUser: false,
      ));
      setState(() {});
    });
  }

  @override
  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _dotCtrl.dispose();
    VoiceService.stop();
    SttService.stopListening();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;
    _textCtrl.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    final history = _messages
        .where((m) => m != _messages.last)
        .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
        .toList();

    final reply = await AiService.sendMessage(text, history);

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(text: reply, isUser: false));
      _isLoading = false;
    });
    _scrollToBottom();
    // Speak the assistant reply with the ElevenLabs voice.
    // No-op when ELEVENLABS_API_KEY is absent or sound is muted.
    final p = context.read<GameProvider>();
    if (!p.profile.soundMuted) {
      unawaited(VoiceService.speak(reply));
    }
  }

  Future<void> _toggleVoiceInput() async {
    final isRussian = context.read<GameProvider>().isRussian;

    if (_isListening) {
      await SttService.stopListening();
      setState(() => _isListening = false);
      if (_voiceText.trim().isNotEmpty) {
        await _sendMessage(_voiceText);
        _voiceText = '';
      }
      return;
    }

    final available = await SttService.isAvailable;
    if (!available) {
      setState(() {
        _messages.add(_ChatMessage(
          text: 'Микрофон недоступен. Проверь разрешения.',
          isUser: false,
        ));
      });
      _scrollToBottom();
      return;
    }

    setState(() {
      _isListening = true;
      _voiceText = '';
    });

    await SttService.startListening(
      localeId: isRussian ? 'ru_RU' : 'kk_KZ',
      onResult: (text) {
        setState(() => _voiceText = text);
      },
      onDone: () {
        setState(() => _isListening = false);
        if (_voiceText.trim().isNotEmpty) {
          _sendMessage(_voiceText);
          _voiceText = '';
        }
      },
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<GameProvider>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1b1e2b),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildChatHeader(p),
          const Divider(color: Colors.white12, height: 1),
          Expanded(child: _buildMessagesList(p)),
          if (_isLoading) _buildTypingIndicator(),
          _buildQuickActions(p),
          _buildInputBar(p),
        ],
      ),
    );
  }

  Widget _buildHandle() => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _buildChatHeader(GameProvider p) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset('assets/cumbot/glad.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.t('Бота Ассистент', 'Бота Ассистент'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF58CC02),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    p.t('Желіде', 'Онлайн'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => p.toggleTts(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              p.isTtsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: Colors.white60,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.close_rounded, color: Colors.white60, size: 20),
          ),
        ),
      ],
    ),
  );

  Widget _buildMessagesList(GameProvider p) => ListView.builder(
    controller: _scrollCtrl,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    itemCount: _messages.length,
    itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
  );

  Widget _buildMessageBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!msg.isUser) ...[
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 8, bottom: 2),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/cumbot/glad.png', fit: BoxFit.cover),
                ),
              ),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: msg.isUser
                      ? AppColors.primary
                      : const Color(0xFF2d3248),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                    bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: msg.isUser ? Colors.white : Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2d3248),
        borderRadius: BorderRadius.circular(18),
      ),
      child: AnimatedBuilder(
        animation: _dotCtrl,
        builder: (_, a0) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.3;
            final val = ((_dotCtrl.value + delay) % 1.0);
            final opacity = 0.3 + 0.7 * (val < 0.5 ? val * 2 : 2 - val * 2);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    ),
  );

  Widget _buildQuickActions(GameProvider p) {
    if (_messages.length > 2) return const SizedBox.shrink();
    final actions = [
      {
        'icon': Icons.quiz_rounded,
        'textKz': 'Викторинаға көмек',
        'textRu': 'Помоги с викториной',
      },
      {
        'icon': Icons.info_outline_rounded,
        'textKz': 'Қазақстан туралы',
        'textRu': 'Расскажи о Казахстане',
      },
      {
        'icon': Icons.lightbulb_outline_rounded,
        'textKz': 'Қызық факт',
        'textRu': 'Интересный факт',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: actions.map((a) => GestureDetector(
            onTap: () => _sendMessage(p.isRussian ? a['textRu'] as String : a['textKz'] as String),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(a['icon'] as IconData, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    p.isRussian ? a['textRu'] as String : a['textKz'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildInputBar(GameProvider p) => Container(
    padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
    decoration: BoxDecoration(
      color: const Color(0xFF252940),
      border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
    ),
    child: Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _isListening ? AppColors.primary.withValues(alpha: 0.15) : const Color(0xFF1b1e2b),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isListening ? AppColors.primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: _isListening
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _voiceText.isEmpty ? p.t('Тыңдап тұрмын...', 'Слушаю...') : _voiceText,
                      style: TextStyle(
                        color: _voiceText.isEmpty ? Colors.white.withValues(alpha: 0.5) : Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  )
                : TextField(
                    controller: _textCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: p.t('Сұрақ жаз...', 'Напиши вопрос...'),
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: _sendMessage,
                    textInputAction: TextInputAction.send,
                  ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _toggleVoiceInput,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isListening ? AppColors.error : const Color(0xFF2d3248),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isListening ? AppColors.error.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              _isListening ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _sendMessage(_textCtrl.text),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
    ),
  );
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
