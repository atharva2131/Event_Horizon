const express = require("express")
const router = express.Router()
const { check } = require("express-validator")
const notificationController = require("../controllers/notificationController")
const { protect, authorize } = require("../middleware/authMiddleware")

// Apply authentication middleware to all routes
router.use(protect)

// Validation middleware for creating notifications
const createNotificationValidation = [
  check("recipient", "Recipient ID is required").notEmpty().isMongoId(),
  check("type", "Type is required").notEmpty(),
  check("title", "Title is required").notEmpty(),
  check("message", "Message is required").notEmpty(),
  check("priority", "Priority must be low, medium, or high").optional().isIn(["low", "medium", "high"]),
]

// User notification routes
router.get("/", notificationController.getUserNotifications)
router.patch("/:id/read", notificationController.markAsRead)
router.patch("/read-all", notificationController.markAllAsRead)
router.delete("/:id", notificationController.deleteNotification)

// Admin routes
router.post("/", authorize("admin"), createNotificationValidation, notificationController.createNotification)

module.exports = router

