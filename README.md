# EmoDrive - Flutter Web App

**EmoDrive** is a Flutter web application designed for driverless taxis, enhancing the passenger experience through personalized music recommendations based on real-time emotion detection. By analyzing the user's facial expressions, EmoDrive suggests suitable music from Spotify, creating a more enjoyable and tailored ride.

<video width="640" height="360" controls>
  <source src="./ui/assets/videos/video.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

## Features

* **Real-time Emotion Detection:** Utilizes facial recognition to analyze the passenger's emotional state.
* **Spotify Integration:** Leverages the Spotify API to provide music recommendations.
* **Personalized Music Playlists:** Dynamically generates playlists based on detected emotions.
* **Seamless User Experience:** Built with Flutter for a smooth and responsive web interface.
* **Flask Backend:** Uses Flask to bridge communication between the Flutter frontend and the Spotify API.

## Technology Stack

* **Flutter:** For the user interface and cross-platform web development.
* **Spotify API:** For music data and playback.
* **Flask (Python):** For backend services and API integration.
* **Facial Recognition/Emotion Detection Libraries:** (Specify libraries used if possible, e.g., OpenCV, TensorFlow.js, etc.)

## Setup Instructions

### Prerequisites

* Flutter SDK installed and configured.
* Python 3.9.0 installed.
* Spotify Developer account with API credentials.
* Necessary facial recognition libraries installed and configured.

### Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/me-sarvar/emo_drive
    cd emo_drive
    ```

2.  **Flutter setup:**

    * Navigate to the `ui` directory.
    * Install Flutter dependencies:

        ```bash
        flutter pub get
        ```

3.  **Flask backend setup:**

    * Navigate to the `backend` directory.
    * Create a virtual environment (recommended):

        ```bash
        python -m venv venv
        source venv/bin/activate  # On macOS/Linux
        venv\Scripts\activate     # On Windows
        ```

    * Install Python dependencies:

        ```bash
        pip install -r requirements.txt
        ```

    * Configure Spotify API credentials in `backend/app.py`.

4.  **Running the application:**

    * **Start the Flask backend:**

        ```bash
        cd backend
        python app.py
        ```

    * **Start the Flutter web app:**

        ```bash
        cd ../ui
        flutter run -d chrome
        ```

    * Open the displayed URL in your web browser.

## Deployment

* For deploying the Flask backend, consider using platforms like Heroku, AWS Elastic Beanstalk, or Google Cloud App Engine.
* For deploying the Flutter web app, build the web version using `flutter build web` and host the `web` directory on a web server like Firebase Hosting, Netlify, or AWS S3.

## Awards

This project was awarded a **3 million KRW prize** at the **SW프로직트 경진대회** at **순천향대학교** on **November 6, 2024**.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bug fixes or feature requests.

## License


This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.