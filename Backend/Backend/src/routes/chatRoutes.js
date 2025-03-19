const express = require("express")
const router = express.Router()
const { protect } = require("../middleware/authMiddleware")
const chatController = require("../controllers/chatController")

// All chat routes require authentication
router.use(protect)

// Get all chats for a user
router.get("/", chatController.getUserChats)

// Get chat by ID
router.get("/:chatId", chatController.getChatById)

// Create a new chat
router.post("/", chatController.createChat)

// Send a message in a chat
router.post("/:chatId/messages", chatController.sendMessage)

// Get messages for a chat
router.get("/:chatId/messages", chatController.getChatMessages)

// Mark messages as read
router.patch("/:chatId/read", chatController.markMessagesAsRead)

// Delete a chat
router.delete("/:chatId", chatController.deleteChat)

module.exports = router

