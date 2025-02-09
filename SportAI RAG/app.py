import streamlit as st
from qa_chain import create_qa_chain

st.set_page_config(page_title="Campus Guide AI", layout="wide")
st.title("🏅 SportAI")

# Initialize conversation history in session state
if 'messages' not in st.session_state:
    st.session_state.messages = []

qa_chain = create_qa_chain()

# Input form at the top, with clear_on_submit=True
with st.form("chat_input", clear_on_submit=True):
    user_query = st.text_input("Your message:")
    submitted = st.form_submit_button("Send")
    if submitted and user_query:
        # Get assistant response
        response = qa_chain.run(user_query)
        st.session_state.messages.append({"role": "user", "content": user_query})
        st.session_state.messages.append({"role": "assistant", "content": response})

# Container for chat history (displayed below)
chat_container = st.container()
with chat_container:
    for msg in st.session_state.messages:
        if msg["role"] == "assistant":
            st.markdown(
                f"""
                <div style="
                    text-align: left;
                    background-color: #FFFFFF;
                    color: #000000;
                    border: 2px solid #007BFF;
                    border-radius: 15px;
                    padding: 10px;
                    margin: 10px 0;
                    box-shadow: 2px 2px 8px rgba(0, 0, 0, 0.1);
                    max-width: 70%;
                    ">
                    SportAI: {msg['content']}
                </div>
                """,
                unsafe_allow_html=True
            )
        else:
            st.markdown(
                f"""
                <div style="
                    text-align: right;
                    background-color: #D0EBFF;
                    color: #000000;
                    border: 2px solid #0056B3;
                    border-radius: 15px;
                    padding: 10px;
                    margin: 10px 0;
                    box-shadow: 2px 2px 8px rgba(0, 0, 0, 0.1);
                    max-width: 70%;
                    margin-left: auto;
                    ">
                    You: {msg['content']}
                </div>
                """,
                unsafe_allow_html=True
            )
