# Picnic Pal

Picnic Pal is a Flutter app that helps users discover venues and plan events with optional AI assistance and audio transcription. The workspace also includes a small Flask backend for audio transcription using Google Speech-to-Text.

Quick links:
- App entry: [lib/main.dart](lib/main.dart)
- Chatbot + AI integration: [lib/chatbot_screen.dart](lib/chatbot_screen.dart) — see [`ChatbotScreen`](lib/chatbot_screen.dart)
- Speech-to-text client (Flutter): [lib/speech_recognition_service.dart](lib/speech_recognition_service.dart) — see [`SpeechRecognitionService.initialize`](lib/speech_recognition_service.dart)
- Transcription API client (Flutter): [lib/api_client.dart](lib/api_client.dart) — see [`ApiClient.transcribeAudio`](lib/api_client.dart)
- Web/local backend client: [lib/web_access.dart](lib/web_access.dart)
- Backend server (Flask): [picnic-pal-backend/app.py](picnic-pal-backend/app.py)
- Package config: [pubspec.yaml](pubspec.yaml)

## Features
- Browse recommended venues and place details
- Plan events (choose venue, date, guests, add-ons)
- AI assistant for planning (requires Gemini API key)
- Voice recording and transcription workflow (uses local Flask backend + Google Speech-to-Text)
- Local persistence via SharedPreferences for sessions, profile, saved venues

## Prerequisites
- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)
- Python 3.8+ (for the local backend)
- pip packages for backend: see [picnic-pal-backend/app.py](picnic-pal-backend/app.py)
- A Google Cloud service account and credentials (for server-side transcription) OR configure server-side Google auth via environment variables.

## Setup (Flutter app)
1. Install dependencies:
    ```sh
    flutter pub get
    ```
2. Set up API Keys:

    This project uses API keys for Google GeminI
    
    -   **Gemini API Key**: The application loads the Gemini API key from environment variables. To run the app, you need to pass it as a `--dart-define` flag.

        ```sh
        flutter run --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
        ```


        ```

    -   **Google Cloud Credentials (for Speech-to-Text)**: The `speech_recognition_service.dart` file expects a `google-credentials.json` file in your `assets` directory. Make sure to place your service account key there and update your `pubspec.yaml` to include the asset.

        ```yaml
        flutter:
          assets:
            - assets/google-credentials.json
        ```

3.  **Run the application:**
    ```sh
    flutter run --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
    ```

## Setup (Backend)
The backend is a Flask application for transcribing audio using Google Speech-to-Text.

1. Navigate to the backend directory:
    ```sh
    cd picnic-pal-backend
    ```
2. Set up a virtual environment and activate it:
    ```sh
    python -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    ```
3. Install the required Python packages:
    ```sh
    pip install -r requirements.txt
    ```
4. Set the environment variable for Flask:
    ```sh
    export FLASK_APP=app.py
    ```
5. Run the Flask application:
    ```sh
    flask run
    ```

## 🏗️ Project Structure

The project follows a standard Flutter project structure. Key files of interest include:

- `lib/chatbot_screen.dart`: The core UI and logic for the AI chatbot interaction.
- `lib/change_email_screen.dart`: Handles the user's email change functionality.
- `lib/speech_recognition_service.dart`: Manages the connection to Google's Speech-to-Text API.
- `lib/api_client.dart`: Centralizes API calls, including audio transcription.
- `lib/main.dart`: The entry point of the application.

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.