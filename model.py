import json
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score, mean_squared_error
import joblib
from flask import Flask, request, jsonify
from get_song_features import get_song_features  # Expects a string "Song Name - Artist"

# --------------------------
# Data & Model Functions
# --------------------------

def load_condensed_data(file_path="condensed_training_data.json"):
    """Load the condensed training data from a JSON file."""
    with open(file_path, "r") as f:
        data = json.load(f)
    return pd.DataFrame(data)

def prepare_data(df):
    """
    Select numeric features and target variable from the condensed data.
    Features: bpm, danceability, energy.
    Target: avg_pace.
    Fill missing values with zero.
    """
    features = df[["bpm", "danceability", "energy"]].fillna(0)
    target = df["avg_pace"]
    return features, target

def train_model(X, y):
    """
    Splits the data into training and testing sets, trains a RandomForestRegressor,
    and prints performance metrics.
    """
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    r2 = r2_score(y_test, y_pred)
    mse = mean_squared_error(y_test, y_pred)
    print(f"Model R^2: {r2:.3f}, MSE: {mse:.3f}")
    return model

def predict_pace_for_song(model, song_features):
    """
    Given a dictionary of song features (with keys: bpm, danceability, energy),
    predict the pace using the trained model.
    """
    df = pd.DataFrame([song_features])
    return model.predict(df)[0]

def lookup_song(df, song_details):
    """
    Check if the song (by exact match on songName, case-insensitive) exists in the data.
    Returns the record as a dictionary if found, otherwise returns None.
    """
    matches = df[df["songName"].str.lower() == song_details.lower()]
    if not matches.empty:
        return matches.iloc[0].to_dict()
    return None

def get_top_songs(df, top_n=5):
    """
    Sorts the condensed training data by the count of data points (as a reliability indicator)
    and returns the top songs (including songName, avg_pace, and count) as a list of dictionaries.
    """
    top_songs = df.sort_values(by="count", ascending=False).head(top_n)
    return top_songs[["songName", "avg_pace", "count"]].to_dict(orient="records")

# --------------------------
# Flask Endpoint (Optional)
# --------------------------

app = Flask(__name__)

@app.route("/top-songs", methods=["GET"])
def top_songs_endpoint():
    try:
        df = load_condensed_data("condensed_training_data.json")
        if df.empty:
            return jsonify({"status": "error", "message": "No training data available."}), 404
        top_songs = get_top_songs(df, top_n=5)
        return jsonify(top_songs), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

# --------------------------
# Main Routine for Testing
# --------------------------

def main():
    # Load training data.
    df = load_condensed_data("condensed_training_data.json")
    if df.empty:
        print("No condensed training data found.")
        return

    print("Loaded Condensed Training Data:")
    print(df.head())

    # Prepare data and train ML model.
    X, y = prepare_data(df)
    model = train_model(X, y)
    joblib.dump(model, "pace_model.joblib")
    print("Model saved to pace_model.joblib")

    # Display top songs to the user.
    topSongs = get_top_songs(df, top_n=5)
    print("\nTop Songs Based on Training Data:")
    print(json.dumps(topSongs, indent=4))

    # Prompt for a new song in the format "Song Name - Artist".
    new_song_details = input("\nEnter new song details in the format 'Song Name - Artist': ").strip()

    # Check if the song already exists in the data.
    record = lookup_song(df, new_song_details)
    if record:
        print("Song found in database. Using stored average pace.")
        estimated_pace = record["avg_pace"]
        source = "database"
    else:
        print("Song not found in database. Generating features via LLM...")
        features = get_song_features(new_song_details)
        if features is None:
            print("Failed to generate features for the new song.")
            return
        required_keys = ["bpm", "danceability", "energy"]
        new_song_features = {k: features.get(k, 0) for k in required_keys}
        print("Generated song features:")
        print(new_song_features)
        estimated_pace = predict_pace_for_song(model, new_song_features)
        source = "predicted"

    print(f"\nThe pace for '{new_song_details}' (source: {source}) is estimated at {estimated_pace:.2f} m/s.")

    # Ask for the desired running pace.
    try:
        desired_pace = float(input("Enter your desired running pace (m/s): "))
    except ValueError:
        print("Invalid input. Please enter a numeric value.")
        return
    print(f"Desired pace: {desired_pace:.2f} m/s")

    # Compare estimated pace with desired pace and give a recommendation.
    diff = estimated_pace - desired_pace
    if abs(diff) < 0.1:
        print("This song closely matches your desired pace. Queue it!")
    elif diff > 0:
        print("This song is predicted to be faster than your desired pace (it may help you run faster).")
    else:
        print("This song is predicted to be slower than your desired pace (it may help you run slower).")

if __name__ == "__main__":
    # For testing as a standalone script:
    main()

    # To run as a web server endpoint, uncomment the following line and comment out main():
    # app.run(host='0.0.0.0', port=8000, debug=True)
