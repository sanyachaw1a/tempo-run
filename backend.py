from flask import Flask, request, jsonify
import json
import os

app = Flask(__name__)

# File to store training data
DATA_FILE = "training_data.json"

def append_training_data(data):
    # Create file if it doesn't exist.
    if not os.path.isfile(DATA_FILE):
        with open(DATA_FILE, "w") as f:
            json.dump([], f)
    
    # Load existing data.
    with open(DATA_FILE, "r") as f:
        existing_data = json.load(f)
    
    # Append new records (data is expected to be a list).
    existing_data.extend(data)
    
    # Write updated data back.
    with open(DATA_FILE, "w") as f:
        json.dump(existing_data, f, indent=4)

@app.route('/training-data', methods=['POST'])
def training_data():
    try:
        # Expect a JSON array of training records.
        data = request.get_json()
        if not isinstance(data, list):
            return jsonify({"status": "error", "message": "Data must be a JSON array."}), 400
        
        print("Received training data:")
        print(json.dumps(data, indent=4))
        
        append_training_data(data)
        
        return jsonify({"status": "success", "message": "Training data received."}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

if __name__ == '__main__':
    # Run locally on port 5001.
    app.run(host='0.0.0.0', port=5001, debug=True)
