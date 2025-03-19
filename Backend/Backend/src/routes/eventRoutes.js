const express = require("express")
const router = express.Router()
const { body, param, query } = require("express-validator")
const eventController = require("../controllers/eventController")
const { protect, authorize } = require("../middleware/authMiddleware") // Fixed middleware path
const multer = require("multer")
const path = require("path")
const fs = require("fs")

// Configure multer for event image uploads
// FIXED: Changed path to public/uploads/events to match controller expectations
const UPLOADS_DIR = path.join(__dirname, "..", "public", "uploads", "events")

// Ensure uploads directory exists
if (!fs.existsSync(UPLOADS_DIR)) {
  fs.mkdirSync(UPLOADS_DIR, { recursive: true })
}


const eventImageStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOADS_DIR)
  },
  filename: (req, file, cb) => {
    // Generate a safe filename with event ID to avoid conflicts
    const fileExt = path.extname(file.originalname)
    const fileName = `event-${Date.now()}-${Math.round(Math.random() * 1e9)}${fileExt}`;

    cb(null, fileName)
  },
})


const eventImageFileFilter = (req, file, cb) => {
  // Accept only image files
  if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/)) {
    return cb(new Error("Only image files are allowed for event images"), false)
  }
  cb(null, true)
}

const uploadEventImage = multer({
  storage: eventImageStorage,
  fileFilter: eventImageFileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max file size
  },
})


// Apply authentication middleware to all routes
router.use(protect)

// Validation middleware
const createEventValidation = [
  body("eventName")
    .trim()
    .notEmpty()
    .withMessage("Event name is required")
    .isLength({ max: 100 })
    .withMessage("Event name cannot exceed 100 characters"),
  body("eventDate").notEmpty().withMessage("Event date is required").isISO8601().withMessage("Invalid date format"),
  body("eventTime").notEmpty().withMessage("Event time is required"),
  body("location").trim().notEmpty().withMessage("Location is required"),
  body("budget")
    .optional()
    .isNumeric()
    .withMessage("Budget must be a number")
    .isFloat({ min: 0 })
    .withMessage("Budget cannot be negative"),
  body("description").optional().isLength({ max: 2000 }).withMessage("Description cannot exceed 2000 characters"),
  body("category")
    .optional()
    .isIn([
      "Wedding",
      "Birthday",
      "Corporate",
      "Holiday",
      "Anniversary",
      "Graduation",
      "Baby Shower",
      "Retirement",
      "Other",
    ])
    .withMessage("Invalid category"),
  body("collaborators").optional().isArray().withMessage("Collaborators must be an array"),
  body("collaborators.*").optional().isMongoId().withMessage("Invalid collaborator ID"),
  body("isPublic").optional().isBoolean().withMessage("isPublic must be a boolean"),
  body("guests").optional().isArray().withMessage("Guests must be an array"),
  body("guests.*.email").optional().isEmail().withMessage("Invalid guest email format"),
]

const updateEventValidation = [
  body("eventName")
    .optional()
    .trim()
    .notEmpty()
    .withMessage("Event name cannot be empty")
    .isLength({ max: 100 })
    .withMessage("Event name cannot exceed 100 characters"),
  body("eventDate").optional().isISO8601().withMessage("Invalid date format"),
  body("eventTime").optional().notEmpty().withMessage("Event time cannot be empty"),
  body("location").optional().trim().notEmpty().withMessage("Location cannot be empty"),
  body("budget")
    .optional()
    .isNumeric()
    .withMessage("Budget must be a number")
    .isFloat({ min: 0 })
    .withMessage("Budget cannot be negative"),
  body("description").optional().isLength({ max: 2000 }).withMessage("Description cannot exceed 2000 characters"),
  body("category")
    .optional()
    .isIn([
      "Wedding",
      "Birthday",
      "Corporate",
      "Holiday",
      "Anniversary",
      "Graduation",
      "Baby Shower",
      "Retirement",
      "Other",
    ])
    .withMessage("Invalid category"),
  body("collaborators").optional().isArray().withMessage("Collaborators must be an array"),
  body("collaborators.*").optional().isMongoId().withMessage("Invalid collaborator ID"),
  body("isPublic").optional().isBoolean().withMessage("isPublic must be a boolean"),
  body("status").optional().isIn(["planning", "confirmed", "completed", "cancelled"]).withMessage("Invalid status"),
]

const addGuestValidation = [
  body("email").trim().notEmpty().withMessage("Email is required").isEmail().withMessage("Invalid email format"),
  body("name").optional().trim().isLength({ max: 100 }).withMessage("Name cannot exceed 100 characters"),
  body("phone").optional().trim(),
  body("source").optional().isIn(["manual", "email", "contacts"]).withMessage("Invalid source"),
]

// Event routes


// Get event statistics
router.get("/stats", eventController.getEventStats)

// Get all events with filtering, sorting, and pagination
router.get("/", eventController.getEvents)

// Create a new event (with optional image upload)
router.post("/", uploadEventImage.single("eventImage"), createEventValidation, eventController.createEvent)

// Upload event image
router.post("/:id/upload-image", uploadEventImage.single("eventImage"), eventController.uploadEventImage)

// Get, update, or delete a specific event
router
  .route("/:id")
  .get(eventController.getEventById)
  .put(uploadEventImage.single("eventImage"), updateEventValidation, eventController.updateEvent)
  .delete(eventController.deleteEvent)

// Guest management routes
router.post("/:id/guests", addGuestValidation, eventController.addGuest)

router.delete("/:id/guests/:email", eventController.removeGuest)

router.patch(
  "/:id/guests/:email/rsvp",
  [body("rsvpStatus").isIn(["pending", "confirmed", "declined", "maybe"]).withMessage("Invalid RSVP status")],
  eventController.updateGuestRsvp,
)

// Send invitations to guests
router.post(
  "/:id/send-invitations",
  [
    body("guestEmails").isArray().withMessage("Guest emails must be an array"),
    body("guestEmails.*").isEmail().withMessage("Invalid email format"),
  ],
  eventController.sendInvitations,
)

// Import guests from contacts
router.post(
  "/:id/import-guests",
  [
    body("contacts").isArray().withMessage("Contacts must be an array"),
    body("contacts.*.email").optional().isEmail().withMessage("Invalid email format"),
  ],
  eventController.importGuests,
)

// Handle multer errors
router.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        success: false,
        msg: "File too large. Maximum size is 5MB.",
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