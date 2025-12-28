

import requests

BASE_URL = "http://127.0.0.1:8000"
ADMIN_USERNAME = "murenzi"  # CHANGE THIS
ADMIN_PASSWORD = "Kadasarika10!"  # CHANGE THIS

print("🔐 Getting admin token...")
response = requests.post(f"{BASE_URL}/auth/token/", json={
    "username": ADMIN_USERNAME,
    "password": ADMIN_PASSWORD
})

if response.status_code != 200:
    print(f"❌ Failed: {response.text}")
    exit()

token = response.json()["access"]
headers = {"Authorization": f"Bearer {token}"}
print("✅ Token obtained!\n")

print("📋 Checking pending verifications...")
response = requests.get(f"{BASE_URL}/verification-admin/pending/", headers=headers)  # CHANGED URL
print(f"Status Code: {response.status_code}")

if response.status_code == 200:
    data = response.json()
    print(f"✅ Found {len(data)} pending verifications")
    for v in data:
        print(f"  - ID: {v['id']}, User: {v['user_username']}, Status: {v['status']}")
else:
    print(f"❌ Error: {response.text}")

print()

print("📊 Getting statistics...")
response = requests.get(f"{BASE_URL}/verification-admin/statistics/", headers=headers)  # CHANGED URL
print(f"Status Code: {response.status_code}")
if response.status_code == 200:
    print(response.json())
else:
    print(f"❌ Error: {response.text}")