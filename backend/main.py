import os
import cv2
import time
import json
import requests
import spotipy
import random
import numpy as np
import pandas as pd
import face_recognition
from flask import Flask, jsonify, request
from flask_cors import CORS
from tensorflow.keras.preprocessing import image
from tensorflow.keras.models import model_from_json
import tensorflow as tf
from spotipy.oauth2 import SpotifyOAuth
from dotenv import load_dotenv


load_dotenv()
app = Flask(__name__)
CORS(app)

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

face_exp_model = tf.keras.models.model_from_json(open("../model/facial_expression_model_structure.json", 'r').read())
face_exp_model.load_weights("../model/facial_expression_model_weights.h5")

emotions_label = ('Angry', 'disgust', 'fear', 'Happy', 'Sad', 'surprise', 'Calm')
emotions_for_music_recom = ['Happy', 'Sad', 'Angry', 'Calm']

client_id = os.getenv("SPOTIFY_CLIENT_ID")
client_secret = os.getenv("SPOTIFY_CLIENT_SECRET")
redirect_uri = os.getenv("SPOTIFY_REDIRECT_URI")
GOOGLE_MAPS_API_KEY = os.getenv("GOOGLE_MAPS_API_KEY")
scope = 'playlist-modify-public user-read-playback-state user-modify-playback-state'
sp = spotipy.Spotify(auth_manager=SpotifyOAuth(client_id=client_id,
                                               client_secret=client_secret,
                                               redirect_uri=redirect_uri,
                                               scope=scope))

# Global variables for caching
cache = {
    'response': None,
    'timestamp': 0
}
CACHE_DURATION = 30  # Cache duration in seconds

@app.route('/getPolyline', methods=['GET'])
def get_polyline():
    origin = request.args.get('origin')
    destination = request.args.get('destination')
    mode = request.args.get('mode', 'driving')

    url = f'https://maps.googleapis.com/maps/api/directions/json?origin={origin}&destination={destination}&mode={mode}&key={GOOGLE_MAPS_API_KEY}'
    response = requests.get(url)
    return jsonify(response.json())

@app.route('/analyze', methods=['POST'])
def analyze():
    # video_path = request.json.get('video_path')
    video_path = '../backend/data/video.webm'  # Directly use this for testing


    if not video_path:
        return jsonify({'error': 'No video path provided'}), 400

    current_time = time.time()

    if cache['response'] is not None and (current_time - cache['timestamp'] < CACHE_DURATION):
        return jsonify(cache['response'])

    try:
        video_capture = cv2.VideoCapture(video_path)
        
        # Check if video capture was successful
        if not video_capture.isOpened():
            print(f"Failed to open video: {video_path}")
            return jsonify({'error': 'Could not open video file'}), 400

        emotion_counts = {emotion: 0 for emotion in emotions_label}
        detected_emotions = []

        start_time = time.time()

        while True:
            ret, current_frame = video_capture.read()
            if not ret:
                break

            current_frame_small = cv2.resize(current_frame, (0, 0), fx=0.25, fy=0.25)
            all_face_locations = face_recognition.face_locations(current_frame_small, number_of_times_to_upsample=2, model='hog')

            for current_face_location in all_face_locations:
                top_pos, right_pos, bottom_pos, left_pos = current_face_location
                top_pos, right_pos, bottom_pos, left_pos = top_pos * 4, right_pos * 4, bottom_pos * 4, left_pos * 4

                current_face_image = current_frame[top_pos:bottom_pos, left_pos:right_pos]
                current_face_image = cv2.cvtColor(current_face_image, cv2.COLOR_BGR2GRAY)
                current_face_image = cv2.resize(current_face_image, (48, 48))
                img_pixels = image.img_to_array(current_face_image)
                img_pixels = np.expand_dims(img_pixels, axis=0)
                img_pixels /= 255

                exp_predictions = face_exp_model.predict(img_pixels)
                max_index = np.argmax(exp_predictions[0])
                emotion_label = emotions_label[max_index]
                emotion_counts[emotion_label] += 1

                if emotion_label in emotions_for_music_recom:
                    detected_emotions.append(emotion_label)

            if time.time() - start_time > 8:
                break

        video_capture.release()
        cv2.destroyAllWindows()

        if detected_emotions:
            most_detected_emotion = max(set(detected_emotions), key=detected_emotions.count)
        else:
            most_detected_emotion = 'NULL'

        if most_detected_emotion != 'NULL':
            recommendations = recommend_music_if_emotion_is_detected(most_detected_emotion)
        else:
            recommendations = recommend_music_if_emotion_is_not_detected()

        response_data = {
            'emotion': most_detected_emotion,
            'recommendations': recommendations
        }

        cache['response'] = response_data
        cache['timestamp'] = current_time

        print(json.dumps(response_data, indent=4))
        return jsonify(response_data)

    except Exception as e:
        print(f"An error occurred: {e}")
        return jsonify({'error': str(e)}), 500



def recommend_music_if_emotion_is_detected(emotion):
    music_dataset = pd.read_csv("../model/final_music_recom_dataset.csv")
    filtered_by_emotion = music_dataset[music_dataset['mood'] == emotion]
    
    random_songs = filtered_by_emotion.sample(50)[['track_id', 'track_name']]
    random_songs['track_id'] = 'spotify:track:' + random_songs['track_id'].astype(str)

    track_list = [
        {
            'track_id': row.track_id,
            'track_name': row.track_name,
            # 'artist': row.artist
        } for index, row in random_songs.iterrows()
    ]    
    return track_list


def recommend_music_if_emotion_is_not_detected():
    trending_songs = get_trending_songs()
    return trending_songs

def get_trending_songs(limit=50):
    playlist_id = '37i9dQZF1DXcBWIGoYBM5M'
    results = sp.playlist_tracks(playlist_id, limit=limit)
    tracks = results['items']

    trending_songs = []
    for item in tracks:
        track = item['track']
        song_info = {
            'name': track['name'],
            # 'artist': track['artists'][0]['name'],
            'album': track['album']['name'],
            'spotify_uri': track['uri']
        }
        trending_songs.append(song_info)

    random.shuffle(trending_songs)
    return trending_songs

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
