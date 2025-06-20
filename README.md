# OKR OpenTelemetry Custom Buildpack

A custom Heroku buildpack for deploying OpenTelemetry Collector with OKR-specific configurations.

## 🎯 Purpose

This buildpack provides:
- **Flexible OpenTelemetry Collector** deployment for Rails OKR applications
- **OKR-specific telemetry** collection and configuration
- **Multi-backend support** (Datadog, New Relic, Honeycomb, Grafana Cloud, Generic OTLP)
- **Custom business metrics** for OKR applications

## 🚀 Usage

### Add to your OKR app:

```bash
# Add this custom buildpack first, then Ruby buildpack
heroku buildpacks:add https://github.com/your-username/heroku-buildpack-okr-otelcol
heroku buildpacks:add heroku/ruby
```

### Or in app.json:

```json
{
  "buildpacks": [
    {
      "url": "https://github.com/your-username/heroku-buildpack-okr-otelcol"
    },
    {
      "url": "heroku/ruby"
    }
  ]
}
```

## 📁 Required Structure

Your OKR app should have:
```
your-okr-app/
├── otelcol/
│   ├── config.yml          # OpenTelemetry Collector config
│   ├── prerun.sh           # Pre-startup script (optional)
│   └── env.example         # Environment variable examples
├── Gemfile                 # Must include opentelemetry gems
└── app.json               # Heroku configuration
```

## 🔧 Environment Variables

### Required:
- `OTEL_EXPORTER_OTLP_ENDPOINT` - Your telemetry backend endpoint

### Optional:
- `OTEL_SERVICE_NAME` (default: "okr-management-app")
- `OTEL_SERVICE_VERSION` (default: "1.0.0")
- `OTEL_LOG_LEVEL` (default: "info")
- `OTELCOL_CONTRIB` (default: "true")
- `DISABLE_OTELCOL` (default: "false")

### Backend-specific:
- **Datadog**: `DD_API_KEY`, `DD_SITE`
- **New Relic**: `NEW_RELIC_LICENSE_KEY`
- **Honeycomb**: `HONEYCOMB_API_KEY`
- **Grafana Cloud**: `GRAFANA_CLOUD_OTLP_ENDPOINT`, `GRAFANA_CLOUD_OTLP_BASIC_AUTH`

## 🏗️ Architecture

```
Heroku Dyno
├── Ruby Rails App (OKR)
│   ├── OpenTelemetry Ruby SDK
│   └── Application Instrumentation
├── OpenTelemetry Collector
│   ├── Receivers (OTLP, Host Metrics)
│   ├── Processors (Batch, Resource)
│   └── Exporters (Debug, OTLP HTTP)
└── Your Observability Backend
```

## 🎯 OKR-Specific Features

### Business Metrics
The buildpack can be extended to collect OKR-specific metrics:
- Objective creation/completion rates
- Key Result progress tracking
- User engagement patterns
- File upload operations
- Database query performance

### Custom Configuration
- Automatic detection of Rails + OpenTelemetry apps
- OKR app-specific resource attributes
- Optimized for OKR business logic tracing

## 🔨 Development

### Building the Buildpack

1. **Clone and modify:**
   ```bash
   git clone https://github.com/your-username/heroku-buildpack-okr-otelcol
   cd heroku-buildpack-okr-otelcol
   # Make changes
   ```

2. **Test with your OKR app:**
   ```bash
   # In your OKR app directory
   heroku buildpacks:set https://github.com/your-username/heroku-buildpack-okr-otelcol
   git push heroku main
   ```

### File Structure
```
heroku-buildpack-okr-otelcol/
├── bin/
│   ├── detect              # Detects OKR + OpenTelemetry apps
│   ├── compile             # Downloads and configures collector
│   └── release             # Sets runtime configuration
├── lib/                    # Helper scripts
├── README.md              # This file
└── VERSION                # Buildpack version
```

## 📊 Monitoring

After deployment, monitor your OKR app:
```bash
# View collector logs
heroku logs --grep otelcol --tail

# Check configuration
heroku config

# Monitor dyno status
heroku ps
```

## 🔍 Troubleshooting

### Collector Not Starting
1. Check environment variables: `heroku config`
2. View startup logs: `heroku logs --grep otelcol`
3. Verify buildpack order: `heroku buildpacks`

### No Telemetry Data
1. Verify endpoint configuration
2. Check authentication credentials
3. Test connectivity: `heroku run curl -v $OTEL_EXPORTER_OTLP_ENDPOINT`

### High Memory Usage
1. Adjust collector memory limit: `OTEL_MEMORY_LIMIT_MIB=256`
2. Tune batch size: `OTEL_BATCH_SIZE=512`

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Test with OKR application
4. Submit pull request

## 📄 License

MIT License - see LICENSE file for details.

---

**Designed specifically for OKR Management Applications with OpenTelemetry observability**
