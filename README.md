# SportAI – The AI-Powered Athlete Management Platform

[![GDGC Solution Challenge 2025](https://img.shields.io/badge/GDGC-Solution%20Challenge%202025-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://developers.google.com/community/gdsc-solution-challenge)
[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)

## 🎥 Demo

[Watch our Solution Challenge Demo Video](https://drive.google.com/file/d/1hb96ohcVjzXS7ItFTIBrI0tbBZGOsR3z/view?usp=sharing)

## Overview

SportAI tackles the challenges faced by India's athletes by providing an integrated platform that combines:

- **AI-Driven Coaching**: Real-time, personalized training plans utilizing RAG and NLP.
- **Smart Performance Tracking**: IoT and video analytics for improving techniques.
- **Injury Prediction & Rehabilitation**: ML-based risk detection with proactive recovery strategies.
- **Financial Empowerment**: Tools for budgeting, sponsorship matchmaking, and contract management.
- **360° Athlete Management**: A unified system connecting athletes, coaches, and managers.

## Problem Statement

India’s athletes struggle with:

- **Fragmented Management:** Disparate tools for training, performance, and finances.
- **Inconsistent Training:** Lack of personalized coaching leads to inefficiency.
- **Limited Financial Opportunities:** Missing links between performance data and sponsorship deals.

SportAI provides a comprehensive solution that addresses each of these issues with advanced AI and IoT technologies.

## What Makes Us Different?

- **Personalized AI Coaching**: Leveraging RAG, NLP, and the Gemini API to deliver adaptive training plans.
- **Real-Time Smart Analytics**: Wearable and video-based analysis to provide actionable insights.
- **Predictive Maintenance for Athletes**: Using machine learning for injury prediction and tailored rehab plans.
- **Financial Tools**: AI-powered sponsorship matching, budgeting, and contract management to secure athlete growth.
- **Seamless Collaboration**: A real-time communication hub connecting all stakeholders.

## 🛠️ Core Technology Stack

### AI/ML Components

- **RAG Framework**:
  - LangChain with Gemini 2.0 Flash API for personalized AI coaching
  - all-MiniLM-L6-v2 Sentence Transformer for semantic analysis
- **Machine Learning**: Pre-trained Random Forest models for injury prediction
- **Computer Vision**: OpenCV and MediaPipe for posture analysis and correction

### Frontend

- **Framework**: Flutter for cross-platform mobile and web interfaces
- **UI Components**: Material Design 3.0 with responsive layouts
- **State Management**: Provider/Bloc pattern for efficient data flow

### Backend

- **API Framework**: FastAPI for high-performance backend services
- **Cloud Services**: Firebase for authentication and real-time data
- **Serverless Functions**: For scalable, event-driven processing

## Setup and run guide

### Clone repository
```bash
git clone https://github.com/Suhas-Uppala/The_Brainiacs_Solution_Challenge.git
cd "The_Brainiacs_Solution Challenge"
```

### Running the Frontend (SportAI Flutter App)
#### 1. Navigate to the Flutter App folder:
```bash
cd SportAI
```

#### 2. Install Flutter dependencies:
```bash
flutter pub get
```

#### 3. Run the Application (make sure your emulator/device is ready):
```bash
flutter run
```

### Running the Backend Services
- Our backend is split into two modules: SportAI RAG (for AI-driven coaching) and SportAI Posture (for real-time posture analysis). Both use Python.

### a. SportAI RAG
1. Navigate to the SportAI RAG folder:
```bash
cd "../SportAI RAG"
```
2. Set up a Python virtual environment (Windows Commands):
```bash
python -m venv venv
venv\Scripts\activate
```
3. Install the required packages:
```bash
pip install -r requirements.txt
```
4. Build the FAISS vector store:
```bash
python build_vector_store.py
```
5. Start the AI coaching service:
```bash
python api.py
```

### b. SportAI Posture
1. Navigate to the SportAI Posture folder:
```bash
cd "../SportAI Posture"
```
2. Set up a Python virtual environment (Windows Commands):
```bash
python -m venv venv
venv\Scripts\activate
```
3. Install the required packages:
```bash
pip install -r requirements.txt
```
4. Start the posture analysis service:
```bash
python api.py
```
## Testing & Quality Assurance
### Frontend Tests (from the SportAI directory):
```bash
flutter test
```
### Backend API Tests (in each backend folder):
```bash
pytest
```

## Detailed Feature Implementation

### 1. AI-Driven Coaching System

- **Personal AI Coach**
  - LangChain + Gemini 2.0 Flash API integration
  - Real-time natural language processing
  - Contextual training recommendations
- **Smart Recommendations Engine**
  - Biometric data analysis
  - Performance metric tracking
  - Adaptive training plans

### 2. Computer Vision-Based Performance Analysis

- **Posture Correction**
  - Real-time video capture and processing
  - Body landmark extraction using MediaPipe
  - Joint angle computation and analysis
- **Movement Pattern Analysis**
  - Exercise form validation
  - Real-time feedback generation
  - Progress tracking visualization

### 3. Predictive Risk Management

- **Injury Prevention**
  - Random Forest model implementation
  - Historical data analysis
  - Real-time risk assessment
- **Recovery Planning**
  - AI-generated rehabilitation protocols
  - Progress monitoring
  - Adaptive recovery strategies

### 4. Financial Management Suite

- **Sponsorship Marketplace**
  - AI-driven brand matching
  - Performance-based recommendations
  - Contract management system
- **Financial Planning**
  - Expense tracking
  - Budget optimization
  - Tax compliance tools

## Testing & Quality Assurance

1. **Unit Tests**: Run `flutter test`
2. **Integration Tests**: Execute `flutter drive`
3. **API Tests**: Run `pytest` in the backend directory

## Deployment

1. **Frontend**: Flutter web build and Firebase hosting
2. **Backend**: FastAPI deployment on cloud platform

## Co-owners

### [Rishit](https://github.com/rishitsura)
### [Suhas](https://github.com/Suhas-Uppala)
### [Khyathi](https://github.com/khyathi23)
### [Naveen](https://github.com/T-Naveen-2308)