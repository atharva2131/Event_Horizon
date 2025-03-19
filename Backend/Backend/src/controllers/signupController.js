const crypto = require('crypto');
const util = require('util');
const User = require('../models/User'); // Import User model
require('dotenv').config(); // Load environment variables

// Convert `scrypt` into a Promise-based function
const scryptAsync = util.promisify(crypto.scrypt);
const PASSWORD_SALT_LENGTH = 16;
const PASSWORD_KEY_LENGTH = 64;

// Password Strength Regex
const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/;

// 🟢 USER REGISTRATION
exports.registerUser = async (req, res) => {
  try {
    const { name, email, password, phone, role } = req.body;

    console.log("📩 Incoming Registration Request:", req.body);

    // Validate required fields
    if (!name || !email || !password || !phone || !role) {
      return res.status(400).json({ success: false, msg: 'All fields are required.' });
    }

    // Validate role
    if (!["user", "vendor"].includes(role)) {
      return res.status(400).json({ success: false, msg: 'Invalid role. Role must be either "user" or "vendor".' });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ $or: [{ email }, { phone }] });
    if (existingUser) {
      return res.status(400).json({ success: false, msg: 'User with this email or phone already exists.' });
    }

    // Validate password strength
    if (typeof password !== 'string' || !passwordRegex.test(password)) {
      return res.status(400).json({
        success: false,
        msg: 'Password must be at least 8 characters long and contain one lowercase letter, one uppercase letter, one number, and one special character.',
      });
    }

    console.log("🔑 Password received, proceeding with hashing...");

    // Generate a random salt
    const salt = crypto.randomBytes(PASSWORD_SALT_LENGTH).toString('hex');

    // Hash password using scrypt
    const hashedPasswordBuffer = await scryptAsync(password, salt, PASSWORD_KEY_LENGTH);
    const hashedPassword = `${salt}:${hashedPasswordBuffer.toString('hex')}`;

    console.log("🔒 Hashed Password:", hashedPassword);

    // Create and save new user
    const newUser = new User({
      name,
      email,
      password: hashedPassword, // Store hashed password
      phone,
      role,
    });

    await newUser.save();

    res.status(201).json({
      success: true,
      msg: 'User registered successfully.',
      user: { name: newUser.name, email: newUser.email, phone: newUser.phone, role: newUser.role },
    });

  } catch (err) {
    console.error("❌ Error in registerUser:", err);
    res.status(500).json({ success: false, msg: 'Server error', error: err.message });
  }
};

// 🟢 VERIFY PASSWORD FUNCTION
exports.verifyPassword = async (enteredPassword, storedHash) => {
  try {
    const [salt, storedHashedPassword] = storedHash.split(':');
    const hashedBuffer = await scryptAsync(enteredPassword, salt, PASSWORD_KEY_LENGTH);
    return crypto.timingSafeEqual(Buffer.from(storedHashedPassword, 'hex'), hashedBuffer);
  } catch (error) {
    console.error("❌ Error in verifyPassword:", error);
    return false;
  }
};


// 🟢 GET ALL USERS (EXCLUDING PASSWORDS)
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find().select('-password'); // Exclude passwords
    if (!users.length) {
      return res.status(404).json({ success: false, msg: 'No users found.' });
    }

    res.status(200).json({ success: true, users });
  } catch (err) {
    console.error("❌ Error in getAllUsers:", err);
    res.status(500).json({ success: false, msg: 'Server error', error: err.message });
  }
};

// 🟢 GET USER BY EMAIL
exports.getUserByEmail = async (req, res) => {
  const { email } = req.params;

  try {
    const user = await User.findOne({ email }).select('-password');
    if (!user) {
      return res.status(404).json({ success: false, msg: 'User not found.' });
    }

    res.status(200).json({ success: true, user });
  } catch (err) {
    console.error("❌ Error in getUserByEmail:", err);
    res.status(500).json({ success: false, msg: 'Server error', error: err.message });
  }
};

// 🟢 GET USER BY ID
exports.getUserById = async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findById(userId).select('-password');
    if (!user) {
      return res.status(404).json({ success: false, msg: 'User not found.' });
    }

    res.status(200).json({ success: true, user });
  } catch (err) {
    console.error("❌ Error in getUserById:", err);
    res.status(500).json({ success: false, msg: 'Server error', error: err.message });
  }
};

// 🟢 UPDATE USER DETAILS
exports.updateUser = async (req, res) => {
  const { email } = req.params;
  const { name, password, role, phone } = req.body;

  try {
    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      return res.status(404).json({ success: false, msg: 'User not found.' });
    }

    // Update user details
    if (name) user.name = name;
    if (phone) user.phone = phone;
    if (role && ["user", "vendor"].includes(role)) user.role = role;

    // Handle password update securely
    if (password) {
      if (typeof password !== 'string') {
        return res.status(400).json({ success: false, msg: 'Password must be a valid string.' });
      }

      // Validate password strength
      if (!passwordRegex.test(password)) {
        return res.status(400).json({
          success: false,
          msg: 'Password must be at least 8 characters long and contain one lowercase letter, one uppercase letter, one number, and one special character.',
        });
      }

      // Hash and update password
      user.password = await bcrypt.hash(password, 10);
    }

    await user.save();

    res.status(200).json({ success: true, msg: 'User updated successfully.', user });
  } catch (err) {
    console.error("❌ Error in updateUser:", err);
    res.status(500).json({ success: false, msg: 'Server error', error: err.message });
  }
};

// 🟢 DELETE USER
exports.deleteUser = async (req, res) => {
  const { email } = req.params;

  try {
    const user = await User.findOneAndDelete({ email });
    if (!user) {
      return res.status(404).json({ success: false, msg: 'User not found.' });
    }

    res.status(200).json({ success: true, msg: 'User deleted successfully.' });
  } catch (err) {
    console.error("❌ Error in deleteUser:", err);
    res.status(500).json({ success: false, msg: 'Server error', error: err.message });
  }
};
