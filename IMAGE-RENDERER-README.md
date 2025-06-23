# Grafana Image Renderer Setup

## Overview
The Grafana Image Renderer service enables generating PNG images of dashboards and panels for:
- Alert notifications with visual context
- Scheduled reports
- Embedding dashboard images in external systems

## Configuration Added

### Docker Compose Changes
- Added `renderer` service using `grafana/grafana-image-renderer:latest`
- Configured Grafana to use the renderer service
- Added proper networking between services

### Grafana Configuration
- Created `grafana/grafana.ini` with rendering settings
- Enabled unified alerting for image support
- Added debug logging for rendering

## Usage

### 1. Start the Services
```bash
cd AJX-MONITORING
docker-compose up -d
```

### 2. Verify Setup
```bash
python test-image-renderer.py
```

### 3. Test Image Generation
1. Open Grafana at http://localhost:3000
2. Go to any dashboard
3. Click on a panel → Share → Direct link rendered image
4. The URL should generate a PNG image

### 4. Configure Alert Images
In Grafana alert rules:
1. Go to Alerting → Alert Rules
2. Create/edit an alert rule
3. In notification settings, enable "Include image"
4. Images will be automatically attached to notifications

## Troubleshooting

### Check Services Status
```bash
docker-compose ps
```

### View Logs
```bash
# Renderer logs
docker-compose logs renderer

# Grafana logs
docker-compose logs grafana
```

### Common Issues
1. **Renderer not accessible**: Check if port 8081 is available
2. **Image generation fails**: Check Grafana logs for rendering errors
3. **Timeout errors**: Increase timeout in grafana.ini if needed

### Performance Tuning
For high-volume image generation, consider:
- Scaling renderer service replicas
- Adjusting memory limits
- Using external renderer deployment

## Integration with Alerts

### Telegram Notifications with Images
Your existing Telegram template can be enhanced to include dashboard images:
1. Configure alert rules with image rendering
2. Images will be automatically included in notifications
3. Modify `grafana-telegram-template.txt` if needed for image handling

### Email Notifications
Images are automatically embedded in email notifications when:
- Alert rule has "Include image" enabled
- Email notification channel is configured
- SMTP settings are properly configured in Grafana