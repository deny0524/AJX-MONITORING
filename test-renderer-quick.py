import requests

# Test renderer directly
try:
    r = requests.get('http://localhost:8081', timeout=5)
    print(f"✅ Renderer responding: {r.status_code}")
except:
    print("❌ Renderer not accessible")

# Test Grafana can reach renderer
try:
    r = requests.get('http://localhost:3000/api/health', timeout=5)
    print(f"✅ Grafana responding: {r.status_code}")
except:
    print("❌ Grafana not accessible")