# Infrastructure Monitoring & Observability

## Prometheus, Grafana, Datadog & Zabbix

Infrastructure Monitoring allows you to collect metrics, visualize data, and get alerted when things go wrong. Observability is knowing what's happening in your system.

The main monitoring tools covered in this guide are:

* Prometheus (metrics collection & time-series DB)
* Grafana (visualization & dashboards)
* Datadog (commercial all-in-one)
* Zabbix (traditional monitoring)

---

# 1. What Is Infrastructure Monitoring?

## Without Monitoring (The Problem)

```text
Your Application is Down!

But you don't know:
├─ When it went down
├─ Why it went down
├─ How many users affected
├─ Which server failed
├─ CPU at 99%? Memory leak? Disk full?
├─ Did the database crash?
├─ Are requests slow?
└─ What was the error?

Result:
├─ 30 minutes to notice
├─ 1 hour to find root cause
├─ 2 hours to fix
└─ Complete chaos!
```

## With Monitoring (The Solution)

```text
Your Application is Down!

You know immediately:
├─ Downtime: 2023-01-15 10:30:00 UTC
├─ Root cause: Database connection timeout
├─ Affected users: ~5,000
├─ Failed server: app-server-3
├─ CPU: 5% | Memory: 45% | Disk: 78%
├─ Error rate: Spiked from 0.1% to 50%
├─ Request latency: 2000ms (normal: 100ms)
└─ Database slowlog: 10,000 pending connections

Result:
├─ Alert received immediately
├─ Root cause identified in 2 minutes
├─ Fixed in 5 minutes
└─ Incident resolved!
```

## Benefits of Monitoring

```text
MONITORING BENEFITS:

Visibility:       Know what's happening in real-time
Alerting:         Get notified before disaster
Debugging:        See exactly what went wrong
Capacity:         Know when to scale
Performance:      Track system performance
Compliance:       Meet regulatory requirements
SLA Tracking:     Monitor uptime & response time
Cost:             Identify expensive resources
Troubleshooting:  Historical data for analysis
Prevention:       Fix issues before they happen
```

---

# 2. Monitoring Architecture

```text
┌────────────────────────────────────────────────────────┐
│              MONITORING STACK ARCHITECTURE             │
└────────────────────────────────────────────────────────┘

DATA SOURCES (What to monitor):
├── Servers (CPU, Memory, Disk, Network)
├── Applications (Requests, Errors, Latency)
├── Databases (Queries, Connections, Lock time)
├── Containers (CPU, Memory per container)
├── Kubernetes (Pod status, Node health)
├── Load Balancers (Request count, Health)
└── Infrastructure (API calls, Costs)

                    │
                    ▼

COLLECTION LAYER (How to collect):
├── Prometheus: Pull-based (agents expose metrics)
├── Telegraf: Agent-based collection
├── CloudWatch Agent: AWS native
├── Datadog Agent: Commercial agent
└── Custom exporters: Application-specific

                    │
                    ▼

STORAGE LAYER (Where to store):
├── Prometheus: Time-series database
├── InfluxDB: Time-series database
├── Graphite: Time-series database
├── CloudWatch: AWS storage
└── Datadog: Commercial backend

                    │
                    ▼

VISUALIZATION LAYER (How to display):
├── Grafana: Open-source dashboards
├── Kibana: Elasticsearch visualization
├── CloudWatch Dashboard: AWS native
├── Datadog Dashboard: Commercial
└── Custom: Web-based dashboards

                    │
                    ▼

ALERTING LAYER (How to notify):
├── Alertmanager: Alert routing & grouping
├── PagerDuty: Incident management
├── Slack: Chat notifications
├── Email: Email alerts
└── SMS/Phone: Critical alerts
```

---

# 3. Quick Comparison: All 4 Tools

```text
┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│   Feature    │ Prometheus   │ Grafana      │ Datadog      │ Zabbix       │
├──────────────┼──────────────┼──────────────┼──────────────┼──────────────┤
│ Cost         │ FREE ✓       │ FREE ✓       │ Paid         │ FREE/Paid    │
│ Type         │ Metrics DB   │ Visualization│ All-in-one   │ Traditional  │
│ Data Model   │ Time-series  │ Agnostic     │ Multi-type   │ All types    │
│ Collection   │ Pull-based   │ N/A          │ Agent        │ Agent/Push   │
│ Storage      │ Built-in     │ Multiple     │ Cloud        │ Database     │
│ Setup        │ Medium       │ Easy         │ Easy         │ Complex      │
│ Learning     │ Medium ✓     │ Easy         │ Easy         │ Hard         │
│ Scalability  │ Good ✓       │ Good         │ Enterprise   │ Good         │
│ Community    │ HUGE ✓       │ HUGE ✓       │ Commercial   │ Large        │
│ Alerting     │ Native       │ Via Alertmgr │ Native       │ Native       │
│ Best For     │ Cloud-native │ Dashboards   │ Enterprise   │ Traditional  │
│ Market       │ Most popular │ Standard     │ Premium      │ Legacy       │
└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘
```

---

# 4. My Recommendation: Prometheus

## Why Choose Prometheus?

```text
PROMETHEUS IS BEST FOR LEARNING BECAUSE:

✓ COMPLETELY FREE & OPEN SOURCE
  └── No licensing costs
  └── No vendor lock-in
  └── Community-driven development

✓ INDUSTRY STANDARD FOR CLOUD-NATIVE
  └── Used by Kubernetes community
  └── Used by CNCF (Cloud Native Computing Foundation)
  └── De facto standard for cloud monitoring

✓ SIMPLE ARCHITECTURE
  └── Easy to understand & deploy
  └── Single binary to run
  └── Minimal dependencies

✓ POWERFUL QUERY LANGUAGE (PromQL)
  └── Flexible metrics queries
  └── Can calculate complex expressions
  └── Learn once, use everywhere

✓ ACTIVE ECOSYSTEM
  └── 1000s of exporters available
  └── Works with Grafana perfectly
  └── Integrates with everything

✓ WORKS WITH YOUR STACK
  └── Monitor EC2 instances (provisioned with Terraform)
  └── Monitor apps (deployed with Ansible)
  └── Alert in GitHub Actions
  └── Deployed as Docker container
  └── Works on Kubernetes

✓ PERFECT FOR LEARNING
  └── Easy to set up locally
  └── Start in 5 minutes
  └── Understand fundamentals
  └── Scale to enterprise later

ALTERNATIVE CONSIDERATIONS:

Grafana:
├── Better for: Visualization, not collection
├── Use with: Prometheus as backend
└── Learn together: Prometheus + Grafana

Datadog:
├── Better for: Enterprise all-in-one
├── Cost: Expensive ($15-25 per host)
└── Advantage: Less operational overhead

Zabbix:
├── Better for: Traditional enterprises
├── Learning: Too complex for beginners
└── Modern: Less relevant for cloud-native
```

**FINAL ANSWER: Choose Prometheus + Grafana combo. Best for learning & production.**

---

# 5. Quick Overview: Grafana

## What Is Grafana?

Grafana is a visualization platform. Create beautiful dashboards from any data source (Prometheus, Elasticsearch, MySQL, etc).

## Grafana Features

```text
DASHBOARDS:
├── Create custom dashboards
├── Pre-built dashboards from community
├── Share dashboards with team
├── Dashboard versioning
└── Template variables for flexibility

ALERTING:
├── Alert when metrics exceed threshold
├── Multiple notification channels
├── Alert templates
└── Alert history

DATA SOURCES:
├── Prometheus (time-series)
├── Elasticsearch (logs)
├── MySQL/PostgreSQL (relational)
├── Cloudwatch (AWS metrics)
├── And 50+ others

VISUALIZATIONS:
├── Graphs & charts
├── Heatmaps
├── Tables
├── Gauges
├── Stat panels
└── Custom plugins
```

## Simple Grafana Example

```yaml
# Grafana dashboard (JSON)
{
  "dashboard": {
    "title": "Application Monitoring",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(http_errors_total[5m])"
          }
        ]
      },
      {
        "title": "Latency (p95)",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, http_request_duration_seconds)"
          }
        ]
      }
    ]
  }
}
```

---

# 6. Quick Overview: Datadog

## What Is Datadog?

Datadog is an all-in-one monitoring platform. Metrics, logs, APM, infrastructure, all in one place.

## Datadog Features

```text
INFRASTRUCTURE MONITORING:
├── Server monitoring
├── Container monitoring
├── AWS integration
└── Custom metrics

LOG MANAGEMENT:
├── Log collection
├── Log searching
├── Log analytics
└── Log alerting

APM (Application Performance):
├── Request tracing
├── Performance bottlenecks
├── Error tracking
└── Service dependencies

SECURITY:
├── Cloud security
├── Compliance monitoring
└── Threat detection

COST:
├── $15-25 per host per month
├── $0.10 per custom metric
└── Log ingestion costs
```

## Datadog Pros & Cons

```text
PROS:
✓ All-in-one solution
✓ Easy setup
✓ Great support
✓ Beautiful dashboards
✓ Powerful alerting
✓ Multiple data types

CONS:
✗ Expensive ($15-25/host)
✗ Vendor lock-in
✗ Data ownership concerns
✗ Requires agent on all servers
✗ Overkill for small teams
```

---

# 7. Quick Overview: Zabbix

## What Is Zabbix?

Zabbix is a traditional monitoring platform. Agent-based, enterprise features, mature.

## Zabbix Features

```text
MONITORING:
├── Infrastructure
├── Applications
├── Databases
├── Network devices
└── Custom metrics

COLLECTION:
├── Agents (push)
├── Agentless (pull via SNMP)
└── Passive/active monitoring

ALERTING:
├── Complex alert rules
├── Escalation paths
├── Remediation actions
└── Alert templates

REPORTING:
├── Standard reports
├── Custom reports
├── SLA tracking
└── Historical analysis
```

## Zabbix Pros & Cons

```text
PROS:
✓ Very flexible
✓ Works with anything
✓ Mature & stable
✓ Open source
✓ Good for traditional IT

CONS:
✗ Complex setup
✗ Steep learning curve
✗ Web UI dated
✗ Not cloud-native friendly
✗ Requires agent everywhere
✗ Hard to scale
```

---

# 8. Prometheus: Detailed Guide

Since Prometheus is the best choice for you, here's the detailed guide.

## What Is Prometheus?

Prometheus is an open-source metrics collection and storage platform. Time-series database optimized for monitoring.

## How Prometheus Works

```text
PULL MODEL:

APPLICATION
└── Exposes metrics at /metrics
    (e.g., http://app:3000/metrics)

        │
        │ Prometheus scrapes every 15s
        ▼

PROMETHEUS SERVER
├── Collects metrics
├── Stores in time-series DB
├── Indexes for queries
└── Keeps 15 days by default

        │
        │ Query data
        ▼

GRAFANA / ALERTMANAGER
├── Create beautiful dashboards
├── Send alerts when rules match
└── Integrate with PagerDuty, Slack, etc
```

## Prometheus Architecture

```text
┌─────────────────────────────────────────────┐
│         PROMETHEUS ARCHITECTURE             │
├─────────────────────────────────────────────┤
│                                             │
│  APPLICATION SERVERS                       │
│  ├── /metrics endpoint                     │
│  │   └── http_requests_total 1234          │
│  │   └── http_errors_total 5               │
│  │   └── process_memory_bytes 1000000      │
│  │                                         │
│  ├── /metrics endpoint                     │
│  └── /metrics endpoint                     │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│  PROMETHEUS SERVER (Scraper)               │
│  ├── Scrapes all /metrics endpoints        │
│  ├── Stores in time-series DB              │
│  └── Keeps 15 days of history              │
│                                             │
│  Scrape Config:                            │
│  ├── app-1:3000/metrics (every 15s)       │
│  ├── app-2:3000/metrics (every 15s)       │
│  └── app-3:3000/metrics (every 15s)       │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│  ALERTMANAGER                              │
│  ├── Evaluates alert rules (every 15s)    │
│  ├── Groups related alerts                 │
│  └── Routes to Slack, PagerDuty, etc      │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│  GRAFANA (Visualization)                   │
│  ├── Queries Prometheus                    │
│  ├── Displays dashboards                   │
│  ├── Shows alerts                          │
│  └── Sends to Slack on alert              │
│                                             │
└─────────────────────────────────────────────┘
```

## Prometheus Core Concepts

```text
METRIC:           A measurement (http_requests_total, cpu_usage, etc)
LABEL:            Metadata on metric (method="GET", handler="/api")
TIME-SERIES:      Sequence of (timestamp, value) for one metric
SCRAPE:           Prometheus polling /metrics endpoint
TARGET:           Server exposing metrics
EXPORTER:         Program exposing metrics (Node Exporter, etc)
ALERTING RULE:    Condition that triggers alert (CPU > 80%)
RECORDING RULE:   Pre-computed metric for efficiency
PromQL:           Query language (rate(http_requests_total[5m]))
INSTANCE:         One target server
JOB:              Group of similar instances
```

## Metric Types

```text
COUNTER:
├── Only increases (never decreases)
├── Example: http_requests_total
├── Used for: Cumulative counts
└── Query: rate(http_requests_total[5m]) = requests per second

GAUGE:
├── Can go up or down
├── Example: cpu_usage_percent
├── Used for: Current values
└── Query: cpu_usage_percent > 80

HISTOGRAM:
├── Measures distribution
├── Example: http_request_duration_seconds
├── Creates: _bucket, _count, _sum
└── Query: histogram_quantile(0.95, http_request_duration_seconds)

SUMMARY:
├── Measures distribution + quantiles
├── Example: request_latency_seconds
├── Creates: _count, _sum, quantiles
└── Query: similar to histogram
```

---

# 9. Installing Prometheus

## Install Prometheus (macOS)

```bash
# Install via Homebrew
brew install prometheus

# Verify
prometheus --version

# Start Prometheus
prometheus --config.file=/usr/local/etc/prometheus.yml

# Access at http://localhost:9090
```

## Install Prometheus (Docker)

```bash
# Pull image
docker pull prom/prometheus:latest

# Create config
mkdir -p /etc/prometheus
cat > /etc/prometheus/prometheus.yml <<'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - localhost:9093

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'app'
    static_configs:
      - targets: ['localhost:3000']
EOF

# Run Prometheus
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v /etc/prometheus:/etc/prometheus \
  prom/prometheus \
  --config.file=/etc/prometheus/prometheus.yml
```

## Prometheus Configuration

```yaml
# prometheus.yml

global:
  scrape_interval: 15s          # How often to scrape
  evaluation_interval: 15s      # How often to evaluate rules
  external_labels:
    cluster: 'prod'
    environment: 'production'

# Alert manager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093

# Load alert rules
rule_files:
  - 'alert_rules.yml'
  - 'recording_rules.yml'

# Scrape targets
scrape_configs:
  # Prometheus self-monitoring
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  # Application servers
  - job_name: 'app'
    static_configs:
      - targets:
          - 'app-1:3000'
          - 'app-2:3000'
          - 'app-3:3000'
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
  
  # Node exporter (server metrics)
  - job_name: 'node'
    static_configs:
      - targets:
          - 'app-1:9100'
          - 'app-2:9100'
          - 'app-3:9100'
    relabel_configs:
      - source_labels: [__address__]
        regex: '([^:]+)(?::\d+)?'
        replacement: '${1}:9100'
        target_label: __address__
  
  # Database metrics
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']
  
  # Load balancer metrics
  - job_name: 'alb'
    scrape_interval: 60s
    static_configs:
      - targets: ['alb-exporter:9100']
```

---

# 10. Application Instrumentation

Expose metrics from your application.

## Node.js with Prometheus Client

```javascript
// index.js

const express = require('express');
const prometheus = require('prom-client');

const app = express();

// Create metrics
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const httpRequestsTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

const httpErrorsTotal = new prometheus.Counter({
  name: 'http_errors_total',
  help: 'Total number of HTTP errors',
  labelNames: ['method', 'route', 'status_code']
});

const activeConnections = new prometheus.Gauge({
  name: 'active_connections',
  help: 'Number of active connections'
});

// Middleware to track metrics
app.use((req, res, next) => {
  const start = Date.now();
  activeConnections.inc();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    
    httpRequestDuration
      .labels(req.method, req.route?.path || 'unknown', res.statusCode)
      .observe(duration);
    
    httpRequestsTotal
      .labels(req.method, req.route?.path || 'unknown', res.statusCode)
      .inc();
    
    if (res.statusCode >= 400) {
      httpErrorsTotal
        .labels(req.method, req.route?.path || 'unknown', res.statusCode)
        .inc();
    }
    
    activeConnections.dec();
  });

  next();
});

// Routes
app.get('/api/posts', (req, res) => {
  // Your logic
  res.json({ posts: [] });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'healthy' });
});

// Prometheus metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(await prometheus.register.metrics());
});

app.listen(3000, () => {
  console.log('App listening on port 3000');
  console.log('Metrics available at http://localhost:3000/metrics');
});
```

## Python with Prometheus Client

```python
# app.py

from flask import Flask, Response
from prometheus_client import Counter, Histogram, Gauge, generate_latest

app = Flask(__name__)

# Create metrics
request_count = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

request_duration = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration',
    ['method', 'endpoint']
)

active_connections = Gauge(
    'active_connections',
    'Number of active connections'
)

@app.before_request
def before_request():
    active_connections.inc()

@app.after_request
def after_request(response):
    # Record metrics
    endpoint = request.endpoint or 'unknown'
    request_count.labels(
        method=request.method,
        endpoint=endpoint,
        status=response.status_code
    ).inc()
    
    active_connections.dec()
    return response

@app.route('/api/posts')
def get_posts():
    with request_duration.labels(
        method='GET',
        endpoint='get_posts'
    ).time():
        # Your logic
        return {'posts': []}

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype='text/plain')

if __name__ == '__main__':
    app.run(port=5000)
```

---

# 11. Prometheus Queries (PromQL)

Query metrics using PromQL.

## Basic Queries

```promql
# Get current value
http_requests_total

# Get current value for specific label
http_requests_total{method="GET"}
http_requests_total{method="GET", handler="/api"}

# Multiple label matchers
{job="app", instance="app-1:3000"}

# Label matching operators
http_requests_total{method!="GET"}        # Not equal
http_requests_total{handler=~"/api.*"}    # Regex
http_requests_total{handler!~".*internal"}  # Regex not match
```

## Rate & Increase

```promql
# Rate of change (derivative)
rate(http_requests_total[5m])             # Requests per second (5-minute window)
rate(http_requests_total[1h])             # Requests per second (1-hour window)

# Total increase over time
increase(http_requests_total[5m])         # Total requests in last 5 minutes

# Example: Request rate per second
rate(http_requests_total[5m])             # ~100 req/sec

# Example: Error rate
rate(http_errors_total[5m])               # ~5 errors/sec
```

## Aggregation

```promql
# Sum across all instances
sum(http_requests_total)                  # Total requests across all servers

# Sum by label
sum by (method) (http_requests_total)     # Total requests by method (GET, POST, etc)

# Sum by multiple labels
sum by (method, handler) (http_requests_total)

# Average
avg(cpu_usage_percent)                    # Average CPU usage

# Min/Max
min(memory_usage_bytes)
max(memory_usage_bytes)

# Count distinct
count(distinct http_requests_total)

# Quantiles
topk(5, http_requests_total)              # Top 5 highest
bottomk(5, http_requests_total)           # Bottom 5 lowest
```

## Filtering & Selection

```promql
# Filter by range
http_requests_total > 1000                # More than 1000 total requests

# Filter by duration
increase(http_requests_total[1h]) > 10000 # More than 10k requests per hour

# Current vs past
rate(http_requests_total[5m]) > 2 * rate(http_requests_total[1h] offset 1h)
# Alert if 5-min rate is 2x higher than it was 1 hour ago
```

## Percentiles (Histograms)

```promql
# 95th percentile latency
histogram_quantile(0.95, http_request_duration_seconds)

# 99th percentile
histogram_quantile(0.99, http_request_duration_seconds)

# 99th percentile by handler
histogram_quantile(0.99, 
  sum by (le, handler) (http_request_duration_seconds_bucket)
)
```

## Real-World Examples

```promql
# CPU usage > 80% for more than 5 minutes
cpu_usage_percent > 80

# Error rate > 5%
rate(http_errors_total[5m]) / rate(http_requests_total[5m]) > 0.05

# Memory usage > 85%
memory_usage_percent > 85

# Disk full
disk_usage_percent > 90

# Request latency p95 > 1 second
histogram_quantile(0.95, http_request_duration_seconds) > 1

# Database connections > 90% of max
pg_stat_activity_count / pg_max_connections > 0.9

# Instance down (no heartbeat)
up{job="app"} == 0

# Request rate unusually low
rate(http_requests_total[5m]) < 10
```

---

# 12. Alerting with Prometheus

Define alert rules.

## Alert Rules

```yaml
# alert_rules.yml

groups:
  - name: application
    interval: 15s
    rules:
      # Alert when error rate > 5%
      - alert: HighErrorRate
        expr: rate(http_errors_total[5m]) / rate(http_requests_total[5m]) > 0.05
        for: 5m
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }}"
      
      # Alert when response time > 1 second
      - alert: HighLatency
        expr: histogram_quantile(0.95, http_request_duration_seconds) > 1
        for: 5m
        annotations:
          summary: "High latency detected"
          description: "95th percentile latency is {{ $value }}s"
      
      # Alert when instance is down
      - alert: InstanceDown
        expr: up{job="app"} == 0
        for: 1m
        annotations:
          summary: "Instance {{ $labels.instance }} is down"
          description: "App server {{ $labels.instance }} has been down for 1 minute"

  - name: infrastructure
    interval: 15s
    rules:
      # Alert when CPU > 80%
      - alert: HighCPU
        expr: cpu_usage_percent > 80
        for: 5m
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU is {{ $value }}%"
      
      # Alert when memory > 85%
      - alert: HighMemory
        expr: memory_usage_percent > 85
        for: 5m
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory is {{ $value }}%"
      
      # Alert when disk > 90%
      - alert: DiskAlmostFull
        expr: disk_usage_percent > 90
        for: 5m
        annotations:
          summary: "Disk almost full on {{ $labels.instance }}"
          description: "Disk usage is {{ $value }}%"

  - name: database
    interval: 15s
    rules:
      # Alert when connections > 90% of max
      - alert: HighDatabaseConnections
        expr: pg_stat_activity_count / pg_max_connections > 0.9
        for: 5m
        annotations:
          summary: "Database connection pool almost full"
          description: "{{ $value | humanizePercentage }} of connections in use"
```

## Alertmanager Configuration

```yaml
# alertmanager.yml

global:
  resolve_timeout: 5m

route:
  # Default receiver
  receiver: 'default'
  
  # Alert grouping
  group_by: ['alertname', 'cluster']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  
  # Route high-severity alerts to pagerduty
  routes:
    - match:
        severity: critical
      receiver: 'pagerduty'
      continue: true
    
    - match:
        severity: warning
      receiver: 'slack'

# Receivers define where to send alerts
receivers:
  - name: 'default'
    # No configuration = silent (just log)
  
  - name: 'slack'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'
        channel: '#alerts'
        title: 'Alert: {{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
  
  - name: 'pagerduty'
    pagerduty_configs:
      - service_key: 'YOUR_SERVICE_KEY'
        description: '{{ .GroupLabels.alertname }}'
```

---

# 13. Node Exporter (Server Metrics)

Monitor server CPU, memory, disk, network.

## Install Node Exporter

```bash
# Download
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.6.0.linux-amd64.tar.gz
cd node_exporter-1.6.0.linux-amd64

# Run
./node_exporter

# Access metrics at http://localhost:9100/metrics
```

## Node Exporter Metrics

```text
CPU:
├── node_cpu_seconds_total          (CPU time in seconds)
├── node_load1                      (1-minute load average)
├── node_load5                      (5-minute load average)
└── node_load15                     (15-minute load average)

Memory:
├── node_memory_MemTotal_bytes      (Total memory)
├── node_memory_MemAvailable_bytes  (Available memory)
├── node_memory_MemFree_bytes       (Free memory)
└── node_memory_Cached_bytes        (Cached memory)

Disk:
├── node_filesystem_size_bytes      (Filesystem size)
├── node_filesystem_avail_bytes     (Available space)
└── node_filesystem_files           (Inode count)

Network:
├── node_network_receive_bytes_total   (Bytes received)
├── node_network_transmit_bytes_total  (Bytes sent)
├── node_network_receive_errs_total    (Receive errors)
└── node_network_transmit_errs_total   (Transmit errors)

Disk I/O:
├── node_disk_reads_completed_total    (Read count)
├── node_disk_writes_completed_total   (Write count)
└── node_disk_io_time_seconds_total    (I/O time)
```

## Using Node Exporter Metrics

```promql
# CPU usage percentage (user + system)
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Disk usage percentage
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100

# Network traffic (bytes/sec)
rate(node_network_receive_bytes_total[5m])

# Disk I/O (ops/sec)
rate(node_disk_reads_completed_total[5m]) + rate(node_disk_writes_completed_total[5m])
```

---

# 14. Grafana Dashboard

Visualize metrics with Grafana.

## Install Grafana

```bash
# Docker
docker run -d \
  --name grafana \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  grafana/grafana

# Access at http://localhost:3000 (admin/admin)
```

## Add Prometheus Data Source

```bash
# In Grafana UI:
1. Settings → Data Sources
2. Add → Prometheus
3. URL: http://prometheus:9090
4. Click "Save & Test"
```

## Create Dashboard

```json
{
  "dashboard": {
    "title": "Application Monitoring",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Error Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(http_errors_total[5m]) / rate(http_requests_total[5m])"
          }
        ],
        "unit": "percentunit"
      },
      {
        "title": "Latency (p95)",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, http_request_duration_seconds)"
          }
        ]
      },
      {
        "title": "Active Connections",
        "type": "stat",
        "targets": [
          {
            "expr": "active_connections"
          }
        ]
      }
    ]
  }
}
```

---

# 15. Integration: Blog Application Monitoring

Monitor your blog app infrastructure.

## Application Metrics

```javascript
// Your app exports metrics:
// - http_requests_total
// - http_errors_total
// - http_request_duration_seconds
// - active_connections
// - database_query_duration_seconds
```

## Server Metrics (Node Exporter)

```promql
# CPU on app servers
100 - (avg by (instance) (irate(node_cpu_seconds_total{job="node", instance=~"app-.*"}[5m])) * 100)

# Memory on app servers
(1 - (node_memory_MemAvailable_bytes{job="node", instance=~"app-.*"} / node_memory_MemTotal_bytes)) * 100

# Disk on app servers
(1 - (node_filesystem_avail_bytes{job="node", instance=~"app-.*"} / node_filesystem_size_bytes)) * 100
```

## Alert Rules for Blog

```yaml
# alert_rules.yml for blog app

groups:
  - name: blog-app
    rules:
      # Alert if error rate > 5%
      - alert: BlogAppHighErrorRate
        expr: rate(http_errors_total{job="app"}[5m]) / rate(http_requests_total{job="app"}[5m]) > 0.05
        for: 5m
        annotations:
          severity: warning
          summary: "Blog app error rate high"
      
      # Alert if latency p95 > 1 second
      - alert: BlogAppHighLatency
        expr: histogram_quantile(0.95, http_request_duration_seconds{job="app"}) > 1
        for: 5m
        annotations:
          severity: warning
          summary: "Blog app latency high"
      
      # Alert if any app instance is down
      - alert: BlogAppInstanceDown
        expr: up{job="app"} == 0
        for: 1m
        annotations:
          severity: critical
          summary: "Blog app instance {{ $labels.instance }} is down"
      
      # Alert if CPU > 80%
      - alert: BlogAppHighCPU
        expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{job="node", instance=~"app-.*"}[5m])) * 100) > 80
        for: 5m
        annotations:
          severity: warning
          summary: "Blog app CPU high on {{ $labels.instance }}"
```

## Grafana Dashboard for Blog

```json
{
  "dashboard": {
    "title": "Blog Application",
    "panels": [
      {
        "title": "Request Rate (req/sec)",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{job=\"app\"}[5m]))"
          }
        ]
      },
      {
        "title": "Error Rate (%)",
        "targets": [
          {
            "expr": "sum(rate(http_errors_total{job=\"app\"}[5m])) / sum(rate(http_requests_total{job=\"app\"}[5m])) * 100"
          }
        ]
      },
      {
        "title": "Latency p95 (ms)",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, http_request_duration_seconds{job=\"app\"}) * 1000"
          }
        ]
      },
      {
        "title": "Active Connections",
        "targets": [
          {
            "expr": "sum(active_connections{job=\"app\"})"
          }
        ]
      },
      {
        "title": "Database Query Time p95 (ms)",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, database_query_duration_seconds) * 1000"
          }
        ]
      },
      {
        "title": "Server CPU Usage (%)",
        "targets": [
          {
            "expr": "100 - (avg by (instance) (irate(node_cpu_seconds_total{job=\"node\", instance=~\"app-.*\"}[5m])) * 100)"
          }
        ]
      },
      {
        "title": "Server Memory Usage (%)",
        "targets": [
          {
            "expr": "(1 - (node_memory_MemAvailable_bytes{job=\"node\", instance=~\"app-.*\"} / node_memory_MemTotal_bytes)) * 100"
          }
        ]
      },
      {
        "title": "Disk Usage (%)",
        "targets": [
          {
            "expr": "(1 - (node_filesystem_avail_bytes{job=\"node\", instance=~\"app-.*\"} / node_filesystem_size_bytes)) * 100"
          }
        ]
      }
    ]
  }
}
```

---

# 16. Learning Path for Prometheus + Grafana

## Week 1: Prometheus Basics

```text
DAY 1:
├── Install Prometheus locally
├── Start Prometheus
├── Access web UI (port 9090)
└── Query prometheus_up

DAY 2:
├── Install Node Exporter
├── Add to Prometheus scrape config
├── Query node_cpu_seconds_total
└── Query node_memory_MemTotal_bytes

DAY 3:
├── Write basic PromQL queries
├── Query with labels
├── Use rate() function
└── Practice range queries

DAY 4-5:
├── Create alert rules
├── Start Alertmanager
├── Configure Slack notifications
└── Test alerts work
```

## Week 2: Application Monitoring

```text
DAY 6-7:
├── Add Prometheus client to app
├── Expose /metrics endpoint
├── Create custom metrics (counter, gauge)
├── Scrape app metrics

DAY 8-9:
├── Install Grafana
├── Add Prometheus as datasource
├── Create simple dashboard
├── Add multiple panels

DAY 10-12:
├── Advanced PromQL (histograms, quantiles)
├── Alert rules for application
├── Beautiful Grafana dashboards
└── Project: Complete monitoring setup
```

## Week 3: Production Monitoring

```text
DAY 13-14:
├── Setup Prometheus HA
├── Long-term storage (Thanos)
├── Recording rules
├── SLA dashboards

DAY 15:
├── Monitoring best practices
├── Troubleshooting guide
├── Team onboarding
└── Dashboard library
```

## Project Ideas

```text
PROJECT 1 (Week 1):
└── Monitor local machine with Node Exporter

PROJECT 2 (Week 2):
├── Monitor blog application
├── Create Grafana dashboard
├── Setup alerts for app metrics

PROJECT 3 (Week 2-3):
├── Monitor all 3 blog app servers
├── Aggregate metrics
├── Alert on high load

PROJECT 4 (Week 3):
├── Monitor entire infrastructure
├── EC2 instances (Node Exporter)
├── Application (custom metrics)
├── Database (PostgreSQL exporter)
├── Load balancer (custom exporter)
└── Complete production setup
```

---

# 17. Prometheus vs Alternatives

```text
SCENARIO: Learning monitoring

Prometheus:
├── Easiest to learn
├── Start in 5 minutes
├── Perfect for cloud-native
└── BEST ✓✓✓

Datadog:
├── Easiest setup overall
├── But: Expensive ($15-25/host)
├── Vendor lock-in
└── Better for companies, not learning

Zabbix:
├── Powerful but complex
├── Steep learning curve
├── Too much for beginners
└── Not recommended

─────────────────────────────

SCENARIO: What to visualize

Prometheus + Grafana:
├── Both FREE
├── Unlimited dashboards
├── Perfect combination
└── BEST ✓✓✓

Datadog:
├── Built-in dashboards
├── But: Can't customize freely

Zabbix:
├── Has UI but dated

─────────────────────────────

SCENARIO: Alerting

Prometheus + Alertmanager:
├── Powerful alert rules
├── Multiple integrations
├── Complete control
└── BEST ✓✓✓

Datadog:
├── Good alerting
├── But: Expensive

Zabbix:
├── Mature alerting
├── Complex setup
```

---

# Quick Reference Commands

```bash
# Prometheus
prometheus --config.file=prometheus.yml
curl http://localhost:9090/api/v1/query?query=up

# Node Exporter
node_exporter --textfile.directory=/var/node_exporter

# Alertmanager
alertmanager --config.file=alertmanager.yml

# Query Prometheus (curl)
curl 'http://localhost:9090/api/v1/query?query=http_requests_total'

# Prometheus HTTP API
# Query: GET /api/v1/query?query=<expr>
# Range: GET /api/v1/query_range?query=<expr>&start=<time>&end=<time>&step=<seconds>
# Metadata: GET /api/v1/targets

# Useful PromQL
rate(metric[5m])                              # Rate of change
increase(metric[1h])                          # Total increase
sum by (label) (metric)                       # Sum by label
avg(metric)                                   # Average
histogram_quantile(0.95, metric)              # 95th percentile
topk(5, metric)                               # Top 5 values
```

---

# Summary: Monitoring Decision

```
┌────────────────────────────────────────────────┐
│                                                │
│  ✓ CHOICE: PROMETHEUS + GRAFANA               │
│  ✓ COST: FREE ✓                               │
│  ✓ LEARNING TIME: 1-2 weeks                   │
│  ✓ PLATFORM: Cloud-native (perfect fit)       │
│  ✓ POWER: Industrial-grade monitoring         │
│  ✓ CAREER VALUE: Highest in cloud market      │
│  ✓ START: Today with Docker                   │
│                                                │
│  INTEGRATION WITH YOUR STACK:                 │
│  ├─ Monitor EC2 (Node Exporter)              │
│  ├─ Monitor app (custom metrics)              │
│  ├─ Monitor database (exporter)               │
│  ├─ Monitor load balancer (custom)            │
│  ├─ Alert in Slack / PagerDuty               │
│  └─ All FREE and open-source!                │
│                                                │
│  PROMETHEUS + GRAFANA IS:                    │
│  ├─ Industry standard for cloud              │
│  ├─ Used by CNCF projects                    │
│  ├─ Skills apply everywhere                  │
│  ├─ Unlimited scalability                    │
│  └─ Perfect for learning                     │
│                                                │
└────────────────────────────────────────────────┘
```

---

# Complete Learning Path Summary

Your DevOps journey:

```
1. cloud-serverless.md          ← Where to deploy
2. provisioning.md              ← How to provision (Terraform)
3. configuration-management.md  ← How to configure (Ansible)
4. ci-cd-tools.md              ← How to automate (GitHub Actions)
5. secret-management.md         ← How to secure (Vault)
6. infrastructure-monitoring.md ← How to monitor (Prometheus)
7. integrated-devops-project.md ← How it all works (blog app)

ALL CONNECTED - ONE COMPLETE SYSTEM!
```

---

# Resources & Learning

## Official Resources

- [Prometheus Official Docs](https://prometheus.io/docs)
- [Prometheus Query Examples](https://prometheus.io/docs/prometheus/latest/querying/examples/)
- [Grafana Official Docs](https://grafana.com/docs)
- [Alertmanager Docs](https://prometheus.io/docs/alerting/latest/overview/)

## Learning Resources

- [Prometheus Getting Started](https://prometheus.io/docs/prometheus/latest/getting_started/)
- [Grafana Getting Started](https://grafana.com/grafana/getting-started/)
- [Node Exporter](https://github.com/prometheus/node_exporter)
- [Prometheus Exporters](https://prometheus.io/docs/instrumenting/exporters/)

## Community

- [Prometheus Community](https://prometheus.io/community/)
- [Grafana Community](https://community.grafana.com/)
- [Stack Overflow #prometheus](https://stackoverflow.com/questions/tagged/prometheus)
- [CNCF Landscape](https://landscape.cncf.io/) - Monitoring tools

---

**Last Updated:** August 24, 2026
**Curated for:** DevOps Learning Path
**Integration:** Works with Terraform, Ansible, GitHub Actions, Kubernetes
**Recommendation:** Choose Prometheus + Grafana & start today!
**Perfect for:** Your blog application infrastructure!
