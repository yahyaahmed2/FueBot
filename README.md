# FueBot Ecosystem

FueBot is an integrated academic advising system for students and advisors at Future University Egypt's Faculty of Computers & Information Technology. It features role-based access, automated scheduling, and a RAG-powered chatbot using the university handbook.


## System Highlights (Technical Contributions)

- RAG-based question answering over structured academic handbook data
- Custom PDF ingestion pipeline using structured extraction and chunking strategy
- Vector search using ChromaDB with OpenAI embeddings
- Context-aware query rewriting for improved retrieval accuracy
- Session-based memory for personalized chat continuity
- Role-based advising logic (student vs advisor flows)


## Architecture

Three microservices:

1. **Backend API** (`backend/`): Node.js/Express with PostgreSQL. Handles authentication, student management, course registration, advisor approvals, and integrates with AI service for RAG-based academic advising.

2. **AI Service** (`ai-service/`): Python/FastAPI with LangChain, ChromaDB, and OpenAI. Implements a RAG pipeline over the university handbook with custom ingestion, embedding, and retrieval tuning for improved answer accuracy.

Includes iterative improvements in chunking strategy, embedding selection, and retrieval configuration to improve answer grounding and reduce hallucination.

3. **Frontend** (`frontend/`): React/TypeScript with Tailwind CSS. Role-based UI for students (chat, progress tracking) and advisors (student management).

## Prerequisites

- Node.js v18+, Python 3.10+, PostgreSQL

## Quick Start

1. **Database Setup**:
   ```bash
   psql -U postgres -c "CREATE DATABASE fuebot_db;"
   psql -U postgres -d fuebot_db -f backend/db/FueBot.sql
   ```

2. **AI Service**:
   ```bash
   cd ai-service
   pip install -r requirements.txt
   cp .env.example .env  # Add OPENAI_API_KEY
   cp /path/to/handbook.pdf data/handbook.pdf
   python -m app.ingest
   # Builds vector store from handbook PDF (required for RAG system to function)
   python app/main.py
   ```

3. **Backend**:
   ```bash
   cd backend
   npm install
   cp .env.example .env  # Configure DB and AI service URL
   npm start
   ```

4. **Frontend**:
   ```bash
   cd frontend
   npm install
   cp .env.example .env  # Set REACT_APP_API_BASE_URL=http://localhost:8080
   npm start
   ```

Access at `http://localhost:3000`. Seed accounts: students `hassan@example.com` (student123), advisors `ahmed.advisor@fue.edu.eg` (advisor123).

## API Overview

- **Auth**: `/auth/login`, `/auth/register`, `/auth/me`
- **Chat**: `/chat/message` (student-only)
- **Courses**: `/courses/*` (enrollment, status updates)
- **Advisor**: `/advisor/*` (student management)

Ports: Backend 8080, AI 8000, Frontend 3000.

## Project Structure

```
fuebot/
├── backend/          # Node.js API server
├── ai-service/       # Python RAG chatbot
├── frontend/         # React UI
└── README.md
```
