const mongoose = require('mongoose');

const actorSchema = new mongoose.Schema({
  id: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  role: { type: String },
  email: { type: String },
  name: { type: String }
}, { _id: false });

const targetSchema = new mongoose.Schema({
  id: { type: mongoose.Schema.Types.ObjectId },
  type: { type: String },
  name: { type: String }
}, { _id: false });

const auditLogSchema = new mongoose.Schema({
  action: { type: String, required: true },
  status: { type: String, enum: ['success', 'failure'], default: 'success' },
  message: { type: String },
  actor: actorSchema,
  target: targetSchema,
  metadata: { type: mongoose.Schema.Types.Mixed },
  ip: { type: String },
  userAgent: { type: String },
  correlationId: { type: String }
}, {
  timestamps: { createdAt: 'timestamp', updatedAt: false }
});

auditLogSchema.index({ action: 1, timestamp: -1 });
auditLogSchema.index({ 'actor.id': 1, timestamp: -1 });
auditLogSchema.index({ correlationId: 1 });

auditLogSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id;
    delete ret._id;
    delete ret.__v;
    return ret;
  }
});

module.exports = mongoose.model('AuditLog', auditLogSchema);
