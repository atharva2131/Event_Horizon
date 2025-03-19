const express = require("express")
const router = express.Router()
const { check } = require("express-validator")
const bookingController = require("../controllers/bookingController")
const { protect, authorize } = require("../middleware/authMiddleware")

// Apply authentication middleware to all routes
router.use(protect)

// Validation middleware
const createBookingValidation = [
  check("eventId", "Event ID is required").notEmpty().isMongoId(),
  check("vendorId", "Vendor ID is required").notEmpty().isMongoId(),
  check("serviceId", "Service ID is required").notEmpty().isMongoId(),
  check("bookingDate", "Booking date is required").notEmpty().isISO8601(),
  check("timeSlot", "Time slot is required").notEmpty(),
  check("timeSlot.startTime", "Start time is required")
    .notEmpty()
    .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
  check("timeSlot.endTime", "End time is required")
    .notEmpty()
    .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
  check("price", "Price must be a number").optional().isNumeric(),
]

// User booking routes
router.post("/", createBookingValidation, bookingController.createBooking)
router.get("/", bookingController.getUserBookings)
router.patch("/:id/cancel", bookingController.cancelBooking)

// Vendor booking routes
router.get("/vendor", authorize("vendor", "admin"), bookingController.getVendorBookings)
router.patch("/:id/status", authorize("vendor", "admin"), bookingController.updateBookingStatus)
router.patch("/:id/payment", authorize("vendor", "admin"), bookingController.updatePaymentStatus)

// Common routes
router.get("/:id", bookingController.getBookingById)

module.exports = router

