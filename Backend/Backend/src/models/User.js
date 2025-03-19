const mongoose = require("mongoose")
const bcrypt = require("bcryptjs")
const crypto = require("crypto")

// User Schema
const UserSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Name is required"],
      trim: true,
      maxlength: [50, "Name cannot be more than 50 characters"],
    },
    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,
      trim: true,
      lowercase: true,
      match: [/^[^\s@]+@[^\s@]+\.[^\s@]+$/, "Invalid email format"],
    },
    password: {
      type: String,
      required: [true, "Password is required"],
      minlength: [8, "Password must be at least 8 characters long"],
      select: false, // Don't return password by default
    },
    phone: {
      type: String,
      required: [true, "Phone number is required"],
      unique: true,
      match: [/^\d{10}$/, "Phone number must be 10 digits"],
    },
    role: {
      type: String,
      required: [true, "Role is required"],
      enum: ["vendor", "user", "admin"],
      default: "user",
    },
    resetPasswordToken: String,
    resetPasswordExpires: Date,
    passwordChangedAt: Date,
    failedLoginAttempts: {
      type: Number,
      default: 0,
    },
    accountLocked: {
      type: Boolean,
      default: false,
    },
    lockUntil: Date,
    lastLogin: Date,
    active: {
      type: Boolean,
      default: true,
    },
    profileImage: {
      type: String,
      default: "/uploads/default-profile.png",
    },
    bio: {
      type: String,
      trim: true,
      maxlength: [500, "Bio cannot be more than 500 characters"],
    },
    address: {
      type: String,
      trim: true,
      maxlength: [200, "Address cannot be more than 200 characters"],
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  },
)

// Virtual for user's full profile URL
UserSchema.virtual("profileUrl").get(function () {
  return `/api/users/${this._id}`
})

// Index for faster queries
UserSchema.index({ email: 1 })
UserSchema.index({ phone: 1 })
UserSchema.index({ role: 1 })

// Hash password before saving
UserSchema.pre("save", async function (next) {
  // Only hash the password if it's modified (or new)
  if (!this.isModified("password")) return next()

  try {
    // Ensure password is a valid string before hashing
    if (typeof this.password !== "string") {
      throw new Error("Password must be a string")
    }

    // Generate salt and hash password
    const salt = await bcrypt.genSalt(12)
    this.password = await bcrypt.hash(this.password, salt)

    next()
  } catch (error) {
    next(error)
  }
})

// Update passwordChangedAt when password is changed
UserSchema.pre("save", function (next) {
  if (!this.isModified("password") || this.isNew) return next()

  // Set passwordChangedAt to current time minus 1 second
  // This ensures the token is created after the password has been changed
  this.passwordChangedAt = Date.now() - 1000
  next()
})

// Only return active users
UserSchema.pre(/^find/, function (next) {
  // 'this' refers to the current query
  this.find({ active: { $ne: false } })
  next()
})

// Compare entered password with stored hash
UserSchema.methods.comparePassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password)
}

// Check if password was changed after token was issued
UserSchema.methods.changedPasswordAfter = function (JWTTimestamp) {
  if (this.passwordChangedAt) {
    const changedTimestamp = Number.parseInt(this.passwordChangedAt.getTime() / 1000, 10)
    return JWTTimestamp < changedTimestamp
  }

  // False means NOT changed
  return false
}

// Generate password reset token
UserSchema.methods.createPasswordResetToken = function () {
  const resetToken = crypto.randomBytes(32).toString("hex")

  this.resetPasswordToken = crypto.createHash("sha256").update(resetToken).digest("hex")

  // Token expires in 1 hour
  this.resetPasswordExpires = Date.now() + 3600000

  return resetToken
}

module.exports = mongoose.model("User", UserSchema)

