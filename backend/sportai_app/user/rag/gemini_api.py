import google.generativeai as genai
import os
from dotenv import load_dotenv

load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
genai.configure(api_key=GEMINI_API_KEY)

_chat_session = None
_chat_history = []

def query_gemini(prompt):
    try:
        return _extracted_from_query_gemini_7(prompt)
    except Exception as e:
        _chat_session = None
        _chat_history = []
        return f"❌ API Error: {e}"

def _extracted_from_query_gemini_7(prompt):
    global _chat_session, _chat_history
    model = genai.GenerativeModel('gemini-2.0-flash-exp')

    safety_settings = {
        "HARASSMENT": "block_none",
        "HATE_SPEECH": "block_none",
        "SEXUALLY_EXPLICIT": "block_none",
        "DANGEROUS_CONTENT": "block_none",
    }

    if _chat_session is None:
        system_prompt = """You are a professional and caring AI fitness coach that has access to athlete's data.
- When someone asks questions, provide advice based on analyzing athlete_data.txt file's data as a reference
- Never assume the user is someone mentioend in the context file - they are asking about his fitness regime and data
- Start responses with phrases like "Based on the data..." or "Looking at the athlete's profile..."
- Give explanations and recommendations while referring to the data as a third person case study
- Keep responses focused on sports, fitness, and health-related topics
- If something is unclear, ask for clarification
- For general greetings, respond professionally without assuming anything about the user"""

        _chat_session = model.start_chat(history=[])
        _chat_history = []
        _chat_session.send_message(system_prompt)

    _chat_history.append({"role": "user", "content": prompt})

    response = _chat_session.send_message(prompt)

    _chat_history.append({"role": "assistant", "content": response.text})

    return response.text

def reset_chat():
    global _chat_session, _chat_history
    _chat_session = None
    _chat_history = []
    return {"message": "Chat history cleared", "history": []}

def get_chat_history():
    global _chat_history
    return _chat_history
