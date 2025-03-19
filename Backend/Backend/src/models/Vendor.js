const mongoose = require("mongoose")

// Service Schema (sub-document)
const ServiceSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Service name is required"],
      trim: true,
      maxlength: [100, "Service name cannot be more than 100 characters"],
    },
    description: {
      type: String,
      required: [true, "Service description is required"],
      trim: true,
      maxlength: [2000, "Description cannot be more than 2000 characters"],
    },
    category: {
      type: String,
      required: [true, "Category is required"],
      enum: [
        "Photography",
        "Videography",
        "Catering",
        "Venue",
        "Music",
        "Decoration",
        "Transportation",
        "Accommodation",
        "Beauty",
        "Invitation",
        "Cake",
        "Flowers",
        "Lighting",
        "Entertainment",
        "Other"
      ],
    },
    pricing: {
      type: [{
        name: {
          type: String,
          required: [true, "Package name is required"],
          trim: true,
        },
        price: {
          type: Number,
          required: [true, "Price is required"],
          min: [0, "Price cannot be negative"],
        },
        description: {
          type: String,
          required: [true, "Package description is required"],
          trim: true,
        },
        features: [String],
        isPopular: {
          type: Boolean,
          default: false,
        }
      }],
      validate: [
        {
          validator: function(pricing) {
            return pricing.length > 0;
          },
          message: "At least one pricing package is required"
        }
      ]
    },
    tags: [String],
    isActive: {
      type: Boolean,
      default: true,
    },
    averageRating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    totalReviews: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true }
)

// Portfolio Item Schema (sub-document)
const PortfolioItemSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, "Title is required"],
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    mediaType: {
      type: String,
      enum: ["image", "video"],
      default: "image",
    },
    mediaUrl: {
      type: String,
      required: [true, "Media URL is required"],
    },
    serviceId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Service",
    },
    featured: {
      type: Boolean,
      default: false,
    },
    tags: [String],
  },
  { timestamps: true }
)

// Availability Schema (sub-document)
const AvailabilitySchema = new mongoose.Schema(
  {
    date: {
      type: Date,
      required: [true, "Date is required"],
    },
    slots: [
      {
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
        isBooked: {
          type: Boolean,
          default: false,
        },
        bookingId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Booking",
        },
      },
    ],
    isFullyBooked: {
      type: Boolean,
      default: false,
    },
    isUnavailable: {
      type: Boolean,
      default: false,
    },
  },
  { _id: true }
)

// Vendor Schema
const VendorSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "User ID is required"],
      unique: true,
    },
    businessName: {
      type: String,
      required: [true, "Business name is required"],
      trim: true,
      maxlength: [100, "Business name cannot be more than 100 characters"],
    },
    businessDescription: {
      type: String,
      required: [true, "Business description is required"],
      trim: true,
      maxlength: [2000, "Business description cannot be more than 2000 characters"],
    },
    contactEmail: {
      type: String,
      required: [true, "Contact email is required"],
      trim: true,
      lowercase: true,
      match: [/^[^\s@]+@[^\s@]+\.[^\s@]+$/, "Invalid email format"],
    },
    contactPhone: {
      type: String,
      required: [true, "Contact phone is required"],
      trim: true,
    },
    businessAddress: {
      street: {
        type: String,
        required: [true, "Street address is required"],
        trim: true,
      },
      city: {
        type: String,
        required: [true, "City is required"],
        trim: true,
      },
      state: {
        type: String,
        required: [true, "State is required"],
        trim: true,
      },
      zipCode: {
        type: String,
        required: [true, "Zip code is required"],
        trim: true,
      },
      country: {
        type: String,
        required: [true, "Country is required"],
        trim: true,
      },
    },
    businessLogo: {
      type: String,
      default: "/uploads/vendors/default-logo.png",
    },
    businessCoverImage: {
      type: String,
      default: "/uploads/vendors/default-cover.png",
    },
    services: [ServiceSchema],
    portfolio: [PortfolioItemSchema],
    availability: [AvailabilitySchema],
    socialMedia: {
      website: {
        type: String,
        trim: true,
      },
      facebook: {
        type: String,
        trim: true,
      },
      instagram: {
        type: String,
        trim: true,
      },
      twitter: {
        type: String,
        trim: true,
      },
      linkedin: {
        type: String,
        trim: true,
      },
      youtube: {
        type: String,
        trim: true,
      },
    },
    businessHours: {
      monday: {
        isOpen: { type: Boolean, default: true },
        openTime: { type: String, default: "09:00" },
        closeTime: { type: String, default: "17:00" },
      },
      tuesday: {
        isOpen: { type: Boolean, default: true },
        openTime: { type: String, default: "09:00" },
        closeTime: { type: String, default: "17:00" },
      },
      wednesday: {
        isOpen: { type: Boolean, default: true },
        openTime: { type: String, default: "09:00" },
        closeTime: { type: String, default: "17:00" },
      },
      thursday: {
        isOpen: { type: Boolean, default: true },
        openTime: { type: String, default: "09:00" },
        closeTime: { type: String, default: "17:00" },
      },
      friday: {
        isOpen: { type: Boolean, default: true },
        openTime: { type: String, default: "09:00" },
        closeTime: { type: String, default: "17:00" },
      },
      saturday: {
        isOpen: { type: Boolean, default: true },
        openTime: { type: String, default: "10:00" },
        closeTime: { type: String, default: "15:00" },
      },
      sunday: {
        isOpen: { type: Boolean, default: false },
        openTime: { type: String, default: "00:00" },
        closeTime: { type: String, default: "00:00" },
      },
    },
    paymentMethods: {
      acceptsCash: {
        type: Boolean,
        default: true,
      },
      acceptsCard: {
        type: Boolean,
        default: true,
      },
      acceptsOnlinePayment: {
        type: Boolean,
        default: true,
      },
      bankDetails: {
        accountName: {
          type: String,
          trim: true,
        },
        accountNumber: {
          type: String,
          trim: true,
        },
        bankName: {
          type: String,
          trim: true,
        },
        ifscCode: {
          type: String,
          trim: true,
        },
      },
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
    verificationDocuments: [
      {
        name: {
          type: String,
          trim: true,
        },
        documentType: {
          type: String,
          enum: ["ID", "Business License", "Tax Certificate", "Other"],
        },
        documentUrl: {
          type: String,
        },
        uploadedAt: {
          type: Date,
          default: Date.now,
        },
        status: {
          type: String,
          enum: ["pending", "approved", "rejected"],
          default: "pending",
        },
        notes: {
          type: String,
          trim: true,
        },
      },
    ],
    isActive: {
      type: Boolean,
      default: true,
    },
    featuredUntil: {
      type: Date,
    },
    isFeatured: {
      type: Boolean,
      default: false,
    },
    averageRating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    totalReviews: {
      type: Number,
      default: 0,
    },
    cancellationPolicy: {
      type: String,
      enum: ["Flexible", "Moderate", "Strict"],
      default: "Moderate",
    },
    cancellationPolicyDescription: {
      type: String,
      trim: true,
    },
    tags: [String],
    serviceAreas: [String],
    profileCompleted: {
      type: Boolean,
      default: false,
    }
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
)

// Indexes for faster queries
VendorSchema.index({ userId: 1 }, { unique: true })
VendorSchema.index({ businessName: "text", businessDescription: "text" })
VendorSchema.index({ "services.name": "text", "services.description": "text" })
VendorSchema.index({ "services.category": 1 })
VendorSchema.index({ isVerified: 1, isActive: 1 })
VendorSchema.index({ isFeatured: 1 })
VendorSchema.index({ averageRating: -1 })
VendorSchema.index({ "serviceAreas": 1 })

// Virtual for total services count
VendorSchema.virtual("totalServices").get(function () {
  return this.services.length
})

// Virtual for total portfolio items count
VendorSchema.virtual("totalPortfolioItems").get(function () {
  return this.portfolio.length
})

// Virtual for featured portfolio items
VendorSchema.virtual("featuredPortfolio").get(function () {
  return this.portfolio.filter(item => item.featured)
})

// Pre-save hook to check if vendor is featured
VendorSchema.pre("save", function (next) {
  if (this.featuredUntil && this.featuredUntil > new Date()) {
    this.isFeatured = true
  } else {
    this.isFeatured = false
    this.featuredUntil = undefined
  }
  next()
})

// Method to check if a date is available
VendorSchema.methods.isDateAvailable = function (date) {
  const targetDate = new Date(date)
  targetDate.setHours(0, 0, 0, 0)
  
  const availabilityEntry = this.availability.find(a => {
    const availDate = new Date(a.date)
    availDate.setHours(0, 0, 0, 0)
    return availDate.getTime() === targetDate.getTime()
  })
  
  if (!availabilityEntry) return false
  if (availabilityEntry.isUnavailable) return false
  if (availabilityEntry.isFullyBooked) return false
  
  return availabilityEntry.slots.some(slot => !slot.isBooked)
}

// Method to get available slots for a date
VendorSchema.methods.getAvailableSlotsForDate = function (date) {
  const targetDate = new Date(date)
  targetDate.setHours(0, 0, 0, 0)
  
  const availabilityEntry = this.availability.find(a => {
    const availDate = new Date(a.date)
    availDate.setHours(0, 0, 0, 0)
    return availDate.getTime() === targetDate.getTime()
  })
  
  if (!availabilityEntry) return []
  if (availabilityEntry.isUnavailable) return []
  
  return availabilityEntry.slots.filter(slot => !slot.isBooked)
}

module.exports = mongoose.model("Vendor", VendorSchema)