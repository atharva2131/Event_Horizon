const mongoose = require("mongoose")

const MessageSchema = new mongoose.Schema(
  {
    chat: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Chat",
      required: true,
    },
    sender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    content: {
      type: String,
      trim: true,
    },
    attachments: [
      {
        type: String, // URL to the attachment
        trim: true,
      },
    ],
    readBy: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],
  },
  {
    timestamps: true,
  },
)

// Create indexes for faster queries
MessageSchema.index({ chat: 1, createdAt: -1 })
MessageSchema.index({ sender: 1 })

module.exports = mongoose.model("Message", MessageSchema)

