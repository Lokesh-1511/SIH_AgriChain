// Simple in-memory offline action queue
// API: enqueue(action), drain() -> actions[], size()

class OfflineQueue {
  constructor() {
    this._q = [];
  }
  enqueue(action) {
    this._q.push(action);
  }
  drain() {
    const d = this._q.slice();
    this._q = [];
    return d;
  }
  size() { return this._q.length; }
}

const offlineQueue = new OfflineQueue();
export default offlineQueue;