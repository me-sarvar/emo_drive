import os, json, requests
from flask import Flask, redirect, request, session, url_for, render_template, jsonify
from dotenv import load_dotenv
from flask_cors import CORS

load_dotenv()

app = Flask(__name__)
CORS(app)
CORS(app, resources={r"/*": {"origins": "http://localhost:8080"}})

app.secret_key = os.getenv("SECRET_KEY")
SPOTIFY_CLIENT_ID = os.getenv("SPOTIFY_CLIENT_ID")
SPOTIFY_CLIENT_SECRET = os.getenv("SPOTIFY_CLIENT_SECRET")
SPOTIFY_REDIRECT_URI = os.getenv("SPOTIFY_REDIRECT_URI")
BASE_URL = "https://accounts.spotify.com"

GOOGLE_MAPS_API_KEY = 'AIzaSyDJdy5mPXqLsX71RF8_kFNvLWZG1AlX-XE'

@app.route('/getPolyline', methods=['GET'])
def get_polyline():
    origin = request.args.get('origin')
    destination = request.args.get('destination')
    mode = request.args.get('mode', 'driving')

    url = f'https://maps.googleapis.com/maps/api/directions/json?origin={origin}&destination={destination}&mode={mode}&key={GOOGLE_MAPS_API_KEY}'
    response = requests.get(url)
    return jsonify(response.json())


# Spotify Authorization URL
@app.route('/')
def home():
    auth_url = f"{BASE_URL}/authorize?client_id={SPOTIFY_CLIENT_ID}&response_type=code&redirect_uri={SPOTIFY_REDIRECT_URI}&scope=streaming%20user-read-email%20user-read-private%20user-library-read%20user-read-playback-state%20user-modify-playback-state"
    return render_template("index.html", auth_url=auth_url)

@app.route('/data/tracks.json')
def get_songs():
    with open('data/tracks.json') as f:
        data = json.load(f)
    return jsonify(data)

# Callback Route for Spotify Authentication
@app.route('/callback')
def callback():
    code = request.args.get("code")
    response = requests.post(f"{BASE_URL}/api/token", data={
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": SPOTIFY_REDIRECT_URI,
        "client_id": SPOTIFY_CLIENT_ID,
        "client_secret": SPOTIFY_CLIENT_SECRET,
    })       
    response_data = response.json()
    session["access_token"] = response_data["access_token"]
    return redirect(url_for("player"))

# Player Route
@app.route('/player')
def player():
    if "access_token" not in session:
        return redirect(url_for("home"))
    return render_template("index.html", access_token=session["access_token"])

# Fetch Current Playback Information
@app.route('/current_playback')
def current_playback():
    access_token = session.get("access_token")
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
    response = requests.get("https://api.spotify.com/v1/me/player/currently-playing", headers=headers)
    if response.status_code == 200:
        return jsonify(response.json())
    return jsonify({"error": "No track playing"}), 404

if __name__ == "__main__":
    app.run(debug=True)
