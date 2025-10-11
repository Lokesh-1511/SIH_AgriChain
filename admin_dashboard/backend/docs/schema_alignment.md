# Schema Alignment (Flutter <-> Node Backend)

This document captures the mapping decisions made to keep the Flutter (Dart) data models in sync with the Node/Mongoose backend without changing existing Flutter code.

## 1. User (AgriChainUser)

Flutter model fields:
- id (Mongo ObjectId)
- firebaseUid (string)
- name, email, phone, role, address
- isVerified (bool)
- createdAt, updatedAt (ISO8601 strings)
- kycDetails (Map<String,dynamic>)
- additionalInfo (optional)

Backend adjustments:
- Added `firebaseUid` (indexed)
- Added `kycDetails` field (Mixed)
- Added `isActive` (boolean) to mirror Flutter createUser default
- Ensured `address` defaults to empty string to match non-null assumption in Flutter
- `toJSON` now preserves: id, firebaseUid, kycDetails, isActive, createdAt, updatedAt

No removal of existing profile sub-schemas; these are additive beyond the Flutter core contract.

## 2. Batch

Flutter expects snake_case keys (see `batch_model.dart`):
- farmer_id, product_name, base_price, current_price, created_at, harvested_at, image_url, quality_metrics, distributor_id, retailer_id, delivered_at

Backend action:
- Retained camelCase persisted fields in Mongo.
- Added snake_case aliases in `toJSON` transform so responses satisfy Flutter parser without modifying mobile code.

## 3. Transaction

Flutter expects snake_case keys in `Transaction.fromJson`:
- batch_id, from_user_id, to_user_id, transaction_type, amount, status, timestamp, blockchain_hash, metadata

Backend action:
- Added snake_case alias properties in `toJSON` including `timestamp` (maps to `occurredAt` or fallback `createdAt`).

## 4. Additional Collections (Planned)
- DeliveryTracking / TrackingPoint: Not yet implemented in backend. Will mirror Flutter with snake_case aliases the same way when added.

## 5. Conventions
- Internal persistence: camelCase (Mongoose default) for clarity in code.
- API surface (JSON to Flutter): snake_case aliasing for any fields Flutter already consumes.
- Timestamps: Rely on Mongoose `timestamps` (createdAt, updatedAt). Aliases added only where Flutter expects different naming (e.g., created_at for Batch).
- Mixed / dynamic fields: Use `mongoose.Schema.Types.Mixed` (kycDetails, qualityMetrics, metadata) permitting flexible structure.

## 6. Non-breaking Strategy
- All changes are additive—no removal or renaming at the persistence layer.
- Mobile code remains untouched; backend adapts serialization layer.

## 7. Future Tasks
- Introduce Delivery/Tracking schemas with geospatial indexes; maintain the same aliasing approach.
- Standardize audit/log objects if Flutter starts consuming them.
- Optionally introduce versioning in responses (header) once schemas evolve further.

---
Generated on: 2025-10-07
