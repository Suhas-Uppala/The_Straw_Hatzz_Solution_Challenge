from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from qa_chain import create_qa_chain
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # adjust domains as needed
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Define request schema
class ChatRequest(BaseModel):
    query: str


# Initialize qa_chain once at startup
qa_chain = create_qa_chain()


@app.post("/chat")
def chat(request: ChatRequest):
    if not request.query:
        raise HTTPException(status_code=400, detail="Query is required")
    response = qa_chain.run(request.query)
    return {"response": response}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
