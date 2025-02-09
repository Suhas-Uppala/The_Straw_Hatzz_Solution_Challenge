from langchain.llms.base import LLM
from typing import Optional, List
from gemini_api import query_gemini

class GeminiLLM(LLM):
    def __init__(self, callbacks=None):
        super().__init__()
        self.callbacks = callbacks

    @property
    def _llm_type(self) -> str:
        return "gemini"

    def _call(self, prompt: str, stop: Optional[List[str]] = None) -> str:
        return query_gemini(prompt)

    @property
    def _identifying_params(self) -> dict:
        return {}
