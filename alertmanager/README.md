# AJX Monitoring - Telegram Alert Templates

This directory contains the configuration for AlertManager and beautiful Telegram alert templates for the AJX Monitoring system.

## Setup Instructions

### 1. Create a Telegram Bot

1. Open Telegram and search for `@BotFather`
2. Start a chat with BotFather and send `/newbot`
3. Follow the instructions to create a new bot
4. Save the API token provided by BotFather

### 2. Get Your Telegram Chat ID

1. Create a group in Telegram where you want to receive alerts
2. Add your bot to this group
3. Make the bot an administrator of the group
4. Send a message in the group
5. Visit `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
6. Look for the `chat` object and note the `id` value (it will be negative for group chats)

### 3. Configure AlertManager

1. Update the `alertmanager.yml` file with your Telegram bot token and chat ID:

```yaml
- name: 'telegram-critical'
  webhook_configs:
  - url: 'http://localhost:9087/alert/YOUR_CHAT_ID_HERE'
    send_resolved: true
    http_config:
      bearer_token: YOUR_BOT_TOKEN
```

2. Update the `docker-compose.yml` file with your Telegram bot token and user ID:

```yaml
telegram-bot:
  environment:
    - TELEGRAM_ADMIN=YOUR_TELEGRAM_USER_ID
    - TELEGRAM_TOKEN=YOUR_BOT_TOKEN
```

### 4. Start the Services

```bash
docker-compose up -d
```

## Alert Templates

The system includes beautiful alert templates for Telegram:

1. **Default Template** - A general-purpose alert template
2. **CPU Alert Template** - A specialized template for CPU alerts with usage metrics

### Customizing Templates

You can customize the templates in `templates/telegram.tmpl`. The templates use Go's template syntax.

To use a specific template for an alert, add a `telegram_template` annotation to your alert rule:

```yaml
annotations:
  summary: "High CPU load"
  description: "CPU load is > 80%"
  telegram_template: "telegram.cpu"
```

## Testing Alerts

You can test the alerts by temporarily lowering the threshold in your alert rules or by using the AlertManager API to send a test alert.

Example test command:
```bash
curl -H "Content-Type: application/json" -d '[{"labels":{"alertname":"TestAlert","severity":"critical","instance":"test-instance"},"annotations":{"summary":"Test Alert","description":"This is a test alert with VALUE = 95.5"},"startsAt":"2023-01-01T00:00:00.000Z"}]' http://localhost:9093/api/v1/alerts
```