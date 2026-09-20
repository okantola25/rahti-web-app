const express = require("express");
const mysql = require("mysql2/promise");

const app = express();
const port = 8000;

app.get("/api", async (req, res) => {
    try {
        const db = await mysql.createConnection({
            host: process.env.DB_HOST || "db",
            user: process.env.DB_USER || "appuser",
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME || "appdb"
        });

        // Create a table if it does not already exist
        await db.execute(`
            CREATE TABLE IF NOT EXISTS visits (
                id INT AUTO_INCREMENT PRIMARY KEY,
                message VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);

        // Write data to the database
        await db.execute(
            "INSERT INTO visits (message) VALUES (?)",
            ["Frontend visited the backend"]
        );

        // Read data from the database
        const [rows] = await db.execute(`
            SELECT id, message, created_at
            FROM visits
            ORDER BY id DESC
            LIMIT 1
        `);

        const [countRows] = await db.execute(
            "SELECT COUNT(*) AS visit_count FROM visits"
        );

        await db.end();

        res.json({
            message: "Backend is working",
            database_write: rows[0].message,
            database_time: rows[0].created_at,
            visit_count: countRows[0].visit_count
        });

    } catch (error) {
        console.error(error);

        res.status(500).json({
            error: "Database operation failed"
        });
    }
});

app.listen(port, "0.0.0.0", () => {
    console.log(`Backend listening on port ${port}`);
});