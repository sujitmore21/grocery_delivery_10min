import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');

// Test configuration
export const options = {
  stages: [
    { duration: '30s', target: 10 },  // Ramp up to 10 users
    { duration: '1m', target: 10 },   // Stay at 10 users
    { duration: '30s', target: 20 },  // Ramp up to 20 users
    { duration: '1m', target: 20 },   // Stay at 20 users
    { duration: '30s', target: 0 },   // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests should be below 500ms
    http_req_failed: ['rate<0.1'],    // Error rate should be less than 10%
    errors: ['rate<0.1'],             // Custom error rate
  },
};

// Base URL - update this to match your API
const BASE_URL = __ENV.BASE_URL || 'https://api.tenminutedelivery.com';

// Test data
const testUsers = [
  { email: 'test1@example.com', password: 'password123' },
  { email: 'test2@example.com', password: 'password123' },
  { email: 'test3@example.com', password: 'password123' },
];

const searchQueries = ['milk', 'bread', 'eggs', 'chicken', 'rice', 'pasta', 'vegetables', 'fruits'];
const categories = ['1', '2', '3', '4', '5'];

// Helper function to get random item from array
function getRandomItem(array) {
  return array[Math.floor(Math.random() * array.length)];
}

// Helper function to generate random string
function randomString(length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

// Authentication helper
function login(email, password) {
  const response = http.post(`${BASE_URL}/api/auth/login`, JSON.stringify({
    email: email,
    password: password,
  }), {
    headers: { 'Content-Type': 'application/json' },
  });

  const success = check(response, {
    'login status is 200': (r) => r.status === 200,
    'login has token': (r) => {
      const body = JSON.parse(r.body);
      return body.data?.token || body.token;
    },
  });

  if (!success) {
    errorRate.add(1);
    return null;
  }

  const body = JSON.parse(response.body);
  return body.data?.token || body.token || null;
}

// Main test function
export default function () {
  // 1. Browse categories (most common action)
  const categoriesResponse = http.get(`${BASE_URL}/api/categories`);
  const categoriesSuccess = check(categoriesResponse, {
    'categories status is 200': (r) => r.status === 200,
    'categories has data': (r) => {
      const body = JSON.parse(r.body);
      return body.data && Array.isArray(body.data);
    },
  });
  if (!categoriesSuccess) errorRate.add(1);
  sleep(1);

  // 2. Get products (with random category filter)
  const categoryId = getRandomItem(categories);
  const productsResponse = http.get(`${BASE_URL}/api/products`, {
    params: { category_id: categoryId },
  });
  const productsSuccess = check(productsResponse, {
    'products status is 200': (r) => r.status === 200,
    'products has data': (r) => {
      const body = JSON.parse(r.body);
      return body.data && Array.isArray(body.data);
    },
  });
  if (!productsSuccess) errorRate.add(1);
  sleep(1);

  // 3. Get product details (if products exist)
  let productId = null;
  try {
    const productsBody = JSON.parse(productsResponse.body);
    const products = productsBody.data || productsBody;
    if (Array.isArray(products) && products.length > 0) {
      productId = products[0].id;
    }
  } catch (e) {
    // Ignore parsing errors
  }

  if (productId) {
    const productDetailResponse = http.get(`${BASE_URL}/api/products/${productId}`);
    const productDetailSuccess = check(productDetailResponse, {
      'product detail status is 200': (r) => r.status === 200,
      'product detail has data': (r) => {
        const body = JSON.parse(r.body);
        return body.data || body.id;
      },
    });
    if (!productDetailSuccess) errorRate.add(1);
    sleep(1);
  }

  // 4. Search products (common user action)
  const searchQuery = getRandomItem(searchQueries);
  const searchResponse = http.get(`${BASE_URL}/api/search`, {
    params: { q: searchQuery },
  });
  const searchSuccess = check(searchResponse, {
    'search status is 200': (r) => r.status === 200,
    'search has data': (r) => {
      const body = JSON.parse(r.body);
      return body.data && Array.isArray(body.data);
    },
  });
  if (!searchSuccess) errorRate.add(1);
  sleep(1);

  // 5. Get best sellers
  const bestSellersResponse = http.get(`${BASE_URL}/api/products`, {
    params: { best_seller: true },
  });
  const bestSellersSuccess = check(bestSellersResponse, {
    'best sellers status is 200': (r) => r.status === 200,
    'best sellers has data': (r) => {
      const body = JSON.parse(r.body);
      return body.data && Array.isArray(body.data);
    },
  });
  if (!bestSellersSuccess) errorRate.add(1);
  sleep(1);

  // 6. Authenticated user flow (30% of users)
  if (Math.random() < 0.3) {
    const testUser = getRandomItem(testUsers);
    const token = login(testUser.email, testUser.password);

    if (token) {
      const headers = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      };

      // Get cart
      const cartResponse = http.get(`${BASE_URL}/api/cart`, { headers });
      check(cartResponse, {
        'cart status is 200 or 404': (r) => r.status === 200 || r.status === 404,
      });
      sleep(1);

      // Get orders
      const ordersResponse = http.get(`${BASE_URL}/api/orders`, { headers });
      check(ordersResponse, {
        'orders status is 200': (r) => r.status === 200,
      });
      sleep(1);

      // Get addresses
      const addressesResponse = http.get(`${BASE_URL}/api/addresses`, { headers });
      check(addressesResponse, {
        'addresses status is 200 or 404': (r) => r.status === 200 || r.status === 404,
      });
      sleep(1);
    }
  }

  // 7. Signup (10% of users)
  if (Math.random() < 0.1) {
    const randomEmail = `test_${randomString(8)}@example.com`;
    const signupResponse = http.post(`${BASE_URL}/api/auth/signup`, JSON.stringify({
      name: `Test User ${randomString(5)}`,
      email: randomEmail,
      password: 'password123',
      phone: `+1234567890${Math.floor(Math.random() * 1000)}`,
    }), {
      headers: { 'Content-Type': 'application/json' },
    });
    check(signupResponse, {
      'signup status is 200 or 201': (r) => r.status === 200 || r.status === 201,
    });
    sleep(1);
  }
}

// Setup function to run before the test
export function setup() {
  // Optional: Pre-authenticate a test user or set up test data
  console.log(`Starting load test against: ${BASE_URL}`);
  return {};
}

// Teardown function to run after the test
export function teardown(data) {
  console.log('Load test completed');
}

