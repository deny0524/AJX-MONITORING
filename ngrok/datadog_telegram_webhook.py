import requests
import json
from flask import Flask, request

app = Flask(__name__)

# Configuration
TELEGRAM_BOT_TOKEN = "7586738684:AAHHEpv-_-KxbCCF7KPsuKJa-ncvYvTc00w"
TELEGRAM_CHAT_ID = "-4823330088"
TELEGRAM_API_URL = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"

@app.route('/webhook', methods=['POST'])
def webhook():
    """
    Receive webhook from Datadog and forward to Telegram
    """
    if request.method == 'POST':
        # Get the alert data from Datadog
        alert_data = request.json

        # Extract relevant information
        if alert_data:
            try:
                # Format the message for Telegram
                message = format_telegram_message(alert_data)

                # Send to Telegram
                send_telegram_message(message)

                return "Alert sent to Telegram", 200
            except Exception as e:
                print(f"Error processing webhook: {str(e)}")
                return f"Error: {str(e)}", 500

        return "No data received", 400

def format_telegram_message(alert_data):
    """Format the Datadog alert data for Telegram"""

    # Extract alert information (adjust based on Datadog's webhook payload structure)
    title = alert_data.get('title', 'Alert from Datadog')
    message = alert_data.get('message', 'No message provided')
    priority = alert_data.get('priority', 'unknown')
    alert_url = alert_data.get('link', '')

    # Create a formatted message
    formatted_message = f"🚨 *{title}*\n\n"
    formatted_message += f"*Priority:* {priority}\n"
    formatted_message += f"*Message:* {message}\n"

    if alert_url:
        formatted_message += f"\n[View in Datadog]({alert_url})"

    return formatted_message

def send_telegram_message(message):
    """Send message to Telegram"""
    payload = {
        'chat_id': TELEGRAM_CHAT_ID,
        'text': message,
        'parse_mode': 'Markdown'
    }

    response = requests.post(TELEGRAM_API_URL, json=payload)

    if response.status_code != 200:
        raise Exception(f"Failed to send message to Telegram: {response.text}")

    return response.json()

if __name__ == '__main__':
    # For local testing
    app.run(host='0.0.0.0', port=5000)
