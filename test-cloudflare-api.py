#!/usr/bin/env python3
import os
import json
import requests

# Get API token from environment or use the one from .env.cloudflare
API_TOKEN = os.environ.get('CF_API_TOKEN', '6Syj9DJKp6qzyQmE-K20EGSRw_QSmBvvnD-4H5g6')
ZONE = os.environ.get('CF_DOMAINS', 'bgslwp.xyz')

def test_api():
    print(f"Testing Cloudflare API with token: {API_TOKEN[:5]}...{API_TOKEN[-5:]}")
    print(f"Looking for zone: {ZONE}")
    
    # Try different authentication methods
    
    # Method 1: X-Auth-Token header
    headers1 = {
        'X-Auth-Token': API_TOKEN,
        'Content-Type': 'application/json'
    }
    
    print("\nTrying X-Auth-Token header...")
    response1 = requests.get(
        'https://api.cloudflare.com/client/v4/zones',
        headers=headers1
    )
    
    print(f"Status code: {response1.status_code}")
    if response1.status_code == 200:
        data = response1.json()
        print(f"Success! Found {len(data.get('result', []))} zones")
        print(json.dumps(data, indent=2))
    else:
        print(f"Error: {response1.text}")
    
    # Method 2: Authorization: Bearer header
    headers2 = {
        'Authorization': f'Bearer {API_TOKEN}',
        'Content-Type': 'application/json'
    }
    
    print("\nTrying Authorization: Bearer header...")
    response2 = requests.get(
        'https://api.cloudflare.com/client/v4/zones',
        headers=headers2
    )
    
    print(f"Status code: {response2.status_code}")
    if response2.status_code == 200:
        data = response2.json()
        print(f"Success! Found {len(data.get('result', []))} zones")
        print(json.dumps(data, indent=2))
    else:
        print(f"Error: {response2.text}")

if __name__ == "__main__":
    test_api()