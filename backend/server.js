const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const Product = require('./models/Product');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/nutridecide';

// ---- Database Connection ----
mongoose.connect(MONGO_URI)
  .then(() => console.log('✅ Connected to MongoDB Atlas'))
  .catch((err) => console.error('❌ MongoDB Connection Error:', err));

// ---- Health Endpoint ----
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'NutriDecide API is running smoothly.' });
});

// ---- Products API (Placeholder for Future Scaling) ----
// In the future, this backend will act as the master sync source alongside Firebase.

// Search for regional foods using text indices
app.get('/api/products/search', async (req, res) => {
  try {
    const { query } = req.query;
    if (!query) return res.status(400).json({ error: 'Search query required' });

    const products = await Product.find(
      { $text: { $search: query, $caseSensitive: false } },
      { score: { $meta: "textScore" } } 
    ).sort({ score: { $meta: "textScore" } });

    res.json(products);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Sync approved products from Firebase global_products
app.post('/api/products/sync', async (req, res) => {
  try {
    const { barcode, productName, sugar, category, ingredients, approvedBy } = req.body;
    
    // Upsert the product into MongoDB to ensure global scaling
    const product = await Product.findOneAndUpdate(
      { barcode },
      { productName, sugar, category, ingredients, status: 'approved', approvedBy },
      { new: true, upsert: true }
    );

    res.status(201).json({ message: 'Product synched safely to MongoDB', product });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 NutriDecide Backend Server running on port ${PORT}`);
  console.log(`ℹ️ Note: This infrastructure is designed to extend Firebase limitations when scaling regional foods.`);
});
