// Placeholder service for future IVR logic (fetching prompts, prices, etc.)
export async function fetchCropPrices(code) {
  // Replace with real API call later
  return Promise.resolve({
    code,
    items: [
      { name: 'Wheat', price: 2145 },
      { name: 'Maize', price: 1880 }
    ]
  });
}
