const Vendor = require("../models/Vendor");
const User = require("../models/User");
const { validationResult } = require("express-validator");
const mongoose = require("mongoose");
const fs = require("fs");
const path = require("path");
const authMiddleware = require("../middleware/authMiddleware");

/**
 * Add a service
 * @route POST /api/vendors/services
 * @access Private (requires user with vendor role)
 */
exports.addService = async (req, res) => {
  try {
    // Validate request using express-validator
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Only vendors can add services",
      });
    }

    // Validate user ID
    if (!mongoose.Types.ObjectId.isValid(req.user.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      });
    }

    const { name, description, category, pricing, tags, location } = req.body;

    // Transform pricing data if it doesn't match the schema
    let transformedPricing = pricing;
    if (pricing && pricing.length > 0 && pricing[0].type && pricing[0].amount) {
      transformedPricing = pricing.map(item => ({
        name: item.type,
        price: item.amount,
        description: `${item.type} package` // Default description
      }));
    }

    // Find vendor profile for the logged-in user
    let vendor = await Vendor.findOne({ userId: req.user.id });

    // If vendor profile doesn't exist, create a basic one automatically
    if (!vendor) {
      // Find user to get basic info
      const user = await User.findById(req.user.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          msg: "User not found",
        });
      }

      // Create a new vendor profile with default values for required fields
      vendor = new Vendor({
        userId: req.user.id,
        businessName: user.name ? `${user.name}'s Business` : "New Vendor Business",
        businessDescription: "Professional vendor services",
        contactEmail: user.email || "vendor@example.com",
        contactPhone: user.phone || "1234567890",
        businessAddress: {
          street: "Default Street",
          city: "Default City",
          state: "Default State",
          zipCode: "12345",
          country: "Default Country",
        },
        isActive: true,
        isVerified: true, // Auto-verify for now
      });

      await vendor.save();
      console.log(`Created new vendor profile for user ${req.user.id}`);
    }

    // Create new service
    const newService = {
      name,
      description,
      category,
      pricing: transformedPricing || [],
      tags: tags || [],
      location: location || "", // Add location field
      isActive: true,
    };

    // Add service to vendor
    vendor.services.push(newService);
    await vendor.save();

    res.status(201).json({
      success: true,
      msg: "Service added successfully",
      service: newService,
    });
  } catch (error) {
    console.error("❌ Error adding service:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while adding service",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Get all services for the logged-in vendor
 * @route GET /api/vendors/services
 * @access Private (requires user with vendor role)
 */
exports.getVendorServices = async (req, res) => {
  try {
    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Only vendors can access their services",
      });
    }

    // Validate user ID
    if (!mongoose.Types.ObjectId.isValid(req.user.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      });
    }

    // Find vendor profile for the logged-in user
    let vendor = await Vendor.findOne({ userId: req.user.id });

    // If vendor profile doesn't exist, create a basic one automatically
    if (!vendor) {
      // Find user to get basic info
      const user = await User.findById(req.user.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          msg: "User not found",
        });
      }

      // Create a new vendor profile with default values for required fields
      vendor = new Vendor({
        userId: req.user.id,
        businessName: user.name ? `${user.name}'s Business` : "New Vendor Business",
        businessDescription: "Professional vendor services",
        contactEmail: user.email || "vendor@example.com",
        contactPhone: user.phone || "1234567890",
        businessAddress: {
          street: "Default Street",
          city: "Default City",
          state: "Default State",
          zipCode: "12345",
          country: "Default Country",
        },
        isActive: true,
        isVerified: true, // Auto-verify for now
      });

      await vendor.save();
      console.log(`Created new vendor profile for user ${req.user.id}`);
    }

    // Return only the services for this vendor
    res.status(200).json({
      success: true,
      count: vendor.services.length,
      services: vendor.services,
    });
  } catch (error) {
    console.error("❌ Error fetching vendor services:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching services",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Get all services from all vendors (public)
 * @route GET /api/vendors/services/all
 * @access Public
 */
exports.getAllServices = async (req, res) => {
  try {
    // Pagination
    const page = Number.parseInt(req.query.page, 10) || 1;
    const limit = Number.parseInt(req.query.limit, 10) || 10;
    const skip = (page - 1) * limit;

    // Build filter object
    const filter = { isActive: true, isVerified: true, "services.isActive": true };

    // Filter by category
    if (req.query.category) {
      filter["services.category"] = req.query.category;
    }

    // Filter by search term
    if (req.query.search) {
      const searchRegex = { $regex: req.query.search, $options: "i" };
      filter.$or = [
        { "services.name": searchRegex },
        { "services.description": searchRegex },
        { "services.tags": searchRegex }
      ];
    }

    // Filter by location
    if (req.query.location) {
      const locationRegex = { $regex: req.query.location, $options: "i" };
      filter["services.location"] = locationRegex;
    }

    // Filter by price range
    if (req.query.minPrice) {
      filter["services.pricing.price"] = { $gte: Number.parseFloat(req.query.minPrice) };
    }
    if (req.query.maxPrice) {
      if (filter["services.pricing.price"]) {
        filter["services.pricing.price"].$lte = Number.parseFloat(req.query.maxPrice);
      } else {
        filter["services.pricing.price"] = { $lte: Number.parseFloat(req.query.maxPrice) };
      }
    }

    // Build sort object
    const sort = {};
    if (req.query.sortBy) {
      const sortField = req.query.sortBy === "price" 
        ? "services.pricing.price" 
        : `services.${req.query.sortBy}`;
      const sortOrder = req.query.sortOrder === "desc" ? -1 : 1;
      sort[sortField] = sortOrder;
    } else {
      // Default sort by rating
      sort["services.averageRating"] = -1;
    }

    // Find vendors and unwind services
    const vendors = await Vendor.aggregate([
      { $match: filter },
      { $unwind: "$services" },
      { $match: { "services.isActive": true } },
      { $sort: sort },
      { $skip: skip },
      { $limit: limit },
      {
        $project: {
          _id: 1,
          businessName: 1,
          businessLogo: 1,
          averageRating: 1,
          totalReviews: 1,
          service: "$services",
          vendorId: "$_id"
        }
      }
    ]);

    // Get total count for pagination
    const totalAggregation = await Vendor.aggregate([
      { $match: filter },
      { $unwind: "$services" },
      { $match: { "services.isActive": true } },
      { $count: "total" }
    ]);

    const total = totalAggregation.length > 0 ? totalAggregation[0].total : 0;

    res.status(200).json({
      success: true,
      count: vendors.length,
      total,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      services: vendors
    });
  } catch (error) {
    console.error("❌ Error fetching all services:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching services",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Update a service
 * @route PUT /api/vendors/services/:serviceId
 * @access Private (requires user with vendor role)
 */
exports.updateService = async (req, res) => {
  try {
    // Validate request using express-validator
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Only vendors can update services",
      });
    }

    const { serviceId } = req.params;

    // Validate serviceId is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(serviceId)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid service ID format",
      });
    }

    // Validate user ID
    if (!mongoose.Types.ObjectId.isValid(req.user.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      });
    }

    // Find vendor profile for the logged-in user
    const vendor = await Vendor.findOne({ userId: req.user.id });

    if (!vendor) {
      return res.status(404).json({
        success: false,
        msg: "Vendor profile not found",
      });
    }

    // Find service index
    const serviceIndex = vendor.services.findIndex(service => service._id.toString() === serviceId);

    if (serviceIndex === -1) {
      return res.status(404).json({
        success: false,
        msg: "Service not found",
      });
    }

    const { name, description, category, pricing, tags, isActive, location } = req.body;

    // Transform pricing data if it doesn't match the schema
    let transformedPricing = pricing;
    if (pricing && pricing.length > 0 && pricing[0].type && pricing[0].amount) {
      transformedPricing = pricing.map(item => ({
        name: item.type,
        price: item.amount,
        description: `${item.type} package` // Default description
      }));
    }

    // Update service fields if provided
    if (name) vendor.services[serviceIndex].name = name;
    if (description) vendor.services[serviceIndex].description = description;
    if (category) vendor.services[serviceIndex].category = category;
    if (pricing) vendor.services[serviceIndex].pricing = transformedPricing;
    if (tags) vendor.services[serviceIndex].tags = tags;
    if (location) vendor.services[serviceIndex].location = location;
    if (isActive !== undefined) vendor.services[serviceIndex].isActive = isActive;

    await vendor.save();

    res.status(200).json({
      success: true,
      msg: "Service updated successfully",
      service: vendor.services[serviceIndex],
    });
  } catch (error) {
    console.error("❌ Error updating service:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while updating service",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Delete a service
 * @route DELETE /api/vendors/services/:serviceId
 * @access Private (requires user with vendor role)
 */
exports.deleteService = async (req, res) => {
  try {
    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Only vendors can delete services",
      });
    }

    const { serviceId } = req.params;

    // Validate serviceId is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(serviceId)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid service ID format",
      });
    }

    // Validate user ID
    if (!mongoose.Types.ObjectId.isValid(req.user.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      });
    }

    // Find vendor profile for the logged-in user
    const vendor = await Vendor.findOne({ userId: req.user.id });

    if (!vendor) {
      return res.status(404).json({
        success: false,
        msg: "Vendor profile not found",
      });
    }

    // Find service index
    const serviceIndex = vendor.services.findIndex(service => service._id.toString() === serviceId);

    if (serviceIndex === -1) {
      return res.status(404).json({
        success: false,
        msg: "Service not found",
      });
    }

    // Remove service
    vendor.services.splice(serviceIndex, 1);
    await vendor.save();

    res.status(200).json({
      success: true,
      msg: "Service deleted successfully",
    });
  } catch (error) {
    console.error("❌ Error deleting service:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while deleting service",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Add a portfolio item with file upload
 * @route POST /api/vendors/portfolio
 * @access Private (requires user with vendor role)
 */
exports.addPortfolioItem = async (req, res) => {
  try {
    // Validate request using express-validator
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      // If there's a file uploaded but validation fails, remove it
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      // If there's a file uploaded but user is not a vendor, remove it
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(403).json({
        success: false,
        msg: "Only vendors can add portfolio items",
      });
    }

    // Validate user ID
    if (!mongoose.Types.ObjectId.isValid(req.user.id)) {
      // If there's a file uploaded but ID is invalid, remove it
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      });
    }

    // Find vendor profile for the logged-in user
    let vendor = await Vendor.findOne({ userId: req.user.id });

    // If vendor profile doesn't exist, create a basic one automatically
    if (!vendor) {
      // Find user to get basic info
      const user = await User.findById(req.user.id);
      if (!user) {
        // If there's a file uploaded but user not found, remove it
        if (req.file) {
          fs.unlinkSync(req.file.path);
        }
        return res.status(404).json({
          success: false,
          msg: "User not found",
        });
      }

      // Create a new vendor profile with default values for required fields
      vendor = new Vendor({
        userId: req.user.id,
        businessName: user.name ? `${user.name}'s Business` : "New Vendor Business",
        businessDescription: "Professional vendor services",
        contactEmail: user.email || "vendor@example.com",
        contactPhone: user.phone || "1234567890",
        businessAddress: {
          street: "Default Street",
          city: "Default City",
          state: "Default State",
          zipCode: "12345",
          country: "Default Country",
        },
        isActive: true,
        isVerified: true, // Auto-verify for now
      });

      await vendor.save();
      console.log(`Created new vendor profile for user ${req.user.id}`);
    }

    const { title, description, mediaType, serviceId, featured, tags, location } = req.body;

    // Validate serviceId if provided
    if (serviceId && !mongoose.Types.ObjectId.isValid(serviceId)) {
      // If there's a file uploaded but serviceId is invalid, remove it
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({
        success: false,
        msg: "Invalid service ID format",
      });
    }

    // Check if service exists if serviceId is provided
    if (serviceId) {
      const serviceExists = vendor.services.some(service => service._id.toString() === serviceId);
      if (!serviceExists) {
        // If there's a file uploaded but service not found, remove it
        if (req.file) {
          fs.unlinkSync(req.file.path);
        }
        return res.status(404).json({
          success: false,
          msg: "Service not found",
        });
      }
    }

    // Handle file upload
    let mediaUrl = "";
    if (req.file) {
      // Create a relative path for the file
      mediaUrl = `/uploads/vendors/${req.file.filename}`;
    } else {
      return res.status(400).json({
        success: false,
        msg: "Please upload a media file",
      });
    }

    // Determine media type based on file extension if not specified
    let determinedMediaType = mediaType || "image";
    if (req.file && !mediaType) {
      const ext = path.extname(req.file.originalname).toLowerCase();
      if (ext === '.mp4' || ext === '.mov' || ext === '.avi' || ext === '.wmv') {
        determinedMediaType = "video";
      }
    }

    // Create new portfolio item
    const newPortfolioItem = {
      title,
      description: description || "",
      mediaType: determinedMediaType,
      mediaUrl,
      serviceId: serviceId || undefined,
      featured: featured || false,
      tags: tags || [],
      location: location || "",
    };

    // Add portfolio item to vendor
    vendor.portfolio.push(newPortfolioItem);
    await vendor.save();

    res.status(201).json({
      success: true,
      msg: "Portfolio item added successfully",
      portfolioItem: newPortfolioItem,
    });
  } catch (error) {
    // If there's a file uploaded but an error occurred, remove it
    if (req.file) {
      fs.unlinkSync(req.file.path);
    }
    console.error("❌ Error adding portfolio item:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while adding portfolio item",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Get all portfolio items for the logged-in vendor
 * @route GET /api/vendors/portfolio
 * @access Private (requires user with vendor role)
 */
exports.getVendorPortfolio = async (req, res) => {
  try {
    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Only vendors can access their portfolio",
      });
    }

    // Validate user ID
    if (!mongoose.Types.ObjectId.isValid(req.user.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      });
    }

    // Find vendor profile for the logged-in user
    let vendor = await Vendor.findOne({ userId: req.user.id });

    // If vendor profile doesn't exist, create a basic one automatically
    if (!vendor) {
      // Find user to get basic info
      const user = await User.findById(req.user.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          msg: "User not found",
        });
      }

      // Create a new vendor profile with default values for required fields
      vendor = new Vendor({
        userId: req.user.id,
        businessName: user.name ? `${user.name}'s Business` : "New Vendor Business",
        businessDescription: "Professional vendor services",
        contactEmail: user.email || "vendor@example.com",
        contactPhone: user.phone || "1234567890",
        businessAddress: {
          street: "Default Street",
          city: "Default City",
          state: "Default State",
          zipCode: "12345",
          country: "Default Country",
        },
        isActive: true,
        isVerified: true, // Auto-verify for now
      });

      await vendor.save();
      console.log(`Created new vendor profile for user ${req.user.id}`);
    }

    // Return only the portfolio items for this vendor
    res.status(200).json({
      success: true,
      count: vendor.portfolio.length,
      portfolio: vendor.portfolio,
    });
  } catch (error) {
    console.error("❌ Error fetching vendor portfolio:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching portfolio",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Update a portfolio item with file upload
 * @route PUT /api/vendors/portfolio/:portfolioItemId
 * @access Private (requires user with vendor role)
 */
exports.updatePortfolioItem = async (req, res) => {
  try {
    // Validate request using express-validator
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      // If there's a file uploaded but validation fails, remove it
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      // If there's a file uploaded but user is not a vendor, remove it
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(403).json({
        success: false,
        msg: "Only vendors can update portfolio items",
      });
    }

    const { portfolioItemId } = req.params;

    // Validate portfolioItemId is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(portfolioItemId)) {
      // If there's a file uploaded but ID is invalid, remove it
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({
        success: false,
        msg: "Invalid portfolio item ID format",
      });
    }

    // Validate user ID
    if (!mongoose.Types.ObjectId.isValid(req.user.id)) {
      // If there's a file uploaded but ID is invalid, remove it
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      });
    }

    // Find vendor profile for the logged-in user
    const vendor = await Vendor.findOne({ userId: req.user.id });

    if (!vendor) {
      // If there's a file uploaded but vendor not found, remove it
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(404).json({
        success: false,
        msg: "Vendor profile not found",
      });
    }

    // Find portfolio item index
    const portfolioItemIndex = vendor.portfolio.findIndex(item => item._id.toString() === portfolioItemId);

    if (portfolioItemIndex === -1) {
      // If there's a file uploaded but portfolio item not found, remove it
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(404).json({
        success: false,
        msg: "Portfolio item not found",
      });
    }

    const { title, description, mediaType, serviceId, featured, tags, location } = req.body;

    // Validate serviceId if provided
    if (serviceId && !mongoose.Types.ObjectId.isValid(serviceId)) {
      // If there's a file uploaded but serviceId is invalid, remove it
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return res.status(400).json({
        success: false,
        msg: "Invalid service ID format",
      });
    }

    // Check if service exists if serviceId is provided
    if (serviceId) {
      const serviceExists = vendor.services.some(service => service._id.toString() === serviceId);
      if (!serviceExists) {
        // If there's a file uploaded but service not found, remove it
        if (req.file) {
          fs.unlinkSync(req.file.path);
        }
        return res.status(404).json({
          success: false,
          msg: "Service not found",
        });
      }
    }

    // Handle file upload
    let mediaUrl = vendor.portfolio[portfolioItemIndex].mediaUrl; // Keep existing URL by default
    if (req.file) {
      // If there's an existing file and it's in our uploads directory, delete it
      const existingUrl = vendor.portfolio[portfolioItemIndex].mediaUrl;
      if (existingUrl && existingUrl.startsWith('/uploads/vendors/')) {
        const existingFilePath = path.join(__dirname, '..', existingUrl);
        if (fs.existsSync(existingFilePath)) {
          fs.unlinkSync(existingFilePath);
        }
      }
      
      // Create a relative path for the new file
      mediaUrl = `/uploads/vendors/${req.file.filename}`;
    }

    // Determine media type based on file extension if not specified
    let determinedMediaType = mediaType || vendor.portfolio[portfolioItemIndex].mediaType;
    if (req.file && !mediaType) {
      const ext = path.extname(req.file.originalname).toLowerCase();
      if (ext === '.mp4' || ext === '.mov' || ext === '.avi' || ext === '.wmv') {
        determinedMediaType = "video";
      } else {
        determinedMediaType = "image";
      }
    }

    // Update portfolio item fields if provided
    if (title) vendor.portfolio[portfolioItemIndex].title = title;
    if (description !== undefined) vendor.portfolio[portfolioItemIndex].description = description;
    if (determinedMediaType) vendor.portfolio[portfolioItemIndex].mediaType = determinedMediaType;
    vendor.portfolio[portfolioItemIndex].mediaUrl = mediaUrl;
    if (serviceId) vendor.portfolio[portfolioItemIndex].serviceId = serviceId;
    if (featured !== undefined) vendor.portfolio[portfolioItemIndex].featured = featured;
    if (tags) vendor.portfolio[portfolioItemIndex].tags = tags;
    if (location) vendor.portfolio[portfolioItemIndex].location = location;

    await vendor.save();

    res.status(200).json({
      success: true,
      msg: "Portfolio item updated successfully",
      portfolioItem: vendor.portfolio[portfolioItemIndex],
    });
  } catch (error) {
    // If there's a file uploaded but an error occurred, remove it
    if (req.file) {
      fs.unlinkSync(req.file.path);
    }
    console.error("❌ Error updating portfolio item:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while updating portfolio item",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Delete a portfolio item
 * @route DELETE /api/vendors/portfolio/:portfolioItemId
 * @access Private (requires user with vendor role)
 */
exports.deletePortfolioItem = async (req, res) => {
  try {
    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Only vendors can delete portfolio items",
      });
    }

    const { portfolioItemId } = req.params;

    // Validate portfolioItemId is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(portfolioItemId)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid portfolio item ID format",
      });
    }

    // Validate user ID
    if (!mongoose.Types.ObjectId.isValid(req.user.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      });
    }

    // Find vendor profile for the logged-in user
    const vendor = await Vendor.findOne({ userId: req.user.id });

    if (!vendor) {
      return res.status(404).json({
        success: false,
        msg: "Vendor profile not found",
      });
    }

    // Find portfolio item index
    const portfolioItemIndex = vendor.portfolio.findIndex(item => item._id.toString() === portfolioItemId);

    if (portfolioItemIndex === -1) {
      return res.status(404).json({
        success: false,
        msg: "Portfolio item not found",
      });
    }

    // Check if the file exists in the uploads directory and delete it
    const mediaUrl = vendor.portfolio[portfolioItemIndex].mediaUrl;
    if (mediaUrl && mediaUrl.startsWith('/uploads/vendors/')) {
      const filePath = path.join(__dirname, '..', mediaUrl);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    }

    // Remove portfolio item
    vendor.portfolio.splice(portfolioItemIndex, 1);
    await vendor.save();

    res.status(200).json({
      success: true,
      msg: "Portfolio item deleted successfully",
    });
  } catch (error) {
    console.error("❌ Error deleting portfolio item:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while deleting portfolio item",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Add availability
 * @route POST /api/vendors/availability
 * @access Private (requires user with vendor role)
 */
exports.addAvailability = async (req, res) => {
  try {
    // Validate request using express-validator
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Only vendors can add availability",
      });
    }

    // Validate user ID
    if (!mongoose.Types.ObjectId.isValid(req.user.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      });
    }

    // Find vendor profile for the logged-in user
    let vendor = await Vendor.findOne({ userId: req.user.id });

    // If vendor profile doesn't exist, create a basic one automatically
    if (!vendor) {
      // Find user to get basic info
      const user = await User.findById(req.user.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          msg: "User not found",
        });
      }

      // Create a new vendor profile with default values for required fields
      vendor = new Vendor({
        userId: req.user.id,
        businessName: user.name ? `${user.name}'s Business` : "New Vendor Business",
        businessDescription: "Professional vendor services",
        contactEmail: user.email || "vendor@example.com",
        contactPhone: user.phone || "1234567890",
        businessAddress: {
          street: "Default Street",
          city: "Default City",
          state: "Default State",
          zipCode: "12345",
          country: "Default Country",
        },
        isActive: true,
        isVerified: true, // Auto-verify for now
      });

      await vendor.save();
      console.log(`Created new vendor profile for user ${req.user.id}`);
    }

    const { date, slots, isUnavailable, location } = req.body;

    // Validate date
    const availabilityDate = new Date(date);
    if (isNaN(availabilityDate.getTime())) {
      return res.status(400).json({
        success: false,
        msg: "Invalid date format",
      });
    }

    // Check if date is in the past
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (availabilityDate < today) {
      return res.status(400).json({
        success: false,
        msg: "Cannot add availability for past dates",
      });
    }

    // Check if availability already exists for this date
    const existingAvailabilityIndex = vendor.availability.findIndex(a => {
      const existingDate = new Date(a.date);
      existingDate.setHours(0, 0, 0, 0);
      return existingDate.getTime() === availabilityDate.setHours(0, 0, 0, 0);
    });

    if (existingAvailabilityIndex !== -1) {
      return res.status(400).json({
        success: false,
        msg: "Availability already exists for this date",
      });
    }

    // Create new availability
    const newAvailability = {
      date: availabilityDate,
      slots: slots || [],
      isUnavailable: isUnavailable || false,
      isFullyBooked: false,
      location: location || "", // Add location field
    };

    // Add availability to vendor
    vendor.availability.push(newAvailability);
    await vendor.save();

    res.status(201).json({
      success: true,
      msg: "Availability added successfully",
      availability: newAvailability,
    });
  } catch (error) {
    console.error("❌ Error adding availability:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while adding availability",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Get all availability for the logged-in vendor
 * @route GET /api/vendors/availability
 * @access Private (requires user with vendor role)
 */
exports.getVendorAvailability = async (req, res) => {
  try {
    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Only vendors can access their availability",
      });
    }

    // Validate user ID
    if (!mongoose.Types.ObjectId.isValid(req.user.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      });
    }

    // Find vendor profile for the logged-in user
    let vendor = await Vendor.findOne({ userId: req.user.id });

    // If vendor profile doesn't exist, create a basic one automatically
    if (!vendor) {
      // Find user to get basic info
      const user = await User.findById(req.user.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          msg: "User not found",
        });
      }

      // Create a new vendor profile with default values for required fields
      vendor = new Vendor({
        userId: req.user.id,
        businessName: user.name ? `${user.name}'s Business` : "New Vendor Business",
        businessDescription: "Professional vendor services",
        contactEmail: user.email || "vendor@example.com",
        contactPhone: user.phone || "1234567890",
        businessAddress: {
          street: "Default Street",
          city: "Default City",
          state: "Default State",
          zipCode: "12345",
          country: "Default Country",
        },
        isActive: true,
        isVerified: true, // Auto-verify for now
      });

      await vendor.save();
      console.log(`Created new vendor profile for user ${req.user.id}`);
    }

    // Return only the availability for this vendor
    res.status(200).json({
      success: true,
      count: vendor.availability.length,
      availability: vendor.availability,
    });
  } catch (error) {
    console.error("❌ Error fetching vendor availability:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching availability",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Update availability
 * @route PUT /api/vendors/availability/:availabilityId
 * @access Private (requires user with vendor role)
 */
exports.updateAvailability = async (req, res) => {
  try {
    // Validate request using express-validator
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Only vendors can update availability",
      });
    }

    const { availabilityId } = req.params;

    // Validate availabilityId is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(availabilityId)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid availability ID format",
      });
    }

    // Validate user ID
    if (!mongoose.Types.ObjectId.isValid(req.user.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      });
    }

    // Find vendor profile for the logged-in user
    const vendor = await Vendor.findOne({ userId: req.user.id });

    if (!vendor) {
      return res.status(404).json({
        success: false,
        msg: "Vendor profile not found",
      });
    }

    // Find availability index
    const availabilityIndex = vendor.availability.findIndex(a => a._id.toString() === availabilityId);

    if (availabilityIndex === -1) {
      return res.status(404).json({
        success: false,
        msg: "Availability not found",
      });
    }

    const { slots, isUnavailable, location } = req.body;

    // Update availability fields if provided
    if (slots) vendor.availability[availabilityIndex].slots = slots;
    if (isUnavailable !== undefined) vendor.availability[availabilityIndex].isUnavailable = isUnavailable;
    if (location) vendor.availability[availabilityIndex].location = location;

    // Update isFullyBooked based on slots
    if (slots) {
      vendor.availability[availabilityIndex].isFullyBooked = slots.every(slot => slot.isBooked);
    }

    await vendor.save();

    res.status(200).json({
      success: true,
      msg: "Availability updated successfully",
      availability: vendor.availability[availabilityIndex],
    });
  } catch (error) {
    console.error("❌ Error updating availability:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while updating availability",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Delete availability
 * @route DELETE /api/vendors/availability/:availabilityId
 * @access Private (requires user with vendor role)
 */
exports.deleteAvailability = async (req, res) => {
  try {
    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Only vendors can delete availability",
      });
    }

    const { availabilityId } = req.params;

    // Validate availabilityId is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(availabilityId)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid availability ID format",
      });
    }

    // Validate user ID
    if (!mongoose.Types.ObjectId.isValid(req.user.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      });
    }

    // Find vendor profile for the logged-in user
    const vendor = await Vendor.findOne({ userId: req.user.id });

    if (!vendor) {
      return res.status(404).json({
        success: false,
        msg: "Vendor profile not found",
      });
    }

    // Find availability index
    const availabilityIndex = vendor.availability.findIndex(a => a._id.toString() === availabilityId);

    if (availabilityIndex === -1) {
      return res.status(404).json({
        success: false,
        msg: "Availability not found",
      });
    }

    // Check if any slots are booked
    const hasBookedSlots = vendor.availability[availabilityIndex].slots.some(slot => slot.isBooked);
    if (hasBookedSlots) {
      return res.status(400).json({
        success: false,
        msg: "Cannot delete availability with booked slots",
      });
    }

    // Remove availability
    vendor.availability.splice(availabilityIndex, 1);
    await vendor.save();

    res.status(200).json({
      success: true,
      msg: "Availability deleted successfully",
    });
  } catch (error) {
    console.error("❌ Error deleting availability:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while deleting availability",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Get all vendors with filtering, sorting, and pagination
 * @route GET /api/vendors
 * @access Public
 */
exports.getAllVendors = async (req, res) => {
  try {
    // Pagination
    const page = Number.parseInt(req.query.page, 10) || 1;
    const limit = Number.parseInt(req.query.limit, 10) || 10;
    const skip = (page - 1) * limit;

    // Build filter object
    const filter = { isActive: true, isVerified: true };

    // Filter by category
    if (req.query.category) {
      filter["services.category"] = req.query.category;
    }

    // Filter by search term
    if (req.query.search) {
      const searchRegex = { $regex: req.query.search, $options: "i" };
      filter.$or = [
        { businessName: searchRegex },
        { businessDescription: searchRegex },
        { "services.name": searchRegex },
        { "services.description": searchRegex },
      ];
    }

    // Filter by service area
    if (req.query.serviceArea) {
      filter.serviceAreas = req.query.serviceArea;
    }

    // Filter by location
    if (req.query.location) {
      const locationRegex = { $regex: req.query.location, $options: "i" };
      filter.$or = filter.$or || [];
      filter.$or.push(
        { "services.location": locationRegex },
        { "portfolio.location": locationRegex },
        { "availability.location": locationRegex }
      );
    }

    // Filter by featured
    if (req.query.featured === "true") {
      filter.isFeatured = true;
    }

    // Filter by minimum rating
    if (req.query.minRating) {
      filter.averageRating = { $gte: Number.parseFloat(req.query.minRating) };
    }

    // Build sort object
    const sort = {};
    if (req.query.sortBy) {
      const sortField = req.query.sortBy;
      const sortOrder = req.query.sortOrder === "desc" ? -1 : 1;
      sort[sortField] = sortOrder;
    } else {
      // Default sort by featured and then rating
      sort.isFeatured = -1;
      sort.averageRating = -1;
    }

    // Execute query with pagination
    const vendors = await Vendor.find(filter)
      .select(
        "businessName businessDescription businessLogo businessCoverImage services.category averageRating totalReviews isFeatured"
      )
      .sort(sort)
      .skip(skip)
      .limit(limit);

    // Get total count for pagination
    const total = await Vendor.countDocuments(filter);

    res.status(200).json({
      success: true,
      count: vendors.length,
      total,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      vendors,
    });
  } catch (error) {
    console.error("❌ Error fetching vendors:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching vendors",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Get vendor by ID
 * @route GET /api/vendors/:vendorId
 * @access Public
 */
exports.getVendorById = async (req, res) => {
  try {
    const { vendorId } = req.params;

    // Validate vendorId is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(vendorId)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid vendor ID format",
      });
    }

    // Find vendor
    const vendor = await Vendor.findById(vendorId)
      .select("-verificationDocuments -paymentMethods.bankDetails");

    if (!vendor) {
      return res.status(404).json({
        success: false,
        msg: "Vendor not found",
      });
    }

    // Check if vendor is active and verified for public access
    if (!vendor.isActive || !vendor.isVerified) {
      // Allow access if user is admin or the vendor owner
      if (!req.user || (req.user.role !== "admin" && req.user.id !== vendor.userId.toString())) {
        return res.status(404).json({
          success: false,
          msg: "Vendor not found",
        });
      }
    }

    res.status(200).json({
      success: true,
      vendor,
    });
  } catch (error) {
    console.error("❌ Error fetching vendor:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching vendor",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

/**
 * Get vendor profile for the logged-in vendor
 * @route GET /api/vendors/profile
 * @access Private (requires user with vendor role)
 */
exports.getVendorProfile = async (req, res) => {
  try {
    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Only vendors can access their profile",
      });
    }

    // Validate user ID
    if (!mongoose.Types.ObjectId.isValid(req.user.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      });
    }

    // Find vendor profile for the logged-in user
    let vendor = await Vendor.findOne({ userId: req.user.id });

    // If vendor profile doesn't exist, create a basic one automatically
    if (!vendor) {
      // Find user to get basic info
      const user = await User.findById(req.user.id);
      if (!user) {
        return res.status(404).json({
          success: false,
          msg: "User not found",
        });
      }

      // Create a new vendor profile with default values for required fields
      vendor = new Vendor({
        userId: req.user.id,
        businessName: user.name ? `${user.name}'s Business` : "New Vendor Business",
        businessDescription: "Professional vendor services",
        contactEmail: user.email || "vendor@example.com",
        contactPhone: user.phone || "1234567890",
        businessAddress: {
          street: "Default Street",
          city: "Default City",
          state: "Default State",
          zipCode: "12345",
          country: "Default Country",
        },
        isActive: true,
        isVerified: true, // Auto-verify for now
      });

      await vendor.save();
      console.log(`Created new vendor profile for user ${req.user.id}`);
    }

    res.status(200).json({
      success: true,
      vendor,
    });
  } catch (error) {
    console.error("❌ Error fetching vendor profile:", error);
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching vendor profile",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};

module.exports = exports; 