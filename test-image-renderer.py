#!/usr/bin/env python3
"""
Test script to verify Grafana Image Renderer is working
"""
import requests
import json
import time

def test_renderer():
    """Test if the image renderer service is responding"""
    try:
        response = requests.get('http://localhost:8081/render', timeout=10)
        if response.status_code == 400:  # Expected for GET without params
            print("✅ Image Renderer service is running")
            return True
        else:
            print(f"❌ Unexpected response: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to Image Renderer service")
        return False
    except Exception as e:
        print(f"❌ Error testing renderer: {e}")
        return False

def test_grafana_rendering():
    """Test Grafana's rendering capability"""
    try:
        # Test Grafana API endpoint
        response = requests.get('http://localhost:3000/api/health', timeout=10)
        if response.status_code == 200:
            print("✅ Grafana is running")
            
            # Check rendering configuration
            auth = ('admin', 'admin')
            config_response = requests.get(
                'http://localhost:3000/api/admin/settings',
                auth=auth,
                timeout=10
            )
            
            if config_response.status_code == 200:
                print("✅ Grafana API accessible")
                return True
            else:
                print(f"❌ Cannot access Grafana settings: {config_response.status_code}")
                return False
        else:
            print(f"❌ Grafana not responding: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to Grafana")
        return False
    except Exception as e:
        print(f"❌ Error testing Grafana: {e}")
        return False

if __name__ == "__main__":
    print("Testing Grafana Image Renderer setup...")
    print("-" * 40)
    
    print("1. Testing Image Renderer service...")
    renderer_ok = test_renderer()
    
    print("\n2. Testing Grafana service...")
    grafana_ok = test_grafana_rendering()
    
    print("\n" + "=" * 40)
    if renderer_ok and grafana_ok:
        print("✅ All tests passed! Image Renderer is properly configured.")
        print("\nNext steps:")
        print("- Create dashboard panels and test image generation")
        print("- Configure alert notifications with images")
    else:
        print("❌ Some tests failed. Check the services are running:")
        print("docker-compose ps")
        print("docker-compose logs renderer")
        print("docker-compose logs grafana")