const express = require("express");
const mysql = require("mysql2/promise");

const app = express();
const port = 8000;

app.get("/api", async (req, res) => {
    try {
        const db = await mysql.createConnection({
            host: process.env.DB_HOST || "db",
            user: process.env.DB_USER || "appuser",
            password: process.env.DB_PASSWORD || "apppassword",
            database: process.env.DB_NAME || "appdb"
        });

        const [rows] = await db.execute("SELECT NOW() AS current_time");

        await db.end();

        res.json({
            message: "Backend is working",
            database_time: rows[0].current_time
        });

    } catch (error) {
        console.error(error);

        res.status(500).json({
            error: "Could not connect to database"
        });
    }
});

app.listen(port, "0.0.0.0", () => {
    console.log(`Backend listening on port ${port}`);
});