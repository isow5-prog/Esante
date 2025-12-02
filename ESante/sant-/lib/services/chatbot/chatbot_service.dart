import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatBotService {
  // Option 1: Hugging Face Inference API (gratuit, sans clé API requise pour les modèles publics)
  // Modèles optimisés pour le chat et la conversation
  static const List<String> _huggingFaceModels = [
    'microsoft/DialoGPT-medium', // Modèle de dialogue, plus fiable
    'facebook/blenderbot-400M-distill', // Modèle de conversation
    'google/flan-t5-base', // Modèle plus petit mais plus rapide
  ];
  
  // Option 2: OpenAI (nécessite une clé API)
  static const String _openAiApiKey = 'YOUR_API_KEY';
  static const String _openAiUrl = 'https://api.openai.com/v1/chat/completions';
  
  // Choisir le service à utiliser
  static const bool _useHuggingFace = true; // Utiliser Hugging Face par défaut (gratuit)
  static const bool _useFallbackOnly = false; // Utiliser les vraies API, pas seulement les réponses prédéfinies

  // Vérifie si la clé API OpenAI est configurée
  static bool get isOpenAiKeyConfigured {
    return _openAiApiKey.isNotEmpty && 
           _openAiApiKey != 'YOUR_API_KEY' && 
           !_openAiApiKey.startsWith('YOUR_');
  }

  // Envoie un message à l'IA et reçoit la réponse
  static Future<String> sendMessage({
    required String message,
    required List<Map<String, String>> conversationHistory,
  }) async {
    // Si on utilise uniquement les réponses prédéfinies (mode dégradé)
    if (_useFallbackOnly) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getEnhancedFallbackResponse(message);
    }
    
    // Essayer Hugging Face en premier (gratuit)
    if (_useHuggingFace) {
      try {
        final response = await _sendMessageHuggingFace(message, conversationHistory);
        // Si la réponse est valide, la retourner (minimum 3 caractères)
        final trimmedResponse = response.trim();
        if (trimmedResponse.isNotEmpty && 
            trimmedResponse.length >= 3 &&
            trimmedResponse.toLowerCase() != message.toLowerCase()) {
          return trimmedResponse;
        }
        // Sinon, essayer le fallback
      } catch (e) {
        // En cas d'erreur, continuer vers les autres options
      }
    }
    
    // Essayer OpenAI si la clé est configurée
    if (isOpenAiKeyConfigured) {
      try {
        return await _sendMessageOpenAI(message, conversationHistory);
      } catch (e) {
        // En cas d'erreur, continuer vers le fallback
      }
    }
    
    // Dernier recours : réponses prédéfinies améliorées
    return _getEnhancedFallbackResponse(message);
  }

  // Envoie un message via Hugging Face (gratuit, sans clé API)
  // Essaie plusieurs modèles jusqu'à ce qu'un fonctionne
  static Future<String> _sendMessageHuggingFace(
    String message,
    List<Map<String, String>> conversationHistory,
  ) async {
    // Essayer chaque modèle jusqu'à ce qu'un fonctionne
    for (String model in _huggingFaceModels) {
      try {
        // Essayer jusqu'à 2 fois (pour gérer le mode "sleep" des modèles)
        for (int attempt = 0; attempt < 2; attempt++) {
          final response = await _tryHuggingFaceModel(model, message, conversationHistory);
          if (response != null && response.trim().isNotEmpty && response.length >= 3) {
            return response;
          }
          
          // Si le modèle est en chargement (503), attendre un peu plus longtemps
          if (attempt == 0) {
            await Future.delayed(const Duration(seconds: 3));
          }
        }
      } catch (e) {
        // Continuer avec le modèle suivant
        continue;
      }
    }
    
    // Si aucun modèle n'a fonctionné, lancer une exception pour déclencher le fallback
    throw Exception('Aucun modèle Hugging Face disponible');
  }

  // Essaie un modèle Hugging Face spécifique
  static Future<String?> _tryHuggingFaceModel(
    String model,
    String message,
    List<Map<String, String>> conversationHistory,
  ) async {
    try {
      final url = 'https://api-inference.huggingface.co/models/$model';
      
      // Construire le contexte de conversation pour les modèles de dialogue
      String conversationContext = '';
      if (model.contains('DialoGPT') || model.contains('blenderbot')) {
        // Pour les modèles de dialogue, construire un historique de conversation
        for (var hist in conversationHistory.take(4)) {
          if (hist['role'] == 'user') {
            conversationContext += 'Utilisateur: ${hist['content']}\n';
          } else if (hist['role'] == 'assistant') {
            conversationContext += 'Assistant: ${hist['content']}\n';
          }
        }
      }
      
      // Prompt optimisé selon le type de modèle
      String prompt;
      Map<String, dynamic> parameters;
      
      if (model.contains('DialoGPT')) {
        // DialoGPT fonctionne mieux avec un format de conversation
        prompt = conversationContext.isNotEmpty 
            ? '$conversationContext Utilisateur: $message\nAssistant:'
            : message;
        parameters = {
          'max_length': 200,
          'temperature': 0.9,
          'return_full_text': false,
          'do_sample': true,
          'top_p': 0.95,
          'repetition_penalty': 1.2,
        };
      } else if (model.contains('blenderbot')) {
        // BlenderBot utilise un format de conversation
        prompt = message;
        parameters = {
          'max_length': 200,
          'temperature': 0.7,
          'return_full_text': false,
          'do_sample': true,
        };
      } else {
        // Modèles de génération de texte (flan-t5, etc.)
        prompt = 'Tu es un assistant IA spécialisé dans la santé maternelle et infantile au Sénégal. '
            'Tu réponds de manière bienveillante et claire aux questions sur la grossesse, '
            'les vaccins, la santé des enfants et les consultations prénatales. '
            'Réponds en français de manière concise et utile.\n\n'
            'Question: $message\n'
            'Réponse:';
        parameters = {
          'max_length': 300,
          'temperature': 0.7,
          'return_full_text': false,
          'do_sample': true,
          'top_p': 0.9,
        };
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': prompt,
          'parameters': parameters,
        }),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException('Timeout lors de l\'appel à l\'API');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Gérer différents formats de réponse Hugging Face
        String? generatedText;
        
        if (data is List && data.isNotEmpty) {
          // Format liste
          if (data[0] is Map) {
            generatedText = data[0]['generated_text'] as String?;
          } else if (data[0] is String) {
            generatedText = data[0] as String;
          } else {
            generatedText = data[0].toString();
          }
        } else if (data is Map) {
          // Format objet
          if (data.containsKey('generated_text')) {
            generatedText = data['generated_text'] as String?;
          } else if (data.containsKey('summary_text')) {
            generatedText = data['summary_text'] as String?;
          } else if (data.containsKey('0')) {
            final firstItem = data['0'];
            if (firstItem is Map && firstItem.containsKey('generated_text')) {
              generatedText = firstItem['generated_text'] as String?;
            }
          } else if (data.containsKey('text')) {
            generatedText = data['text'] as String?;
          }
        } else if (data is String) {
          generatedText = data;
        }
        
        if (generatedText != null && generatedText.trim().isNotEmpty) {
          // Nettoyer la réponse
          String cleaned = generatedText.trim();
          
          // Pour DialoGPT, enlever le préfixe "Assistant:" si présent
          if (cleaned.startsWith('Assistant:')) {
            cleaned = cleaned.substring('Assistant:'.length).trim();
          }
          
          // Enlever le prompt si présent
          if (cleaned.contains('Réponse:')) {
            cleaned = cleaned.split('Réponse:').last.trim();
          }
          if (cleaned.contains('Question:')) {
            cleaned = cleaned.split('Question:').first.trim();
          }
          
          // Enlever les répétitions du prompt
          if (prompt.length < cleaned.length && cleaned.contains(prompt)) {
            cleaned = cleaned.replaceAll(prompt, '').trim();
          }
          
          // Enlever les répétitions de mots
          final words = cleaned.split(' ');
          if (words.length > 1) {
            final uniqueWords = <String>[];
            String? lastWord;
            for (var word in words) {
              if (word != lastWord || uniqueWords.isEmpty) {
                uniqueWords.add(word);
                lastWord = word;
              }
            }
            cleaned = uniqueWords.join(' ');
          }
          
          // Retourner la réponse nettoyée si elle est valide
          if (cleaned.length >= 3 && 
              cleaned.toLowerCase() != message.toLowerCase() &&
              !cleaned.toLowerCase().contains('error') &&
              !cleaned.toLowerCase().contains('erreur')) {
            return cleaned;
          }
        }
      } else if (response.statusCode == 503) {
        // Modèle en cours de chargement
        // Retourner null pour que le système réessaye avec un délai
        return null;
      } else {
        // Autre erreur HTTP
        return null;
      }
      
      return null;
    } on TimeoutException {
      return null;
    } on http.ClientException {
      return null;
    } catch (e) {
      return null;
    }
  }

  // Envoie un message via OpenAI (nécessite une clé API)
  static Future<String> _sendMessageOpenAI(
    String message,
    List<Map<String, String>> conversationHistory,
  ) async {
    try {
      final messages = [
        {
          'role': 'system',
          'content':
              'Tu es un assistant IA spécialisé dans la santé maternelle et infantile au Sénégal. '
              'Tu réponds de manière bienveillante et claire aux questions sur la grossesse, '
              'les vaccins, la santé des enfants et les consultations prénatales. '
              'Réponds en français de manière concise et utile.'
        },
        ...conversationHistory,
        {'role': 'user', 'content': message},
      ];

      final response = await http.post(
        Uri.parse(_openAiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else if (response.statusCode == 401) {
        throw Exception('Clé API invalide.');
      } else if (response.statusCode == 429) {
        throw Exception('Limite de requêtes atteinte.');
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      return _getEnhancedFallbackResponse(message);
    }
  }

  // Réponses prédéfinies améliorées (utilisées en fallback)
  static String _getFallbackResponse(String message) {
    return _getEnhancedFallbackResponse(message);
  }

  // Réponses prédéfinies améliorées avec plus de contexte
  static String _getEnhancedFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase().trim();
    
    // Détection des salutations (en premier pour être prioritaire)
    if (lowerMessage.contains('bonjour') || 
        lowerMessage.contains('bonsoir') ||
        lowerMessage.contains('salut') || 
        lowerMessage.contains('hello') ||
        lowerMessage.contains('hi') ||
        lowerMessage.contains('bienvenue') ||
        lowerMessage.contains('bon matin') ||
        lowerMessage.contains('bon après-midi') ||
        lowerMessage.contains('bonsoir') ||
        lowerMessage == 'bonjour' ||
        lowerMessage == 'salut' ||
        lowerMessage == 'hello' ||
        lowerMessage == 'hi' ||
        lowerMessage.startsWith('bonjour') ||
        lowerMessage.startsWith('salut') ||
        lowerMessage.startsWith('hello')) {
      return 'Bonjour ! 👋\n\n'
          'Je suis votre assistant santé spécialisé dans la santé maternelle et infantile au Sénégal.\n\n'
          'Je peux vous aider avec :\n'
          '• Questions sur la grossesse\n'
          '• Informations sur les vaccins\n'
          '• Conseils sur l\'alimentation\n'
          '• Suivi de votre santé\n'
          '• Informations sur les consultations prénatales\n'
          '• Conseils sur l\'allaitement\n\n'
          'N\'hésitez pas à me poser vos questions ! Je suis là pour vous accompagner. 😊';
    }
    
    if (lowerMessage.contains('grossesse') || lowerMessage.contains('enceinte') || 
        lowerMessage.contains('enceinte') || lowerMessage.contains('bébé')) {
      return 'Pour une grossesse en bonne santé, voici quelques conseils importants :\n\n'
          '📅 **Consultations prénatales** :\n'
          '• Au moins 4 consultations pendant la grossesse\n'
          '• Premier rendez-vous avant 12 semaines\n'
          '• Suivi régulier avec votre sage-femme ou médecin\n\n'
          '💊 **Vitamines et suppléments** :\n'
          '• Acide folique (avant et pendant les 3 premiers mois)\n'
          '• Fer (souvent prescrit à partir du 2ème trimestre)\n'
          '• Calcium et vitamine D\n\n'
          '🍎 **Alimentation** :\n'
          '• Manger équilibré et varié\n'
          '• Éviter les aliments crus (poisson, viande, fromage)\n'
          '• Boire beaucoup d\'eau\n\n'
          '🚫 **À éviter** :\n'
          '• Alcool et tabac\n'
          '• Médicaments non prescrits\n'
          '• Activités à risque\n\n'
          '💪 **Activité physique** :\n'
          '• Marche, natation, yoga prénatal\n'
          '• Éviter les sports de contact\n\n'
          'N\'hésitez pas à consulter votre agent de santé pour un suivi personnalisé !';
          
    } else if (lowerMessage.contains('vaccin') || lowerMessage.contains('vaccination') ||
               lowerMessage.contains('injection')) {
      return 'Les vaccins sont essentiels pour protéger votre enfant contre les maladies graves.\n\n'
          '📋 **Calendrier vaccinal au Sénégal** :\n\n'
          '👶 **À la naissance** :\n'
          '• BCG (tuberculose)\n'
          '• Polio 0\n'
          '• Hépatite B 0\n\n'
          '💉 **À 6, 10 et 14 semaines** :\n'
          '• DTC (Diphtérie, Tétanos, Coqueluche)\n'
          '• Polio\n'
          '• Hépatite B\n'
          '• Hib (Haemophilus influenzae type b)\n'
          '• Pneumocoque\n\n'
          '🌡️ **À 9 mois** :\n'
          '• Rougeole\n'
          '• Fièvre jaune\n\n'
          '✅ **Rappels** :\n'
          '• DTC + Polio à 15-18 mois\n'
          '• DTC + Polio à 5-6 ans\n\n'
          '💡 **Conseils** :\n'
          '• Respecter le calendrier vaccinal\n'
          '• Noter les dates dans le carnet de santé\n'
          '• Consulter en cas de réaction\n\n'
          'Consultez votre agent de santé pour plus d\'informations !';
          
    } else if (lowerMessage.contains('alimentation') || lowerMessage.contains('manger') ||
               lowerMessage.contains('nourriture') || lowerMessage.contains('repas')) {
      return 'Une bonne alimentation pendant la grossesse est essentielle pour vous et votre bébé.\n\n'
          '✅ **Aliments recommandés** :\n'
          '• Fruits et légumes frais (bien lavés)\n'
          '• Céréales complètes (riz, mil, maïs)\n'
          '• Protéines (poisson bien cuit, viande, œufs, légumineuses)\n'
          '• Produits laitiers pasteurisés\n'
          '• Eau potable en quantité suffisante\n\n'
          '🚫 **À éviter** :\n'
          '• Aliments crus ou mal cuits\n'
          '• Fromages au lait cru\n'
          '• Poissons contenant du mercure\n'
          '• Café et thé en excès\n'
          '• Aliments transformés\n\n'
          '💡 **Conseils** :\n'
          '• Manger 3 repas + 2 collations par jour\n'
          '• Écouter votre faim\n'
          '• Privilégier la qualité à la quantité\n\n'
          'Consultez votre sage-femme pour un plan alimentaire personnalisé !';
          
    } else if (lowerMessage.contains('symptôme') || lowerMessage.contains('douleur') ||
               lowerMessage.contains('mal') || lowerMessage.contains('problème')) {
      return 'Si vous ressentez des symptômes inquiétants pendant la grossesse, voici ce qu\'il faut savoir :\n\n'
          '⚠️ **Symptômes nécessitant une consultation urgente** :\n'
          '• Saignements vaginaux\n'
          '• Fortes douleurs abdominales\n'
          '• Perte de liquide\n'
          '• Maux de tête intenses avec vision trouble\n'
          '• Fièvre élevée\n'
          '• Absence de mouvements du bébé (après 28 semaines)\n\n'
          '📞 **En cas d\'urgence** :\n'
          'Contactez immédiatement votre agent de santé ou rendez-vous à l\'hôpital.\n\n'
          '💡 **Symptômes normaux** :\n'
          '• Nausées (surtout au 1er trimestre)\n'
          '• Fatigue\n'
          '• Besoin fréquent d\'uriner\n'
          '• Légères douleurs ligamentaires\n\n'
          'En cas de doute, consultez toujours votre agent de santé !';
          
    } else if (lowerMessage.contains('consultation') || lowerMessage.contains('rdv') ||
               lowerMessage.contains('rendez-vous') || lowerMessage.contains('suivi')) {
      return 'Les consultations prénatales sont essentielles pour suivre votre grossesse.\n\n'
          '📅 **Calendrier recommandé** :\n'
          '• 1ère consultation : avant 12 semaines\n'
          '• 2ème consultation : vers 20 semaines\n'
          '• 3ème consultation : vers 28 semaines\n'
          '• 4ème consultation : vers 36 semaines\n'
          '• Consultations supplémentaires si nécessaire\n\n'
          '🔍 **Lors de chaque consultation** :\n'
          '• Mesure de la tension artérielle\n'
          '• Pesée\n'
          '• Écoute du rythme cardiaque du bébé\n'
          '• Mesure de la hauteur utérine\n'
          '• Discussion sur votre bien-être\n\n'
          '📝 **Préparez-vous** :\n'
          '• Notez vos questions\n'
          '• Apportez votre carnet de santé\n'
          '• Mentionnez tout symptôme inhabituel\n\n'
          'Votre agent de santé est là pour vous accompagner !';
          
    } else if (lowerMessage.contains('accouchement') || lowerMessage.contains('naissance') ||
               lowerMessage.contains('contraction')) {
      return 'L\'accouchement est un moment important. Voici ce qu\'il faut savoir :\n\n'
          '🕐 **Signes de début de travail** :\n'
          '• Contractions régulières et rapprochées\n'
          '• Perte des eaux (liquide amniotique)\n'
          '• Perte de sang (le "bouchon muqueux")\n\n'
          '📞 **Quand appeler** :\n'
          '• Contractions toutes les 5 minutes (première grossesse)\n'
          '• Contractions toutes les 10 minutes (grossesses suivantes)\n'
          '• Perte des eaux\n'
          '• Saignements importants\n\n'
          '🏥 **Préparation** :\n'
          '• Avoir votre carnet de santé\n'
          '• Préparer une valise pour vous et bébé\n'
          '• Organiser le transport\n'
          '• Informer votre accompagnant\n\n'
          '💪 **Pendant le travail** :\n'
          '• Respirer calmement\n'
          '• Bouger si possible\n'
          '• Écouter les conseils de la sage-femme\n\n'
          'Votre équipe médicale est là pour vous soutenir !';
          
    } else if (lowerMessage.contains('allaitement') || lowerMessage.contains('lait') ||
               lowerMessage.contains('nourrir') || lowerMessage.contains('sein')) {
      return 'L\'allaitement maternel est le meilleur aliment pour votre bébé.\n\n'
          '🍼 **Avantages** :\n'
          '• Protection contre les infections\n'
          '• Nutrition complète et adaptée\n'
          '• Renforce le lien mère-enfant\n'
          '• Gratuit et toujours disponible\n\n'
          '💡 **Conseils pratiques** :\n'
          '• Allaiter à la demande (quand bébé a faim)\n'
          '• Position confortable pour vous et bébé\n'
          '• Vérifier que bébé prend bien le sein\n'
          '• Alterner les deux seins\n'
          '• Boire beaucoup d\'eau\n'
          '• Avoir une alimentation équilibrée\n\n'
          '⏰ **Fréquence** :\n'
          '• Nouveau-né : 8-12 fois par jour\n'
          '• Bébé plus grand : selon sa demande\n\n'
          'Consultez votre sage-femme ou une consultante en lactation si besoin !';
          
    } else {
      return 'Merci pour votre question ! Je suis un assistant spécialisé en santé maternelle et infantile.\n\n'
          'Je peux vous aider avec :\n'
          '• Questions sur la grossesse et le suivi prénatal\n'
          '• Informations sur les vaccins et le calendrier vaccinal\n'
          '• Conseils sur l\'alimentation pendant la grossesse\n'
          '• Informations sur les consultations et rendez-vous\n'
          '• Conseils sur l\'accouchement et l\'allaitement\n'
          '• Questions sur la santé de votre enfant\n\n'
          'Posez-moi une question spécifique et je ferai de mon mieux pour vous aider ! 💚\n\n'
          '💡 **Rappel** : Pour des questions médicales urgentes, consultez toujours votre agent de santé.';
    }
  }
}

