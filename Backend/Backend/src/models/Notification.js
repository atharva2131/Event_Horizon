const mongoose = require("mongoose")

// Notification Schema
const NotificationSchema = new mongoose.Schema(
  {
    recipient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "Recipient is required"],
    },
    type: {
      type: String,
      enum: [
        "booking_request",
        "booking_confirmed",
        "booking_rejected",
        "booking_cancelled",
        "booking_reminder",
        "payment_received",
        "message_received",
        "system",
      ],
      required: [true, "Notification type is required"],
    },
    title: {
      type: String,
      required: [true, "Title is required"],
      trim: true,
    },
    message: {
      type: String,
      required: [true, "Message is required"],
      trim: true,
    },
    relatedId: {
      type: mongoose.Schema.Types.ObjectId,
      refPath: "onModel",
    },
    onModel: {
      type: String,
      enum: ["Booking", "Event", "User", "Message"],
    },
    isRead: {
      type: Boolean,
      default: false,
    },
    readAt: {
      type: Date,
    },
    priority: {
      type: String,
      enum: ["low", "medium", "high"],
      default: "medium",
    },
    actionLink: {
      type: String,
      trim: true,
    },
  },
  {
    timestamps: true,
  },
)

// Indexes for faster queries
NotificationSchema.index({ recipient: 1 })
NotificationSchema.index({ isRead: 1 })
NotificationSchema.index({ createdAt: -1 })
NotificationSchema.index({ type: 1 })

module.exports = mongoose.model("Notification", NotificationSchema)

