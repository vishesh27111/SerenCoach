from flask import Flask, request, jsonify
from langchain_core.prompts import ChatPromptTemplate
from langchain_ollama import OllamaLLM
from flask_cors import CORS
import json
import logging

logging.basicConfig(level=logging.DEBUG)
app = Flask(__name__)
app.config['SERVER_NAME'] = None
CORS(app)
app.config['WTF_CSRF_ENABLED'] = False
# Define the updated prompt template with question, answer, and confidence handling
template = """
Classify the level of anxiety and depression either high, low or medium from the following question and answer.
Also, provide a confidence score on the scale of 0.00 to 1.00 for both anxiety and depression predictions.
Give a follow-up question to gather more information related to the answer.
Suggest activities in an array format to help with the level of anxiety and depression based on your classification. 
The activities can be practical, context-specific based on the user's answer, and can also include general suggestions like walking, reading, or listening to music.
The array should contain nested objects which have keys "activity" and "description".
The activity should name the activity to do in 3-4 words maximum. For eg - "Walk", "Practice mindfulness".
The description should have a description in one line of what to do for the activity.

Respond only with a JSON dictionary and nothing else.

Question: {question}
Answer: {answer}

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


@app.route('/therapist', methods=['POST'])
def classify_response():
    logging.debug("Received request to /therapist")
    try:
        # Log the received request body
        data = request.get_json(force=True, silent=True)
        logging.debug(f"Request body: {data}")

        if not data:
            return jsonify({"error": "Invalid JSON in request body"}), 400

        # Extract "question" and "answer" from the request body
        user_question = data.get('question', '')
        user_answer = data.get('answer', '')

        if not user_question or not user_answer:
            return jsonify({"error": "Both 'question' and 'answer' fields are required"}), 400

        # Pass the user's question and answer to the model for classification using `invoke`
        result = chain.invoke({"question": user_question, "answer": user_answer})

        try:
            # Extract the JSON part of the response
            json_start = result.find('{')
            json_end = result.rfind('}') + 1
            json_response = result[json_start:json_end]
            parsed_result = json.loads(json_response)

            # Log the generated response before sending it
            logging.debug(f"Generated response: {parsed_result}")

            # Return the parsed JSON as the API response
            return jsonify(parsed_result)

        except json.JSONDecodeError as json_error:
            error_message = f"JSON parsing error: {str(json_error)}"
            logging.error(error_message)
            return jsonify({"error": error_message, "raw_result": result}), 400
        except ValueError as value_error:
            error_message = f"Value error: {str(value_error)}"
            logging.error(error_message)
            return jsonify({"error": error_message, "raw_result": result}), 400

    except Exception as model_error:
        logging.error(f"Error in classify_response: {str(model_error)}")
        return jsonify({"error": f"Model invocation error: {str(model_error)}"}), 500


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)
