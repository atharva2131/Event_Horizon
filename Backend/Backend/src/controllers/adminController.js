const User = require("../models/User")
const Booking = require("../models/Booking")
const Payment = require("../models/Payment")
const Vendor = require("../models/Vendor")
const mongoose = require("mongoose")

/**
 * Get dashboard data for admin
 * @route GET /api/admin/dashboard
 */
exports.getDashboardData = async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Unauthorized. Admin access required.",
      })
    }

    // Get counts
    const totalUsers = await User.countDocuments({ role: "user" })
    const activeVendors = await User.countDocuments({ role: "vendor", active: true })
    const pendingBookings = await Booking.countDocuments({ status: "pending" })

    // Get total revenue
    const payments = await Payment.find({ status: "completed" })
    const totalRevenue = payments.reduce((sum, payment) => sum + payment.amount, 0)

    // Get monthly revenue for the current year
    const currentYear = new Date().getFullYear()
    const monthlyRevenue = []

    for (let month = 0; month < 12; month++) {
      const startDate = new Date(currentYear, month, 1)
      const endDate = new Date(currentYear, month + 1, 0)

      const monthPayments = await Payment.find({
        status: "completed",
        createdAt: {
          $gte: startDate,
          $lte: endDate,
        },
      })

      const monthRevenue = monthPayments.reduce((sum, payment) => sum + payment.amount, 0)
      monthlyRevenue.push(monthRevenue)
    }

    // Get recent activities
    const recentActivities = []

    // Recent user registrations
    const recentUsers = await User.find().sort({ createdAt: -1 }).limit(2)

    recentUsers.forEach((user) => {
      recentActivities.push({
        type: "user",
        title: "New User Registration",
        description: `${user.name} registered as a new ${user.role}`,
        time: getTimeAgo(user.createdAt),
      })
    })

    // Recent bookings
    const recentBookings = await Booking.find()
      .sort({ createdAt: -1 })
      .limit(2)
      .populate("userId", "name")
      .populate("vendorId", "name")

    recentBookings.forEach((booking) => {
      recentActivities.push({
        type: "booking",
        title: "New Booking",
        description: `${booking.eventName} booked by ${booking.userId?.name || "a user"}`,
        time: getTimeAgo(booking.createdAt),
      })
    })

    // Recent payments
    const recentPayments = await Payment.find().sort({ createdAt: -1 }).limit(2).populate("bookingId", "eventName")

    recentPayments.forEach((payment) => {
      recentActivities.push({
        type: "payment",
        title: "Payment Received",
        description: `₹${payment.amount} received for ${payment.bookingId?.eventName || "booking"}`,
        time: getTimeAgo(payment.createdAt),
      })
    })

    // Sort activities by time
    recentActivities.sort((a, b) => {
      const timeA = parseTimeAgo(a.time)
      const timeB = parseTimeAgo(b.time)
      return timeA - timeB
    })

    res.status(200).json({
      success: true,
      dashboardData: {
        totalUsers,
        activeVendors,
        pendingBookings,
        totalRevenue,
        monthlyRevenue,
        recentActivities: recentActivities.slice(0, 5), // Limit to 5 activities
      },
    })
  } catch (err) {
    console.error("❌ Error in getDashboardData:", err)
    res.status(500).json({
      success: false,
      msg: "Server error",
      error: process.env.NODE_ENV === "development" ? err.message : undefined,
    })
  }
}

/**
 * Get all users with detailed information for admin
 * @route GET /api/admin/users
 */
exports.getUsers = async (req, res) => {
  try {
    // Check if user is admin
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
    if (req.query.active !== undefined) filter.active = req.query.active === "true"
    if (req.query.search) {
      filter.$or = [
        { name: { $regex: req.query.search, $options: "i" } },
        { email: { $regex: req.query.search, $options: "i" } },
        { phone: { $regex: req.query.search, $options: "i" } },
      ]
    }

    // Count total documents for pagination
    const total = await User.countDocuments(filter)

    // Get users with pagination and filtering
    const users = await User.find(filter)
      .select("-password -resetPasswordToken -resetPasswordExpires")
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 })

    res.status(200).json({
      success: true,
      count: users.length,
      total,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      users,
    })
  } catch (err) {
    console.error("❌ Error in getUsers:", err)
    res.status(500).json({
      success: false,
      msg: "Server error",
      error: process.env.NODE_ENV === "development" ? err.message : undefined,
    })
  }
}

/**
 * Get user details with bookings and payments
 * @route GET /api/admin/users/:userId
 */
exports.getUserDetails = async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Unauthorized. Admin access required.",
      })
    }

    const { userId } = req.params

    // Validate userId is a valid MongoDB ObjectId
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      })
    }

    // Get user details
    const user = await User.findById(userId).select("-password -resetPasswordToken -resetPasswordExpires")

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found",
      })
    }

    // Get user bookings
    const bookings = await Booking.find({ userId }).sort({ createdAt: -1 }).populate("vendorId", "name")

    // Get user payments
    const payments = await Payment.find({ userId }).sort({ createdAt: -1 }).populate("bookingId", "eventName")

    res.status(200).json({
      success: true,
      user,
      bookings,
      payments,
    })
  } catch (err) {
    console.error("❌ Error in getUserDetails:", err)
    res.status(500).json({
      success: false,
      msg: "Server error",
      error: process.env.NODE_ENV === "development" ? err.message : undefined,
    })
  }
}

/**
 * Update user admin notes
 * @route PATCH /api/admin/users/:userId/notes
 */
exports.updateUserNotes = async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Unauthorized. Admin access required.",
      })
    }

    const { userId } = req.params
    const { adminNotes } = req.body

    // Validate userId is a valid MongoDB ObjectId
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({
        success: false,
        msg: "Invalid user ID format",
      })
    }

    // Update user notes
    const user = await User.findByIdAndUpdate(userId, { adminNotes }, { new: true, runValidators: true }).select(
      "-password -resetPasswordToken -resetPasswordExpires",
    )

    if (!user) {
      return res.status(404).json({
        success: false,
        msg: "User not found",
      })
    }

    res.status(200).json({
      success: true,
      msg: "User notes updated successfully",
      user,
    })
  } catch (err) {
    console.error("❌ Error in updateUserNotes:", err)
    res.status(500).json({
      success: false,
      msg: "Server error",
      error: process.env.NODE_ENV === "development" ? err.message : undefined,
    })
  }
}

/**
 * Get all bookings for admin
 * @route GET /api/admin/bookings
 */
exports.getBookings = async (req, res) => {
  try {
    // Check if user is admin
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
    if (req.query.status) filter.status = req.query.status
    if (req.query.search) {
      filter.$or = [
        { eventName: { $regex: req.query.search, $options: "i" } },
        { location: { $regex: req.query.search, $options: "i" } },
      ]
    }

    // Count total documents for pagination
    const total = await Booking.countDocuments(filter)

    // Get bookings with pagination and filtering
    const bookings = await Booking.find(filter)
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 })
      .populate("userId", "name email")
      .populate("vendorId", "name")

    res.status(200).json({
      success: true,
      count: bookings.length,
      total,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      bookings,
    })
  } catch (err) {
    console.error("❌ Error in getBookings:", err)
    res.status(500).json({
      success: false,
      msg: "Server error",
      error: process.env.NODE_ENV === "development" ? err.message : undefined,
    })
  }
}

/**
 * Get all payments for admin
 * @route GET /api/admin/payments
 */
exports.getPayments = async (req, res) => {
  try {
    // Check if user is admin
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
    if (req.query.status) filter.status = req.query.status

    // Count total documents for pagination
    const total = await Payment.countDocuments(filter)

    // Get payments with pagination and filtering
    const payments = await Payment.find(filter)
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 })
      .populate("userId", "name email")
      .populate("bookingId", "eventName")

    res.status(200).json({
      success: true,
      count: payments.length,
      total,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      payments,
    })
  } catch (err) {
    console.error("❌ Error in getPayments:", err)
    res.status(500).json({
      success: false,
      msg: "Server error",
      error: process.env.NODE_ENV === "development" ? err.message : undefined,
    })
  }
}

/**
 * Get admin reports and analytics
 * @route GET /api/admin/reports
 */
exports.getReports = async (req, res) => {
  try {
    // Check if user is admin
    if (req.user.role !== "admin") {
      return res.status(403).json({
        success: false,
        msg: "Unauthorized. Admin access required.",
      })
    }

    const { period } = req.query // daily, weekly, monthly, yearly

    // Default to monthly if not specified
    const reportPeriod = period || "monthly"

    // Get current date
    const now = new Date()

    // Initialize report data
    let reportData = {}

    if (reportPeriod === "yearly") {
      // Yearly report - last 5 years
      reportData = await getYearlyReport(now)
    } else if (reportPeriod === "monthly") {
      // Monthly report - last 12 months
      reportData = await getMonthlyReport(now)
    } else if (reportPeriod === "weekly") {
      // Weekly report - last 12 weeks
      reportData = await getWeeklyReport(now)
    } else {
      // Daily report - last 30 days
      reportData = await getDailyReport(now)
    }

    res.status(200).json({
      success: true,
      period: reportPeriod,
      reportData,
    })
  } catch (err) {
    console.error("❌ Error in getReports:", err)
    res.status(500).json({
      success: false,
      msg: "Server error",
      error: process.env.NODE_ENV === "development" ? err.message : undefined,
    })
  }
}

// Helper functions

/**
 * Get time ago string from date
 * @param {Date} date - Date to convert
 * @returns {String} Time ago string
 */
function getTimeAgo(date) {
  const seconds = Math.floor((new Date() - new Date(date)) / 1000)

  let interval = Math.floor(seconds / 31536000)
  if (interval > 1) return interval + " years ago"
  if (interval === 1) return "1 year ago"

  interval = Math.floor(seconds / 2592000)
  if (interval > 1) return interval + " months ago"
  if (interval === 1) return "1 month ago"

  interval = Math.floor(seconds / 86400)
  if (interval > 1) return interval + " days ago"
  if (interval === 1) return "1 day ago"

  interval = Math.floor(seconds / 3600)
  if (interval > 1) return interval + " hours ago"
  if (interval === 1) return "1 hour ago"

  interval = Math.floor(seconds / 60)
  if (interval > 1) return interval + " minutes ago"
  if (interval === 1) return "1 minute ago"

  if (seconds < 10) return "just now"

  return Math.floor(seconds) + " seconds ago"
}

/**
 * Parse time ago string to get seconds
 * @param {String} timeAgo - Time ago string
 * @returns {Number} Seconds
 */
function parseTimeAgo(timeAgo) {
  if (timeAgo === "just now") return 0

  const parts = timeAgo.split(" ")
  const value = Number.parseInt(parts[0])
  const unit = parts[1]

  switch (unit) {
    case "seconds":
    case "second":
      return value
    case "minutes":
    case "minute":
      return value * 60
    case "hours":
    case "hour":
      return value * 3600
    case "days":
    case "day":
      return value * 86400
    case "months":
    case "month":
      return value * 2592000
    case "years":
    case "year":
      return value * 31536000
    default:
      return 0
  }
}

/**
 * Get yearly report
 * @param {Date} now - Current date
 * @returns {Object} Report data
 */
async function getYearlyReport(now) {
  const currentYear = now.getFullYear()
  const years = []
  const userCounts = []
  const bookingCounts = []
  const revenueCounts = []

  // Get data for last 5 years
  for (let i = 0; i < 5; i++) {
    const year = currentYear - i
    years.unshift(year.toString())

    const startDate = new Date(year, 0, 1)
    const endDate = new Date(year, 11, 31, 23, 59, 59)

    // Count users registered in this year
    const userCount = await User.countDocuments({
      createdAt: { $gte: startDate, $lte: endDate },
    })
    userCounts.unshift(userCount)

    // Count bookings made in this year
    const bookingCount = await Booking.countDocuments({
      createdAt: { $gte: startDate, $lte: endDate },
    })
    bookingCounts.unshift(bookingCount)

    // Sum revenue from payments in this year
    const payments = await Payment.find({
      status: "completed",
      createdAt: { $gte: startDate, $lte: endDate },
    })
    const revenue = payments.reduce((sum, payment) => sum + payment.amount, 0)
    revenueCounts.unshift(revenue)
  }

  return {
    labels: years,
    datasets: {
      users: userCounts,
      bookings: bookingCounts,
      revenue: revenueCounts,
    },
  }
}

/**
 * Get monthly report
 * @param {Date} now - Current date
 * @returns {Object} Report data
 */
async function getMonthlyReport(now) {
  const months = []
  const userCounts = []
  const bookingCounts = []
  const revenueCounts = []

  // Get data for last 12 months
  for (let i = 0; i < 12; i++) {
    const date = new Date(now)
    date.setMonth(date.getMonth() - i)

    const monthName = date.toLocaleString("default", { month: "short" })
    const year = date.getFullYear()
    months.unshift(`${monthName} ${year}`)

    const startDate = new Date(date.getFullYear(), date.getMonth(), 1)
    const endDate = new Date(date.getFullYear(), date.getMonth() + 1, 0, 23, 59, 59)

    // Count users registered in this month
    const userCount = await User.countDocuments({
      createdAt: { $gte: startDate, $lte: endDate },
    })
    userCounts.unshift(userCount)

    // Count bookings made in this month
    const bookingCount = await Booking.countDocuments({
      createdAt: { $gte: startDate, $lte: endDate },
    })
    bookingCounts.unshift(bookingCount)

    // Sum revenue from payments in this month
    const payments = await Payment.find({
      status: "completed",
      createdAt: { $gte: startDate, $lte: endDate },
    })
    const revenue = payments.reduce((sum, payment) => sum + payment.amount, 0)
    revenueCounts.unshift(revenue)
  }

  return {
    labels: months,
    datasets: {
      users: userCounts,
      bookings: bookingCounts,
      revenue: revenueCounts,
    },
  }
}

/**
 * Get weekly report
 * @param {Date} now - Current date
 * @returns {Object} Report data
 */
async function getWeeklyReport(now) {
  const weeks = []
  const userCounts = []
  const bookingCounts = []
  const revenueCounts = []

  // Get data for last 12 weeks
  for (let i = 0; i < 12; i++) {
    const date = new Date(now)
    date.setDate(date.getDate() - i * 7)

    const weekStart = new Date(date)
    weekStart.setDate(date.getDate() - date.getDay())

    const weekEnd = new Date(weekStart)
    weekEnd.setDate(weekStart.getDate() + 6)

    const weekLabel = `${weekStart.toLocaleDateString("default", { month: "short", day: "numeric" })} - ${weekEnd.toLocaleDateString("default", { month: "short", day: "numeric" })}`
    weeks.unshift(weekLabel)

    // Count users registered in this week
    const userCount = await User.countDocuments({
      createdAt: { $gte: weekStart, $lte: new Date(weekEnd.setHours(23, 59, 59)) },
    })
    userCounts.unshift(userCount)

    // Count bookings made in this week
    const bookingCount = await Booking.countDocuments({
      createdAt: { $gte: weekStart, $lte: new Date(weekEnd.setHours(23, 59, 59)) },
    })
    bookingCounts.unshift(bookingCount)

    // Sum revenue from payments in this week
    const payments = await Payment.find({
      status: "completed",
      createdAt: { $gte: weekStart, $lte: new Date(weekEnd.setHours(23, 59, 59)) },
    })
    const revenue = payments.reduce((sum, payment) => sum + payment.amount, 0)
    revenueCounts.unshift(revenue)
  }

  return {
    labels: weeks,
    datasets: {
      users: userCounts,
      bookings: bookingCounts,
      revenue: revenueCounts,
    },
  }
}

/**
 * Get daily report
 * @param {Date} now - Current date
 * @returns {Object} Report data
 */
async function getDailyReport(now) {
  const days = []
  const userCounts = []
  const bookingCounts = []
  const revenueCounts = []

  // Get data for last 30 days
  for (let i = 0; i < 30; i++) {
    const date = new Date(now)
    date.setDate(date.getDate() - i)

    const dayLabel = date.toLocaleDateString("default", { month: "short", day: "numeric" })
    days.unshift(dayLabel)

    const startDate = new Date(date.setHours(0, 0, 0, 0))
    const endDate = new Date(date.setHours(23, 59, 59, 999))

    // Count users registered on this day
    const userCount = await User.countDocuments({
      createdAt: { $gte: startDate, $lte: endDate },
    })
    userCounts.unshift(userCount)

    // Count bookings made on this day
    const bookingCount = await Booking.countDocuments({
      createdAt: { $gte: startDate, $lte: endDate },
    })
    bookingCounts.unshift(bookingCount)

    // Sum revenue from payments on this day
    const payments = await Payment.find({
      status: "completed",
      createdAt: { $gte: startDate, $lte: endDate },
    })
    const revenue = payments.reduce((sum, payment) => sum + payment.amount, 0)
    revenueCounts.unshift(revenue)
  }

  return {
    labels: days,
    datasets: {
      users: userCounts,
      bookings: bookingCounts,
      revenue: revenueCounts,
    },
  }
}

module.exports = exports

 