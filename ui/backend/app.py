from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS
import requests

app = Flask(__name__)
CORS(app)  # Enable CORS on the Flask app

GOOGLE_MAPS_API_KEY = 'AIzaSyDJdy5mPXqLsX71RF8_kFNvLWZG1AlX-XE'

@app.route('/getPolyline', methods=['GET'])
def get_polyline():
    origin = request.args.get('origin')
    destination = request.args.get('destination')
    mode = request.args.get('mode', 'driving')

    url = f'https://maps.googleapis.com/maps/api/directions/json?origin={origin}&destination={destination}&mode={mode}&key={GOOGLE_MAPS_API_KEY}'
    response = requests.get(url)
    return jsonify(response.json())

if __name__ == '__main__':
    app.run(debug=True)
