#!/usr/bin/env bash
# lib/utils.sh
# Utility functions for OKR OpenTelemetry buildpack

# Color codes for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Indentation for Heroku buildpack output
indent() {
    sed -u 's/^/       /'
}

# Get OpenTelemetry Collector version
get_otelcol_version() {
    echo "${OTELCOL_VERSION:-0.95.0}"
}

# Check if environment variable is set
check_env_var() {
    local var_name="$1"
    local required="${2:-false}"
    
    if [[ -n "${!var_name}" ]]; then
        log_info "$var_name is set"
        return 0
    elif [[ "$required" == "true" ]]; then
        log_error "Required environment variable $var_name is not set"
        return 1
    else
        log_warning "$var_name is not set (optional)"
        return 0
    fi
}

# Detect observability backend based on environment variables
detect_backend() {
    if [[ -n "$DD_API_KEY" ]]; then
        echo "datadog"
    elif [[ -n "$NEW_RELIC_LICENSE_KEY" ]]; then
        echo "newrelic"
    elif [[ -n "$HONEYCOMB_API_KEY" ]]; then
        echo "honeycomb"
    elif [[ -n "$GRAFANA_CLOUD_OTLP_BASIC_AUTH" ]]; then
        echo "grafana"
    elif [[ -n "$OTEL_EXPORTER_OTLP_ENDPOINT" ]]; then
        echo "otlp"
    else
        echo "unknown"
    fi
}

# Validate collector binary
validate_collector() {
    local binary_path="$1"
    
    if [[ ! -f "$binary_path" ]]; then
        log_error "Collector binary not found: $binary_path"
        return 1
    fi
    
    if [[ ! -x "$binary_path" ]]; then
        log_error "Collector binary is not executable: $binary_path"
        return 1
    fi
    
    # Test binary execution
    if ! "$binary_path" --version >/dev/null 2>&1; then
        log_error "Collector binary failed version check: $binary_path"
        return 1
    fi
    
    log_success "Collector binary validated: $binary_path"
    return 0
}

# Create OKR-specific resource attributes
create_okr_attributes() {
    local attributes=""
    
    # Standard attributes
    attributes="service.name=${OTEL_SERVICE_NAME:-okr-management-app}"
    attributes="${attributes},service.version=${OTEL_SERVICE_VERSION:-1.0.0}"
    attributes="${attributes},deployment.environment=${RAILS_ENV:-production}"
    
    # Heroku-specific attributes
    if [[ -n "$HEROKU_APP_NAME" ]]; then
        attributes="${attributes},heroku.app.name=${HEROKU_APP_NAME}"
    fi
    
    if [[ -n "$DYNO" ]]; then
        attributes="${attributes},heroku.dyno.name=${DYNO}"
    fi
    
    if [[ -n "$HEROKU_RELEASE_VERSION" ]]; then
        attributes="${attributes},heroku.release.version=${HEROKU_RELEASE_VERSION}"
    fi
    
    # OKR-specific attributes
    attributes="${attributes},application.type=okr-management"
    attributes="${attributes},telemetry.source=custom-buildpack"
    
    echo "$attributes"
}

# Check if this is an OKR application
is_okr_app() {
    local build_dir="$1"
    
    # Check for OKR-specific indicators
    if [[ -f "$build_dir/app/models/objective.rb" ]] && 
       [[ -f "$build_dir/app/models/key_result.rb" ]]; then
        return 0
    fi
    
    # Check for OKR routes
    if [[ -f "$build_dir/config/routes.rb" ]] &&
       grep -q "objectives\|key_results" "$build_dir/config/routes.rb"; then
        return 0
    fi
    
    return 1
}

# Setup OKR-specific telemetry configuration
setup_okr_telemetry() {
    local config_dir="$1"
    
    # Create OKR-specific instrumentation hints
    cat > "$config_dir/okr-instrumentation.yml" << 'EOF'
# OKR Application Instrumentation Configuration
# This file provides hints for custom instrumentation

instrumentation:
  objectives:
    - creation_events
    - completion_tracking
    - progress_updates
  
  key_results:
    - value_updates
    - status_changes
    - measurement_types
  
  organization:
    - vision_updates
    - mission_updates
    - document_uploads
  
  database:
    - query_performance
    - connection_pooling
    - active_record_events

custom_metrics:
  business:
    - objectives_created_total
    - objectives_completed_total
    - key_results_updated_total
    - average_completion_rate
    - user_engagement_score
  
  technical:
    - request_duration_seconds
    - database_query_duration_seconds
    - file_upload_size_bytes
    - background_job_duration_seconds
EOF

    log_success "Created OKR instrumentation configuration"
}
