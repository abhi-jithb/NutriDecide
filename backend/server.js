/**
 * 🍃 NutriDecide Backend (Mock Structure)
 * This is a starting point for a Node.js/Express server that integrates with MongoDB.
 */

require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI)
    .then(() => {
        console.log('✅ Connected to MongoDB');
        seedData();
    })
    .catch(err => console.error('❌ MongoDB Connection Error:', err));

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

// 🌿 Seed Data Function
async function seedData() {
    const count = await RegionalFood.countDocuments();
    if (count === 0) {
        console.log('🌱 Seeding initial regional food data...');
        const initialFoods = [
            {
                name: 'Puttu (Steamed Rice Cake)',
                nutrients: { sugars_100g: 0.5, sodium_100g: 0.1, protein_100g: 8.0, carbs_100g: 45.0 },
                ingredients: ['rice flour', 'grated coconut', 'water', 'salt'],
                categories: ['kerala_breakfast', 'steamed_food'],
                imageUrl: 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?q=80&w=300&auto=format&fit=crop'
            },
            {
                name: 'Appam',
                nutrients: { sugars_100g: 1.2, sodium_100g: 0.15, protein_100g: 4.0, carbs_100g: 38.0 },
                ingredients: ['rice', 'coconut milk', 'yeast', 'sugar', 'salt'],
                categories: ['kerala_breakfast', 'fermented_food'],
                imageUrl: 'https://images.unsplash.com/photo-1630406144797-021c1801038f?q=80&w=300&auto=format&fit=crop'
            },
            {
                name: 'Malabar Parotta',
                nutrients: { sugars_100g: 2.0, sodium_100g: 0.8, protein_100g: 7.0, carbs_100g: 55.0 },
                ingredients: ['maida (refined flour)', 'oil', 'water', 'salt', 'sugar'],
                categories: ['kerala_bread', 'high_carb'],
                imageUrl: 'https://images.unsplash.com/photo-1632742051515-585a2665dd35?q=80&w=300&auto=format&fit=crop'
            }
        ];
        await RegionalFood.insertMany(initialFoods);
        console.log('✅ Seeded regional food data');
    }
}

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
