const bcrypt = require("bcryptjs")
const jwt = require("jsonwebtoken")
const crypto = require("crypto")
const User = require("../models/User")
const { validationResult } = require("express-validator")
const rateLimit = require("express-rate-limit")
const fs = require("fs")
const path = require("path")
const mongoose = require("mongoose")

// Security constants
const BCRYPT_SALT_ROUNDS = 12
const JWT_EXPIRES_IN = "7d"
const REFRESH_TOKEN_EXPIRES_IN = "30d"
const PASSWORD_RESET_EXPIRES = 3600000 // 1 hour in milliseconds

// Password Strength Regex - Improved version
const PASSWORD_REGEX = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])(?!.*\s).{10,}$/

// Create rate limiters for sensitive operations
exports.loginRateLimiter = rateLimit({
  windowMs: 10 * 1000, // 10 seconds (changed from 15 minutes)
  max: 5, // 5 requests per windowMs per IP
  message: { success: false, msg: "Too many login attempts, please try again later." },
  standardHeaders: true,
  legacyHeaders: false,
})

/**
 * Register a new user
 * @route POST /api/auth/register
 */
exports.registerUser = async (req, res) => {
  try {
    // Validate request using express-validator
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() })
    }

    const { name, email, password, phone, role } = req.body
    console.log("📩 Incoming Registration Request:", { name, email, phone, role })

    // Validate required fields
    if (!name || !email || !password || !phone) {
      return res.status(400).json({ success: false, msg: "All fields are required." })
    }

    // Validate role
    const validRoles = ["user", "vendor", "admin"]
    const userRole = role || "user" // Default to "user" if not provided

    if (!validRoles.includes(userRole)) {
      return res.status(400).json({
        success: false,
        msg: `Invalid role. Role must be one of: ${validRoles.join(", ")}.`,
      })
    }

    // Check if user already exists
    const existingUser = await User.findOne({
      $or: [{ email }, { phone }],
    })

    if (existingUser) {
      // Don't reveal which field matched for security
      return res.status(400).json({
        success: false,
        msg: "An account with this email or phone already exists.",
      })
    }

    // Validate password strength
    if (!PASSWORD_REGEX.test(password)) {
      return res.status(400).json({
        success: false,
        msg: "Password must be at least 10 characters long and contain one lowercase letter, one uppercase letter, one number, and one special character with no spaces.",
      })
    }

    // Create new user (password will be hashed by the pre-save hook)
    const newUser = new User({
      name,
      email,
      password, // Will be hashed in the model's pre-save hook
      phone,
      role: userRole,
      active: true,
    })

    await newUser.save()

    // Generate JWT token
    const token = generateToken(newUser)

    // Return success without exposing sensitive data
    res.status(201).json({
      success: true,
      msg: "User registered successfully.",
      user: {
        id: newUser._id,
        name: newUser.name,
        email: newUser.email,
        phone: newUser.phone,
        role: newUser.role,
      },
      token,
    })
  } catch (err) {
    console.error("❌ Error in registerUser:", err)
    res.status(500).json({
      success: false,
      msg: "Server error occurred during registration",
      error: process.env.NODE_ENV === "development" ? err.message : undefined,
    })
  }
}

/**
 * User login
 * @route POST /api/auth/login
 */
exports.loginUser = async (req, res) => {
  try {
    const { email, password, role } = req.body

    // Validate request
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() })
    }

    console.log("📩 Incoming Login Request:", { email, role })

    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        msg: "Email and password are required.",
      })
    }

    // Find user by email and include password field
    const user = await User.findOne({ email }).select("+password")

    // Check if user exists
    if (!user) {
      // Use generic message for security
      return res.status(401).json({
        success: false,
        msg: "Invalid credentials.",
      })
    }

    // Special handling for admin users - allow them to log in through any form
    if (user.role === "admin") {
      console.log("🔑 Admin user detected, bypassing role check")
      // Continue with authentication for admin users
    }
    // For non-admin users, check if role matches
    else if (role && user.role !== role) {
      console.log("🚫 Role Mismatch! Expected:", role, "Found:", user.role)
      // Use generic message for security
      return res.status(401).json({
        success: false,
        msg: "Invalid credentials.",
      })
    }

    // Check password
    const isMatch = await user.comparePassword(password)

    if (!isMatch) {
      console.log("🚫 Password mismatch!")

      // Increment failed login attempts
      user.failedLoginAttempts = (user.failedLoginAttempts || 0) + 1

      // Lock account after 5 failed attempts
      if (user.failedLoginAttempts >= 5) {
        user.accountLocked = true
        user.lockUntil = Date.now() + 30 * 60 * 1000 // Lock for 30 minutes
      }

      await user.save()

      return res.status(401).json({
        success: false,
        msg: "Invalid credentials.",
      })
    }

    // Check if account is locked
    if (user.accountLocked && user.lockUntil > Date.now()) {
      const minutesLeft = Math.ceil((user.lockUntil - Date.now()) / 60000)
      return res.status(403).json({
        success: false,
        msg: `Account is temporarily locked. Please try again in ${minutesLeft} minutes.`,
      })
    }

    // Reset failed login attempts and unlock account if needed
    user.failedLoginAttempts = 0
    user.accountLocked = false
    user.lockUntil = undefined
    user.lastLogin = Date.now()
    await user.save()

    // Generate tokens
    const token = generateToken(user)
    const refreshToken = generateRefreshToken(user)

    // Set refresh token as HTTP-only cookie
    res.cookie("refreshToken", refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      maxAge: 30 * 24 * 60 * 60 * 1000, // 30 days
    })

    // Also set the regular token as a cookie for easier access in the frontend
    res.cookie("token", token, {
      httpOnly: false, // Allow JavaScript access
      secure: process.env.NODE_ENV === "production",
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days (matching JWT_EXPIRES_IN)
    })

    // Log login activity
    await logUserActivity(user._id, "login", req.ip, req.headers["user-agent"])

    res.status(200).json({
      success: true,
      msg: "Login successful.",
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profileImage: user.profileImage,
      },
    })
  } catch (err) {
    console.error("❌ Error in loginUser:", err)
    res.status(500).json({
      success: false,
      msg: "Server error occurred during login",
      error: process.env.NODE_ENV === "development" ? err.message : undefined,
    })
  }
}

/**
 * Refresh access token
 * @route POST /api/auth/refresh-token
 */
exports.refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.cookies

    if (!refreshToken) {
      return res.status(401).json({
        success: false,
        msg: "Refresh token not found.",
      })
    }

    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET)

    // Find user
    const user = await User.findById(decoded.userId)

    if (!user) {
      return res.status(401).json({
        success: false,
        msg: "User not found.",
      })
    }

    // Generate new access token
    const token = generateToken(user)

    // Set the new token as a cookie
    res.cookie("token", token, {
      httpOnly: false, // Allow JavaScript access
      secure: process.env.NODE_ENV === "production",
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days (matching JWT_EXPIRES_IN)
    })

    res.status(200).json({
      success: true,
      token,
    })
  } catch (err) {
    console.error("❌ Error in refreshToken:", err)
    res.status(401).json({
      success: false,
      msg: "Invalid or expired refresh token.",
    })
  }
}

/**
 * Logout user
 * @route POST /api/auth/logout
 */
exports.logoutUser = async (req, res) => {
  try {
    // Clear refresh token cookie
    res.clearCookie("refreshToken")
    // Clear token cookie
    res.clearCookie("token")

    // Log user activity if user is authenticated
    if (req.user) {
      await logUserActivity(req.user.id, "logout", req.ip, req.headers["user-agent"])
    }

    res.status(200).json({
      success: true,
      msg: "Logged out successfully.",
    })
  } catch (err) {
    console.error("❌ Error in logoutUser:", err)
    res.status(500).json({ success: false, msg: "Server error" })
  }
}

/**
 * Request password reset
 * @route POST /api/auth/forgot-password
 */
exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body

    if (!email) {
      return res.status(400).json({
        success: false,
        msg: "Email is required.",
      })
    }

    const user = await User.findOne({ email })

    // Don't reveal if user exists for security
    if (!user) {
      return res.status(200).json({
        success: true,
        msg: "If your email is registered, you will receive a password reset link.",
      })
    }

    // Generate reset token
    const resetToken = crypto.randomBytes(32).toString("hex")

    // Hash token before saving to database
    const hashedToken = crypto.createHash("sha256").update(resetToken).digest("hex")

    // Save to user document
    user.resetPasswordToken = hashedToken
    user.resetPasswordExpires = Date.now() + PASSWORD_RESET_EXPIRES
    await user.save()

    // Create reset URL (in a real app, you would send this via email)
    const resetUrl = `${req.protocol}://${req.get("host")}/api/auth/reset-password/${resetToken}`

    // For demonstration purposes, return the reset URL
    // In a production app, you would send this via email and not return it
    res.status(200).json({
      success: true,
      msg: "Password reset token generated successfully.",
      resetUrl: process.env.NODE_ENV === "development" ? resetUrl : undefined,
    })
  } catch (err) {
    console.error("❌ Error in forgotPassword:", err)
    res.status(500).json({ success: false, msg: "Server error" })
  }
}

/**
 * Reset password
 * @route POST /api/auth/reset-password/:token
 */
exports.resetPassword = async (req, res) => {
  try {
    const { token } = req.params
    const { password } = req.body

    if (!password) {
      return res.status(400).json({
        success: false,
        msg: "New password is required.",
      })
    }

    // Validate password strength
    if (!PASSWORD_REGEX.test(password)) {
      return res.status(400).json({
        success: false,
        msg: "Password must be at least 10 characters long and contain one lowercase letter, one uppercase letter, one number, and one special character with no spaces.",
      })
    }

    // Hash the token from params
    const hashedToken = crypto.createHash("sha256").update(token).digest("hex")

    // Find user with valid token
    const user = await User.findOne({
      resetPasswordToken: hashedToken,
      resetPasswordExpires: { $gt: Date.now() },
    })

    if (!user) {
      return res.status(400).json({
        success: false,
        msg: "Invalid or expired reset token.",
      })
    }

    // Update password
    user.password = password
    user.resetPasswordToken = undefined
    user.resetPasswordExpires = undefined

    // Force logout from all devices by changing passwordChangedAt
    user.passwordChangedAt = Date.now()

    await user.save()

    // Log password reset activity
    await logUserActivity(user._id, "password-reset", req.ip, req.headers["user-agent"])

    res.status(200).json({
      success: true,
      msg: "Password has been reset successfully. You can now log in with your new password.",
    })
  } catch (err) {
    console.error("❌ Error in resetPassword:", err)
    res.status(500).json({ success: false, msg: "Server error" })
  }
}

/**
 * Get all users (admin only)
 * @route GET /api/auth/users
 */
exports.getAllUsers = async (req, res) => {
  try {
    // Check if user is admin (middleware should handle this)
    if (req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Unauthorized. Admin access required.",
      })
    }

    // Pagination
    const page = Number.parseInt(req.query.page) || 1
    const limit = Number.parseInt(req.query.limit) || 10
    const skip = (page - 1) * limit

    // Filtering
    const filter = {}
    if (req.query.role) filter.role = req.query.role
    if (req.query.active) filter.active = req.query.active === "true"

    // Count total documents for pagination
    const total = await User.countDocuments(filter)

    // Get users with pagination and filtering
    const users = await User.find(filter)
      .select("-password -resetPasswordToken -resetPasswordExpires")
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 })

    if (!users.length) {
      return res.status(404).json({
        success: false,
        msg: "No users found.",
      })
    }

    res.status(200).json({
      success: true,
      count: users.length,
      total,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      users,
    })
  } catch (err) {
    console.error("❌ Error in getAllUsers:", err)
    res.status(500).json({ success: false, msg: "Server error" })
  }
}

/**
 * Get user by ID
 * @route GET /api/auth/users/:userId
 */
exports.getUserById = async (req, res) => {
  try {
    const { userId } = req.params

    // Check if user is admin or requesting their own data
    if (req.user.role !== "admin" && req.user.id !== userId) {
      return res.status(403).json({
        success: false,
        msg: "Unauthorized. You can only access your own data.",
      })
    }

    const user = await User.findById(userId).select("-password -resetPasswordToken -resetPasswordExpires")

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found.",
      })
    }

    res.status(200).json({
      success: true,
      user,
    })
  } catch (err) {
    console.error("❌ Error in getUserById:", err)
    res.status(500).json({ success: false, msg: "Server error" })
  }
}

/**
 * Get user by email
 * @route GET /api/auth/users/email/:email
 */
exports.getUserByEmail = async (req, res) => {
  try {
    const { email } = req.params

    // Check if user is admin or requesting their own data
    if (req.user.role !== "admin" && req.user.email !== email) {
      return res.status(403).json({
        success: false,
        msg: "Unauthorized. You can only access your own data.",
      })
    }

    const user = await User.findOne({ email }).select("-password -resetPasswordToken -resetPasswordExpires")

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found.",
      })
    }

    res.status(200).json({
      success: true,
      user,
    })
  } catch (err) {
    console.error("❌ Error in getUserByEmail:", err)
    res.status(500).json({ success: false, msg: "Server error" })
  }
}

/**
 * Update user
 * @route PUT /api/auth/users/:userId
 */
exports.updateUser = async (req, res) => {
  try {
    const { userId } = req.params
    const { name, phone, role, currentPassword, newPassword } = req.body

    // Check if user is admin or updating their own data
    if (req.user.role !== "admin" && req.user.id !== userId) {
      return res.status(403).json({
        success: false,
        msg: "Unauthorized. You can only update your own data.",
      })
    }

    // Find user
    const user = await User.findById(userId).select("+password")

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found.",
      })
    }

    // Update basic fields
    if (name) user.name = name
    if (phone) user.phone = phone

    // Only admin can update role
    if (role && req.user.role === "admin") {
      const validRoles = ["user", "vendor", "admin"]
      if (!validRoles.includes(role)) {
        return res.status(400).json({
          success: false,
          msg: `Invalid role. Role must be one of: ${validRoles.join(", ")}.`,
        })
      }
      user.role = role
    }

    // Handle password update
    if (newPassword) {
      // Regular users must provide current password
      if (req.user.role !== "admin" && !currentPassword) {
        return res.status(400).json({
          success: false,
          msg: "Current password is required to set a new password.",
        })
      }

      // Verify current password for non-admin users
      if (req.user.role !== "admin") {
        const isMatch = await user.comparePassword(currentPassword)
        if (!isMatch) {
          return res.status(401).json({
            success: false,
            msg: "Current password is incorrect.",
          })
        }
      }

      // Validate password strength
      if (!PASSWORD_REGEX.test(newPassword)) {
        return res.status(400).json({
          success: false,
          msg: "Password must be at least 10 characters long and contain one lowercase letter, one uppercase letter, one number, and one special character with no spaces.",
        })
      }

      // Update password
      user.password = newPassword
      user.passwordChangedAt = Date.now()
    }

    await user.save()

    // Log update activity
    await logUserActivity(user._id, "profile-update", req.ip, req.headers["user-agent"])

    res.status(200).json({
      success: true,
      msg: "User updated successfully.",
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profileImage: user.profileImage,
      },
    })
  } catch (err) {
    console.error("❌ Error in updateUser:", err)
    res.status(500).json({ success: false, msg: "Server error" })
  }
}

/**
 * Delete user
 * @route DELETE /api/auth/users/:userId
 */
exports.deleteUser = async (req, res) => {
  try {
    const { userId } = req.params

    // Check if user is admin or deleting their own account
    if (req.user.role !== "admin" && req.user.id !== userId) {
      return res.status(403).json({
        success: false,
        msg: "Unauthorized. You can only delete your own account.",
      })
    }

    // Find and delete user
    const user = await User.findByIdAndDelete(userId)

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found.",
      })
    }

    // Log deletion activity
    await logUserActivity(req.user.id, `user-deleted:${userId}`, req.ip, req.headers["user-agent"])

    res.status(200).json({
      success: true,
      msg: "User deleted successfully.",
    })
  } catch (err) {
    console.error("❌ Error in deleteUser:", err)
    res.status(500).json({ success: false, msg: "Server error" })
  }
}

/**
 * Change user role (admin only)
 * @route PATCH /api/auth/users/:userId/role
 */
exports.changeUserRole = async (req, res) => {
  try {
    const { userId } = req.params
    const { role } = req.body

    // Check if user is admin
    if (req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Unauthorized. Admin access required.",
      })
    }

    // Validate role
    const validRoles = ["user", "vendor", "admin"]
    if (!validRoles.includes(role)) {
      return res.status(400).json({
        success: false,
        msg: `Invalid role. Role must be one of: ${validRoles.join(", ")}.`,
      })
    }

    // Find and update user
    const user = await User.findByIdAndUpdate(userId, { role }, { new: true, runValidators: true }).select(
      "-password -resetPasswordToken -resetPasswordExpires",
    )

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found.",
      })
    }

    // Log role change activity
    await logUserActivity(req.user.id, `role-change:${userId}:${role}`, req.ip, req.headers["user-agent"])

    res.status(200).json({
      success: true,
      msg: `User role updated to ${role} successfully.`,
      user,
    })
  } catch (err) {
    console.error("❌ Error in changeUserRole:", err)
    res.status(500).json({ success: false, msg: "Server error" })
  }
}

/**
 * Get current user profile
 * @route GET /api/auth/me
 */
exports.getCurrentUser = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password -resetPasswordToken -resetPasswordExpires")

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found.",
      })
    }

    res.status(200).json({
      success: true,
      user,
    })
  } catch (err) {
    console.error("❌ Error in getCurrentUser:", err)
    res.status(500).json({ success: false, msg: "Server error" })
  }
}

/**
 * Change password
 * @route POST /api/auth/change-password
 */
exports.changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body

    // Validate required fields
    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        msg: "Current password and new password are required.",
      })
    }

    // Validate password strength
    if (!PASSWORD_REGEX.test(newPassword)) {
      return res.status(400).json({
        success: false,
        msg: "Password must be at least 10 characters long and contain one lowercase letter, one uppercase letter, one number, and one special character with no spaces.",
      })
    }

    // Find user
    const user = await User.findById(req.user.id).select("+password")

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found.",
      })
    }

    // Verify current password
    const isMatch = await user.comparePassword(currentPassword)

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        msg: "Current password is incorrect.",
      })
    }

    // Update password
    user.password = newPassword
    user.passwordChangedAt = Date.now()
    await user.save()

    // Log password change activity
    await logUserActivity(user._id, "password-change", req.ip, req.headers["user-agent"])

    res.status(200).json({
      success: true,
      msg: "Password changed successfully.",
    })
  } catch (err) {
    console.error("❌ Error in changePassword:", err)
    res.status(500).json({ success: false, msg: "Server error" })
  }
}

/**
 * Upload profile photo
 * @route POST /api/auth/upload-profile-photo
 */
exports.uploadProfilePhoto = async (req, res) => {
  try {
    // Check if file exists in the request
    if (!req.file) {
      return res.status(400).json({
        success: false,
        msg: "No file uploaded",
      })
    }

    // Get user ID from authenticated request
    const userId = req.user.id

    // Find user
    const user = await User.findById(userId)

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found",
      })
    }

    // Get the file path
    const profileImageUrl = `/uploads/${req.file.filename}`

    // Delete old profile image if it exists and is not the default
    if (
      user.profileImage &&
      user.profileImage !== "/uploads/default-profile.png" &&
      user.profileImage.startsWith("/uploads/")
    ) {
      try {
        const oldImagePath = path.join(__dirname, "..", user.profileImage)
        if (fs.existsSync(oldImagePath)) {
          fs.unlinkSync(oldImagePath)
          console.log(`Deleted old profile image: ${oldImagePath}`)
        }
      } catch (error) {
        console.error("Error deleting old profile image:", error)
        // Continue even if delete fails
      }
    }

    // Update user profile image
    user.profileImage = profileImageUrl
    await user.save()

    // Log activity
    await logUserActivity(userId, "profile-photo-update", req.ip, req.headers["user-agent"])

    res.status(200).json({
      success: true,
      msg: "Profile photo uploaded successfully",
      profileImage: profileImageUrl,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profileImage: user.profileImage,
      },
    })
  } catch (err) {
    console.error("❌ Error in uploadProfilePhoto:", err)
    res.status(500).json({
      success: false,
      msg: "Server error occurred during profile photo upload",
      error: process.env.NODE_ENV === "development" ? err.message : undefined,
    })
  }
}

/**
 * Update profile (comprehensive update including profile photo)
 * @route POST /api/auth/update-profile
 */
exports.updateProfile = async (req, res) => {
  try {
    // Get user ID from authenticated request - users can only update their own profile
    const userId = req.user.id

    // Find user
    const user = await User.findById(userId).select("+password")

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found",
      })
    }

    // Extract fields from request body
    const { name, phone, bio, address, currentPassword, newPassword } = req.body

    // Update basic fields if provided
    if (name) user.name = name
    if (phone) user.phone = phone
    if (bio !== undefined) user.bio = bio
    if (address !== undefined) user.address = address

    // Handle profile photo if uploaded
    if (req.file) {
      // Get the file path
      const profileImageUrl = `/uploads/${req.file.filename}`

      // Delete old profile image if it exists and is not the default
      if (
        user.profileImage &&
        user.profileImage !== "/uploads/default-profile.png" &&
        user.profileImage.startsWith("/uploads/")
      ) {
        try {
          const oldImagePath = path.join(__dirname, "..", user.profileImage)
          if (fs.existsSync(oldImagePath)) {
            fs.unlinkSync(oldImagePath)
            console.log(`Deleted old profile image: ${oldImagePath}`)
          }
        } catch (error) {
          console.error("Error deleting old profile image:", error)
          // Continue even if delete fails
        }
      }

      // Update user profile image
      user.profileImage = profileImageUrl
    }

    // Handle password update if provided
    if (newPassword) {
      // Require current password
      if (!currentPassword) {
        return res.status(400).json({
          success: false,
          msg: "Current password is required to set a new password",
        })
      }

      // Verify current password
      const isMatch = await user.comparePassword(currentPassword)
      if (!isMatch) {
        return res.status(401).json({
          success: false,
          msg: "Current password is incorrect",
        })
      }

      // Validate password strength
      if (!PASSWORD_REGEX.test(newPassword)) {
        return res.status(400).json({
          success: false,
          msg: "Password must be at least 10 characters long and contain one lowercase letter, one uppercase letter, one number, and one special character with no spaces",
        })
      }

      // Update password
      user.password = newPassword
      user.passwordChangedAt = Date.now()
    }

    // Save updated user
    await user.save()

    // Log activity
    await logUserActivity(userId, "profile-update", req.ip, req.headers["user-agent"])

    // Return updated user data
    res.status(200).json({
      success: true,
      msg: "Profile updated successfully",
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profileImage: user.profileImage,
        bio: user.bio,
        address: user.address,
      },
    })
  } catch (err) {
    console.error("❌ Error in updateProfile:", err)
    res.status(500).json({
      success: false,
      msg: "Server error occurred during profile update",
      error: process.env.NODE_ENV === "development" ? err.message : undefined,
    })
  }
}

/**
 * Admin update user profile
 * @route POST /api/auth/admin/update-profile/:id
 */
exports.adminUpdateProfile = async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Unauthorized. Admin access required.",
      })
    }

    const { id } = req.params

    // Validate userId is a valid MongoDB ObjectId
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      })
    }

    // Find user
    const user = await User.findById(id).select("+password")

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found",
      })
    }

    // Extract fields from request body
    const { name, email, phone, bio, address, role, newPassword, active } = req.body

    // Update fields if provided
    if (name) user.name = name
    if (email) user.email = email
    if (phone) user.phone = phone
    if (bio !== undefined) user.bio = bio
    if (address !== undefined) user.address = address
    if (role) {
      const validRoles = ["user", "vendor", "admin"]
      if (!validRoles.includes(role)) {
        return res.status(400).json({
          success: false,
          msg: `Invalid role. Role must be one of: ${validRoles.join(", ")}`,
        })
      }
      user.role = role
    }
    if (active !== undefined) user.active = active

    // Handle profile photo if uploaded
    if (req.file) {
      // Get the file path
      const profileImageUrl = `/uploads/${req.file.filename}`

      // Delete old profile image if it exists and is not the default
      if (
        user.profileImage &&
        user.profileImage !== "/uploads/default-profile.png" &&
        user.profileImage.startsWith("/uploads/")
      ) {
        try {
          const oldImagePath = path.join(__dirname, "..", user.profileImage)
          if (fs.existsSync(oldImagePath)) {
            fs.unlinkSync(oldImagePath)
            console.log(`Deleted old profile image: ${oldImagePath}`)
          }
        } catch (error) {
          console.error("Error deleting old profile image:", error)
          // Continue even if delete fails
        }
      }

      // Update user profile image
      user.profileImage = profileImageUrl
    }

    // Handle password update if provided
    if (newPassword) {
      // Validate password strength
      if (!PASSWORD_REGEX.test(newPassword)) {
        return res.status(400).json({
          success: false,
          msg: "Password must be at least 10 characters long and contain one lowercase letter, one uppercase letter, one number, and one special character with no spaces",
        })
      }

      // Update password
      user.password = newPassword
      user.passwordChangedAt = Date.now()
    }

    // Save updated user
    await user.save()

    // Log activity
    await logUserActivity(req.user.id, `admin-profile-update:${id}`, req.ip, req.headers["user-agent"])

    // Return updated user data
    res.status(200).json({
      success: true,
      msg: "Profile updated successfully by admin",
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profileImage: user.profileImage,
        bio: user.bio,
        address: user.address,
        active: user.active,
      },
    })
  } catch (err) {
    console.error("❌ Error in adminUpdateProfile:", err)
    res.status(500).json({
      success: false,
      msg: "Server error occurred during profile update",
      error: process.env.NODE_ENV === "development" ? err.message : undefined,
    })
  }
}

// Helper functions

/**
 * Generate JWT token
 * @param {Object} user - User object
 * @returns {String} JWT token
 */
const generateToken = (user) => {
  return jwt.sign(
    {
      userId: user._id,
      email: user.email,
      role: user.role,
    },
    process.env.JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN },
  )
}

/**
 * Generate refresh token
 * @param {Object} user - User object
 * @returns {String} Refresh token
 */
const generateRefreshToken = (user) => {
  return jwt.sign({ userId: user._id }, process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET, {
    expiresIn: REFRESH_TOKEN_EXPIRES_IN,
  })
}

/**
 * Log user activity
 * @param {String} userId - User ID
 * @param {String} activity - Activity type
 * @param {String} ip - IP address
 * @param {String} userAgent - User agent
 * @returns {Promise} Promise
 */
const logUserActivity = async (userId, activity, ip, userAgent) => {
  try {
    // This would typically save to a UserActivity model
    // For now, just log to console
    console.log(`🔍 User Activity: ${userId} - ${activity} - ${ip} - ${userAgent}`)

    // In a real implementation, you would save this to the database
    // const userActivity = new UserActivity({
    //   userId,
    //   activity,
    //   ip,
    //   userAgent
    // });
    // await userActivity.save();

    return true
  } catch (error) {
    console.error("❌ Error logging user activity:", error)
    return false
  }
}

module.exports = exports

