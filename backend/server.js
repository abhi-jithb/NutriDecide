/**
 * 🍃 NutriDecide Backend - Production Optimized
 * Senior Architect Implementation
 */

require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const winston = require('winston');

// 1. Specialized Logging (Winston)
const logger = winston.createLogger({
    level: 'info',
    format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
    ),
    transports: [
        new winston.transports.File({ filename: 'error.log', level: 'error' }),
        new winston.transports.File({ filename: 'combined.log' }),
    ],
});

if (process.env.NODE_ENV !== 'production') {
    logger.add(new winston.transports.Console({
        format: winston.format.simple(),
    }));
}

const app = express();

// 2. Security Middleware
app.use(helmet());
app.use(express.json({ limit: '10kb' })); // Limit body size
app.use(cors());

// 3. Rate Limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per window
    standardHeaders: true,
    legacyHeaders: false,
});
app.use('/api/', limiter);

// 4. In-memory Cache for Searches (Low TTL)
const cache = new Map();
const CACHE_TTL = 300000; // 5 minutes

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI)
    .then(() => {
        logger.info('✅ Connected to MongoDB');
        seedData();
    })
    .catch(err => logger.error('❌ MongoDB Connection Error:', err));

// 🌿 MongoDB Schema for Regional Food
const foodSchema = new mongoose.Schema({
    name: { type: String, required: true, index: true },
    nutrients: {
        sugars_100g: Number,
        sodium_100g: Number,
        protein_100g: Number,
        carbs_100g: Number
    },
    ingredients: [String],
    categories: [String],
    imageUrl: String,
    upvotes: { type: Number, default: 0 }
});

const RegionalFood = mongoose.model('RegionalFood', foodSchema);

// 5. Seed Data Implementation
async function seedData() {
    const initialFoods = [
        {
            name: 'Puttu (Steamed Rice Cake)',
            nutrients: { sugars_100g: 0.5, sodium_100g: 0.1, protein_100g: 8.0, carbs_100g: 45.0 },
            ingredients: ['rice flour', 'grated coconut', 'water', 'salt'],
            categories: ['kerala_breakfast', 'steamed_food'],
            imageUrl: 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?q=80&w=300&auto=format&fit=crop'
        },
        // ... (Keep existing seed data but use logger)
        {
            name: 'Malabar Parotta',
            nutrients: { sugars_100g: 2.0, sodium_100g: 0.8, protein_100g: 7.0, carbs_100g: 55.0 },
            ingredients: ['maida (refined flour)', 'oil', 'water', 'salt', 'sugar'],
            categories: ['kerala_bread', 'high_carb'],
            imageUrl: 'https://images.unsplash.com/photo-1632742051515-585a2665dd35?q=80&w=300&auto=format&fit=crop'
        },
        {
            name: 'Idli',
            nutrients: { sugars_100g: 0.3, sodium_100g: 0.1, protein_100g: 6.0, carbs_100g: 30.0 },
            ingredients: ['rice', 'urad dal', 'salt'],
            categories: ['south_indian_breakfast', 'steamed_food', 'low_fat'],
            imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?q=80&w=300&auto=format&fit=crop'
        }
    ];

    for (const food of initialFoods) {
        const exists = await RegionalFood.findOne({ name: food.name });
        if (!exists) {
            await new RegionalFood(food).save();
        }
    }
}

// 6. Optimized Endpoints
app.get('/api/regional-food', async (req, res) => {
    try {
        const foods = await RegionalFood.find().select('-__v');
        res.json(foods);
    } catch (err) {
        logger.error(`Error in /api/regional-food: ${err.message}`);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

app.get('/api/search', async (req, res) => {
    const { q: query } = req.query;
    if (!query) return res.json([]);

    // Check Cache
    if (cache.has(query)) {
        const entry = cache.get(query);
        if (Date.now() - entry.timestamp < CACHE_TTL) {
            return res.json(entry.data);
        }
    }

    try {
        const words = query.trim().split(/\s+/).filter(w => w.length > 2);
        const searchRegex = new RegExp(words.join('|'), 'i');
        
        const results = await RegionalFood.find({
            $or: [
                { name: { $regex: query, $options: 'i' } },
                { name: { $regex: searchRegex } }
            ]
        }).limit(20);

        // Update Cache
        cache.set(query, { data: results, timestamp: Date.now() });
        
        res.json(results);
    } catch (err) {
        logger.error(`Error in /api/search: ${err.message}`);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

// User & Family Member Routes (Placeholder for scalability)
const userSchema = new mongoose.Schema({
    userId: { type: String, required: true, unique: true },
    familyMembers: [{
        name: String,
        role: String,
        conditions: [String],
        allergies: [String]
    }]
});

const User = mongoose.model('User', userSchema);

// Global Error Handler
app.use((err, req, res, next) => {
    logger.error(`Critical Error: ${err.message}`);
    res.status(500).json({ error: 'Critical server error occurred' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
    logger.info(`🥗 NutriDecide backend running on port ${PORT}`);
});
