const express = require("express");
const multer = require("multer");
import fetch from "node-fetch";
require("dotenv").config();  // Load .env file

const apiKey = process.env.STORJ_API_KEY;


const app = express();
const upload = multer({ dest: "uploads/" });

app.post("/upload", upload.single("file"), async (req, res) => {
    const storjApiUrl = "https://your-storj-api-url";
    const apiKey = "15XZisrJz2Ynj16mxeAgEaSbQ5Kvic6kcG2BiYKZYjGx6kHfJ9AP7NuqE1tmvibPmYfAXaUHUbZdrU55d5w5xPB9va1URJoEvcLJoPMG2mBQtFJe8DLVYfH3F7883uFPMW1F7w2Kw";

    const formData = new FormData();
    formData.append("file", req.file.buffer, req.file.originalname);

    try {
        const response = await fetch(storjApiUrl, {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${apiKey}`
            },
            body: formData
        });

        const result = await response.json();
        res.json(result);

    } catch (error) {
        console.error("Error uploading to Storj:", error);
        res.status(500).json({ error: "Upload failed" });
    }
});

app.listen(3000, () => console.log("Server running on port 3000"));
