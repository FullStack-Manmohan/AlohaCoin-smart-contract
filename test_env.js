const fs = require('fs');
const path = require('path');
const envPath = path.resolve(__dirname, '.env');

console.log("Checking .env at:", envPath);
if (fs.existsSync(envPath)) {
    console.log(".env exists!");
    const content = fs.readFileSync(envPath, 'utf8');
    console.log("Content length:", content.length);
    console.log("First line:", content.split('\n')[0]);
} else {
    console.log(".env does NOT exist!");
    const files = fs.readdirSync(__dirname);
    console.log("Files in dir:", files);
}

require('dotenv').config();
console.log("PRIVATE_KEY length:", process.env.PRIVATE_KEY ? process.env.PRIVATE_KEY.length : "undefined");
