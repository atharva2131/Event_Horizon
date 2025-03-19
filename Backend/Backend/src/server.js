require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const http = require('http');
const socketIo = require('socket.io');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');
const hpp = require('hpp');

const authRoutes = require('./routes/authRoutes');
const eventRoutes = require('./routes/eventRoutes');
const vendorRoutes = require('./routes/vendorRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const notificationRoutes = require("./routes/notificationRoutes")
const chatRoutes = require('./routes/chatRoutes');

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: process.env.CLIENT_URL || '*',
    methods: ['GET', 'POST'],
    credentials: true
  }
});
console.log('Loaded Environment Variables:', process.env);

const PORT = process.env.PORT || 3000;
const UPLOADS_DIR = path.join(__dirname, 'uploads');

console.log('MONGO_URI:', process.env.MONGO_URI); // Check if the value is being read
console.log('JWT_SECRET:', process.env.JWT_SECRET);

// 🌍 Validate Required Environment Variables
const validateEnvVariables = () => {
  


  const requiredEnvVars = ['MONGO_URI', 'JWT_SECRET'];
  const missingVars = requiredEnvVars.filter((varName) => !process.env[varName]);

  if (missingVars.length > 0) {
    console.error(`❌ Missing required environment variables: ${missingVars.join(', ')}`);
    process.exit(1);
  }
  console.log('✅ Environment variables validated');
};

// 🛠️ Connect to MongoDB
const connectDB = async () => {
  try {
    if (mongoose.connection.readyState !== 1) {
      await mongoose.connect(process.env.MONGO_URI, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        serverSelectionTimeoutMS: 5000,
      });
      console.log('✅ MongoDB Connected Successfully');
    } else {
      console.log('⚠️ MongoDB is already connected.');
    }
  } catch (error) {
    console.error('❌ Error connecting to MongoDB:', error.message);
    process.exit(1);
  }
};

// 📁 Ensure uploads directory exists
const ensureUploadsDir = () => {
  if (!fs.existsSync(UPLOADS_DIR)) {
    try {
      fs.mkdirSync(UPLOADS_DIR, { recursive: true });
      console.log('✅ Uploads directory created');
    } catch (err) {
      console.error('❌ Error creating uploads directory:', err);
      process.exit(1);
    }
  }
};

// Initialize server setup
const initializeServer = async () => {
  // Validate environment variables
  validateEnvVariables();
  
  // Connect to MongoDB
  await connectDB();
  
  // Ensure uploads directory exists
  ensureUploadsDir();
  
  // Start the server
  server.listen(PORT, () => {
    console.log(`🚀 Server running on http://192.168.29.168:${PORT}`);
  });
};

// 🔒 Security Middleware
app.use(helmet()); // Set security HTTP headers
app.use(morgan('dev')); // Logging

// Rate limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  standardHeaders: true,
  message: { message: 'Too many requests from this IP, please try again later.' }
});
app.use('/api/', apiLimiter);

// 🌍 Middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(mongoSanitize()); // Prevent NoSQL injection
app.use(xss()); // Prevent XSS attacks
app.use(hpp()); // Prevent HTTP parameter pollution

// CORS configuration
app.use(cors({
  origin: process.env.CLIENT_URL || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  credentials: true
}));

// Serve static files
app.use('/uploads', express.static(path.join(__dirname, 'public', 'uploads')));

// File upload configuration (Multer)
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOADS_DIR);
  },
  filename: (req, file, cb) => {
    // Generate a safe filename
    const fileExt = path.extname(file.originalname);
    const fileName = `${Date.now()}-${Math.round(Math.random() * 1E9)}${fileExt}`;
    cb(null, fileName);
  }
});

// File filter to only allow certain file types
const fileFilter = (req, file, cb) => {
  // Accept images only
  if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/)) {
    return cb(new Error('Only image files are allowed!'), false);
  }
  cb(null, true);
};

const upload = multer({ 
  storage,
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max file size
  }
});

// 🌍 Upload image endpoint with error handling
app.post('/api/upload', upload.single('image'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No file uploaded' });
    }
    
    // Return the file URL
    const fileUrl = `/uploads/${req.file.filename}`;
    res.status(200).json({ 
      success: true, 
      message: 'File uploaded successfully',
      imageUrl: fileUrl 
    });
  } catch (error) {
    console.error('❌ File upload error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Error uploading file',
      error: error.message 
    });
  }
});

// Handle multer errors
app.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        message: 'File too large. Maximum size is 5MB.'
      });
    }
    return res.status(400).json({
      success: false,
      message: `Upload error: ${err.message}`
    });
  }
  next(err);
});

// 📌 API Routes
app.use('/api/auth', authRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/vendors', vendorRoutes);
app.use('/api/bookings', bookingRoutes);
app.use("/api/notifications", notificationRoutes)
app.use('/api/chats', chatRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'ok',
    uptime: process.uptime(),
    timestamp: Date.now()
  });
});

// 🌍 Global Error Handling Middleware
app.use((err, req, res, next) => {
  console.error('❌ Server Error:', err.stack);
  
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';
  
  res.status(statusCode).json({
    success: false,
    message,
    error: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// 🌍 Handle undefined routes (404) - Must be after all other routes
app.use((req, res) => {
  res.status(404).json({ 
    success: false, 
    message: `Route not found: ${req.originalUrl}` 
  });
});

// 🔌 Socket.IO setup for real-time chat
io.on('connection', (socket) => {
  console.log(`🔌 Socket connected: ${socket.id}`);
  
  // Join a chat room
  socket.on('join_room', (roomId) => {
    socket.join(roomId);
    console.log(`User joined room: ${roomId}`);
  });
  
  // Handle new message
  socket.on('send_message', (data) => {
    // Broadcast to everyone in the room except sender
    socket.to(data.roomId).emit('receive_message', data);
  });
  
  // Handle typing indicator
  socket.on('typing', (data) => {
    socket.to(data.roomId).emit('user_typing', data);
  });
  
  // Handle user disconnection
  socket.on('disconnect', () => {
    console.log(`🔌 Socket disconnected: ${socket.id}`);
  });
});

// 🌍 Graceful Shutdown
const cleanup = () => {
  console.log('🛑 Shutting down server...');
  
  // Close the HTTP server
  if (server) {
    server.close((err) => {
      if (err) {
        console.error('❌ Error closing HTTP server:', err);
        process.exit(1);
      }
      console.log('✅ HTTP server closed.');
      
      // Close MongoDB connection
      if (mongoose.connection.readyState === 1) {
        mongoose.connection.close(false, () => {
          console.log('✅ MongoDB connection closed.');
          process.exit(0);
        });
      } else {
        console.log('⚠️ MongoDB connection already closed.');
        process.exit(0);
      }
    });
  } else {
    process.exit(0);
  }
  
  // Force exit after 10 seconds if graceful shutdown fails
  setTimeout(() => {
    console.error('⚠️ Could not close connections in time, forcefully shutting down');
    process.exit(1);
  }, 10000);
};

// Handle various termination signals
process.on('SIGTERM', cleanup);
process.on('SIGINT', cleanup);
process.on('unhandledRejection', (err) => {
  console.error('🚨 Unhandled Rejection:', err);
  cleanup();
});
process.on('uncaughtException', (err) => {
  console.error('🚨 Uncaught Exception:', err);
  cleanup();
});

// Initialize the server
initializeServer().catch(err => {
  console.error('❌ Server initialization failed:', err);
  process.exit(1);
});

module.exports = { app, server, io }; // Export for testing purposes