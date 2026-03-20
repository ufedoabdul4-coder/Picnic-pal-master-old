import os
from flask import Flask, request, jsonify
from google.cloud import speech
from google.cloud import storage
import logging
import uuid

# --- Basic Configuration ---
app = Flask(__name__)

# IMPORTANT: Set this environment variable to your GCS bucket name.
GCS_BUCKET_NAME = os.environ.get('GCS_BUCKET_NAME')

# Configure logging
logging.basicConfig(level=logging.INFO)

# --- Google Cloud Speech-to-Text Client ---
# This automatically finds credentials via the GOOGLE_APPLICATION_CREDENTIALS
# environment variable. Make sure this variable is set in your terminal.
try:
    # Add a more specific check for the credentials environment variable
    if not os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
        logging.critical("FATAL ERROR: The 'GOOGLE_APPLICATION_CREDENTIALS' environment variable is not set.")
        logging.critical("Please set this variable to the full path of your service account JSON file.")
        raise EnvironmentError("Google Cloud credentials are not configured.")
    speech_client = speech.SpeechClient()
    storage_client = storage.Client()
    logging.info("Google Speech-to-Text client initialized successfully.")
    if not GCS_BUCKET_NAME:
        logging.warning("GCS_BUCKET_NAME environment variable not set. Long audio transcription will fail.")
    else:
        logging.info(f"Using GCS bucket: {GCS_BUCKET_NAME}")
except Exception as e:
    logging.error(f"Could not initialize Google Speech client: {e}")
    speech_client = None
    storage_client = None

# --- API Endpoint for Transcription ---
@app.route('/transcribe', methods=['POST'])
def transcribe_audio():
    """
    Receives an audio file from the Flutter app, transcribes it, and returns the text.
    """
    if not speech_client or not storage_client:
        return jsonify({'error': 'Speech client is not configured on the server.'}), 503

    # 1. Check for the file in the request
    if 'file' not in request.files:
        logging.warning("Transcription request received without a file part.")
        return jsonify({'error': 'No file part in the request'}), 400

    file = request.files['file']

    if file.filename == '':
        logging.warning("Transcription request received with an empty filename.")
        return jsonify({'error': 'No selected file'}), 400

    # 2. Prepare the audio and configuration for Google Speech-to-Text
    try:
        content = file.read()
        audio = speech.RecognitionAudio(content=content)
        audio_duration_seconds = len(content) / (16000 * 2) # 16kHz, 16-bit (2 bytes)

        # Use long-running recognition for audio > 59 seconds
        if audio_duration_seconds > 59:
            if not GCS_BUCKET_NAME:
                 return jsonify({'error': 'Server is not configured for long audio transcription.'}), 503
            
            logging.info(f"Audio is > 60s ({audio_duration_seconds:.2f}s). Using long-running recognition.")
            return _long_transcribe(content)

        # --- Standard synchronous recognition for short audio ---
        logging.info(f"Audio is < 60s ({audio_duration_seconds:.2f}s). Using synchronous recognition.")

        audio = speech.RecognitionAudio(content=content)

        # This configuration MUST match the audio format from the Flutter app.
        # The `record` plugin is set to output PCM 16-bit at 16000Hz.
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz=16000,
            language_code="en-US",
        )

        # 3. Perform the transcription
        logging.info(f"Sending audio ({len(content)} bytes) to Google for transcription...")
        response = speech_client.recognize(config=config, audio=audio)
        
        # 4. Process and return the result
        transcripts = [result.alternatives[0].transcript for result in response.results]
        full_transcript = " ".join(transcripts)
        logging.info(f"Transcription successful: '{full_transcript}'")
        
        return jsonify({'transcript': full_transcript})

    except Exception as e:
        logging.error(f"An error occurred during transcription: {e}")
        return jsonify({'error': 'Failed to transcribe audio due to a server error'}), 500

def _long_transcribe(audio_content):
    """
    Transcribes audio longer than 60 seconds using Google Cloud Storage.
    """
    try:
        # 1. Upload the file to Google Cloud Storage
        bucket = storage_client.bucket(GCS_BUCKET_NAME)
        # Generate a unique filename to prevent overwrites
        blob_name = f"audio-uploads/{uuid.uuid4()}.raw"
        blob = bucket.blob(blob_name)

        logging.info(f"Uploading audio to gs://{GCS_BUCKET_NAME}/{blob_name}")
        blob.upload_from_string(audio_content, content_type='audio/l16; rate=16000')

        # 2. Prepare the long-running recognition request
        gcs_uri = f"gs://{GCS_BUCKET_NAME}/{blob_name}"
        audio = speech.RecognitionAudio(uri=gcs_uri)
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz=16000,
            language_code="en-US",
        )

        # 3. Start the asynchronous job
        logging.info("Starting long-running transcription job...")
        operation = speech_client.long_running_recognize(config=config, audio=audio)
        response = operation.result(timeout=300) # Wait for up to 5 minutes

        # 4. Process and return the result
        transcripts = [result.alternatives[0].transcript for result in response.results]
        full_transcript = " ".join(transcripts)
        logging.info(f"Long-running transcription successful: '{full_transcript}'")

        # 5. Clean up the file from GCS
        blob.delete()
        logging.info(f"Deleted gs://{GCS_BUCKET_NAME}/{blob_name}")

        return jsonify({'transcript': full_transcript})
    except Exception as e:
        logging.error(f"An error occurred during long transcription: {e}")
        return jsonify({'error': 'Failed to transcribe long audio due to a server error'}), 500

if __name__ == '__main__':
    # Host '0.0.0.0' makes the server accessible on your local network
    app.run(host='0.0.0.0', port=5000, debug=True)