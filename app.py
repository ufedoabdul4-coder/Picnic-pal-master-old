import os
import requests
import redis
from functools import wraps
from dotenv import load_dotenv
from flask import Flask, request, jsonify
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

# --- Initialization ---
load_dotenv()
app = Flask(__name__)

# --- Configuration ---
SERPER_API_KEY = os.getenv('SERPER_API_KEY')
OPENWEATHER_API_KEY = os.getenv('OPENWEATHER_API_KEY')
APP_SECRET_TOKEN = os.getenv('APP_SECRET_TOKEN')
REDIS_URL = os.getenv('REDIS_URL')

# --- Redis Cache Setup ---
try:
    redis_client = redis.from_url(REDIS_URL, decode_responses=True)
    redis_client.ping()
    print("Connected to Redis successfully!")
except redis.exceptions.ConnectionError as e:
    print(f"Could not connect to Redis: {e}. Caching will be disabled.")
    redis_client = None

# --- Rate Limiting ---
limiter = Limiter(
    get_remote_address,
    app=app,
    default_limits=["60 per minute"]
)

# --- Authentication Decorator ---
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('x-app-token')
        if not token or token != APP_SECRET_TOKEN:
            return jsonify({"error": "Unauthorized: Invalid or missing token"}), 401
        return f(*args, **kwargs)
    return decorated

# --- Helper for Summarization ---
def summarize_results(results, max_results=4):
    """Creates a concise summary from search results."""
    if not results:
        return "No relevant information found."

    summary_points = []
    for item in results[:max_results]:
        title = item.get('title', 'No Title')
        snippet = item.get('snippet', 'No description available.').replace('\n', ' ')
        summary_points.append(f"• {title}: {snippet}")
    
    return "\n".join(summary_points)

# --- API Endpoints ---

@app.route('/search', methods=['GET'])
@token_required
def search():
    query = request.args.get('q')
    if not query:
        return jsonify({"error": "Query parameter 'q' is required"}), 400

    # Check cache first
    if redis_client:
        cached_result = redis_client.get(f"search:{query}")
        if cached_result:
            return jsonify({"summary": cached_result})

    # Fetch from Serper API
    headers = {'X-API-KEY': SERPER_API_KEY, 'Content-Type': 'application/json'}
    data = {"q": query}
    try:
        response = requests.post("https://google.serper.dev/search", headers=headers, json=data)
        response.raise_for_status()
        search_results = response.json().get('organic', [])
        summary = summarize_results(search_results)

        # Cache the result
        if redis_client:
            redis_client.setex(f"search:{query}", 300, summary) # 5-minute TTL

        return jsonify({"summary": summary})
    except requests.exceptions.RequestException as e:
        return jsonify({"error": f"API request failed: {e}"}), 502

@app.route('/weather', methods=['GET'])
@token_required
def weather():
    city = request.args.get('city')
    if not city:
        return jsonify({"error": "City parameter is required"}), 400

    # Check cache
    if redis_client:
        cached_weather = redis_client.get(f"weather:{city}")
        if cached_weather:
            return jsonify({"weather": cached_weather})

    # Fetch from OpenWeather API
    url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={OPENWEATHER_API_KEY}&units=metric"
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        description = data['weather'][0]['description']
        temp = data['main']['temp']
        weather_summary = f"The weather in {city.capitalize()} is currently {description} with a temperature of {temp}°C."

        if redis_client:
            redis_client.setex(f"weather:{city}", 600, weather_summary) # 10-minute TTL

        return jsonify({"weather": weather_summary})
    except requests.exceptions.RequestException as e:
        return jsonify({"error": f"Could not fetch weather data: {e}"}), 502

@app.route('/news', methods=['GET'])
@token_required
def news():
    # This uses the same search endpoint but with a news-focused query
    news_query = "top headlines today"
    headers = {'X-API-KEY': SERPER_API_KEY, 'Content-Type': 'application/json'}
    data = {"q": news_query}
    response = requests.post("https://google.serper.dev/search", headers=headers, json=data)
    news_results = response.json().get('news', [])
    summary = summarize_results(news_results, max_results=5)
    return jsonify({"summary": summary})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)