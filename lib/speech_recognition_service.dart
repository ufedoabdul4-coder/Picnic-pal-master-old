import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/speech/v1.dart' as speech;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class SpeechRecognitionService {
  // Holds the authenticated HTTP client after initialization.
  http.Client? _client;

  // Call this method once when your app starts or before the first transcription.
  Future<void> initialize() async {
    try {
      // 1. Load the JSON credentials from your app's assets.
      final String credentialsJson = await rootBundle.loadString('assets/google-credentials.json');
      final credentials = auth.ServiceAccountCredentials.fromJson(json.decode(credentialsJson));

      // 2. Define the scope of access needed. For Speech-to-Text, it's 'cloud-platform'.
      final scopes = [speech.SpeechApi.cloudPlatformScope];

      // 3. Create an authenticated HTTP client.
      _client = await auth.clientViaServiceAccount(credentials, scopes);
      print("Speech Recognition Service Initialized Successfully.");
    } catch (e) {
      print("Error initializing Speech Recognition Service: $e");
      // Handle initialization error (e.g., file not found, invalid format)
      _client = null;
    }
  }

  // Transcribes a chunk of audio data.
  // The `audioBytes` should be the raw bytes from your audio recording.
  Future<String?> transcribe(List<int> audioBytes) async {
    if (_client == null) {
      print("Service not initialized. Please call initialize() first.");
      return null;
    }

    final speechApi = speech.SpeechApi(_client!);

    // 4. Configure the recognition request.
    final config = speech.RecognitionConfig(
      // IMPORTANT: Set the encoding and sample rate to match your audio recording settings.
      encoding: 'LINEAR16',
      sampleRateHertz: 16000,
      languageCode: 'en-US', // Example: US English
    );

    final audio = speech.RecognitionAudio(content: base64.encode(audioBytes));
    final request = speech.RecognizeRequest(config: config, audio: audio);

    // 5. Send the request and get the response.
    final response = await speechApi.speech.recognize(request);

    // 6. Return the most likely transcript.
    return response.results?.first.alternatives?.first.transcript;
  }
}