import requests

BASE_URL = "http://127.0.0.1:8000"
USERNAME = "murenzi"  # The user whose verification you approved
PASSWORD = "Kadasarika10!"  # Their password

# Get user token (not admin)
print("🔐 Getting user token...")
response = requests.post(f"{BASE_URL}/auth/token/", json={
    "username": USERNAME,
    "password": PASSWORD
})

if response.status_code != 200:
    print(f"❌ Login failed: {response.text}")
    exit()

token = response.json()["access"]
headers = {"Authorization": f"Bearer {token}"}
print("✅ Token obtained!\n")

# Check verification status
print("🔍 Checking verification status...")
response = requests.get(f"{BASE_URL}/driver/verification-status/", headers=headers)
print(f"Status Code: {response.status_code}")
print(f"Response: {response.json()}")

if response.json().get('is_verified'):
    print("\n✅ User is VERIFIED! Can create trips.")
else:
    print("\n❌ User is NOT verified. Cannot create trips.")