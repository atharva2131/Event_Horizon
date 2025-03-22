const express = require("express")
const router = express.Router()
const adminController = require("../controllers/adminController")
const { protect, authorize } = require("../middleware/authMiddleware")

// Apply authentication middleware to all routes
router.use(protect)
router.use(authorize("admin")) // Ensure only admins can access these routes

// Dashboard routes
router.get("/dashboard", adminController.getDashboardData)

// User management routes
router.get("/users", adminController.getUsers)
router.get("/users/:userId", adminController.getUserDetails)
router.patch("/users/:userId/notes", adminController.updateUserNotes)

// Booking management routes
router.get("/bookings", adminController.getBookings)

// Payment management routes
router.get("/payments", adminController.getPayments)

// Reports and analytics
router.get("/reports", adminController.getReports)

module.exports = router

