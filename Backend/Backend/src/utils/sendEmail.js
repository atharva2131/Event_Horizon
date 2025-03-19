const nodemailer = require('nodemailer');

const sendEmail = async (to, subject, text) => {
  try {
    let transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });

    const info = await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to,
      subject,
      text,
    });

    console.log('Message sent: %s', info.messageId);
  } catch (error) {
    console.error('Error sending email', error);
  }
};

module.exports = sendEmail;
