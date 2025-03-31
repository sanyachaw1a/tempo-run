import json
import pandas as pd
import numpy as np
from get_song_features import get_song_features  # This function accepts "Song Name - Artist"

def load_training_data(file_path="training_data.json"):
    """Load training data from a JSON file."""
    with open(file_path, "r") as f:
        data = json.load(f)
    return data

def aggregate_training_data(data):
    """
    Group training data by trackId and songName and compute average pace,
    standard deviation, and count.
    """
    df = pd.DataFrame(data)
    grouped = df.groupby(["trackId", "songName"])["pace"].agg(
        avg_pace="mean",
        pace_std="std",
        count="count"
    ).reset_index()
    return grouped

def enrich_aggregated_data(grouped_df):
    """
    For each aggregated song, call get_song_features by passing the entire songName
    (which is already in the format "Song Name - Artist"). Append the generated features.
    """
    features_list = []
    for idx, row in grouped_df.iterrows():
        full_song = row["songName"]
        print(f"Processing song: '{full_song}'")
        features = get_song_features(full_song)
        if features is None:
            features = {}  # fallback to an empty dictionary if no features are returned
        features_list.append(features)
    features_df = pd.DataFrame(features_list)
    # Concatenate the aggregated data and the generated features
    enriched_df = pd.concat([grouped_df.reset_index(drop=True), features_df], axis=1)
    return enriched_df

def write_condensed_data(enriched_df, output_file="condensed_training_data.json"):
    """Write the enriched DataFrame to a JSON file."""
    condensed_data = enriched_df.to_dict(orient="records")
    with open(output_file, "w") as f:
        json.dump(condensed_data, f, indent=4)
    print(f"Condensed data written to {output_file}")

def main():
    # Load training data.
    data = load_training_data("training_data.json")
    if not data:
        print("No training data found.")
        return

    # Step 1: Aggregate the training data by unique song.
    grouped = aggregate_training_data(data)
    print("Aggregated Training Data:")
    print(grouped)

    # Step 2: Enrich the aggregated data with generated song features.
    enriched = enrich_aggregated_data(grouped)
    print("\nEnriched Data with Generated Song Features:")
    print(enriched)

    # Step 3: Write the enriched (condensed) data to a new JSON file.
    write_condensed_data(enriched)

if __name__ == "__main__":
    main()
