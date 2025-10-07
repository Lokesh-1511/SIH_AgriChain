const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  transactionCode: { type: String, required: true, unique: true },
  batchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Batch', required: true },
  fromUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  toUserId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  transactionType: { type: String, required: true },
  amount: { type: Number },
  status: { type: String, default: 'pending' },
  blockchainHash: { type: String },
  metadata: { type: mongoose.Schema.Types.Mixed },
  occurredAt: { type: Date, default: Date.now }
}, {
  timestamps: true
});

transactionSchema.index({ batchId: 1, occurredAt: -1 });
transactionSchema.index({ transactionType: 1 });

transactionSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    // Snake_case aliases for Flutter Transaction.fromJson
    ret.batch_id = ret.batchId?.toString();
    ret.from_user_id = ret.fromUserId?.toString();
    ret.to_user_id = ret.toUserId?.toString();
    ret.transaction_type = ret.transactionType;
    ret.blockchain_hash = ret.blockchainHash;
    ret.timestamp = ret.occurredAt || ret.createdAt;
    return ret;
  }
});

module.exports = mongoose.model('Transaction', transactionSchema);
