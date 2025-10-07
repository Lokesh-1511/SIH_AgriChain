const mongoose = require('mongoose');

const qualityMetricsSchema = new mongoose.Schema({}, { strict: false, _id: false });

const batchSchema = new mongoose.Schema({
  batchCode: { type: String, required: true, unique: true },
  farmerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  productName: { type: String, required: true },
  quantity: { type: Number, required: true },
  unit: { type: String, required: true },
  basePrice: { type: Number, required: true },
  currentPrice: { type: Number },
  status: { type: String, default: 'pending' },
  imageUrl: { type: String },
  qualityMetrics: qualityMetricsSchema,
  distributorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  retailerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  harvestedAt: { type: Date },
  deliveredAt: { type: Date }
}, {
  timestamps: true
});

batchSchema.index({ status: 1, createdAt: -1 });
batchSchema.index({ farmerId: 1 });

batchSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    // Add snake_case aliases expected by Flutter Batch.fromJson
    ret.farmer_id = ret.farmerId?.toString();
    ret.product_name = ret.productName;
    ret.base_price = ret.basePrice;
    ret.current_price = ret.currentPrice;
    ret.created_at = ret.createdAt;
    ret.harvested_at = ret.harvestedAt;
    ret.image_url = ret.imageUrl;
    ret.quality_metrics = ret.qualityMetrics;
    ret.distributor_id = ret.distributorId?.toString();
    ret.retailer_id = ret.retailerId?.toString();
    ret.delivered_at = ret.deliveredAt;
    return ret;
  }
});

module.exports = mongoose.model('Batch', batchSchema);
