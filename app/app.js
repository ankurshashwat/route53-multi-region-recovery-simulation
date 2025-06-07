const express = require("express");
const mysql = require("mysql2/promise");
const dotenv = require("dotenv");
const path = require("path");

dotenv.config();
const app = express();
const port = process.env.PORT || 80;

let db;

async function initDatabase() {
  try {
    db = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });
    console.log("Connected to database");

    await db.execute(`
      CREATE TABLE IF NOT EXISTS comments (
        id INT AUTO_INCREMENT PRIMARY KEY,
        text VARCHAR(255) NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log("Comments table ready");
  } catch (err) {
    console.error(`Database initialization failed: ${err.message}`);
    process.exit(1); 
  }
}

initDatabase();

// Middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

// Routes
app.get("/", (req, res) => {
  res.render("index", { region: process.env.REGION || "us-east-1" });
});

app.get("/comments", async (req, res) => {
  try {
    const [results] = await db.query(
      "SELECT * FROM comments ORDER BY timestamp DESC"
    );
    res.json(results);
  } catch (err) {
    console.error(`Failed to fetch comments: ${err.message}`);
    res.status(500).json({ error: "Failed to fetch comments" });
  }
});

app.post("/comments", async (req, res) => {
  const { comment } = req.body;
  if (!comment) {
    return res.status(400).json({ error: "Comment text is required" });
  }
  try {
    await db.query("INSERT INTO comments (text) VALUES (?)", [comment]);
    res.status(201).json({ message: "Comment added successfully" });
  } catch (err) {
    console.error(`Failed to insert comment: ${err.message}`);
    res.status(500).json({ error: "Failed to insert comment" });
  }
});

app.get("/health", async (req, res) => {
  try {
    await db.query("SELECT 1");
    res.status(200).send("Database connection OK");
  } catch (err) {
    console.error(`Health check failed: ${err.message}`);
    res.status(500).send("Database health check failed");
  }
});

app.listen(port, (err) => {
  if (err) {
    console.error(`Failed to start server on port ${port}: ${err.message}`);
    process.exit(1);
  }
  console.log(`Server running on port ${port}`);
});