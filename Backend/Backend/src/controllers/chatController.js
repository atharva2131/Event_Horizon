const Chat = require('../models/Chat');
const Message = require('../models/Message');
const User = require('../models/User');

/**
 * Get all chats for a user
 * @route GET /api/chats
 */
exports.getUserChats = async (req, res) => {
  try {
    // Find all chats where the user is a participant
    const chats = await Chat.find({
      participants: req.user.id
    })
      .populate('participants', 'name email profileImage')
      .populate({
        path: 'lastMessage',
        select: 'content createdAt sender readBy'
      })
      .sort({ updatedAt: -1 });

    res.status(200).json({
      success: true,
      count: chats.length,
      chats
    });
  } catch (err) {
    console.error('❌ Error in getUserChats:', err);
    res.status(500).json({ success: false, msg: 'Server error' });
  }
};

/**
 * Get chat by ID
 * @route GET /api/chats/:chatId
 */
exports.getChatById = async (req, res) => {
  try {
    const { chatId } = req.params;

    // Find chat and check if user is a participant
    const chat = await Chat.findOne({
      _id: chatId,
      participants: req.user.id
    }).populate('participants', 'name email profileImage');

    if (!chat) {
      return res.status(404).json({
        success: false,
        msg: 'Chat not found or you are not a participant'
      });
    }

    res.status(200).json({
      success: true,
      chat
    });
  } catch (err) {
    console.error('❌ Error in getChatById:', err);
    res.status(500).json({ success: false, msg: 'Server error' });
  }
};

/**
 * Create a new chat
 * @route POST /api/chats
 */
exports.createChat = async (req, res) => {
  try {
    const { participantId, initialMessage } = req.body;

    if (!participantId) {
      return res.status(400).json({
        success: false,
        msg: 'Participant ID is required'
      });
    }

    // Check if participant exists
    const participant = await User.findById(participantId);
    if (!participant) {
      return res.status(404).json({
        success: false,
        msg: 'Participant not found'
      });
    }

    // Check if chat already exists between these users
    const existingChat = await Chat.findOne({
      participants: { $all: [req.user.id, participantId] }
    });

    if (existingChat) {
      return res.status(200).json({
        success: true,
        msg: 'Chat already exists',
        chat: existingChat
      });
    }

    // Create new chat
    const newChat = new Chat({
      participants: [req.user.id, participantId],
      createdBy: req.user.id
    });

    await newChat.save();

    // If initial message is provided, create it
    if (initialMessage) {
      const message = new Message({
        chat: newChat._id,
        sender: req.user.id,
        content: initialMessage,
        readBy: [req.user.id]
      });

      await message.save();

      // Update chat with last message
      newChat.lastMessage = message._id;
      await newChat.save();
    }

    // Populate participants
    await newChat.populate('participants', 'name email profileImage');

    res.status(201).json({
      success: true,
      msg: 'Chat created successfully',
      chat: newChat
    });
  } catch (err) {
    console.error('❌ Error in createChat:', err);
    res.status(500).json({ success: false, msg: 'Server error' });
  }
};

/**
 * Send a message in a chat
 * @route POST /api/chats/:chatId/messages
 */
exports.sendMessage = async (req, res) => {
  try {
    const { chatId } = req.params;
    const { content, attachments } = req.body;

    if (!content && (!attachments || attachments.length === 0)) {
      return res.status(400).json({
        success: false,
        msg: 'Message content or attachments are required'
      });
    }

    // Check if chat exists and user is a participant
    const chat = await Chat.findOne({
      _id: chatId,
      participants: req.user.id
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        msg: 'Chat not found or you are not a participant'
      });
    }

    // Create new message
    const newMessage = new Message({
      chat: chatId,
      sender: req.user.id,
      content: content || '',
      attachments: attachments || [],
      readBy: [req.user.id]
    });

    await newMessage.save();

    // Update chat's lastMessage and updatedAt
    chat.lastMessage = newMessage._id;
    chat.updatedAt = Date.now();
    await chat.save();

    // Populate sender info
    await newMessage.populate('sender', 'name email profileImage');

    res.status(201).json({
      success: true,
      msg: 'Message sent successfully',
      message: newMessage
    });
  } catch (err) {
    console.error('❌ Error in sendMessage:', err);
    res.status(500).json({ success: false, msg: 'Server error' });
  }
};

/**
 * Get messages for a chat
 * @route GET /api/chats/:chatId/messages
 */
exports.getChatMessages = async (req, res) => {
  try {
    const { chatId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    // Check if chat exists and user is a participant
    const chat = await Chat.findOne({
      _id: chatId,
      participants: req.user.id
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        msg: 'Chat not found or you are not a participant'
      });
    }

    // Get messages with pagination
    const messages = await Message.find({ chat: chatId })
      .populate('sender', 'name email profileImage')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    // Get total count for pagination
    const total = await Message.countDocuments({ chat: chatId });

    res.status(200).json({
      success: true,
      count: messages.length,
      total,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      messages: messages.reverse() // Return in chronological order
    });
  } catch (err) {
    console.error('❌ Error in getChatMessages:', err);
    res.status(500).json({ success: false, msg: 'Server error' });
  }
};

/**
 * Mark messages as read
 * @route PATCH /api/chats/:chatId/read
 */
exports.markMessagesAsRead = async (req, res) => {
  try {
    const { chatId } = req.params;

    // Check if chat exists and user is a participant
    const chat = await Chat.findOne({
      _id: chatId,
      participants: req.user.id
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        msg: 'Chat not found or you are not a participant'
      });
    }

    // Mark all unread messages as read
    const result = await Message.updateMany(
      {
        chat: chatId,
        sender: { $ne: req.user.id },
        readBy: { $ne: req.user.id }
      },
      {
        $addToSet: { readBy: req.user.id }
      }
    );

    res.status(200).json({
      success: true,
      msg: 'Messages marked as read',
      count: result.modifiedCount
    });
  } catch (err) {
    console.error('❌ Error in markMessagesAsRead:', err);
    res.status(500).json({ success: false, msg: 'Server error' });
  }
};

/**
 * Delete a chat
 * @route DELETE /api/chats/:chatId
 */
exports.deleteChat = async (req, res) => {
  try {
    const { chatId } = req.params;

    // Check if chat exists and user is a participant
    const chat = await Chat.findOne({
      _id: chatId,
      participants: req.user.id
    });

    if (!chat) {
      return res.status(404).json({
        success: false,
        msg: 'Chat not found or you are not a participant'
      });
    }

    // Delete all messages in the chat
    await Message.deleteMany({ chat: chatId });

    // Delete the chat
    await Chat.findByIdAndDelete(chatId);

    res.status(200).json({
      success: true,
      msg: 'Chat and all messages deleted successfully'
    });
  } catch (err) {
    console.error('❌ Error in deleteChat:', err);
    res.status(500).json({ success: false, msg: 'Server error' });
  }
};