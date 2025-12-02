import 'dart:async';
import 'package:flutter/material.dart';
import 'package:esante/services/chatbot/chatbot_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isLoading = false;
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0; // Durée en secondes
  
  // Langues disponibles pour l'audio
  final List<Map<String, String>> _availableLanguages = [
    {'code': 'fr-FR', 'name': 'Français', 'locale': 'fr_FR'},
    {'code': 'wo-SN', 'name': 'Wolof', 'locale': 'wo_SN'},
    {'code': 'en-US', 'name': 'English', 'locale': 'en_US'},
  ];
  
  String _selectedLanguageCode = 'fr-FR';
  String _selectedLocale = 'fr_FR';

  // Message de bienvenue au démarrage
  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeSpeech();
    _messages.add({
      'text':
          'Bonjour ! Je suis votre assistant santé. Comment puis-je vous aider aujourd\'hui ?',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  Future<void> _initializeSpeech() async {
    try {
      // Demander la permission du microphone d'abord
      PermissionStatus micPermission = await Permission.microphone.status;
      if (!micPermission.isGranted) {
        micPermission = await Permission.microphone.request();
        if (!micPermission.isGranted) {
          if (mounted) {
            setState(() {
              _speechAvailable = false;
            });
            debugPrint('Permission microphone refusée');
          }
          return;
        }
      }

      bool available = await _speech.initialize(
        onStatus: (status) {
          if (mounted) {
            setState(() {
              if (status == 'done' || status == 'notListening') {
                _isListening = false;
              }
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: ${error.errorMsg}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
      );
      if (mounted) {
        setState(() {
          _speechAvailable = available;
        });
        if (!available) {
          debugPrint('Reconnaissance vocale non disponible après initialisation');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _speechAvailable = false;
        });
        debugPrint('Erreur d\'initialisation de la reconnaissance vocale: $e');
      }
    }
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage(_selectedLanguageCode);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
      });
    });
  }
  
  Future<void> _changeLanguage(String languageCode, String locale) async {
    setState(() {
      _selectedLanguageCode = languageCode;
      _selectedLocale = locale;
    });
    
    // Mettre à jour la langue TTS
    await _flutterTts.setLanguage(languageCode);
    
    // Si on est en train d'écouter, arrêter et redémarrer avec la nouvelle langue
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _recordingDuration = 0;
      });
      _stopRecordingTimer();
    }
  }
  
  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Choisir la langue pour l\'audio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A7A33),
                ),
              ),
            ),
            const Divider(),
            ..._availableLanguages.map((lang) => ListTile(
              leading: Icon(
                _selectedLanguageCode == lang['code']
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: _selectedLanguageCode == lang['code']
                    ? const Color(0xFF0A7A33)
                    : Colors.grey,
              ),
              title: Text(
                lang['name']!,
                style: TextStyle(
                  fontWeight: _selectedLanguageCode == lang['code']
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: _selectedLanguageCode == lang['code']
                      ? const Color(0xFF0A7A33)
                      : Colors.black87,
                ),
              ),
              subtitle: Text(
                'Code: ${lang['code']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              onTap: () {
                _changeLanguage(lang['code']!, lang['locale']!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Langue changée: ${lang['name']}'),
                    backgroundColor: const Color(0xFF0A7A33),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
    } else {
      setState(() {
        _isSpeaking = true;
      });
      await _flutterTts.speak(text);
    }
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  void _startListening() async {
    // Vérifier la permission du microphone
    PermissionStatus micPermission = await Permission.microphone.status;
    if (!micPermission.isGranted) {
      micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permission microphone requise. Veuillez l\'autoriser dans les paramètres.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Paramètres',
                onPressed: openAppSettings,
              ),
            ),
          );
        }
        return;
      }
    }

    // Vérifier et réinitialiser si nécessaire
    if (!_speechAvailable) {
      // Réessayer l'initialisation
      await _initializeSpeech();
      if (!_speechAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'La reconnaissance vocale n\'est pas disponible. Vérifiez les permissions du microphone.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
    }

    if (_isListening) {
      await _speech.stop();
      _stopRecordingTimer();
      setState(() {
        _isListening = false;
        _recordingDuration = 0;
      });
      return;
    }

    setState(() {
      _isListening = true;
      _recordingDuration = 0;
    });
    
    // Démarrer le timer pour suivre la durée
    _startRecordingTimer();

    try {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });
          if (result.finalResult) {
            _stopRecordingTimer();
            setState(() {
              _isListening = false;
              _recordingDuration = 0;
            });
            // Envoie automatiquement le message après la reconnaissance
            if (result.recognizedWords.trim().isNotEmpty) {
              _sendMessage();
            }
          }
        },
        localeId: _selectedLocale,
        listenMode: stt.ListenMode.confirmation,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'écoute: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _stopListening() async {
    await _speech.stop();
    _stopRecordingTimer();
    setState(() {
      _isListening = false;
      _recordingDuration = 0;
    });
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isListening) {
        setState(() {
          _recordingDuration++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Prépare l'historique de conversation
      final history = _messages
          .where((m) => !m['isUser'])
          .map((m) => {
                'role': 'assistant',
                'content': m['text'] as String,
              })
          .toList();

      // Appelle l'API IA
      final response = await ChatBotService.sendMessage(
        message: message,
        conversationHistory: history,
      );

      setState(() {
        _messages.add({
          'text': response,
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
      // Lecture automatique de la réponse
      _speak(response);
    } catch (e) {
      setState(() {
        _messages.add({
          'text':
              'Désolé, une erreur s\'est produite. Vérifiez votre connexion internet ou votre clé API OpenAI.',
          'isUser': false,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
      });
    }

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
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    _stopRecordingTimer();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A7A33),
        title: const Text(
          'Assistant IA',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Bouton de sélection de langue
          IconButton(
            icon: const Icon(
              Icons.language,
              color: Colors.white,
            ),
            onPressed: _showLanguageSelector,
            tooltip: 'Choisir la langue',
          ),
          IconButton(
            icon: Icon(
              _isSpeaking ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
            ),
            onPressed: () {
              if (_isSpeaking) {
                _stopSpeaking();
              } else {
                // Trouve le dernier message du chatbot et le lit
                for (int i = _messages.length - 1; i >= 0; i--) {
                  if (!_messages[i]['isUser']) {
                    _speak(_messages[i]['text'] as String);
                    break;
                  }
                }
              }
            },
            tooltip: _isSpeaking ? 'Arrêter la lecture' : 'Lire la dernière réponse',
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone de messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  // Indicateur de chargement
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFF0A7A33),
                          child: Icon(Icons.smart_toy, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Text('L\'assistant écrit...'),
                      ],
                    ),
                  );
                }

                final message = _messages[index];
                final isUser = message['isUser'] as bool;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment:
                        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        CircleAvatar(
                          backgroundColor: const Color(0xFF0A7A33),
                          child: const Icon(Icons.smart_toy, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFF0A7A33)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  message['text'] as String,
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (!isUser) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _speak(message['text'] as String),
                                  child: Icon(
                                    Icons.volume_up,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 12),
                        const CircleAvatar(
                          backgroundColor: Color(0xFF1AAA42),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Zone de saisie
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Bouton microphone
                  CircleAvatar(
                    backgroundColor: _isListening
                        ? Colors.red
                        : const Color(0xFF0A7A33),
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                      ),
                      onPressed: _isLoading ? null : _startListening,
                      tooltip: _isListening ? 'Arrêter l\'enregistrement' : 'Parler',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Stack(
                      children: [
                        TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: _isListening
                                ? 'Parlez maintenant...'
                                : 'Tapez votre message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: _isListening
                                    ? Colors.red
                                    : Colors.grey[300]!,
                                width: _isListening ? 2 : 1,
                              ),
                            ),
                            filled: true,
                            fillColor: _isListening
                                ? Colors.red.withOpacity(0.1)
                                : Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          enabled: !_isLoading && !_isListening,
                        ),
                        // Affichage de la durée pendant l'enregistrement
                        if (_isListening)
                          Positioned(
                            right: 16,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.mic,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDuration(_recordingDuration),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0A7A33),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _isLoading || _isListening ? null : _sendMessage,
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
}

