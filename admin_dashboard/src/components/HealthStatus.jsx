import React, { useEffect, useState } from 'react';
import { healthApi } from '../services/api';

// Simple badge showing backend health
export default function HealthStatus({ intervalMs = 15000 }) {
  const [status, setStatus] = useState('checking');
  const [latency, setLatency] = useState(null);
  const [error, setError] = useState(null);

  async function check() {
    const start = performance.now();
    try {
      const data = await healthApi.get();
      setLatency(Math.round(performance.now() - start));
      if (data?.status === 'success') {
        setStatus('up');
        setError(null);
      } else {
        setStatus('degraded');
      }
    } catch (e) {
      setLatency(null);
      setStatus('down');
      setError(e.message);
    }
  }

  useEffect(() => {
    check();
    const id = setInterval(check, intervalMs);
    return () => clearInterval(id);
  }, [intervalMs]);

  let color = '#999';
  if (status === 'up') color = '#16a34a';
  else if (status === 'down') color = '#dc2626';
  else if (status === 'degraded') color = '#d97706';

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12 }}>
      <span style={{ width: 10, height: 10, borderRadius: '50%', background: color, display: 'inline-block' }} />
      <span>{status}</span>
      {latency !== null && status === 'up' && <span style={{ color: '#666' }}>{latency}ms</span>}
      {error && status === 'down' && (
        <span
          style={{ maxWidth: 200, color: '#dc2626', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}
          title={error}
        >
          {error.includes('Failed to fetch') || error.includes('NetworkError') ? 'Connection refused' : error}
        </span>
      )}
    </div>
  );
}
