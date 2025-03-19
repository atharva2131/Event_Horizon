const Event = require("../models/Event")
const User = require("../models/User")
const { validationResult } = require("express-validator")
const mongoose = require("mongoose")
const fs = require("fs")
const path = require("path")

/**
 * Create a new event with enhanced validation and features
 * @route POST /api/events
 * @access Private
 */
exports.createEvent = async (req, res) => {
  try {
    // Validate request using express-validator
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      })
    }

    const {
      eventName,
      eventDate,
      eventTime,
      location,
      budget,
      description,
      collaborators,
      guests,
      category,
      isPublic,
      reminderSettings,
    } = req.body

    // Validate event date is in the future
    const eventDateObj = new Date(eventDate)
    if (eventDateObj < new Date()) {
      return res.status(400).json({
        success: false,
        msg: "Event date must be in the future",
      })
    }

    // Process guests data
    let processedGuests = []
    if (guests && Array.isArray(guests)) {
      processedGuests = guests.map((guest) => {
        return {
          name: guest.name || "Guest",
          email: guest.email,
          phone: guest.phone || "",
          rsvpStatus: "pending",
          inviteSent: false,
          source: guest.source || "manual", // 'manual', 'email', 'contacts'
          notes: guest.notes || "",
        }
      })
    }

    // Handle event image if uploaded
    let eventImage = "/uploads/events/default-event.png"
    if (req.file) {
      eventImage = `/uploads/events/${req.file.filename}`;
      console.log("Image path saved:", eventImage);
    }

    // Create new event with enhanced fields
    const newEvent = new Event({
      eventName,
      eventDate: eventDateObj,
      eventTime,
      location,
      budget,
      description: description || "",
      collaborators: collaborators || [],
      guests: processedGuests,
      category: category || "Other",
      isPublic: isPublic || false,
      eventImage, // Add the event image
      reminderSettings: reminderSettings || {
        reminderEnabled: true,
        reminderTime: 24, // hours before event
      },
      createdBy: req.user.id, // Assuming req.user is set by auth middleware
      updatedBy: req.user.id,
    })

    await newEvent.save()

    // If collaborators are specified, update their events list
    if (collaborators && collaborators.length > 0) {
      await User.updateMany({ _id: { $in: collaborators } }, { $addToSet: { collaboratingEvents: newEvent._id } })
    }

    res.status(201).json({
      success: true,
      msg: "Event created successfully",
      event: newEvent,
    })
  } catch (error) {
    console.error("❌ Error creating event:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while creating event",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}



/**
 * Upload an image for an event
 * @route POST /api/events/:id/upload-image
 * @access Private
 */
exports.uploadEventImage = async (req, res) => {
  try {
    // Check if file exists in the request
    if (!req.file) {
      return res.status(400).json({
        success: false,
        msg: "No file uploaded",
      })
    }

    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid event ID format",
      })
    }

    // Find event first to check permissions
    const event = await Event.findById(req.params.id)

    if (!event) {
      return res.status(404).json({
        success: false,
        msg: "Event not found",
      })
    }

    // FIXED: Convert ObjectId to string for comparison
    const eventCreatorId = event.createdBy.toString();
    const requestUserId = req.user.id.toString();
    
    // Check if user has permission to update this event
    // FIXED: Compare string values and log for debugging
    console.log(`Comparing user IDs - Event creator: ${eventCreatorId}, Request user: ${requestUserId}`);

    
    if (
      eventCreatorId !== requestUserId &&
      !event.collaborators.some(id => id.toString() === requestUserId) &&
      req.user.role !== "admin"
    ) {
      return res.status(403).json({
        success: false,
        msg: "You do not have permission to update this event",
      })
    }

    // Get the file path
    const eventImageUrl = `/uploads/events/${req.file.filename}`;
    console.log("Image upload path:", eventImageUrl);

    // Delete old event image if it exists and is not the default
    if (
      event.eventImage &&
      event.eventImage !== "/uploads/events/default-event.png" &&
      event.eventImage.startsWith("/uploads/events/")
    ) {
      try {
        const oldImagePath = path.join(__dirname, "..", "public", event.eventImage)
        if (fs.existsSync(oldImagePath)) {
          fs.unlinkSync(oldImagePath)
          console.log(`Deleted old event image: ${oldImagePath}`);
        }
      } catch (error) {
        console.error("Error deleting old event image:", error)
        // Continue even if delete fails
      }
    }

    // Update event image
    event.eventImage = eventImageUrl
    event.updatedBy = req.user.id
    event.updatedAt = Date.now()

    await event.save()

    res.status(200).json({
      success: true,
      msg: "Event image uploaded successfully",
      eventImage: eventImageUrl,
      event: {
        id: event._id,
        eventName: event.eventName,
        eventImage: event.eventImage,
      },
    })
  } catch (error) {
    console.error("❌ Error uploading event image:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while uploading event image",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}


/**
 * Update an event by ID with validation and permission checks
 * @route PUT /api/events/:id
 * @access Private
 */
exports.updateEvent = async (req, res) => {
  try {
    // Validate request using express-validator
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      })
    }

    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid event ID format",
      })
    }

    // Find event first to check permissions
    const event = await Event.findById(req.params.id)

    if (!event) {
      return res.status(404).json({
        success: false,
        msg: "Event not found",
      })
    }

    // FIXED: Convert ObjectId to string for comparison
    const eventCreatorId = event.createdBy.toString();
    const requestUserId = req.user.id.toString();
    
    // Check if user has permission to update this event
    if (
      eventCreatorId !== requestUserId &&
      !event.collaborators.some(id => id.toString() === requestUserId) &&
      req.user.role !== "admin"
    ) {
      return res.status(403).json({
        success: false,
        msg: "You do not have permission to update this event",
      })
    }

    // Process guests data if provided
    if (req.body.guests && Array.isArray(req.body.guests)) {
      // Keep existing guests that aren't in the new list
      const existingGuestEmails = event.guests.map((g) => g.email)
      const newGuestEmails = req.body.guests.map((g) => g.email)

      // Guests to keep (not in the new list)
      const guestsToKeep = event.guests.filter((g) => !newGuestEmails.includes(g.email))

      // Process new/updated guests
      const processedNewGuests = req.body.guests.map((guest) => {
        // If guest already exists, preserve some fields
        if (existingGuestEmails.includes(guest.email)) {
          const existingGuest = event.guests.find((g) => g.email === guest.email)
          return {
            name: guest.name || existingGuest.name,
            email: guest.email,
            phone: guest.phone || existingGuest.phone,
            rsvpStatus: guest.rsvpStatus || existingGuest.rsvpStatus,
            inviteSent: guest.inviteSent !== undefined ? guest.inviteSent : existingGuest.inviteSent,
            source: guest.source || existingGuest.source,
            notes: guest.notes || existingGuest.notes,
          }
        }

        // New guest
        return {
          name: guest.name || "Guest",
          email: guest.email,
          phone: guest.phone || "",
          rsvpStatus: "pending",
          inviteSent: false,
          source: guest.source || "manual",
          notes: guest.notes || "",
        }
      })

      // Combine kept guests with new/updated guests
      req.body.guests = [...guestsToKeep, ...processedNewGuests]
    }

    // If eventDate is provided, validate it's in the future
    if (req.body.eventDate) {
      const eventDateObj = new Date(req.body.eventDate)
      if (eventDateObj < new Date()) {
        return res.status(400).json({
          success: false,
          msg: "Event date must be in the future",
        })
      }
      req.body.eventDate = eventDateObj
    }

    // Handle event image if uploaded
    if (req.file) {
      // Get the file path
      const eventImageUrl = `/uploads/events/${req.file.filename}`;
      console.log("Updated image path:", eventImageUrl);

      // Delete old event image if it exists and is not the default
      if (
        event.eventImage &&
        event.eventImage !== "/uploads/events/default-event.png" &&
        event.eventImage.startsWith("/uploads/events/")
      ) {
        try {
          const oldImagePath = path.join(__dirname, "..", "public", event.eventImage)
          if (fs.existsSync(oldImagePath)) {
            fs.unlinkSync(oldImagePath)
            console.log(`Deleted old event image: ${oldImagePath}`);
          }
        } catch (error) {
          console.error("Error deleting old event image:", error)
          // Continue even if delete fails
        }
      }

      // Add the new image URL to the request body
      req.body.eventImage = eventImageUrl
    }

    // Update collaborators if changed
    const oldCollaborators = event.collaborators || []
    const newCollaborators = req.body.collaborators || oldCollaborators

    // Add updatedBy and updatedAt
    req.body.updatedBy = req.user.id
    req.body.updatedAt = Date.now()

    // Update the event
    const updatedEvent = await Event.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    }).populate("collaborators", "name email profileImage")

    // Update collaborators' events lists if collaborators changed
    if (JSON.stringify(oldCollaborators) !== JSON.stringify(newCollaborators)) {
      // Remove event from collaborators who were removed
      const removedCollaborators = oldCollaborators.filter((id) => !newCollaborators.includes(id))

      if (removedCollaborators.length > 0) {
        await User.updateMany({ _id: { $in: removedCollaborators } }, { $pull: { collaboratingEvents: req.params.id } })
      }

      // Add event to new collaborators
      const addedCollaborators = newCollaborators.filter((id) => !oldCollaborators.includes(id))

      if (addedCollaborators.length > 0) {
        await User.updateMany(
          { _id: { $in: addedCollaborators } },
          { $addToSet: { collaboratingEvents: req.params.id } },
        )
      }
    }

    res.status(200).json({
      success: true,
      msg: "Event updated successfully",
      event: updatedEvent,
    })
  } catch (error) {
    console.error("❌ Error updating event:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while updating event",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}


/**
 * Get all events with filtering, sorting, and pagination
 * @route GET /api/events
 * @access Private
 */
exports.getEvents = async (req, res) => {
  try {
    // Pagination
    const page = Number.parseInt(req.query.page) || 1
    const limit = Number.parseInt(req.query.limit) || 10
    const skip = (page - 1) * limit

    // Build filter object
    const filter = { createdBy: req.user.id }

    // Filter by date range
    if (req.query.startDate && req.query.endDate) {
      filter.eventDate = {
        $gte: new Date(req.query.startDate),
        $lte: new Date(req.query.endDate),
      }
    } else if (req.query.startDate) {
      filter.eventDate = { $gte: new Date(req.query.startDate) }
    } else if (req.query.endDate) {
      filter.eventDate = { $lte: new Date(req.query.endDate) }
    }

    // Filter by category
    if (req.query.category) {
      filter.category = req.query.category
    }

    // Filter by search term
    if (req.query.search) {
      filter.$or = [
        { eventName: { $regex: req.query.search, $options: "i" } },
        { description: { $regex: req.query.search, $options: "i" } },
        { location: { $regex: req.query.search, $options: "i" } },
      ]
    }

    // Include collaborating events if requested
    if (req.query.includeCollaborating === "true") {
      filter.$or = filter.$or || []
      filter.$or.push({ collaborators: req.user.id })
    }

    // Build sort object
    const sort = {}
    if (req.query.sortBy) {
      const sortField = req.query.sortBy
      const sortOrder = req.query.sortOrder === "desc" ? -1 : 1
      sort[sortField] = sortOrder
    } else {
      // Default sort by eventDate ascending
      sort.eventDate = 1
    }

    // Execute query with pagination
    const events = await Event.find(filter)
      .populate("collaborators", "name email profileImage")
      .sort(sort)
      .skip(skip)
      .limit(limit)

    // Get total count for pagination
    const total = await Event.countDocuments(filter)

    res.status(200).json({
      success: true,
      count: events.length,
      total,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      events,
    })
  } catch (error) {
    console.error("❌ Error fetching events:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching events",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Get a single event by ID with detailed information
 * @route GET /api/events/:id
 * @access Private
 */
exports.getEventById = async (req, res) => {
  try {
    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid event ID format",
      })
    }

    const event = await Event.findById(req.params.id)
      .populate("collaborators", "name email profileImage")
      .populate("createdBy", "name email profileImage")
      .populate("updatedBy", "name email profileImage")

    if (!event) {
      return res.status(404).json({
        success: false,
        msg: "Event not found",
      })
    }

    // Check if user has permission to view this event
    if (
      event.createdBy._id.toString() !== req.user.id &&
      !event.collaborators.some((collab) => collab._id.toString() === req.user.id) &&
      !event.isPublic &&
      req.user.role !== "admin"
    ) {
      return res.status(403).json({
        success: false,
        msg: "You do not have permission to view this event",
      })
    }

    res.status(200).json({
      success: true,
      event,
    })
  } catch (error) {
    console.error("❌ Error fetching event:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching event",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Delete an event by ID with permission checks
 * @route DELETE /api/events/:id
 * @access Private
 */
exports.deleteEvent = async (req, res) => {
  try {
    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid event ID format",
      })
    }

    // Find event first to check permissions
    const event = await Event.findById(req.params.id)

    if (!event) {
      return res.status(404).json({
        success: false,
        msg: "Event not found",
      })
    }

    // Check if user has permission to delete this event
    if (event.createdBy.toString() !== req.user.id && req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "You do not have permission to delete this event",
      })
    }

    // Delete event image if it exists and is not the default
    if (
      event.eventImage &&
      event.eventImage !== "/uploads/events/default-event.png" &&
      event.eventImage.startsWith("/uploads/events/")
    ) {
      try {
        const oldImagePath = path.join(__dirname, "..", "public", event.eventImage)
        if (fs.existsSync(oldImagePath)) {
          fs.unlinkSync(oldImagePath)
          console.log(`Deleted old event image: ${oldImagePath}`);
        }
      } catch (error) {
        console.error("Error deleting old event image:", error)
        // Continue even if delete fails
      }
    }

    // Remove event from all collaborators' lists
    if (event.collaborators && event.collaborators.length > 0) {
      await User.updateMany({ _id: { $in: event.collaborators } }, { $pull: { collaboratingEvents: req.params.id } })
    }

    // Delete the event
    await Event.findByIdAndDelete(req.params.id)

    res.status(200).json({
      success: true,
      msg: "Event deleted successfully",
    })
  } catch (error) {
    console.error("❌ Error deleting event:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while deleting event",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Add a guest to an event
 * @route POST /api/events/:id/guests
 * @access Private
 */
exports.addGuest = async (req, res) => {
  try {
    // Validate request
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      })
    }

    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid event ID format",
      })
    }

    const { name, email, phone, source, notes } = req.body

    if (!email) {
      return res.status(400).json({
        success: false,
        msg: "Email is required for a guest",
      })
    }

    // Find event first to check permissions
    const event = await Event.findById(req.params.id)

    if (!event) {
      return res.status(404).json({
        success: false,
        msg: "Event not found",
      })
    }

    // FIXED: Convert ObjectId to string for comparison
    const eventCreatorId = event.createdBy.toString();
    const requestUserId = req.user.id.toString();
    
    // Check if user has permission to update this event
    if (
      eventCreatorId !== requestUserId &&
      !event.collaborators.some(id => id.toString() === requestUserId) &&
      req.user.role !== "admin"
    ) {
      return res.status(403).json({
        success: false,
        msg: "You do not have permission to update this event",
      })
    }

    // Check if guest already exists
    const existingGuest = event.guests.find((g) => g.email === email)
    if (existingGuest) {
      return res.status(400).json({
        success: false,
        msg: "A guest with this email already exists",
      })
    }

    // Create new guest
    const newGuest = {
      name: name || "Guest",
      email,
      phone: phone || "",
      rsvpStatus: "pending",
      inviteSent: false,
      source: source || "manual",
      notes: notes || "",
    }

    // Add guest to event
    event.guests.push(newGuest)
    event.updatedBy = req.user.id
    event.updatedAt = Date.now()

    await event.save()

    res.status(200).json({
      success: true,
      msg: "Guest added successfully",
      guest: newGuest,
    })
  } catch (error) {
    console.error("❌ Error adding guest:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while adding guest",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Remove a guest from an event
 * @route DELETE /api/events/:id/guests/:email
 * @access Private
 */
exports.removeGuest = async (req, res) => {
  try {
    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid event ID format",
      })
    }

    const { email } = req.params

    if (!email) {
      return res.status(400).json({
        success: false,
        msg: "Guest email is required",
      })
    }

    // Find event first to check permissions
    const event = await Event.findById(req.params.id)

    if (!event) {
      return res.status(404).json({
        success: false,
        msg: "Event not found",
      })
    }

    // FIXED: Convert ObjectId to string for comparison
    const eventCreatorId = event.createdBy.toString();
    const requestUserId = req.user.id.toString();
    
    // Check if user has permission to update this event
    if (
      eventCreatorId !== requestUserId &&
      !event.collaborators.some(id => id.toString() === requestUserId) &&
      req.user.role !== "admin"
    ) {
      return res.status(403).json({
        success: false,
        msg: "You do not have permission to update this event",
      })
    }

    // Check if guest exists
    const guestIndex = event.guests.findIndex((g) => g.email === email)
    if (guestIndex === -1) {
      return res.status(404).json({
        success: false,
        msg: "Guest not found",
      })
    }

    // Remove guest
    event.guests.splice(guestIndex, 1)
    event.updatedBy = req.user.id
    event.updatedAt = Date.now()

    await event.save()

    res.status(200).json({
      success: true,
      msg: "Guest removed successfully",
    })
  } catch (error) {
    console.error("❌ Error removing guest:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while removing guest",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Update guest RSVP status
 * @route PATCH /api/events/:id/guests/:email/rsvp
 * @access Private
 */
exports.updateGuestRsvp = async (req, res) => {
  try {
    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid event ID format",
      })
    }

    const { email } = req.params
    const { rsvpStatus } = req.body

    if (!email) {
      return res.status(400).json({
        success: false,
        msg: "Guest email is required",
      })
    }

    if (!rsvpStatus || !["pending", "confirmed", "declined", "maybe"].includes(rsvpStatus)) {
      return res.status(400).json({
        success: false,
        msg: "Valid RSVP status is required (pending, confirmed, declined, maybe)",
      })
    }

    // Find event
    const event = await Event.findById(req.params.id)

    if (!event) {
      return res.status(404).json({
        success: false,
        msg: "Event not found",
      })
    }

    // Find guest
    const guestIndex = event.guests.findIndex((g) => g.email === email)
    if (guestIndex === -1) {
      return res.status(404).json({
        success: false,
        msg: "Guest not found",
      })
    }

    // Update RSVP status
    event.guests[guestIndex].rsvpStatus = rsvpStatus
    event.updatedAt = Date.now()

    await event.save()

    res.status(200).json({
      success: true,
      msg: "Guest RSVP status updated successfully",
      guest: event.guests[guestIndex],
    })
  } catch (error) {
    console.error("❌ Error updating guest RSVP:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while updating guest RSVP",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

/**
 * Send invitations to guests
 * @route POST /api/events/:id/send-invitations
 * @access Private
 */
exports.sendInvitations = async (req, res) => {
  try {
    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid event ID format",
      })
    }

    const { guestEmails } = req.body

    if (!guestEmails || !Array.isArray(guestEmails) || guestEmails.length === 0) {
      return res.status(400).json({
        success: false,
        msg: "Guest emails array is required",
      })
    }

    // Find event first to check permissions
    const event = await Event.findById(req.params.id)

    if (!event) {
      return res.status(404).json({
        success: false,
        msg: "Event not found",
      })
    }

    // FIXED: Convert ObjectId to string for comparison
    const eventCreatorId = event.createdBy.toString();
    const requestUserId = req.user.id.toString();
    
    // Check if user has permission to update this event
    if (
      eventCreatorId !== requestUserId &&
      !event.collaborators.some(id => id.toString() === requestUserId) &&
      req.user.role !== "admin"
    ) {
      return res.status(403).json({
        success: false,
        msg: "You do not have permission to send invitations for this event",
      })
    }

    // Filter valid emails that exist in the guest list
    const validGuests = event.guests.filter((guest) => guestEmails.includes(guest.email))

    if (validGuests.length === 0) {
      return res.status(400).json({
        success: false,
        msg: "No valid guests found with the provided emails",
      })
    }

    // In a real application, you would send emails here
    // For now, we'll just mark them as invited

    // Update inviteSent status for valid guests
    validGuests.forEach((guest) => {
      const guestIndex = event.guests.findIndex((g) => g.email === guest.email)
      if (guestIndex !== -1) {
        event.guests[guestIndex].inviteSent = true
      }
    })

    event.updatedBy = req.user.id
    event.updatedAt = Date.now()

    await event.save()

    res.status(200).json({
      success: true,
      msg: `Invitations sent to ${validGuests.length} guests`,
      invitedGuests: validGuests.map((g) => g.email),
    })
  } catch (error) {
    console.error("❌ Error sending invitations:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while sending invitations",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}


/**
 * Import guests from contacts
 * @route POST /api/events/:id/import-guests
 * @access Private
 */
exports.importGuests = async (req, res) => {
  try {
    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid event ID format",
      })
    }

    const { contacts } = req.body

    if (!contacts || !Array.isArray(contacts) || contacts.length === 0) {
      return res.status(400).json({
        success: false,
        msg: "Contacts array is required",
      })
    }

    // Find event first to check permissions
    const event = await Event.findById(req.params.id)

    if (!event) {
      return res.status(404).json({
        success: false,
        msg: "Event not found",
      })
    }

    // FIXED: Convert ObjectId to string for comparison
    const eventCreatorId = event.createdBy.toString();
    const requestUserId = req.user.id.toString();
    
    // Check if user has permission to update this event
    if (
      eventCreatorId !== requestUserId &&
      !event.collaborators.some(id => id.toString() === requestUserId) &&
      req.user.role !== "admin"
    ) {
      return res.status(403).json({
        success: false,
        msg: "You do not have permission to import guests for this event",
      })
    }

    // Get existing guest emails
    const existingEmails = event.guests.map((g) => g.email)

    // Process contacts into guests
    const newGuests = []
    const skippedContacts = []

    contacts.forEach((contact) => {
      // Skip contacts without email
      if (!contact.email) {
        skippedContacts.push({
          name: contact.name || "Unknown",
          reason: "Missing email",
        })
        return
      }

      // Skip if email already exists in guest list
      if (existingEmails.includes(contact.email)) {
        skippedContacts.push({
          name: contact.name || "Unknown",
          email: contact.email,
          reason: "Already invited",
        })
        return
      }

      // Create new guest
      const newGuest = {
        name: contact.name || "Guest",
        email: contact.email,
        phone: contact.phone || "",
        rsvpStatus: "pending",
        inviteSent: false,
        source: "contacts",
        notes: contact.notes || "",
      }

      newGuests.push(newGuest)
      existingEmails.push(contact.email) // Prevent duplicates in the same import
    })

    // Add new guests to event
    if (newGuests.length > 0) {
      event.guests = [...event.guests, ...newGuests]
      event.updatedBy = req.user.id
      event.updatedAt = Date.now()

      await event.save()
    }

    res.status(200).json({
      success: true,
      msg: `${newGuests.length} guests imported successfully`,
      imported: newGuests.length,
      skipped: skippedContacts.length,
      skippedDetails: skippedContacts,
      newGuests,
    })
  } catch (error) {
    console.error("❌ Error importing guests:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while importing guests",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}


/**
 * Get event statistics
 * @route GET /api/events/stats
 * @access Private
 */
exports.getEventStats = async (req, res) => {
  try {
    // Get user's events
    const userEvents = await Event.find({
      $or: [{ createdBy: req.user.id }, { collaborators: req.user.id }],
    })

    // Calculate statistics
    const stats = {
      totalEvents: userEvents.length,
      upcomingEvents: userEvents.filter((e) => new Date(e.eventDate) > new Date()).length,
      pastEvents: userEvents.filter((e) => new Date(e.eventDate) <= new Date()).length,
      totalGuests: userEvents.reduce((sum, event) => sum + event.guests.length, 0),
      confirmedGuests: userEvents.reduce(
        (sum, event) => sum + event.guests.filter((g) => g.rsvpStatus === "confirmed").length,
        0,
      ),
      categories: {},
      monthlyEvents: {},
    }

    // Calculate category distribution
    userEvents.forEach((event) => {
      const category = event.category || "other"
      stats.categories[category] = (stats.categories[category] || 0) + 1
    })

    // Calculate monthly distribution (for the next 12 months)
    const now = new Date()
    for (let i = 0; i < 12; i++) {
      const month = new Date(now.getFullYear(), now.getMonth() + i, 1)
      const monthKey = `${month.getFullYear()}-${month.getMonth() + 1}`;
      const monthName = month.toLocaleString("default", { month: "long" })

      // Count events in this month
      stats.monthlyEvents[monthKey] = {
        month: monthName,
        year: month.getFullYear(),
        count: userEvents.filter((event) => {
          const eventDate = new Date(event.eventDate)
          return eventDate.getFullYear() === month.getFullYear() && eventDate.getMonth() === month.getMonth()
        }).length,
      }
    }

    res.status(200).json({
      success: true,
      stats,
    })
  } catch (error) {
    console.error("❌ Error getting event statistics:", error)
    res.status(500).json({
      success: false,
      msg: "Server error occurred while fetching event statistics",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    })
  }
}

module.exports = exports