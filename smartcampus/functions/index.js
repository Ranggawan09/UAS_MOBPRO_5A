const functions = require("firebase-functions");
const admin = require("firebase-admin");
const express = require("express");
const cors = require("cors");

// Inisialisasi Firebase Admin SDK
admin.initializeApp();

const app = express();
app.use(cors({origin: true}));

// Endpoint: Login
app.post("/login", async (req, res) => {
  const {email, password} = req.body;

  if (!email || !password) {
    return res.status(400).json({error: "Email dan password harus disediakan"});
  }

  try {
    const user = await admin.auth().getUserByEmail(email);

    // Validasi password dilakukan di sisi client
    const customToken = await admin.auth().createCustomToken(user.uid);

    res.status(200).json({
      token: customToken,
      uid: user.uid,
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(400).json({error: error.message});
  }
});

// Endpoint: Register
app.post("/register", async (req, res) => {
  const {email, password, role} = req.body;

  if (!email || !password || !role) {
    return res.status(400).json({error: "Semua data harus disediakan"});
  }

  try {
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
    });

    await admin.auth().setCustomUserClaims(userRecord.uid, {role: role});
    res.status(201).json({uid: userRecord.uid});
  } catch (error) {
    console.error("Register error:", error);
    res.status(400).json({error: error.message});
  }
});

// Ekspor API sebagai Firebase Function
exports.api = functions.https.onRequest(app);
