# Load Testing for Ten Minute Delivery API

This directory contains load testing scripts for the Ten Minute Delivery API using both **k6** and **Locust**.

## Overview

Both tools test the following API endpoints:
- `GET /api/categories` - Browse product categories
- `GET /api/products` - Browse products (with optional filters)
- `GET /api/products/:id` - View product details
- `GET /api/search?q=query` - Search products
- `GET /api/products?best_seller=true` - View best sellers
- `POST /api/auth/login` - User authentication
- `POST /api/auth/signup` - User registration
- `GET /api/cart` - View shopping cart (authenticated)
- `GET /api/orders` - View order history (authenticated)
- `GET /api/addresses` - View saved addresses (authenticated)
- `GET /api/delivery/tracking/:id` - Track delivery

## Prerequisites

### For k6:
```bash
# macOS
brew install k6

# Linux
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6

# Or download from https://k6.io/docs/getting-started/installation/
```

### For Locust:
```bash
pip install locust
```

## Configuration

Update the `BASE_URL` in the scripts to match your API endpoint:

**k6:**
```bash
export BASE_URL=https://api.tenminutedelivery.com
```

**Locust:**
```bash
# Pass via command line
locust -f locust_test.py --host=https://api.tenminutedelivery.com
```

## Running Tests

### k6

#### Basic Run
```bash
cd load_tests
k6 run k6_test.js
```

#### With Custom Base URL
```bash
BASE_URL=https://api.tenminutedelivery.com k6 run k6_test.js
```

#### Custom Virtual Users
```bash
# Edit the options in k6_test.js or use command line
k6 run --vus 50 --duration 5m k6_test.js
```

#### Custom Stages
```bash
k6 run --stage 30s:20 --stage 1m:50 --stage 30s:0 k6_test.js
```

#### Output Results to File
```bash
k6 run --out json=results.json k6_test.js
```

### Locust

#### Web UI Mode (Recommended)
```bash
cd load_tests
locust -f locust_test.py --host=https://api.tenminutedelivery.com
```

Then open http://localhost:8089 in your browser to:
- Set number of users
- Set spawn rate
- Start/stop tests
- View real-time statistics
- Download results as CSV

#### Headless Mode (CLI)
```bash
locust -f locust_test.py \
  --host=https://api.tenminutedelivery.com \
  --users 50 \
  --spawn-rate 5 \
  --run-time 5m \
  --headless
```

#### With Custom Load Shape
Uncomment and use the `CustomLoadShape` class in `locust_test.py` for gradual ramp-up scenarios.

## Test Scenarios

### Default Scenario (k6)
- **Ramp-up**: 30s to 10 users
- **Sustain**: 1m at 10 users
- **Ramp-up**: 30s to 20 users
- **Sustain**: 1m at 20 users
- **Ramp-down**: 30s to 0 users

### Default Scenario (Locust)
- **Wait time**: 1-3 seconds between tasks
- **User distribution**: 
  - 30% authenticated users
  - 70% anonymous browsing

### Task Weights (Locust)
Tasks are weighted by frequency:
- Browse categories: 10 (most common)
- Browse products: 8
- Search products: 7
- View product detail: 6
- View best sellers: 5
- View cart: 3
- View orders: 2
- View addresses: 2
- Signup: 1
- Track delivery: 1

## Performance Thresholds (k6)

The k6 script includes thresholds:
- `http_req_duration`: 95% of requests should be below 500ms
- `http_req_failed`: Error rate should be less than 10%
- Custom `errors` metric: Error rate should be less than 10%

## Results Interpretation

### k6 Output
- **http_req_duration**: Request duration metrics (avg, min, max, p95, p99)
- **http_req_failed**: Failed request rate
- **iterations**: Number of test iterations completed
- **vus**: Virtual users count

### Locust Output
- **Requests/s**: Requests per second
- **Response time**: Average, median, p95, p99 response times
- **Failure rate**: Percentage of failed requests
- **User count**: Number of concurrent users

## Customization

### Adding More Test Users
Edit the `testUsers` array in `k6_test.js` or `TEST_USERS` in `locust_test.py`.

### Adjusting Test Data
Modify:
- `SEARCH_QUERIES`: Search terms to test
- `CATEGORIES`: Category IDs to filter by
- Test user credentials

### Changing Load Patterns
**k6**: Modify the `stages` array in `options.stages`
**Locust**: Modify task weights or use custom load shapes

## Best Practices

1. **Start Small**: Begin with low user counts and gradually increase
2. **Monitor Resources**: Watch server CPU, memory, and database connections
3. **Test in Staging First**: Never run load tests against production without permission
4. **Set Reasonable Thresholds**: Adjust thresholds based on your SLA requirements
5. **Test Different Scenarios**: 
   - Peak load (high concurrent users)
   - Sustained load (long duration)
   - Spike test (sudden increase)

## Troubleshooting

### Connection Errors
- Verify API URL is correct
- Check network connectivity
- Ensure API server is running

### Authentication Failures
- Update test user credentials in scripts
- Verify authentication endpoint and payload format

### High Error Rates
- Check API server logs
- Verify database connections
- Monitor resource usage
- Consider rate limiting

## CI/CD Integration

### k6
```yaml
# GitHub Actions example
- name: Run k6 load test
  run: |
    k6 run --out json=results.json load_tests/k6_test.js
  env:
    BASE_URL: ${{ secrets.API_URL }}
```

### Locust
```yaml
# GitHub Actions example
- name: Run Locust load test
  run: |
    locust -f load_tests/locust_test.py \
      --host=${{ secrets.API_URL }} \
      --users 10 \
      --spawn-rate 2 \
      --run-time 1m \
      --headless \
      --html=results.html
```

## Additional Resources

- [k6 Documentation](https://k6.io/docs/)
- [Locust Documentation](https://docs.locust.io/)
- [Load Testing Best Practices](https://k6.io/docs/test-types/load-testing/)

