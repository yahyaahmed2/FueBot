<<<<<<< HEAD
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');
const multer = require('multer');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CLIENT_URL || 'http://localhost:3000',
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api/', limiter);

// File upload configuration
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/')
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['.pdf', '.doc', '.docx', '.txt', '.pptx'];
    const extname = path.extname(file.originalname).toLowerCase();
    if (allowedTypes.includes(extname)) {
      return cb(null, true);
    }
    cb(new Error('Only PDF, DOC, DOCX, TXT, and PPTX files are allowed'));
  }
});

// Mock database (replace with actual database)
const conversations = new Map();

// API Routes

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Chat endpoint - READY FOR YOUR RAG AI CONNECTION
app.post('/api/chat', 
  [
    body('message').trim().notEmpty().withMessage('Message is required'),
    body('history').isArray().optional()
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { message, history, conversation_id } = req.body;
      
      // THIS IS WHERE YOU CONNECT TO YOUR RAG AI SYSTEM
      // Replace this mock response with actual API call to your AI backend
      
      // Example structure for RAG response:
      const ragResponse = {
        answer: `This is a mock response for: "${message}". Connect this to your RAG AI system.`,
        sources: [
          {
            title: "Sample Academic Paper",
            url: "https://university.edu/papers/sample.pdf",
            page: 42,
            confidence: 0.95
          },
          {
            title: "Course Syllabus - CS101",
            url: "https://university.edu/courses/cs101/syllabus",
            page: 1,
            confidence: 0.87
          }
        ],
        conversation_id: conversation_id || `conv_${Date.now()}`,
        metadata: {
          processing_time: 0.45,
          tokens_used: 150
        }
      };

      // Store conversation in memory (replace with database)
      if (!conversations.has(ragResponse.conversation_id)) {
        conversations.set(ragResponse.conversation_id, []);
      }
      conversations.get(ragResponse.conversation_id).push({
        role: 'user',
        content: message,
        timestamp: new Date()
      });
      conversations.get(ragResponse.conversation_id).push({
        role: 'assistant',
        content: ragResponse.answer,
        timestamp: new Date()
      });

      res.json(ragResponse);
    } catch (error) {
      console.error('Chat error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
);

// File upload endpoint
app.post('/api/upload', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    // Here you would process the file for RAG
    // Extract text, chunk it, and store in vector database
    
    const response = {
      file_id: `file_${Date.now()}`,
      filename: req.file.originalname,
      filepath: req.file.path,
      size: req.file.size,
      mimetype: req.file.mimetype,
      status: 'uploaded',
      message: 'File uploaded successfully. Ready for processing.'
    };

    res.json(response);
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get conversation history
app.get('/api/conversations/:id?', (req, res) => {
  try {
    const { id } = req.params;
    
    if (id) {
      const conversation = conversations.get(id);
      if (!conversation) {
        return res.status(404).json({ error: 'Conversation not found' });
      }
      return res.json({
        conversation_id: id,
        messages: conversation,
        created_at: new Date(parseInt(id.split('_')[1])).toISOString()
      });
    }

    // Return all conversations
    const allConversations = Array.from(conversations.entries()).map(([id, messages]) => ({
      conversation_id: id,
      message_count: messages.length,
      last_message: messages[messages.length - 1],
      created_at: new Date(parseInt(id.split('_')[1])).toISOString()
    }));

    res.json({ conversations: allConversations });
  } catch (error) {
    console.error('Error fetching conversations:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Document search endpoint
app.post('/api/search', async (req, res) => {
  try {
    const { query, filters = {} } = req.body;
    
    // Connect this to your vector database search
    const searchResults = {
      query,
      results: [
        {
          id: 'doc_001',
          title: 'Introduction to Computer Science',
          content: 'Sample content matching your query...',
          relevance: 0.92,
          metadata: {
            course: 'CS101',
            professor: 'Dr. Smith',
            year: 2023
          }
        }
      ],
      total: 1
    };

    res.json(searchResults);
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something broke!' });
});

// Create uploads directory if it doesn't exist
const fs = require('fs');
if (!fs.existsSync('uploads')) {
  fs.mkdirSync('uploads');
}

app.listen(PORT, () => {
  console.log(`FueBot backend running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/api/health`);
});
=======
require('dotenv').config();
const express = require('express');
const sessionMiddleware = require('./config/config');
const authRoutes = require('./routes/authRoutes');

const app = express();

app.use(express.json());
app.use(sessionMiddleware);
app.use('/auth', authRoutes);

app.listen(process.env.PORT || 5000, () =>
  console.log('Server running')
);
>>>>>>> yahya-signup
