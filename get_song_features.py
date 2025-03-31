import json
from groq import Groq

API_KEY = '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'
client = Groq(api_key=API_KEY)

def get_song_features(song_details, retries=2):
    """
    Uses the Groq API to generate audio features and musical characteristics for a song.
    
    The function expects the input 'song_details' in the format "Song Name - Artist".
    It splits the input to get the song title and artist, then builds a prompt for Groq.
    
    The prompt instructs the model to return a JSON object with these keys:
      - "bpm": a number representing the song's tempo in BPM,
      - "danceability": a number between 0.0 and 1.0 indicating how danceable the song is,
      - "energy": a number between 0.0 and 1.0 indicating the energy level of the song,
      - "mood": a short description of the song's mood,
      - "genre": a general genre label.
    
    Only return the JSON object without any additional commentary.
    
    If no features are generated, the function will retry up to 'retries' times.
    """
    # Split the input string into song title and artist.
    if " - " in song_details:
        song_title, artist = song_details.split(" - ", 1)
        song_title = song_title.strip()
        artist = artist.strip()
    else:
        print("Input is not in the expected format 'Song Name - Artist'.")
        return None

    prompt = f"""
You are an expert music analyst. Given the following song details:
Song Title: "{song_title}"
Artist: "{artist}"
Please provide a JSON object with the following keys:
- "bpm": a number representing the song's tempo in BPM,
- "danceability": a number between 0.0 and 1.0 indicating how danceable the song is,
- "energy": a number between 0.0 and 1.0 indicating the energy level of the song,
- "mood": a short text description of the overall mood of the song,
- "genre": a general genre of the song.
Only return the JSON object without any additional commentary.
"""
    attempt = 0
    while attempt <= retries:
        try:
            chat_completion = client.chat.completions.create(
                messages=[{"role": "user", "content": prompt}],
                model="llama3-8b-8192"
            )
            content = chat_completion.choices[0].message.content.strip()
            features = json.loads(content)
            if features:
                return features
            else:
                print(f"No features generated on attempt {attempt+1}. Retrying...")
        except Exception as e:
            print(f"Error generating song features on attempt {attempt+1}: {e}")
        attempt += 1
    return None

if __name__ == "__main__":
    song_details = input("Enter song details in the format 'Song Name - Artist': ").strip()
    features = get_song_features(song_details)
    if features:
        print("Generated Audio Features:")
        print(json.dumps(features, indent=4))
    else:
        print("No features generated after multiple attempts.")
