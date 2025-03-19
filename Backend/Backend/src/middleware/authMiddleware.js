const jwt = require("jsonwebtoken")
const User = require("../models/User")

/**
 * Protect routes - Verify JWT token and attach user to request
 */
exports.protect = async (req, res, next) => {
  try {
    let token

    // Get token from Authorization header
    if (req.headers.authorization && req.headers.authorization.startsWith("Bearer")) {
      token = req.headers.authorization.split(" ")[1]
    }
    // Get token from cookie
    else if (req.cookies && req.cookies.token) {
      token = req.cookies.token
    }

    // Check if token exists
    if (!token) {
      return res.status(401).json({
        success: false,
        msg: "Not authorized to access this route",
      })
    }

    try {
      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET)

      // Get user from database
      const user = await User.findById(decoded.userId)

      // Check if user exists
      if (!user) {
        return res.status(401).json({
          success: false,
          msg: "User not found",
        })
      }

      // Check if user changed password after token was issued
      if (user.passwordChangedAt && user.changedPasswordAfter(decoded.iat)) {
        return res.status(401).json({
          success: false,
          msg: "User recently changed password. Please log in again.",
        })
      }

      // Add user to request object
      req.user = {
        id: user._id,
        email: user.email,
        role: user.role,
      }

      next()
    } catch (error) {
      return res.status(401).json({
        success: false,
        msg: "Not authorized to access this route",
      })
    }
  } catch (err) {
    console.error("❌ Error in auth middleware:", err)
    res.status(500).json({ success: false, msg: "Server error" })
  }
}

/**
 * Authorize roles - Restrict access to specific roles
 * @param {...String} roles - Roles to authorize
 */
exports.authorize = (...roles) => {
  return (req, res, next) => {
    // Check if user exists and has a role
    if (!req.user) {
      return res.status(401).json({
        success: false,
        msg: "User not authenticated",
      })
    }

    // Check if user's role is in the allowed roles
    if (!roles.includes(req.user.role)) {
      console.log(`🚫 Authorization failed: User role ${req.user.role} not in allowed roles [${roles.join(", ")}]`)
      return res.status(403).json({
        success: false,
        msg: `Unauthorized. ${req.user.role} role cannot access this route.`,
      })
    }

    // User is authorized
    next()
  }
}

