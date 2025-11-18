"""
Locust load testing script for Ten Minute Delivery API
Install: pip install locust
Run: locust -f locust_test.py --host=https://api.tenminutedelivery.com
"""

from locust import HttpUser, task, between
from random import choice, randint
import random
import string
import time

# Test data
TEST_USERS = [
    {"email": "test1@example.com", "password": "password123"},
    {"email": "test2@example.com", "password": "password123"},
    {"email": "test3@example.com", "password": "password123"},
]

SEARCH_QUERIES = [
    "milk", "bread", "eggs", "chicken", "rice", "pasta",
    "vegetables", "fruits", "cheese", "yogurt", "juice"
]

CATEGORIES = ["1", "2", "3", "4", "5"]


def random_string(length=8):
    """Generate a random string"""
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=length))


class DeliveryAPIUser(HttpUser):
    """Simulates a user browsing and using the delivery API"""
    
    wait_time = between(1, 3)  # Wait 1-3 seconds between tasks
    token = None

    def on_start(self):
        """Called when a simulated user starts"""
        # 30% of users will be authenticated
        if random.random() < 0.3:
            self.authenticate()

    def authenticate(self):
        """Authenticate a user and store the token"""
        user = choice(TEST_USERS)
        response = self.client.post(
            "/api/auth/login",
            json={
                "email": user["email"],
                "password": user["password"]
            },
            name="POST /api/auth/login"
        )
        
        if response.status_code in [200, 201]:
            try:
                data = response.json()
                self.token = data.get("data", {}).get("token") or data.get("token")
                if self.token:
                    self.client.headers.update({
                        "Authorization": f"Bearer {self.token}"
                    })
            except:
                pass

    @task(10)
    def browse_categories(self):
        """Browse product categories - most common action"""
        with self.client.get(
            "/api/categories",
            name="GET /api/categories",
            catch_response=True
        ) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "data" in data and isinstance(data["data"], list):
                        response.success()
                    else:
                        response.failure("Invalid response format")
                except:
                    response.failure("Failed to parse response")
            else:
                response.failure(f"Status code: {response.status_code}")

    @task(8)
    def browse_products(self):
        """Browse products, optionally filtered by category"""
        params = {}
        if random.random() < 0.5:
            params["category_id"] = choice(CATEGORIES)
        
        with self.client.get(
            "/api/products",
            params=params,
            name="GET /api/products",
            catch_response=True
        ) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "data" in data and isinstance(data["data"], list):
                        response.success()
                        # Store product IDs for later use
                        products = data["data"]
                        if products:
                            self.product_id = products[0].get("id")
                    else:
                        response.failure("Invalid response format")
                except:
                    response.failure("Failed to parse response")
            else:
                response.failure(f"Status code: {response.status_code}")

    @task(6)
    def view_product_detail(self):
        """View a specific product detail"""
        # Try to use a product ID from previous request, or use a random one
        product_id = getattr(self, 'product_id', None) or f"product_{randint(1, 100)}"
        
        with self.client.get(
            f"/api/products/{product_id}",
            name="GET /api/products/:id",
            catch_response=True
        ) as response:
            if response.status_code == 200:
                response.success()
            elif response.status_code == 404:
                response.success()  # Product not found is acceptable
            else:
                response.failure(f"Status code: {response.status_code}")

    @task(7)
    def search_products(self):
        """Search for products"""
        query = choice(SEARCH_QUERIES)
        
        with self.client.get(
            "/api/search",
            params={"q": query},
            name="GET /api/search",
            catch_response=True
        ) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "data" in data or isinstance(data, list):
                        response.success()
                    else:
                        response.failure("Invalid response format")
                except:
                    response.failure("Failed to parse response")
            else:
                response.failure(f"Status code: {response.status_code}")

    @task(5)
    def view_best_sellers(self):
        """View best selling products"""
        with self.client.get(
            "/api/products",
            params={"best_seller": True},
            name="GET /api/products?best_seller=true",
            catch_response=True
        ) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    if "data" in data and isinstance(data["data"], list):
                        response.success()
                    else:
                        response.failure("Invalid response format")
                except:
                    response.failure("Failed to parse response")
            else:
                response.failure(f"Status code: {response.status_code}")

    @task(3)
    def view_cart(self):
        """View shopping cart (requires authentication)"""
        if not self.token:
            return
        
        with self.client.get(
            "/api/cart",
            name="GET /api/cart",
            catch_response=True
        ) as response:
            if response.status_code in [200, 404]:
                response.success()
            else:
                response.failure(f"Status code: {response.status_code}")

    @task(2)
    def view_orders(self):
        """View order history (requires authentication)"""
        if not self.token:
            return
        
        with self.client.get(
            "/api/orders",
            name="GET /api/orders",
            catch_response=True
        ) as response:
            if response.status_code == 200:
                try:
                    data = response.json()
                    response.success()
                except:
                    response.failure("Failed to parse response")
            else:
                response.failure(f"Status code: {response.status_code}")

    @task(2)
    def view_addresses(self):
        """View saved addresses (requires authentication)"""
        if not self.token:
            return
        
        with self.client.get(
            "/api/addresses",
            name="GET /api/addresses",
            catch_response=True
        ) as response:
            if response.status_code in [200, 404]:
                response.success()
            else:
                response.failure(f"Status code: {response.status_code}")

    @task(1)
    def signup(self):
        """User signup - less frequent"""
        email = f"test_{random_string(8)}@example.com"
        
        with self.client.post(
            "/api/auth/signup",
            json={
                "name": f"Test User {random_string(5)}",
                "email": email,
                "password": "password123",
                "phone": f"+1234567890{randint(100, 999)}"
            },
            name="POST /api/auth/signup",
            catch_response=True
        ) as response:
            if response.status_code in [200, 201]:
                response.success()
            elif response.status_code == 409:
                response.success()  # User already exists is acceptable
            else:
                response.failure(f"Status code: {response.status_code}")

    @task(1)
    def track_delivery(self):
        """Track a delivery order"""
        order_id = f"order_{randint(1, 1000)}"
        
        with self.client.get(
            f"/api/delivery/tracking/{order_id}",
            name="GET /api/delivery/tracking/:id",
            catch_response=True
        ) as response:
            if response.status_code in [200, 404]:
                response.success()
            else:
                response.failure(f"Status code: {response.status_code}")


# Optional: Add custom load shape
class CustomLoadShape:
    """Custom load shape for gradual ramp-up"""
    def __init__(self):
        self.stages = [
            {"duration": 30, "users": 10, "spawn_rate": 2},
            {"duration": 60, "users": 10, "spawn_rate": 2},
            {"duration": 30, "users": 20, "spawn_rate": 2},
            {"duration": 60, "users": 20, "spawn_rate": 2},
            {"duration": 30, "users": 0, "spawn_rate": 2},
        ]
        self.stage_index = 0
        self.start_time = None

    def tick(self):
        if self.start_time is None:
            self.start_time = time.time()
        
        elapsed = time.time() - self.start_time
        current_stage = self.stages[self.stage_index]
        
        if elapsed < current_stage["duration"]:
            return (current_stage["users"], current_stage["spawn_rate"])
        
        self.stage_index += 1
        if self.stage_index >= len(self.stages):
            return None
        
        return (self.stages[self.stage_index]["users"], self.stages[self.stage_index]["spawn_rate"])

