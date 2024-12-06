import time

from flask import jsonify
import openai
import json
from langchain_core.prompts import ChatPromptTemplate
from langchain_ollama import OllamaLLM
import cv2
from fer import FER

template = """
You are an expert in mental health and wellness, specializing in anxiety and depression assessment. 
Please classify the level of anxiety and depression as "high," "medium," or "low" from the user's answer to the question.
If a summary of emotions detected from the FER model is provided, incorporate this information into your assessment. If no summary is available, rely solely on the user's answer.

Include an accuracy/confidence score on a scale of 0.00 to 1.00 for both anxiety and depression predictions. Based on this, generate a follow-up 
question to gain more insights and provide activities in an array format to help with the classified levels.
The array should contain nested objects which have keys "activity" and "description".
Each activity should be concise (3-4 words max), and the description should be practical and specific.
The description should have a description in one line of what to do for the activity.

Respond only with a JSON dictionary and nothing else.

Question: {question}
Answer: {answer}

Summary: {{summary or 'No facial emotion data available'}}

Return the JSON dictionary in the following format:
{{
  "anxiety": "<level>",
  "anxiety_confidence": <confidence_value>,
  "depression": "<level>",
  "depression_confidence": <confidence_value>,
  "follow_up": "<question_if_needed>",
  "suggested_activities": ["<activity_1>", "<activity_2>", "<activity_3>", ...]
}}
"""

# Create the prompt template
prompt = ChatPromptTemplate.from_template(template)
# Initialize the model
model = OllamaLLM(model="llama3")
# Combine the prompt and the model using the new sequence approach
chain = prompt | model

def combined_analysis(user_question, user_answer, video_path = None):

    emotion_summary = extract_emotion_summary(video_path) if video_path else 'No facial emotion data available'
    print(emotion_summary)

    try:
        # Invoke with either emotion summary or default message
        result = chain.invoke({
            "question": user_question,
            "answer": user_answer,
            "summary": emotion_summary
        })

        # Extract the JSON part of the response
        json_start = result.find('{')
        json_end = result.rfind('}') + 1
        json_response = result[json_start:json_end]
        parsed_result = json.loads(json_response)

        return parsed_result

    except json.JSONDecodeError as e:
        error_message = f"Failed to parse JSON from response: {str(e)}"
        print(error_message)
        return {"error": error_message}
    except Exception as e:
        error_message = f"Unexpected error in Llama_analysis: {str(e)}"
        print(error_message)
        return {"error": error_message}


def extract_emotion_summary(video_source=0, frame_interval=5, max_duration=10):
    cap = cv2.VideoCapture(video_source)
    emotion_detector = FER()

    emotion_summary = {
        'happy': 0,
        'sad': 0,
        'angry': 0,
        'surprised': 0,
        'neutral': 0,
        'fear': 0,
        'disgust': 0,
    }

    # Variables for frame sampling and duration control
    start_time = time.time()
    frame_count = 0
    valid_frames = 0

    # Process video frames
    while True:
        ret, frame = cap.read()
        if not ret or (time.time() - start_time > max_duration):
            break

        # Process only every `frame_interval`-th frame
        if frame_count % frame_interval == 0:
            results = emotion_detector.detect_emotions(frame)

            # Only update the summary if emotions are detected
            if results:
                valid_frames += 1
                for result in results:
                    emotions = result['emotions']
                    for emotion, value in emotions.items():
                        if emotion in emotion_summary:
                            emotion_summary[emotion] += value

        frame_count += 1

    cap.release()

    # Normalize emotion summary
    total_counts = sum(emotion_summary.values())
    for emotion in emotion_summary:
        emotion_summary[emotion] = emotion_summary[emotion] / total_counts if total_counts > 0 else 0

    return emotion_summary
