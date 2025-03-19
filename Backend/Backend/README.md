# Event Horizon Backend

Event Horizon is a backend service for managing events, users, vendors, bookings, and chats. 

## Setup

1. Clone this repository.
2. Install dependencies with `npm install`.
3. Create a `.env` file with the required environment variables:
   - `MONGO_URI` (MongoDB URI)
   - `JWT_SECRET` (Secret key for JWT authentication)
   - `EMAIL_USER` (Your email for sending emails)
   - `EMAIL_PASS` (Your email password)
4. Run the app with `npm start`.

## Routes

- **POST /api/auth/register** - Register a new user
- **POST /api/auth/login** - Login a user
- **POST /api/events/create** - Create a new event
- **GET /api/events/:eventId** - Get event details

## Dependencies

- Express
- Mongoose
- JWT
- Nodemailer
- Bcrypt
- CORS
