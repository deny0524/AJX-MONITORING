#!/usr/bin/env python3
import os
import json
import requests
import sys

# Get API token from environment or command line
if len(sys.argv) > 1:
    API_TOKEN = sys.argv[1]
else:
    API_TOKEN = os.environ.get('CF_API_TOKEN', '')

# Get domain from environment or command line
if len(sys.argv) > 2:
    DOMAIN = sys.argv[2]
else:
    DOMAIN = os.environ.get('CF_DOMAINS', '')

if not API_TOKEN or not DOMAIN:
    print("Usage: python get-cloudflare-zone-id.py [API_TOKEN] [DOMAIN]")
    print("Or set CF_API_TOKEN and CF_DOMAINS environment variables")
    sys.exit(1)

print(f"Looking up zone ID for domain: {DOMAIN}")

# Try with X-Auth-Token header
headers = {
    'X-Auth-Token': API_TOKEN,
    'Content-Type': 'application/json'
}

response = requests.get(
    'https://api.cloudflare.com/client/v4/zones',
    headers=headers
)

if response.status_code == 200:
    data = response.json()
    for zone in data.get('result', []):
        if zone['name'] == DOMAIN:
            print(f"\nZone ID for {DOMAIN}: {zone['id']}")
            print("\nAdd this to your .env.cloudflare file as:")
            print(f"CF_ZONE_ID={zone['id']}")
            sys.exit(0)
    
    print(f"\nZone {DOMAIN} not found. Available zones:")
    for zone in data.get('result', []):
        print(f"- {zone['name']} (ID: {zone['id']})")
else:
    print(f"Error: {response.status_code}")
    print(response.text)

# Try with Bearer token as fallback
headers = {
    'Authorization': f'Bearer {API_TOKEN}',
    'Content-Type': 'application/json'
}

response = requests.get(
    'https://api.cloudflare.com/client/v4/zones',
    headers=headers
)

if response.status_code == 200:
    data = response.json()
    for zone in data.get('result', []):
        if zone['name'] == DOMAIN:
            print(f"\nZone ID for {DOMAIN}: {zone['id']}")
            print("\nAdd this to your .env.cloudflare file as:")
            print(f"CF_ZONE_ID={zone['id']}")
            sys.exit(0)
    
    print(f"\nZone {DOMAIN} not found with Bearer token either.")
else:
    print(f"Bearer token authentication also failed: {response.status_code}")
    print(response.text)

print("\nPlease check your API token permissions and domain name.")
sys.exit(1)