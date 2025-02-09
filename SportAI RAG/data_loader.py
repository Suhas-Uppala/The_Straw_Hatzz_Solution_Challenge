# data_loader.py
from langchain.text_splitter import CharacterTextSplitter
from langchain.docstore.document import Document

def load_athlete_data(file_path="athlete_data.txt"):
    """Reads and splits athlete-related data into smaller chunks."""
    with open(file_path, "r", encoding="utf-8") as file:
        text = file.read()

    text_splitter = CharacterTextSplitter(chunk_size=200, chunk_overlap=20)
    chunks = text_splitter.split_text(text)
    
    return [Document(page_content=chunk) for chunk in chunks]

if __name__ == "__main__":
    docs = load_athlete_data()
    print(f"Loaded {len(docs)} document chunks from athlete data.")
