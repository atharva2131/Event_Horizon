const Booking = require("../models/Booking")
const Event = require("../models/Event")
const Vendor = require("../models/Vendor")
const User = require("../models/User")
const Notification = require("../models/Notification")
const { validationResult } = require("express-validator")
const mongoose = require("mongoose")

/**
 * Create a new booking request
 * @route POST /api/bookings
 * @access Private
 */
exports.createBooking = async (req, res) => {
  try {
    // Validate request using express-validator
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      })
    }

    const { eventId, vendorId, serviceId, bookingDate, timeSlot, requirements, price } = req.body

    // Validate required fields
    if (!eventId || !vendorId || !serviceId || !bookingDate || !timeSlot) {
      return res.status(400).json({
        success: false,
        msg: "Missing required fields",
      })
    }

    // Validate ObjectIds
    if (
      !mongoose.Types.ObjectId.isValid(eventId) ||
      !mongoose.Types.ObjectId.isValid(vendorId) ||
      !mongoose.Types.ObjectId.isValid(serviceId)
    ) {
      return res.status(400).json({
        success: false,
        msg: "Invalid ID format",
      })
    }

    // Check if event exists and belongs to the user
    const event = await Event.findById(eventId)
    if (!event) {
      return res.status(404).json({
        success: false,
        msg: "Event not found",
      })
    }

    // Verify user owns the event or is a collaborator
    if (event.createdBy.toString() !== req.user.id && !event.collaborators.includes(req.user.id)) {
      return res.status(403).json({
        success: false,
        msg: "You don't have permission to book for this event",
      })
    }

    // Check if vendor exists
    const vendor = await Vendor.findById(vendorId)
    if (!vendor) {
      return res.status(404).json({
        success: false,
        msg: "Vendor not found",
      })
    }

    // Check if service exists for this vendor
    const service = vendor.services.id(serviceId)
    if (!service) {
      return res.status(404).json({
        success: false,
        msg: "Service not found for this vendor",
      })
    }

    // Validate booking date is in the future
    const bookingDateObj = new Date(bookingDate)
    if (bookingDateObj < new Date()) {
      return res.status(400).json({
        success: false,
        msg: "Booking date must be in the future",
      })
    }

    // Check if vendor is available on the requested date and time
    const isAvailable = vendor.isDateAvailable(bookingDate)
    if (!isAvailable) {
      return res.status(400).json({
        success: false,
        msg: "Vendor is not available on the requested date",
      }) 
    }

    // Find the availability entry for the requested date
    const availabilityEntry = vendor.availability.find((a) => {
      const availDate = new Date(a.date)
      availDate.setHours(0, 0, 0, 0)
      const targetDate = new Date(bookingDate)
      targetDate.setHours(0, 0, 0, 0)
      return availDate.getTime() === targetDate.getTime()
    })

    // Check if the requested time slot is available
    if (availabilityEntry) {
      const requestedSlot = availabilityEntry.slots.find(
        (slot) => slot.startTime === timeSlot.startTime && slot.endTime === timeSlot.endTime && !slot.isBooked,
      )

      if (!requestedSlot) {
        return res.status(400).json({
          success: false,
          msg: "The requested time slot is not available",
        })
      }
    } else {
      return res.status(400).json({
        success: false,
        msg: "No availability found for the requested date",
      })
    }

    // Create new booking
    const newBooking = new Booking({
      eventId,
      vendorId,
      userId: req.user.id,
      serviceId,
      bookingDate: bookingDateObj,
      timeSlot,
      requirements: requirements || "",
      price: price || 0,
      status: "pending",
    })

    await newBooking.save()

    // Create notification for vendor
    const vendorUser = await User.findById(vendor.userId)
    if (vendorUser) {
      const notification = new Notification({
        recipient: vendorUser._id,
        type: "booking_request",
        title: "New Booking Request",
        message: `You have a new booking request for ${event.eventName} on ${new Date(
          bookingDate,
        ).toLocaleDateString()}`,
        relatedId: newBooking._id,
        onModel: "Booking",
        priority: "high",
        actionLink: `/vendor/bookings/${newBooking._id}`,
      })

      await notification.save()
    }

    res.status(201).json({
      success: true,
      msg: "Booking request created successfully",
      booking: newBooking,
    })
  } catch (error) {
    console.error("❌ Error creating booking:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while creating booking",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Get all bookings for the logged-in user
 * @route GET /api/bookings
 * @access Private
 */
exports.getUserBookings = async (req, res) => {
  try {
    // Pagination
    const page = Number.parseInt(req.query.page) || 1
    const limit = Number.parseInt(req.query.limit) || 10
    const skip = (page - 1) * limit

    // Build filter object
    const filter = { userId: req.user.id }

    // Filter by status
    if (req.query.status) {
      filter.status = req.query.status
    }

    // Filter by date range
    if (req.query.startDate && req.query.endDate) {
      filter.bookingDate = {
        $gte: new Date(req.query.startDate),
        $lte: new Date(req.query.endDate),
      }
    } else if (req.query.startDate) {
      filter.bookingDate = { $gte: new Date(req.query.startDate) }
    } else if (req.query.endDate) {
      filter.bookingDate = { $lte: new Date(req.query.endDate) }
    }

    // Filter by event
    if (req.query.eventId) {
      filter.eventId = req.query.eventId
    }

    // Build sort object
    const sort = {}
    if (req.query.sortBy) {
      const sortField = req.query.sortBy
      const sortOrder = req.query.sortOrder === "desc" ? -1 : 1
      sort[sortField] = sortOrder
    } else {
      // Default sort by createdAt descending
      sort.createdAt = -1
    }

    // Execute query with pagination
    const bookings = await Booking.find(filter)
      .populate("eventId", "eventName eventDate location")
      .populate("vendorId", "businessName businessLogo")
      .sort(sort)
      .skip(skip)
      .limit(limit)

    // Get total count for pagination
    const total = await Booking.countDocuments(filter)

    res.status(200).json({
      success: true,
      count: bookings.length,
      total,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      bookings,
    })
  } catch (error) {
    console.error("❌ Error fetching user bookings:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching bookings",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Get all bookings for the logged-in vendor
 * @route GET /api/bookings/vendor
 * @access Private (vendor only)
 */
exports.getVendorBookings = async (req, res) => {
  try {
    // Check if user is a vendor
    if (req.user.role !== "vendor" && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Only vendors can access their bookings",
      })
    }

    // Find vendor profile for the logged-in user
    const vendor = await Vendor.findOne({ userId: req.user.id })
    if (!vendor) {
      return res.status(404).json({
        success: false,
        msg: "Vendor profile not found",
      })
    }

    // Pagination
    const page = Number.parseInt(req.query.page) || 1
    const limit = Number.parseInt(req.query.limit) || 10
    const skip = (page - 1) * limit

    // Build filter object
    const filter = { vendorId: vendor._id }

    // Filter by status
    if (req.query.status) {
      filter.status = req.query.status
    }

    // Filter by date range
    if (req.query.startDate && req.query.endDate) {
      filter.bookingDate = {
        $gte: new Date(req.query.startDate),
        $lte: new Date(req.query.endDate),
      }
    } else if (req.query.startDate) {
      filter.bookingDate = { $gte: new Date(req.query.startDate) }
    } else if (req.query.endDate) {
      filter.bookingDate = { $lte: new Date(req.query.endDate) }
    }

    // Build sort object
    const sort = {}
    if (req.query.sortBy) {
      const sortField = req.query.sortBy
      const sortOrder = req.query.sortOrder === "desc" ? -1 : 1
      sort[sortField] = sortOrder
    } else {
      // Default sort by createdAt descending
      sort.createdAt = -1
    }

    // Execute query with pagination
    const bookings = await Booking.find(filter)
      .populate("eventId", "eventName eventDate location")
      .populate("userId", "name email phone profileImage")
      .sort(sort)
      .skip(skip)
      .limit(limit)

    // Get total count for pagination
    const total = await Booking.countDocuments(filter)

    res.status(200).json({
      success: true,
      count: bookings.length,
      total,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      bookings,
    })
  } catch (error) {
    console.error("❌ Error fetching vendor bookings:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching bookings",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Get a single booking by ID
 * @route GET /api/bookings/:id
 * @access Private
 */
exports.getBookingById = async (req, res) => {
  try {
    const { id } = req.params

    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid booking ID format",
      })
    }

    // Find booking with detailed information
    const booking = await Booking.findById(id)
      .populate("eventId", "eventName eventDate location eventImage")
      .populate("vendorId", "businessName businessLogo contactEmail contactPhone")
      .populate("userId", "name email phone profileImage")

    if (!booking) {
      return res.status(404).json({
        success: false,
        msg: "Booking not found",
      })
    }

    // Check if user has permission to view this booking
    const isVendor = req.user.role === "vendor"
    const isAdmin = req.user.role === "admin"
    const isOwner = booking.userId._id.toString() === req.user.id
    const isVendorOwner = isVendor && (await Vendor.findOne({ userId: req.user.id, _id: booking.vendorId }))

    if (!isOwner && !isVendorOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        msg: "You don't have permission to view this booking",
      })
    }

    // Get service details
    let serviceDetails = null
    if (booking.vendorId) {
      const vendor = await Vendor.findById(booking.vendorId)
      if (vendor) {
        serviceDetails = vendor.services.id(booking.serviceId)
      }
    }

    res.status(200).json({
      success: true,
      booking,
      serviceDetails,
    })
  } catch (error) {
    console.error("❌ Error fetching booking:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching booking",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Update booking status (vendor only)
 * @route PATCH /api/bookings/:id/status
 * @access Private (vendor only)
 */
exports.updateBookingStatus = async (req, res) => {
  try {
    const { id } = req.params
    const { status, notes } = req.body

    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid booking ID format",
      })
    }

    // Validate status
    const validStatuses = ["confirmed", "rejected", "cancelled", "completed"]
    if (!status || !validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        msg: `Status must be one of: ${validStatuses.join(", ")}`,
      })
    }

    // Find booking
    const booking = await Booking.findById(id)
    if (!booking) {
      return res.status(404).json({
        success: false,
        msg: "Booking not found",
      })
    }

    // Check if user is the vendor for this booking or an admin
    const isAdmin = req.user.role === "admin"
    const isVendor = req.user.role === "vendor"
    const isVendorOwner = isVendor && (await Vendor.findOne({ userId: req.user.id, _id: booking.vendorId }))

    if (!isVendorOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        msg: "You don't have permission to update this booking",
      })
    }

    // Update booking status
    booking.status = status
    if (notes) booking.notes = notes

    // Handle cancellation
    if (status === "cancelled") {
      booking.cancellationReason = notes || "Cancelled by vendor"
      booking.cancelledBy = "vendor"
      booking.cancelledAt = Date.now()
    }

    // If confirming, update vendor's availability
    if (status === "confirmed") {
      const vendor = await Vendor.findById(booking.vendorId)
      if (vendor) {
        // Find the availability entry for the booking date
        const availabilityEntry = vendor.availability.find((a) => {
          const availDate = new Date(a.date)
          availDate.setHours(0, 0, 0, 0)
          const bookingDate = new Date(booking.bookingDate)
          bookingDate.setHours(0, 0, 0, 0)
          return availDate.getTime() === bookingDate.getTime()
        })

        if (availabilityEntry) {
          // Find and mark the time slot as booked
          const slotIndex = availabilityEntry.slots.findIndex(
            (slot) => slot.startTime === booking.timeSlot.startTime && slot.endTime === booking.timeSlot.endTime,
          )

          if (slotIndex !== -1) {
            availabilityEntry.slots[slotIndex].isBooked = true
            availabilityEntry.slots[slotIndex].bookingId = booking._id

            // Check if all slots are booked
            const allSlotsBooked = availabilityEntry.slots.every((slot) => slot.isBooked)
            if (allSlotsBooked) {
              availabilityEntry.isFullyBooked = true
            }

            await vendor.save()
          }
        }
      }
    }

    await booking.save()

    // Create notification for user
    const notification = new Notification({
      recipient: booking.userId,
      type: `booking_${status}`,
      title: `Booking ${status.charAt(0).toUpperCase() + status.slice(1)}`,
      message: `Your booking for ${booking.eventId} has been ${status} by the vendor.`,
      relatedId: booking._id,
      onModel: "Booking",
      priority: "high",
      actionLink: `/bookings/${booking._id}`,
    })

    await notification.save()

    res.status(200).json({
      success: true,
      msg: `Booking ${status} successfully`,
      booking,
    })
  } catch (error) {
    console.error("❌ Error updating booking status:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while updating booking status",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Cancel booking (user only)
 * @route PATCH /api/bookings/:id/cancel
 * @access Private
 */
exports.cancelBooking = async (req, res) => {
  try {
    const { id } = req.params
    const { reason } = req.body

    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid booking ID format",
      })
    }

    // Find booking
    const booking = await Booking.findById(id)
    if (!booking) {
      return res.status(404).json({
        success: false,
        msg: "Booking not found",
      })
    }

    // Check if user is the owner of this booking
    if (booking.userId.toString() !== req.user.id && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "You don't have permission to cancel this booking",
      })
    }

    // Check if booking can be cancelled
    if (booking.status === "cancelled") {
      return res.status(400).json({
        success: false,
        msg: "Booking is already cancelled",
      })
    }

    if (booking.status === "completed") {
      return res.status(400).json({
        success: false,
        msg: "Cannot cancel a completed booking",
      })
    }

    // Update booking
    booking.status = "cancelled"
    booking.cancellationReason = reason || "Cancelled by user"
    booking.cancelledBy = "user"
    booking.cancelledAt = Date.now()

    await booking.save()

    // If the booking was confirmed, free up the time slot
    if (booking.status === "confirmed") {
      const vendor = await Vendor.findById(booking.vendorId)
      if (vendor) {
        // Find the availability entry for the booking date
        const availabilityEntry = vendor.availability.find((a) => {
          const availDate = new Date(a.date)
          availDate.setHours(0, 0, 0, 0)
          const bookingDate = new Date(booking.bookingDate)
          bookingDate.setHours(0, 0, 0, 0)
          return availDate.getTime() === bookingDate.getTime()
        })

        if (availabilityEntry) {
          // Find and mark the time slot as available
          const slotIndex = availabilityEntry.slots.findIndex(
            (slot) => slot.startTime === booking.timeSlot.startTime && slot.endTime === booking.timeSlot.endTime,
          )

          if (slotIndex !== -1) {
            availabilityEntry.slots[slotIndex].isBooked = false
            availabilityEntry.slots[slotIndex].bookingId = undefined
            availabilityEntry.isFullyBooked = false

            await vendor.save()
          }
        }
      }
    }

    // Create notification for vendor
    const vendor = await Vendor.findById(booking.vendorId)
    if (vendor) {
      const notification = new Notification({
        recipient: vendor.userId,
        type: "booking_cancelled",
        title: "Booking Cancelled",
        message: `A booking for ${booking.eventId} has been cancelled by the user.`,
        relatedId: booking._id,
        onModel: "Booking",
        priority: "medium",
        actionLink: `/vendor/bookings/${booking._id}`,
      })

      await notification.save()
    }

    res.status(200).json({
      success: true,
      msg: "Booking cancelled successfully",
      booking,
    })
  } catch (error) {
    console.error("❌ Error cancelling booking:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while cancelling booking",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Update booking payment status
 * @route PATCH /api/bookings/:id/payment
 * @access Private (admin or vendor only)
 */
exports.updatePaymentStatus = async (req, res) => {
  try {
    const { id } = req.params
    const { paymentStatus, paymentDetails } = req.body

    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid booking ID format",
      })
    }

    // Validate payment status
    const validStatuses = ["pending", "partial", "paid", "refunded"]
    if (!paymentStatus || !validStatuses.includes(paymentStatus)) {
      return res.status(400).json({
        success: false,
        msg: `Payment status must be one of: ${validStatuses.join(", ")}`,
      })
    }

    // Find booking
    const booking = await Booking.findById(id)
    if (!booking) {
      return res.status(404).json({
        success: false,
        msg: "Booking not found",
      })
    }

    // Check if user is the vendor for this booking or an admin
    const isAdmin = req.user.role === "admin"
    const isVendor = req.user.role === "vendor"
    const isVendorOwner = isVendor && (await Vendor.findOne({ userId: req.user.id, _id: booking.vendorId }))

    if (!isVendorOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        msg: "You don't have permission to update payment status",
      })
    }

    // Update payment status
    booking.paymentStatus = paymentStatus

    // Update payment details if provided
    if (paymentDetails) {
      if (paymentDetails.method) booking.paymentDetails.method = paymentDetails.method
      if (paymentDetails.transactionId) booking.paymentDetails.transactionId = paymentDetails.transactionId
      if (paymentDetails.paidAmount) booking.paymentDetails.paidAmount = paymentDetails.paidAmount

      // Set paidAt timestamp if payment is marked as paid or partial
      if ((paymentStatus === "paid" || paymentStatus === "partial") && !booking.paymentDetails.paidAt) {
        booking.paymentDetails.paidAt = Date.now()
      }
    }

    await booking.save()

    // Create notification for user
    const notification = new Notification({
      recipient: booking.userId,
      type: "payment_received",
      title: "Payment Status Updated",
      message: `The payment status for your booking has been updated to ${paymentStatus}.`,
      relatedId: booking._id,
      onModel: "Booking",
      priority: "medium",
      actionLink: `/bookings/${booking._id}`,
    })

    await notification.save()

    res.status(200).json({
      success: true,
      msg: "Payment status updated successfully",
      booking,
    })
  } catch (error) {
    console.error("❌ Error updating payment status:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while updating payment status",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

module.exports = exports

