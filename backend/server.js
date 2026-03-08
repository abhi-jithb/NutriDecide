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
        },
        {
            name: 'Idli',
            nutrients: { sugars_100g: 0.3, sodium_100g: 0.1, protein_100g: 6.0, carbs_100g: 30.0 },
            ingredients: ['rice', 'urad dal', 'salt'],
            categories: ['south_indian_breakfast', 'steamed_food', 'low_fat'],
            imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?q=80&w=300&auto=format&fit=crop'
        },
        {
            name: 'Vada (Medu Vada)',
            nutrients: { sugars_100g: 0.2, sodium_100g: 0.5, protein_100g: 10.0, carbs_100g: 25.0 },
            ingredients: ['urad dal', 'oil', 'spices', 'salt'],
            categories: ['south_indian_breakfast', 'fried_food'],
            imageUrl: 'https://images.unsplash.com/photo-1606491956689-2ea866880c84?q=80&w=300&auto=format&fit=crop'
        },
        {
            name: 'Sambar',
            nutrients: { sugars_100g: 2.5, sodium_100g: 0.6, protein_100g: 5.0, carbs_100g: 12.0 },
            ingredients: ['pigeon peas', 'vegetables', 'tamarind', 'sambar spice', 'salt'],
            categories: ['kerala_side', 'lentil_soup'],
            imageUrl: 'https://images.unsplash.com/photo-1545247181-516773cae754?q=80&w=300&auto=format&fit=crop'
        },
        {
            name: 'Fish Curry (Kerala Style)',
            nutrients: { sugars_100g: 1.0, sodium_100g: 0.7, protein_100g: 18.0, carbs_100g: 5.0 },
            ingredients: ['fish', 'coconut', 'chili', 'turmeric', 'tamarind', 'salt', 'coconut oil'],
            categories: ['kerala_main', 'high_protein', 'healthy_fats'],
            imageUrl: 'https://images.unsplash.com/photo-1626509653297-fc65dc8254b0?q=80&w=300&auto=format&fit=crop'
        },
        {
            name: 'Chicken Curry (Nadan)',
            nutrients: { sugars_100g: 1.5, sodium_100g: 0.8, protein_100g: 22.0, carbs_100g: 6.0 },
            ingredients: ['chicken', 'onion', 'ginger', 'garlic', 'coconut milk', 'spices', 'salt'],
            categories: ['kerala_main', 'high_protein'],
            imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b0ae398?q=80&w=300&auto=format&fit=crop'
        },
        {
            name: 'Beef Fry (Kerala Style)',
            nutrients: { sugars_100g: 0.5, sodium_100g: 0.9, protein_100g: 26.0, carbs_100g: 4.0 },
            ingredients: ['beef', 'coconut pieces', 'spices', 'salt', 'coconut oil'],
            categories: ['kerala_side', 'high_protein', 'high_sodium'],
            imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?q=80&w=300&auto=format&fit=crop'
        },
        {
            name: 'Vegetable Stew',
            nutrients: { sugars_100g: 2.0, sodium_100g: 0.4, protein_100g: 3.5, carbs_100g: 15.0 },
            ingredients: ['potato', 'carrot', 'beans', 'coconut milk', 'spices', 'salt'],
            categories: ['kerala_side', 'plant_based'],
            imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?q=80&w=300&auto=format&fit=crop'
        },
        {
            name: 'Upma',
            nutrients: { sugars_100g: 1.5, sodium_100g: 0.5, protein_100g: 5.0, carbs_100g: 35.0 },
            ingredients: ['semolina/rava', 'onion', 'ginger', 'curry leaves', 'oil', 'salt'],
            categories: ['south_indian_breakfast', 'healthy'],
            imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?q=80&w=300&auto=format&fit=crop'
        },
        {
            name: 'Kerala Egg Roast',
            nutrients: { sugars_100g: 2.5, sodium_100g: 0.7, protein_100g: 14.0, carbs_100g: 8.0 },
            ingredients: ['eggs', 'onion', 'tomato', 'spices', 'salt'],
            categories: ['kerala_side', 'high_protein'],
            imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?q=80&w=300&auto=format&fit=crop'
        }
    ];

    for (const food of initialFoods) {
        const exists = await RegionalFood.findOne({ name: food.name });
        if (!exists) {
            await new RegionalFood(food).save();
            console.log(`✅ Seeded: ${food.name}`);
        }
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

// Search regional food items
app.get('/api/search', async (req, res) => {
    const query = req.query.q;
    if (!query) return res.json([]);
    const words = query.split(' ').filter(w => w.length > 2);
    
    try {
        // Try exact match/phrase first, then fallback to word-based search
        const results = await RegionalFood.find({
            $or: [
                { name: { $regex: query, $options: 'i' } },
                { name: { $regex: words.join('|'), $options: 'i' } }
            ]
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
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🥗 NutriDecide backend running on port ${PORT}`);
    console.log(`🔗 Reachable at http://192.168.29.159:${PORT}`);
});
