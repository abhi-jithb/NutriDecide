const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  barcode: {
    type: String,
    required: true,
    unique: true,
  },
  productName: {
    type: String,
    required: true,
  },
  sugar: {
    type: Number,
    required: true,
  },
  calories: {
    type: Number,
  },
  category: {
    type: String,
  },
  ingredients: {
    type: [String],
    default: [],
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected'],
    default: 'pending'
  },
  approvedBy: {
    type: String, // Admin UID
  }
}, { timestamps: true });

// Built-in text index for fuzzy regional food search
productSchema.index({ productName: 'text', category: 'text', ingredients: 'text' });

module.exports = mongoose.model('Product', productSchema);
