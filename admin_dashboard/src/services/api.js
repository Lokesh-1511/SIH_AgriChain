// Generic API client wrapper for the admin backend
// Automatically attaches Firebase ID token (if authenticated) and handles JSON parsing

// Accept either new VITE_API_BASE_URL or legacy VITE_BACKEND_API_URL for compatibility
const BASE_URL = import.meta.env.VITE_API_BASE_URL || import.meta.env.VITE_BACKEND_API_URL || 'http://localhost:5000/api';

function buildUrl(path, query) {
  let url = path.startsWith('http') ? path : `${BASE_URL}${path.startsWith('/') ? path : '/' + path}`;
  if (query && Object.keys(query).length) {
    const usp = new URLSearchParams();
    Object.entries(query).forEach(([k, v]) => {
      if (v !== undefined && v !== null) usp.append(k, String(v));
    });
    url += `?${usp.toString()}`;
  }
  return url;
}

async function request(method, path, { body, query, headers } = {}) {
  const backendToken = localStorage.getItem('admin_backend_jwt');

  const finalHeaders = {
    'Content-Type': 'application/json',
  ...(backendToken ? { Authorization: `Bearer ${backendToken}` } : {}),
    ...headers
  };

  const res = await fetch(buildUrl(path, query), {
    method,
    headers: finalHeaders,
    body: body ? JSON.stringify(body) : undefined
  });

  let data;
  const text = await res.text();
  try { data = text ? JSON.parse(text) : null; } catch { data = text; }

  if (!res.ok) {
    const err = new Error(data?.message || `Request failed: ${res.status}`);
    err.status = res.status;
    err.data = data;
    throw err;
  }
  return data;
}

export const api = {
  get: (path, opts) => request('GET', path, opts),
  post: (path, opts) => request('POST', path, opts),
  put: (path, opts) => request('PUT', path, opts),
  patch: (path, opts) => request('PATCH', path, opts),
  delete: (path, opts) => request('DELETE', path, opts)
};

// Convenience domain-specific calls (expand as needed)
export const healthApi = {
  get: () => api.get('/health')
};

export const adminAuthApi = {
  login: (email, password) => api.post('/admin/auth/login', { body: { email, password } }),
  me: () => api.get('/admin/auth/me')
};

export const batchesApi = {
  list: (params) => api.get('/admin/batches', { query: params }),
  stats: () => api.get('/admin/batches/stats'),
  get: (id) => api.get(`/admin/batches/${id}`),
  transactions: (id) => api.get(`/admin/batches/${id}/transactions`)
};

export const transactionsApi = {
  list: (params) => api.get('/admin/transactions', { query: params }),
  stats: () => api.get('/admin/transactions/stats')
};

export const dashboardApi = {
  overview: () => api.get('/admin/dashboard/overview'),
  activity: () => api.get('/admin/dashboard/activity')
};

export const analyticsApi = {
  overview: () => api.get('/admin/analytics/overview'),
  trends: () => api.get('/admin/analytics/trends')
};

export default api;
