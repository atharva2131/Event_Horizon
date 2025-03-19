const mongoose = require("mongoose")

// Booking Schema
const BookingSchema = new mongoose.Schema(
  {
    eventId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Event",
      required: [true, "Event ID is required"],
    },
    vendorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Vendor",
      required: [true, "Vendor ID is required"],
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "User ID is required"],
    },
    serviceId: {
      type: mongoose.Schema.Types.ObjectId,
      required: [true, "Service ID is required"],
    },
    bookingDate: {
      type: Date,
      required: [true, "Booking date is required"],
    },
    timeSlot: {
      startTime: {
        type: String,
        required: [true, "Start time is required"],
        match: [/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, "Time must be in HH:MM format"],
      },
      endTime: {
        type: String,
        required: [true, "End time is required"],
        match: [/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, "Time must be in HH:MM format"],
      },
    },
    status: {
      type: String,
      enum: ["pending", "confirmed", "rejected", "cancelled", "completed"],
      default: "pending",
    },
    requirements: {
      type: String,
      trim: true,
      maxlength: [1000, "Requirements cannot be more than 1000 characters"],
    },
    price: {
      type: Number,
      required: [true, "Price is required"],
      min: [0, "Price cannot be negative"],
    },
    paymentStatus: {
      type: String,
      enum: ["pending", "partial", "paid", "refunded"],
      default: "pending",
    },
    paymentDetails: {
      method: {
        type: String,
        enum: ["cash", "card", "online", "bank_transfer", "none"],
        default: "none",
      },
      transactionId: {
        type: String,
        trim: true,
      },
      paidAmount: {
        type: Number,
        default: 0,
      },
      paidAt: {
        type: Date,
      },
    },
    notes: {
      type: String,
      trim: true,
    },
    cancellationReason: {
      type: String,
      trim: true,
    },
    cancelledBy: {
      type: String,
      enum: ["user", "vendor", "admin", "none"],
      default: "none",
    },
    cancelledAt: {
      type: Date,
    },
    isReviewed: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  },
)

// Indexes for faster queries
BookingSchema.index({ userId: 1 })
BookingSchema.index({ vendorId: 1 })
BookingSchema.index({ eventId: 1 })
BookingSchema.index({ status: 1 })
BookingSchema.index({ bookingDate: 1 })
BookingSchema.index({ createdAt: -1 })

// Virtual for time until booking
BookingSchema.virtual("timeUntilBooking").get(function () {
  const now = new Date()
  const bookingDate = new Date(this.bookingDate)
  const diffTime = Math.abs(bookingDate - now)
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  return bookingDate > now ? diffDays : 0
})

module.exports = mongoose.model("Booking", BookingSchema)

