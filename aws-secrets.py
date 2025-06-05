#!/usr/bin/env python3
import boto3
import json
import os

# Get the secret from AWS Secrets Manager
def get_secret():
    secret_name = "aws/access_key/my_key"
    region_name = "ap-southeast-1"
    
    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    
    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except Exception as e:
        print(f"Error getting secret: {e}")
        return None
    
    # Parse the secret
    if 'SecretString' in get_secret_value_response:
        secret = get_secret_value_response['SecretString']
        return json.loads(secret)
    else:
        return None

# Main function
if __name__ == "__main__":
    # Get the secret
    secret = get_secret()
    
    if secret:
        # Create the .env.aws file with the credentials
        with open('/etc/prometheus/.env.aws', 'w') as f:
            f.write(f"AWS_ACCESS_KEY={secret.get('access_key')}\n")
            f.write(f"AWS_SECRET_KEY={secret.get('secret_key')}\n")
        
        print("AWS credentials retrieved and saved successfully")
    else:
        print("Failed to retrieve AWS credentials")