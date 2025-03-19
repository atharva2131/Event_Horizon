const Notification = require("../models/Notification")
const { validationResult } = require("express-validator")
const mongoose = require("mongoose")

/**
 * Get all notifications for the logged-in user
 * @route GET /api/notifications
 * @access Private
 */
exports.getUserNotifications = async (req, res) => {
  try {
    // Pagination
    const page = Number.parseInt(req.query.page) || 1
    const limit = Number.parseInt(req.query.limit) || 20
    const skip = (page - 1) * limit

    // Build filter object
    const filter = { recipient: req.user.id }

    // Filter by read status
    if (req.query.isRead !== undefined) {
      filter.isRead = req.query.isRead === "true"
    }

    // Filter by type
    if (req.query.type) {
      filter.type = req.query.type
    }

    // Build sort object
    const sort = {}
    if (req.query.sortBy) {
      const sortField = req.query.sortBy
      const sortOrder = req.query.sortOrder === "desc" ? -1 : 1
      sort[sortField] = sortOrder
    } else {
      // Default sort by createdAt descending (newest first)
      sort.createdAt = -1
    }

    // Execute query with pagination
    const notifications = await Notification.find(filter).sort(sort).skip(skip).limit(limit)

    // Get total count for pagination
    const total = await Notification.countDocuments(filter)

    // Get unread count
    const unreadCount = await Notification.countDocuments({
      recipient: req.user.id,
      isRead: false,
    })

    res.status(200).json({
      success: true,
      count: notifications.length,
      total,
      unreadCount,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      notifications,
    })
  } catch (error) {
    console.error("❌ Error fetching notifications:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching notifications",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Mark notification as read
 * @route PATCH /api/notifications/:id/read
 * @access Private
 */
exports.markAsRead = async (req, res) => {
  try {
    const { id } = req.params

    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid notification ID format",
      })
    }

    // Find notification
    const notification = await Notification.findById(id)

    if (!notification) {
      return res.status(404).json({
        success: false,
        msg: "Notification not found",
      })
    }

    // Check if user is the recipient
    if (notification.recipient.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        msg: "You don't have permission to update this notification",
      })
    }

    // Update notification
    notification.isRead = true
    notification.readAt = Date.now()

    await notification.save()

    res.status(200).json({
      success: true,
      msg: "Notification marked as read",
      notification,
    })
  } catch (error) {
    console.error("❌ Error marking notification as read:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while updating notification",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Mark all notifications as read
 * @route PATCH /api/notifications/read-all
 * @access Private
 */
exports.markAllAsRead = async (req, res) => {
  try {
    // Update all unread notifications for the user
    const result = await Notification.updateMany(
      { recipient: req.user.id, isRead: false },
      { isRead: true, readAt: Date.now() },
    )

    res.status(200).json({
      success: true,
      msg: "All notifications marked as read",
      count: result.modifiedCount,
    })
  } catch (error) {
    console.error("❌ Error marking all notifications as read:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while updating notifications",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Delete a notification
 * @route DELETE /api/notifications/:id
 * @access Private
 */
exports.deleteNotification = async (req, res) => {
  try {
    const { id } = req.params

    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid notification ID format",
      })
    }

    // Find notification
    const notification = await Notification.findById(id)

    if (!notification) {
      return res.status(404).json({
        success: false,
        msg: "Notification not found",
      })
    }

    // Check if user is the recipient
    if (notification.recipient.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        msg: "You don't have permission to delete this notification",
      })
    }

    // Delete notification
    await notification.remove()

    res.status(200).json({
      success: true,
      msg: "Notification deleted successfully",
    })
  } catch (error) {
    console.error("❌ Error deleting notification:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while deleting notification",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Create a notification (admin only)
 * @route POST /api/notifications
 * @access Private (admin only)
 */
exports.createNotification = async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Only admins can create notifications",
      })
    }

    // Validate request
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      })
    }

    const { recipient, type, title, message, relatedId, onModel, priority, actionLink } = req.body

    // Validate required fields
    if (!recipient || !type || !title || !message) {
      return res.status(400).json({
        success: false,
        msg: "Recipient, type, title, and message are required",
      })
    }

    // Validate recipient is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(recipient)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid recipient ID format",
      })
    }

    // Create new notification
    const newNotification = new Notification({
      recipient,
      type,
      title,
      message,
      relatedId,
      onModel,
      priority: priority || "medium",
      actionLink,
    })

    await newNotification.save()

    res.status(201).json({
      success: true,
      msg: "Notification created successfully",
      notification: newNotification,
    })
  } catch (error) {
    console.error("❌ Error creating notification:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while creating notification",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

module.exports = exports

