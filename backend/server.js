/**
 * 🍃 NutriDecide Backend (Mock Structure)
 * This is a starting point for a Node.js/Express server that integrates with MongoDB.
 */

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// 🌿 MongoDB Schema for Regional Food
const foodSchema = new mongoose.Schema({
    name: { type: String, required: true },
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

// 🌿 Simple API Endpoints
// Fetch all regional food items
app.get('/api/regional-food', async (req, res) => {
    try {
        const foods = await RegionalFood.find();
        res.json(foods);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Search regional food items (MongoDB Atlas Search ready)
app.get('/api/search', async (req, res) => {
    const query = req.query.q;
    try {
        const results = await RegionalFood.find({
            name: { $regex: query, $options: 'i' }
        });
        res.json(results);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Add a family member (Family Sharing Pillar)
const userSchema = new mongoose.Schema({
    userId: String,
    email: String,
    familyMembers: [{
        name: String,
        role: String, // 'child' | 'parent' | 'senior'
        conditions: [String],
        allergies: [String]
    }]
});

const User = mongoose.model('User', userSchema);

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`🥗 NutriDecide backend running on port ${PORT}`);
    console.log(`🔗 MongoDB Atlas integration ready!`);
});
