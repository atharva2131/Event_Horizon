const mongoose = require("mongoose")

// Guest Schema (sub-document)
const GuestSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
      match: [/^[^\s@]+@[^\s@]+\.[^\s@]+$/, "Invalid email format"],
    },
    phone: {
      type: String,
      trim: true,
    },
    rsvpStatus: {
      type: String,
      enum: ["pending", "confirmed", "declined", "maybe"],
      default: "pending",
    },
    inviteSent: {
      type: Boolean,
      default: false,
    },
    source: {
      type: String,
      enum: ["manual", "email", "contacts"],
      default: "manual",
    },
    notes: {
      type: String,
      trim: true,
    },
  },
  { _id: false },
)

// Reminder Settings Schema (sub-document)
const ReminderSettingsSchema = new mongoose.Schema(
  {
    reminderEnabled: {
      type: Boolean,
      default: true,
    },
    reminderTime: {
      type: Number, // Hours before event
      default: 24,
    },
    reminderSent: {
      type: Boolean,
      default: false,
    },
  },
  { _id: false },
)

// Event Schema
const EventSchema = new mongoose.Schema(
  {
    eventName: {
      type: String,
      required: [true, "Event name is required"],
      trim: true,
      maxlength: [100, "Event name cannot be more than 100 characters"],
    },
    description: {
      type: String,
      trim: true,
      maxlength: [2000, "Description cannot be more than 2000 characters"],
    },
    eventDate: {
      type: Date,
      required: [true, "Event date is required"],
    },
    eventTime: {
      type: String,
      required: [true, "Event time is required"],
      trim: true,
    },
    location: {
      type: String,
      required: [true, "Event location is required"],
      trim: true,
    },
    budget: {
      type: Number,
      default: 0,
      min: [0, "Budget cannot be negative"],
    },
    category: {
      type: String,
      enum: [
        "Wedding",
        "Birthday",
        "Corporate",
        "Holiday",
        "Anniversary",
        "Graduation",
        "Baby Shower",
        "Retirement",
        "Other",
      ],
      default: "Other",
    },
    eventImage: {
      type: String,
      default: "/uploads/events/default-event.png",
    },
    collaborators: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],
    guests: [GuestSchema],
    isPublic: {
      type: Boolean,
      default: false,
    },
    reminderSettings: {
      type: ReminderSettingsSchema,
      default: () => ({}),
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    updatedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
    status: {
      type: String,
      enum: ["planning", "confirmed", "completed", "cancelled"],
      default: "planning",
    },
    attachments: [
      {
        name: String,
        url: String,
        type: String,
        size: Number,
        uploadedAt: {
          type: Date,
          default: Date.now,
        },
      },
    ],
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  },
)

// Indexes for faster queries
EventSchema.index({ eventName: "text", description: "text", location: "text" })
EventSchema.index({ eventDate: 1 })
EventSchema.index({ createdBy: 1 })
EventSchema.index({ collaborators: 1 })
EventSchema.index({ category: 1 })
EventSchema.index({ "guests.email": 1 })

// Virtual for event status based on date
EventSchema.virtual("eventStatus").get(function () {
  const now = new Date()
  if (this.status === "cancelled") return "Cancelled"
  if (this.eventDate < now) return "Past"
  return "Upcoming"
})

// Virtual for confirmed guest count
EventSchema.virtual("confirmedGuestCount").get(function () {
  return this.guests.filter((guest) => guest.rsvpStatus === "confirmed").length
})

// Virtual for total guest count
EventSchema.virtual("totalGuestCount").get(function () {
  return this.guests.length
})

// Virtual for days until event
EventSchema.virtual("daysUntilEvent").get(function () {
  const now = new Date()
  const eventDate = new Date(this.eventDate)
  const diffTime = Math.abs(eventDate - now)
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  return eventDate > now ? diffDays : 0
})

// Pre-save hook to ensure updatedBy is set
EventSchema.pre("save", function (next) {
  if (this.isNew && !this.updatedBy) {
    this.updatedBy = this.createdBy
  }
  next()
})

module.exports = mongoose.model("Event", EventSchema)

