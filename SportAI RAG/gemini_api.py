import google.generativeai as genai
import os
from dotenv import load_dotenv

load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
genai.configure(api_key=GEMINI_API_KEY)

# Global chat session and history
_chat_session = None
_chat_history = []

def query_gemini(prompt):
    """
    Sends a prompt to the Gemini 2.0 Flash API and returns the response text.
    Maintains chat history internally.
    """
    try:
        global _chat_session, _chat_history
        model = genai.GenerativeModel('gemini-2.0-flash-exp')
        
        # Configure chat settings
        safety_settings = {
            "HARASSMENT": "block_none",
            "HATE_SPEECH": "block_none",
            "SEXUALLY_EXPLICIT": "block_none",
            "DANGEROUS_CONTENT": "block_none",
        }
        
        # Initialize chat session if it doesn't exist
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
        
        # Add user message to history
        _chat_history.append({"role": "user", "content": prompt})
        
        # Send user message and get response
        response = _chat_session.send_message(prompt)
        
        # Add AI response to history
        _chat_history.append({"role": "assistant", "content": response.text})
        
        # Return only the assistant's response
        return response.text
    except Exception as e:
        # Reset everything on error
        _chat_session = None
        _chat_history = []
        return f"❌ API Error: {e}"

def reset_chat():
    """
    Resets both the chat session and history.
    """
    global _chat_session, _chat_history
    _chat_session = None
    _chat_history = []
    return {"message": "Chat history cleared", "history": []}

def get_chat_history():
    """
    Returns the current chat history.
    """
    global _chat_history
    return _chat_history
