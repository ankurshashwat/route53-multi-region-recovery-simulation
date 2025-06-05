const express = require("express");
const mysql = require("mysql2");
const dotenv = require("dotenv");
const path = require("path");

dotenv.config();

const app = express();
const port = 80;

const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

db.connect((err) => {
  if (err) {
    throw new Error(`Failed to connect to database: ${err.message}`);
  }
  db.query(
    `
        CREATE TABLE IF NOT EXISTS comments (
            id INT AUTO_INCREMENT PRIMARY KEY,
            text VARCHAR(255) NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `,
    (err) => {
      if (err) {
        throw new Error(`Failed to create comments table: ${err.message}`);
      }
      console.log("Comments table ready");
    }
  );
});

// Middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

// Routes
app.get("/", (req, res) => {
  res.render("index", { region: "us-east-1" });
});

app.get("/comments", (req, res) => {
  db.query("SELECT * FROM comments ORDER BY timestamp DESC", (err, results) => {
    if (err) {
      return res
        .status(500)
        .json({ error: `Failed to fetch comments: ${err.message}` });
    }
    res.json(results);
  });
});

app.post("/comments", (req, res) => {
  const { comment } = req.body;
  if (!comment) {
    return res
      .status(400)
      .json({ error: "Comment text is required in the request body." });
  }
  db.query("INSERT INTO comments (text) VALUES (?)", [comment], (err) => {
    if (err) {
      return res
        .status(500)
        .json({ error: `Failed to insert comment: ${err.message}` });
    }
    res.status(201).json({ message: "Comment added successfully." });
  });
});

app.get("/health", (req, res) => {
  db.ping((err) => {
    if (err) {
      return res
        .status(500)
        .send(`Database health check failed: ${err.message}`);
    }
    res.status(200).send("Database connection OK.");
  });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
