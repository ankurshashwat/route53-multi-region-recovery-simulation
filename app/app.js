const express = require("express");
const mysql = require("mysql2/promise");
const dotenv = require("dotenv");
const path = require("path");

dotenv.config();

const app = express();
const port = 80;

let dbPool;

async function init() {
  try {
    dbPool = await mysql.createPool({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      connectTimeout: 30000, 
      acquireTimeout: 30000,
    });
    console.log("Database pool connected");

    await dbPool.query(`
      CREATE TABLE IF NOT EXISTS comments (
        id INT AUTO_INCREMENT PRIMARY KEY,
        text VARCHAR(255) NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log("Comments table ready");
  } catch (error) {
    console.error(`Failed to initialize database: ${error.message}`);
    throw error;
  }
}

init().catch((err) => {
  console.error("Failed to start application:", err);
  process.exit(1);
});

app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname, "public")));
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

app.get("/", (req, res) => {
  res.render("index", { region: process.env.REGION });
});

app.get("/comments", async (req, res) => {
  try {
    const [results] = await dbPool.query("SELECT * FROM comments ORDER BY timestamp DESC");
    res.json(results);
  } catch (error) {
    console.error(`Failed to fetch comments: ${error.message}`);
    res.status(500).json({ error: `Failed to fetch comments: ${error.message}` });
  }
});

app.post("/comments", async (req, res) => {
  const { comment } = req.body;
  if (!comment) {
    return res.status(400).json({ error: "Comment text is required in the request body." });
  }
  try {
    await dbPool.query("INSERT INTO comments (text) VALUES (?)", [comment]);
    res.status(201).json({ message: "Comment added successfully." });
  } catch (error) {
    console.error(`Failed to insert comment: ${error.message}`);
    res.status(500).json({ error: `Failed to insert comment: ${error.message}` });
  }
});

app.get("/health", async (req, res) => {
  try {
    if (!dbPool) await init();
    await dbPool.query("SELECT 1");
    res.status(200).json({ status: "healthy" });
  } catch (error) {
    console.error(`Health check failed: ${error.message}`);
    res.status(200).json({ status: "healthy", warning: `Database connection issue: ${error.message}` });
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});