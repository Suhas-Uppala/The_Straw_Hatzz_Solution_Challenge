# qa_chain.py
import pickle
from langchain.chains import RetrievalQA
from langchain.text_splitter import CharacterTextSplitter
from langchain_community.vectorstores import FAISS
from langchain_community.embeddings import HuggingFaceEmbeddings
from gemini_llm import GeminiLLM

def load_athlete_data():
    """Load athlete data from the text file"""
    with open('athlete_data.txt', 'r') as file:
        return file.read()

def load_vector_store():
    """Loads the FAISS vector store from disk."""
    with open("vectorstore.pkl", "rb") as f:
        return pickle.load(f)

def create_qa_chain():
    """Creates and returns the Retrieval QA chain using the vector store and Gemini LLM."""
    # Load the athlete data
    athlete_data = load_athlete_data()
    
    # Split the text into chunks
    text_splitter = CharacterTextSplitter(
        separator="\n",
        chunk_size=1000,
        chunk_overlap=200,
        length_function=len
    )
    texts = text_splitter.split_text(athlete_data)
    
    # Create embeddings and vector store with explicit model name
    embeddings = HuggingFaceEmbeddings(
        model_name="sentence-transformers/all-MiniLM-L6-v2"
    )
    vectorstore = FAISS.from_texts(texts=texts, embedding=embeddings)
    
    # Create and return the QA chain without return_source_documents
    llm = GeminiLLM()
    qa_chain = RetrievalQA.from_chain_type(
        llm=llm,
        chain_type="stuff",
        retriever=vectorstore.as_retriever(),
        return_source_documents=False  # Changed to False to fix ValueError
    )
    
    return qa_chain

if __name__ == "__main__":
    qa_chain = create_qa_chain()
    while True:
        query = input("\nAsk a question about the athlete's fitness data (or type 'exit' to quit): ")
        if query.lower() == "exit":
            break
        # Use invoke instead of run
        response = qa_chain.invoke({"query": query})
        print("\nAnswer:", response['result'])
