const express = require("express")
const router = express.Router()
const { body } = require("express-validator")
const authController = require("../controllers/authController")
const { protect, authorize } = require("../middleware/authMiddleware")

// Add these imports at the top of the file
const multer = require("multer")
const path = require("path")
const fs = require("fs")

// Add this after the other imports but before the router definition
// Configure multer for profile photo uploads
const UPLOADS_DIR = path.join(__dirname, "..", "uploads")

// Ensure uploads directory exists
if (!fs.existsSync(UPLOADS_DIR)) {
  fs.mkdirSync(UPLOADS_DIR, { recursive: true })
}

const profileStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOADS_DIR)
  },
  filename: (req, file, cb) => {
    // Generate a safe filename with user ID to avoid conflicts
    const fileExt = path.extname(file.originalname)
    const fileName = `profile-${Date.now()}-${Math.round(Math.random() * 1e9)}${fileExt}`
    cb(null, fileName)
  },
})

const profileFileFilter = (req, file, cb) => {
  // Accept only image files
  if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/)) {
    return cb(new Error("Only image files are allowed for profile photos"), false)
  }
  cb(null, true)
}

const uploadProfilePhoto = multer({
  storage: profileStorage,
  fileFilter: profileFileFilter,
  limits: {
    fileSize: 2 * 1024 * 1024, // 2MB max file size
  },
})

// Validation middleware
const registerValidation = [
  body("name").trim().notEmpty().withMessage("Name is required"),
  body("email").isEmail().normalizeEmail().withMessage("Valid email is required"),
  body("password").isLength({ min: 10 }).withMessage("Password must be at least 10 characters long"),
  body("phone")
    .matches(/^\d{10}$/)
    .withMessage("Phone number must be 10 digits"),
  body("role").isIn(["user", "vendor", "admin"]).withMessage("Invalid role"),
]

const loginValidation = [
  body("email").isEmail().normalizeEmail().withMessage("Valid email is required"),
  body("password").notEmpty().withMessage("Password is required"),
]

// Public routes
router.post("/register", registerValidation, authController.registerUser)
router.post("/login", authController.loginRateLimiter, loginValidation, authController.loginUser)
router.post("/forgot-password", authController.forgotPassword)
router.post("/reset-password/:token", authController.resetPassword)
router.post("/refresh-token", authController.refreshToken)

// Protected routes (require authentication)
router.use(protect) // Apply authentication middleware to all routes below

router.get("/me", authController.getCurrentUser)
router.post("/logout", authController.logoutUser)
router.post("/change-password", authController.changePassword)

// Add these routes after the other protected routes
// Profile photo upload route
router.post(
  "/upload-profile-photo",
  protect,
  uploadProfilePhoto.single("profilePhoto"),
  authController.uploadProfilePhoto,
)

// Comprehensive profile update route (includes photo upload)
router.post("/update-profile", protect, uploadProfilePhoto.single("profilePhoto"), authController.updateProfile)

// Admin-only profile update route
router.post(
  "/admin/update-profile/:id",
  protect,
  authorize("admin"), // This middleware ensures only admins can access this route
  uploadProfilePhoto.single("profilePhoto"),
  authController.adminUpdateProfile,
)

// User management routes
router
  .route("/users/:userId")
  .get(authController.getUserById)
  .put(authController.updateUser)
  .delete(authController.deleteUser)

router.get("/users/email/:email", authController.getUserByEmail)

// Admin only routes
router.get("/users", authorize("admin"), authController.getAllUsers)
router.patch("/users/:userId/role", authorize("admin"), authController.changeUserRole)

// Add this error handler after the router definition but before module.exports
// Handle multer errors for profile photo uploads
router.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        success: false,
        msg: "File too large. Maximum size is 2MB.",
      })
    }
    return res.status(400).json({
      success: false,
      msg: `Upload error: ${err.message}`,
    })
  }
  next(err)
})

module.exports = router

