const express = require("express");
const router = express.Router();
const { check } = require("express-validator");
const vendorController = require("../controllers/vendorController");
const authMiddleware = require("../middleware/authMiddleware");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = path.join(__dirname, "../uploads/vendors");
    
    // Create directory if it doesn't exist
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + "-" + uniqueSuffix + ext);
  },
});

// File filter
const fileFilter = (req, file, cb) => {
  // Accept images only
  if (!file.originalname.match(/\.(jpg|jpeg|png|gif|mp4|mov|avi|wmv)$/)) {
    return cb(new Error("Only image and video files are allowed!"), false);
  }
  cb(null, true);
};

// Initialize multer
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max file size
  },
  fileFilter: fileFilter,
});

// Service routes
router.post(
  "/services",
  authMiddleware.protect,
  [
    check("name", "Service name is required").not().isEmpty(),
    check("description", "Description is required").not().isEmpty(),
    check("category", "Category is required").not().isEmpty(),
    check("pricing", "At least one pricing package is required").isArray({ min: 1 }),
    check("pricing.*.name", "Package name is required").not().isEmpty(),
    check("pricing.*.price", "Price is required and must be a number").isNumeric(),
    check("pricing.*.description", "Package description is required").not().isEmpty(),
  ],
  vendorController.addService
);

router.get("/services", authMiddleware.protect, vendorController.getVendorServices); // Get all services for the logged-in vendor
// Public service routes
router.get("/services/all", vendorController.getAllServices); // Get all services from all vendors

router.put(
  "/services/:serviceId",
  authMiddleware.protect,
  [
    check("name", "Service name is required").optional().not().isEmpty(),
    check("description", "Description is required").optional().not().isEmpty(),
    check("category", "Category is required").optional().not().isEmpty(),
    check("pricing", "At least one pricing package is required").optional().isArray({ min: 1 }),
    check("pricing.*.name", "Package name is required").optional().not().isEmpty(),
    check("pricing.*.price", "Price is required and must be a number").optional().isNumeric(),
    check("pricing.*.description", "Package description is required").optional().not().isEmpty(),
  ],
  vendorController.updateService
);
 
router.delete("/services/:serviceId", authMiddleware.protect, vendorController.deleteService);

// Portfolio routes - Updated to handle file uploads
router.post(
  "/portfolio",
  authMiddleware.protect,
  upload.single("media"), // Handle file upload
  [
    check("title", "Title is required").not().isEmpty(),
    // No mediaUrl validation as we're uploading files
  ],
  vendorController.addPortfolioItem
);

router.get("/portfolio", authMiddleware.protect, vendorController.getVendorPortfolio); // Get all portfolio items for the logged-in vendor

router.put(
  "/portfolio/:portfolioItemId",
  authMiddleware.protect,
  upload.single("media"), // Handle file upload
  [
    check("title", "Title is required").optional().not().isEmpty(),
    // No mediaUrl validation as we're uploading files
  ],
  vendorController.updatePortfolioItem
);

router.delete("/portfolio/:portfolioItemId", authMiddleware.protect, vendorController.deletePortfolioItem);

// Availability routes
router.post(
  "/availability",
  authMiddleware.protect,
  [
    check("date", "Date is required").not().isEmpty(),
    check("slots", "Slots must be an array").isArray(),
    check("slots.*.startTime", "Start time is required").not().isEmpty(),
    check("slots.*.endTime", "End time is required").not().isEmpty(),
  ],
  vendorController.addAvailability
);

router.get("/availability", authMiddleware.protect, vendorController.getVendorAvailability); // Get all availability for the logged-in vendor

router.put(
  "/availability/:availabilityId",
  authMiddleware.protect,
  [
    check("slots", "Slots must be an array").optional().isArray(),
    check("slots.*.startTime", "Start time is required").optional().not().isEmpty(),
    check("slots.*.endTime", "End time is required").optional().not().isEmpty(),
  ],
  vendorController.updateAvailability
);

router.delete("/availability/:availabilityId", authMiddleware.protect, vendorController.deleteAvailability);

// Public vendor routes
router.get("/", vendorController.getAllVendors); // Get all vendors
router.get("/:vendorId", vendorController.getVendorById); // Get vendor by ID

module.exports = router;