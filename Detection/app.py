import os
import openai
from flask import Flask, request, jsonify
from pymongo import MongoClient
from datetime import datetime
from bson import ObjectId
from langchain_core.prompts import ChatPromptTemplate
from langchain_ollama import OllamaLLM
from flask_cors import CORS
from CombinedAnalysis import combined_analysis
from keys import mongodb_host
import logging
from werkzeug.utils import secure_filename
from bson.json_util import dumps
from keys import openai_key

openai.api_key = openai_key
logging.basicConfig(level=logging.DEBUG)
app = Flask(__name__)
app.config['SERVER_NAME'] = None
CORS(app)
app.config['WTF_CSRF_ENABLED'] = False

# Set the folder to store uploaded videos
UPLOAD_FOLDER = 'uploaded_videos'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Create the uploads folder if it doesn't exist
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# Initialize the model
model = OllamaLLM(model="llama3")

client = MongoClient(mongodb_host, tls=True, tlsAllowInvalidCertificates=True)
db = client['sc']
chats_collection = db['chats']
goals_collection = db['goals']
logs_collection = db['logs']
emergency_collection = db['emergency']
meditations_collection = db['meditation']

@app.route('/detect', methods=['POST'])
def detect():
    # data = request.get_json(force=True, silent=True)
    # if not data:
    #     return jsonify({"error": "Invalid JSON in request body"}), 400
    user_question = request.form.get('question', '')
    user_answer = request.form.get('answer', '')
    if not user_question or not user_answer:
        return jsonify({"error": "Both 'question' and 'answer' fields are required"}), 400

    if 'video' not in request.files:
        return jsonify({'error': 'Video file missing'}), 400

    # Get the uploaded video file
    video_file = request.files['video']

    if video_file:
        # Secure the filename and save the video
        filename = secure_filename(video_file.filename)
        video_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        video_file.save(video_path)

    # Analyze voice response
    # try:
    #     voice_prediction = voice_analysis(user_question, user_answer)
    # except Exception as e:
    #     return jsonify({'error': 'Voice Analysis failed'}), 500
    #
    # # Analyze video response
    # try:
    #     video_prediction = video_analysis(video_path)
    # except Exception as e:
    #     return jsonify({'error': 'Video Analysis failed'}), 500

    try:
        result = combined_analysis(user_question, user_answer, video_path)
    except Exception as e:
        return jsonify({'error': 'Analysis failed', 'details': str(e)}), 500
    finally:
        # Clean up: remove video file if it was saved
        if video_path:
            os.remove(video_path)

    # combined_result = combine_results(voice_prediction, video_prediction)
    # os.remove(video_path)

    # Return predictions
    return jsonify(result)

def combine_results(voice_prediction, video_prediction):

    print("Voice Prediction: ", voice_prediction)
    print("Video Prediction: ", video_prediction)


    # Combine anxiety and depression predictions
    combined_anxiety_confidence = (
        min(1.00, voice_prediction['anxiety_confidence'] + video_prediction['anxiety_confidence']) if voice_prediction['anxiety'] == video_prediction['anxiety'] else
        voice_prediction['anxiety_confidence'] - (video_prediction['anxiety_confidence']/5)
    )

    combined_depression_confidence = (
        min(1.00, voice_prediction['depression_confidence'] + video_prediction['depression_confidence']) if voice_prediction['depression'] == video_prediction['depression'] else
        voice_prediction['depression_confidence'] - (video_prediction['depression_confidence'] / 5)
    )

    # combined_depression_confidence = (min(1, voice_prediction['depression_confidence'] + (video_prediction['depression_confidence']/5))) if voice_prediction['depression'] == video_prediction['depression'] else voice_prediction['depression_confidence'] - (video_prediction['depression_confidence'] / 5))

    # Determine final anxiety and depression levels based on confidence
    combined_anxiety = voice_prediction['anxiety']  # Keep voice prediction anxiety level
    combined_depression = voice_prediction['depression']  # Keep voice prediction depression level

    # Create the final combined result
    combined_result = {
        'anxiety': combined_anxiety,
        'anxiety_confidence': round(combined_anxiety_confidence, 2),
        'depression': combined_depression,
        'depression_confidence': round(combined_depression_confidence, 2),
        'follow_up': voice_prediction['follow_up'],
        'suggested_activities': voice_prediction['suggested_activities']
    }

    print("Combined Result: ", combined_result)
    return combined_result

@app.route('/save_chat', methods=['POST'])
def save_chat():
    # data = request.json
    conversation = request.json.get('conversation')

    # Insert the conversation document into MongoDB
    chat_document = {
        'conversation': conversation,
        'timestamp': datetime.utcnow(),
    }

    result = chats_collection.insert_one(chat_document)

    return jsonify({
        'message': 'Chat saved successfully',
        'id': str(result.inserted_id)
    }), 201

@app.route('/get_chats', methods=['GET'])
def get_chats():
    # Retrieve all documents in the collection
    chats = list(chats_collection.find())

    # Convert ObjectId and datetime objects to strings for JSON compatibility
    for chat in chats:
        chat['_id'] = str(chat['_id'])
        chat['timestamp'] = chat['timestamp'].isoformat()

    return jsonify(chats), 200

@app.route('/set_goal', methods=['POST'])
def set_goal():
    data = request.json

    # Construct the goal document
    goal_document = {
        'goal_title': data.get('goal_title'),
        'description': data.get('description'),
        'deadline': datetime.fromisoformat(data.get('deadline')),
        'created_at': datetime.utcnow(),
        'progress': data.get('progress', 0),
        'status': data.get('status', 'in-progress'),
        'stars': 0
    }

    # Insert the goal into MongoDB
    result = goals_collection.insert_one(goal_document)

    return jsonify({
        'message': 'Goal created successfully',
        'id': str(result.inserted_id)
    }), 201

@app.route('/update_goal/<goal_id>', methods=['PATCH'])
def update_goal(goal_id):
    data = request.json
    update_fields = {}

    # Add fields for update based on the provided data
    if 'progress' in data:
        update_fields['progress'] = data['progress']
        if data['progress'] == 100:
            update_fields['stars'] = 5
            update_fields['status'] = 'completed'
    if 'deadline' in data:
        update_fields['deadline'] = datetime.fromisoformat(data['deadline'])

    # Update the goal document in MongoDB
    result = goals_collection.update_one(
        {'_id': ObjectId(goal_id)},
        {'$set': update_fields}
    )

    if result.matched_count == 0:
        return jsonify({'error': 'Goal not found'}), 404

    return jsonify({'message': 'Goal updated successfully'}), 200

@app.route('/goals', methods=['GET'])
def get_goals():
    # Retrieve all goals from MongoDB
    goals = list(goals_collection.find())

    # Convert ObjectId and datetime objects to strings for JSON compatibility
    for goal in goals:
        goal['_id'] = str(goal['_id'])
        goal['deadline'] = goal['deadline'].isoformat()
        goal['created_at'] = goal['created_at'].isoformat()

    return jsonify(goals), 200

template = """
You are a friendly AI therapist. Your goal is to provide empathetic and supportive responses.
When a user shares their feelings, acknowledge their emotions and ask relevant follow-up questions.
The array of complete chat history is provided from the beginning.

Chat History: {chats}
Therapist's next question: 
"""

@app.route('/chat-ai', methods=['POST'])
def chat_ai():
    # Create the prompt template
    # prompt = ChatPromptTemplate.from_template(template)

    # Combine the prompt and the model using the new sequence approach
    # chain = prompt | model

    data = request.json
    chats = data.get('chats')
    prompt = template.format(chats=chats)
    # Call the OpenAI API to get the classification

    try:
        # result = chain.invoke({"questions": questions, "answers": answers})
        # result = chain.invoke({"chats": chats})
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "user", "content": prompt}
            ],
            temperature=0.3,
        )
        print(response.choices[0].message['content'])
        return {"next_question": response.choices[0].message['content']}
    except Exception as e:
        error_message = f"Unexpected error: {str(e)}"
        print(error_message)
        return {"error": error_message}

@app.route('/add_log', methods=['POST'])
def add_log():
    data = request.json
    entry = {
        "date": data['date'],
        "title": data['title'],
        "description": data['description'],
    }
    result = logs_collection.insert_one(entry)
    return jsonify({"message": "Entry added", "id": str(result.inserted_id)}), 201

@app.route('/logs/<date>', methods=['GET'])
def get_log_by_date(date):
    entry = logs_collection.find_one({"date": date})
    if entry:
        entry['_id'] = str(entry['_id'])
        return jsonify(entry), 200
    else:
        return jsonify({"message": "No entry found"}), 404

@app.route('/emergency', methods=['GET'])
def get_emergency_resources():
    emergency_resources = emergency_collection.find({})
    return dumps(emergency_resources), 200

@app.route("/meditations", methods=["GET"])
def get_meditations():
    meditations = list(meditations_collection.find({}, {"_id": 0}))
    return jsonify(meditations)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)