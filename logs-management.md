# Log Management & Analysis

## Elastic Stack, Loki, Papertrail & Graylog

Log Management is collecting, aggregating, searching, and analyzing logs from your infrastructure and applications. Logs tell you WHAT happened, while metrics tell you HOW it happened.

The main log management tools covered in this guide are:

* Elastic Stack (Elasticsearch + Kibana + Beats)
* Loki (Prometheus-style logging)
* Papertrail (commercial log aggregation)
* Graylog (self-hosted log management)

---

# 1. What Is Log Management?

## Without Log Management (The Problem)

```text
Your application crashes!

To find the error:
├─ SSH into server 1
├─ tail -f /var/log/app.log
├─ Can't find error, check server 2
├─ SSH into server 2
├─ tail -f /var/log/app.log
├─ Still nothing, check server 3
├─ SSH into server 3
├─ Found it! 4000 lines, 1 error
└─ 30 minutes wasted searching!

Problems:
├─ Logs scattered across servers
├─ Logs rotate and disappear
├─ Can't search across servers
├─ No full context
├─ No correlation between services
└─ Manual + slow
```

## With Log Management (The Solution)

```text
Your application crashes!

In log management:
├─ Open Kibana (centralized dashboard)
├─ Search: "error"
├─ Instantly see all errors (all servers)
├─ Click on error to see full context
├─ See related logs from other services
├─ Trace request across entire system
└─ Found root cause in 2 minutes!

Benefits:
✓ Centralized (all logs in one place)
✓ Searchable (find anything instantly)
✓ Correlated (see related events)
✓ Retained (keep logs forever)
✓ Analyzed (find patterns)
✓ Alerted (notify on issues)
```

## Logs vs Metrics

```text
METRICS (Prometheus):
├─ What: Quantitative measurements
├─ Example: CPU=80%, Memory=4GB, Requests=1000/sec
├─ Time: Point-in-time values
├─ Storage: Very efficient
├─ Queries: Fast aggregations
└─ Use: Performance & capacity

LOGS (Elastic/Loki):
├─ What: Detailed text records
├─ Example: "User login failed: invalid password"
├─ Time: Full event records
├─ Storage: More space needed
├─ Queries: Full-text search
└─ Use: Debugging & analysis

TOGETHER:
├─ Metrics say "what's wrong" (CPU high)
├─ Logs say "why it's wrong" (query slow)
└─ Traces say "how it happened" (call sequence)
```

---

# 2. Log Architecture

```text
┌────────────────────────────────────────────────────┐
│            LOG MANAGEMENT ARCHITECTURE            │
└────────────────────────────────────────────────────┘

LOG SOURCES (Where logs come from):
├── Applications (stdout, files)
├── Servers (syslog, system logs)
├── Docker containers (STDOUT/STDERR)
├── Kubernetes pods (logs)
├── Load balancers (access logs)
├── Databases (query logs)
├── Firewalls (security logs)
└── Custom applications

                    │
                    ▼

LOG COLLECTION (How to collect):
├── Beats (lightweight agents)
├── Fluentd (open-source agent)
├── Logstash (parse & transform)
├── Fluent Bit (minimal agent)
└── Custom collectors

                    │
                    ▼

LOG PARSING & ENRICHMENT:
├── Parse unstructured text
├── Add context (hostname, service, version)
├── Extract fields (timestamp, level, message)
├── Correlate with other logs
└── Add metadata

                    │
                    ▼

LOG STORAGE (Where to store):
├── Elasticsearch (distributed search engine)
├── InfluxDB (time-series)
├── S3 (cold storage/archive)
└── Local files (retention)

                    │
                    ▼

LOG SEARCH & VISUALIZATION:
├── Kibana (Elasticsearch UI)
├── Grafana Loki (log queries)
├── Custom dashboards
└── Full-text search

                    │
                    ▼

ALERTING & ACTIONS:
├── Alert on error patterns
├── Create incidents
├── Trigger remediation
└── Notify team
```

---

# 3. Quick Comparison: All 4 Tools

```text
┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│   Feature    │ Elastic      │ Loki         │ Papertrail   │ Graylog      │
├──────────────┼──────────────┼──────────────┼──────────────┼──────────────┤
│ Cost         │ FREE/Paid    │ FREE ✓       │ Paid         │ FREE ✓       │
│ Type         │ Full-featured│ Lightweight  │ Cloud SaaS   │ On-premise   │
│ Setup        │ Medium       │ Easy         │ Very Easy    │ Complex      │
│ Learning     │ Medium       │ Easy         │ Easy         │ Hard         │
│ Storage      │ Elasticsearch│ S3/Object    │ Cloud        │ MongoDB      │
│ Search       │ Powerful ✓   │ Simple       │ Basic        │ Good         │
│ Scalability  │ Excellent ✓  │ Excellent    │ Unlimited    │ Good         │
│ Best For     │ Everything   │ K8s/Loki     │ SaaS apps    │ Traditional  │
│ Retention    │ Configurable │ Configurable │ Service plan │ Configurable │
│ Alerting     │ Native       │ Via Prom     │ Limited      │ Native       │
│ Performance  │ Excellent    │ Excellent    │ Excellent    │ Good         │
│ Community    │ HUGE ✓       │ HUGE ✓       │ Commercial   │ Growing      │
└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘
```

---

# 4. My Recommendation: Elastic Stack

## Why Choose Elastic Stack?

```text
ELASTIC STACK IS BEST FOR LEARNING BECAUSE:

✓ COMPLETE SOLUTION
  └── Elasticsearch (storage & search)
  └── Kibana (visualization)
  └── Beats (collection)
  └── Logstash (processing)
  └── All integrated

✓ MOST POWERFUL & FLEXIBLE
  └── Handles any log format
  └── Scales to petabytes
  └── Advanced search queries
  └── Custom visualizations

✓ INDUSTRY STANDARD
  └── Used by major companies
  └── Most job opportunities
  └── Largest community
  └── Thousands of tutorials

✓ WORKS WITH EVERYTHING
  └── Docker containers
  └── Kubernetes pods
  └── VMs & servers
  └── Databases
  └── Cloud services

✓ WORKS WITH YOUR STACK
  └── Collect from apps (Beats)
  └── Parse logs (Logstash)
  └── Search in Kibana
  └── Alert on patterns
  └── Integrate with Prometheus

✓ PERFECT FOR LEARNING
  └── Docker Compose setup
  └── Start in 5 minutes
  └── Understand fundamentals
  └── Scale to enterprise

ALTERNATIVE CONSIDERATIONS:

Loki:
├── Better for: Kubernetes-only
├── Advantage: Lightweight, low storage
└── Disadvantage: Less powerful than Elastic

Papertrail:
├── Better for: Quick setup, SaaS
├── Advantage: Zero maintenance
└── Disadvantage: Expensive ($30-500/month)

Graylog:
├── Better for: On-premise only
├── Advantage: Web UI
└── Disadvantage: Complex setup
```

**FINAL ANSWER: Choose Elastic Stack. Most powerful, most used, best ROI.**

---

# 5. Quick Overview: Loki

## What Is Loki?

Loki is a log aggregation system designed for Kubernetes. Similar to Prometheus but for logs.

## Simple Loki Example

```yaml
# docker-compose.yml

version: '3'

services:
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - ./loki-config.yml:/etc/loki/local-config.yaml
    command: -config.file=/etc/loki/local-config.yaml

  promtail:
    image: grafana/promtail:latest
    volumes:
      - /var/log:/var/log
      - ./promtail-config.yml:/etc/promtail/config.yml
    command: -config.file=/etc/promtail/config.yml

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
```

## Loki Pros & Cons

```text
PROS:
✓ Lightweight & efficient
✓ Kubernetes-native
✓ Works with Prometheus
✓ Low storage requirements
✓ FREE & open-source

CONS:
✗ Kubernetes-only
✗ Less powerful search
✗ Smaller community
✗ Limited integrations
```

---

# 6. Quick Overview: Papertrail

## What Is Papertrail?

Papertrail is a cloud-based log aggregation service. Simple setup, zero maintenance.

## Papertrail Features

```text
CLOUD LOGGING:
├── Automatic log forwarding
├── Web-based search
├── Real-time log viewing
└── Log retention based on plan

PRICING:
├── Free: 1 month retention, 100MB/day
├── $14/month: 1 year retention, 5GB/day
├── $49/month: 1 year retention, 100GB/day
└── Custom enterprise pricing

SETUP:
├── Add 1 line to syslog config
├── Or use Logstash output
├── Or use Docker environment variable
└── Done!
```

## Papertrail Pros & Cons

```text
PROS:
✓ Easiest setup
✓ No infrastructure
✓ Good free tier
✓ Great support

CONS:
✗ Expensive for large volume
✗ Limited search power
✗ Vendor lock-in
✗ Limited customization
```

---

# 7. Quick Overview: Graylog

## What Is Graylog?

Graylog is a self-hosted log aggregation system with web UI.

## Graylog Features

```text
FEATURES:
├── Log parsing & processing
├── Full-text search
├── Alerting & notifications
├── Dashboards & reporting
├── Field extraction
└── Multi-tenancy

STORAGE:
├── MongoDB (metadata)
├── Elasticsearch (logs)
└── Custom fields
```

## Graylog Pros & Cons

```text
PROS:
✓ On-premise (data control)
✓ Web UI
✓ Free tier available
✓ Good for traditional IT

CONS:
✗ Complex setup
✗ Requires Elasticsearch
✗ Requires MongoDB
✗ Steeper learning curve
✗ Smaller community
```

---

# 8. Elastic Stack: Detailed Guide

Since Elastic Stack is the best choice for you, here's the detailed guide.

## What Is Elastic Stack?

Elastic Stack (formerly ELK Stack) is a complete log management solution:
- **Elasticsearch**: Distributed search engine & storage
- **Kibana**: Visualization & exploration UI
- **Beats**: Lightweight data collectors
- **Logstash**: Parse, process, pipeline logs

## Elastic Stack Architecture

```text
┌────────────────────────────────────────────────────┐
│         ELASTIC STACK ARCHITECTURE                 │
└────────────────────────────────────────────────────┘

LOG SOURCES:
├── Applications (stdout, files)
├── Docker (container logs)
├── Kubernetes (pod logs)
├── Servers (syslog, system logs)
└── Load balancers (access logs)

        │
        │ Collect with Beats
        ▼

BEATS (Lightweight agents):
├── Filebeat (collect files)
├── Metricbeat (collect metrics)
├── Packetbeat (collect network)
├── Auditbeat (collect audit logs)
└── Heartbeat (check availability)

        │
        │ Send to
        ▼

LOGSTASH (Optional processing):
├── Parse logs
├── Extract fields
├── Enrich data
└── Filter/transform

        │
        │ Send to
        ▼

ELASTICSEARCH (Storage & search):
├── Store logs
├── Index for fast search
├── Distribute across nodes
└── High availability

        │
        │ Query via
        ▼

KIBANA (Visualization):
├── Explore logs
├── Create dashboards
├── Set up alerts
└── Analyze patterns
```

## Core Concepts

```text
INDEX:           Container for logs (like database table)
DOCUMENT:        Single log entry (like database row)
FIELD:           Property of a log (like column)
MAPPING:         Schema defining fields
SHARD:           Part of index (distribution)
REPLICA:         Copy of shard (redundancy)
NODE:            Elasticsearch server
CLUSTER:         Group of Elasticsearch nodes
```

---

# 9. Installing Elastic Stack

## Quick Start with Docker Compose

```yaml
# docker-compose.yml

version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.9.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - es-data:/usr/share/elasticsearch/data

  kibana:
    image: docker.elastic.co/kibana/kibana:8.9.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

  filebeat:
    image: docker.elastic.co/beats/filebeat:8.9.0
    user: root
    volumes:
      - ./filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    command: filebeat -e -strict.perms=false
    depends_on:
      - elasticsearch

volumes:
  es-data:
```

## Filebeat Configuration

```yaml
# filebeat.yml

filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/*.log
      - /var/log/*/*.log
    fields:
      service: system
  
  - type: log
    enabled: true
    paths:
      - /var/lib/docker/containers/*/*.log
    fields:
      service: docker
    processors:
      - add_docker_metadata:
          host: "unix:///var/run/docker.sock"

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  index: "logs-%{+yyyy.MM.dd}"

logging.level: info
```

---

# 10. Elasticsearch Indexing

## Index Configuration

```json
// Create index with mapping
PUT logs-app-2024.01.15
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1,
    "refresh_interval": "5s"
  },
  "mappings": {
    "properties": {
      "timestamp": {
        "type": "date",
        "format": "strict_date_optional_time"
      },
      "level": {
        "type": "keyword"
      },
      "message": {
        "type": "text",
        "analyzer": "standard"
      },
      "service": {
        "type": "keyword"
      },
      "host": {
        "type": "keyword"
      },
      "request_id": {
        "type": "keyword"
      },
      "user_id": {
        "type": "keyword"
      },
      "duration_ms": {
        "type": "integer"
      }
    }
  }
}
```

## Ingest Pipeline (Process Logs)

```json
// Create ingest pipeline
PUT _ingest/pipeline/parse-app-logs
{
  "description": "Parse application logs",
  "processors": [
    {
      "grok": {
        "field": "message",
        "patterns": [
          "%{TIMESTAMP_ISO8601:timestamp} \\[%{DATA:level}\\] %{DATA:logger} - %{GREEDYDATA:message}"
        ]
      }
    },
    {
      "date": {
        "field": "timestamp",
        "target_field": "@timestamp",
        "formats": ["ISO8601"]
      }
    },
    {
      "remove": {
        "field": "timestamp"
      }
    }
  ]
}
```

---

# 11. Beating: Collecting Logs with Beats

## Filebeat (Collect files)

```yaml
# filebeat.yml for application logs

filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /opt/app/logs/*.log
    multiline.pattern: '^\['
    multiline.negate: true
    multiline.match: after
    fields:
      service: app
      environment: prod

  - type: log
    enabled: true
    paths:
      - /var/log/nginx/access.log
    fields:
      service: nginx
    processors:
      - decode_json_fields:
          fields: ["message"]

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  index: "logs-%{+yyyy.MM.dd}"
  pipeline: "parse-app-logs"

processors:
  - add_host_metadata: ~
  - add_process_metadata: ~
  - add_docker_metadata: ~
```

## Metricbeat (Collect system metrics)

```yaml
# metricbeat.yml

metricbeat.modules:
  - module: system
    period: 10s
    metricsets:
      - cpu
      - memory
      - network
      - process
    processes: ['.*']
  
  - module: docker
    period: 10s
    metricsets:
      - container
      - cpu
      - memory

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
  index: "metrics-%{+yyyy.MM.dd}"
```

---

# 12. Kibana: Searching & Visualizing

## Basic Search

```
# Simple searches in Kibana

// Find all errors
level: "ERROR"

// Find errors in specific service
level: "ERROR" AND service: "app"

// Find specific message
message: "database connection timeout"

// Find by request ID
request_id: "req-123-456"

// Time range filtering (automatic in Kibana UI)
```

## Kibana Query Language (KQL)

```
# Advanced searches

// Boolean operators
level: "ERROR" OR level: "WARN"
level: "ERROR" AND service: "app"
message: "timeout" AND duration_ms: > 5000

// Wildcard
service: app-*

// Range queries
duration_ms: >= 1000
timestamp: >= now-1h

// Field exists
user_id: *

// Nested fields
response.status_code: 500
```

## Creating Dashboards

```json
{
  "dashboard": {
    "title": "Application Logs",
    "panels": [
      {
        "title": "Log Volume by Level",
        "visualization": "pie",
        "query": "*",
        "agg": {
          "field": "level",
          "type": "terms"
        }
      },
      {
        "title": "Errors Over Time",
        "visualization": "area",
        "query": "level: ERROR",
        "agg": {
          "field": "@timestamp",
          "type": "date_histogram",
          "interval": "1m"
        }
      },
      {
        "title": "Top Services",
        "visualization": "bar",
        "query": "*",
        "agg": {
          "field": "service",
          "type": "terms",
          "size": 10
        }
      },
      {
        "title": "Recent Errors",
        "visualization": "table",
        "query": "level: ERROR",
        "columns": ["timestamp", "service", "message", "duration_ms"]
      }
    ]
  }
}
```

---

# 13. Application Log Shipping

## Node.js Application

```javascript
// app.js with winston logger

const winston = require('winston');
const ElasticsearchTransport = require('winston-elasticsearch');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    // Console output
    new winston.transports.Console({
      format: winston.format.simple()
    }),
    
    // Send to Elasticsearch
    new ElasticsearchTransport({
      level: 'info',
      clientOpts: { node: 'http://elasticsearch:9200' },
      index: 'logs-app'
    })
  ]
});

// Log application events
const express = require('express');
const app = express();

app.get('/api/posts', (req, res) => {
  const start = Date.now();
  
  try {
    // Your logic
    const posts = [];
    const duration = Date.now() - start;
    
    logger.info('GET /api/posts', {
      service: 'app',
      method: 'GET',
      path: '/api/posts',
      status: 200,
      duration_ms: duration,
      request_id: req.id
    });
    
    res.json(posts);
  } catch (error) {
    const duration = Date.now() - start;
    
    logger.error('GET /api/posts failed', {
      service: 'app',
      method: 'GET',
      path: '/api/posts',
      error: error.message,
      stack: error.stack,
      duration_ms: duration,
      request_id: req.id
    });
    
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.listen(3000);
```

## Docker Container Logs

```yaml
# docker-compose.yml with ELK

version: '3'

services:
  app:
    image: myapp:latest
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service=app,environment=prod"

  filebeat:
    image: docker.elastic.co/beats/filebeat:8.9.0
    volumes:
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - ./filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
```

## Kubernetes Pod Logs

```yaml
# values.yaml for Helm Filebeat chart

filebeat:
  enabled: true
  config:
    filebeat.inputs:
      - type: container
        paths:
          - /var/log/containers/*-${data.kubernetes.pod.name}_${data.kubernetes.namespace}_*.log
        processors:
          - add_kubernetes_metadata:
              in_cluster: true

    output.elasticsearch:
      hosts: ["elasticsearch:9200"]
      index: "logs-k8s-%{+yyyy.MM.dd}"
```

---

# 14. Alerting in Elasticsearch

## Alert Rules

```json
// Create watcher rule (Elasticsearch alerting)

PUT _watcher/watch/high_error_rate
{
  "trigger": {
    "schedule": {
      "interval": "5m"
    }
  },
  "input": {
    "search": {
      "request": {
        "indices": ["logs-*"],
        "body": {
          "query": {
            "bool": {
              "must": [
                { "match": { "level": "ERROR" } },
                { "range": { "@timestamp": { "gte": "now-5m" } } }
              ]
            }
          },
          "aggs": {
            "error_count": {
              "value_count": { "field": "_id" }
            }
          }
        }
      }
    }
  },
  "condition": {
    "compare": {
      "ctx.payload.aggregations.error_count.value": { "gt": 100 }
    }
  },
  "actions": {
    "send_slack": {
      "slack": {
        "message": {
          "from": "Elasticsearch Alert",
          "to": "#alerts",
          "text": "High error rate detected! {{ ctx.payload.aggregations.error_count.value }} errors in last 5 minutes"
        }
      }
    }
  }
}
```

## Kibana Alerts

```javascript
// Create Kibana alert rule

PUT /api/alerting/rule
{
  "name": "High Error Rate",
  "ruleTypeId": "logs.alert_condition",
  "enabled": true,
  "consumer": "logs",
  "schedule": {
    "interval": "5m"
  },
  "params": {
    "index": "logs-*",
    "timeField": "@timestamp",
    "timeSize": 5,
    "timeUnit": "m",
    "groupBy": "service",
    "logView": {
      "id": "default"
    },
    "criteria": [
      {
        "field": "level",
        "comparator": "equals",
        "value": "ERROR"
      }
    ],
    "threshold": {
      "comparator": "gt",
      "value": 50
    },
    "alertOnGroupDisappear": true
  },
  "actions": [
    {
      "group": "threshold met",
      "actionTypeId": ".slack",
      "params": {
        "message": "Alert: High error rate in {{ rule.name }}"
      }
    }
  ]
}
```

---

# 15. Integration: Blog Application Logging

## Application Logs

```javascript
// app.js - Blog application with structured logging

const logger = require('./logger');

app.get('/api/posts', async (req, res) => {
  const startTime = Date.now();
  const requestId = req.headers['x-request-id'] || crypto.randomUUID();
  
  logger.info('request_started', {
    service: 'blog-app',
    request_id: requestId,
    method: 'GET',
    path: '/api/posts',
    user_id: req.user?.id
  });
  
  try {
    const posts = await db.posts.find();
    const duration = Date.now() - startTime;
    
    logger.info('request_completed', {
      service: 'blog-app',
      request_id: requestId,
      method: 'GET',
      path: '/api/posts',
      status: 200,
      duration_ms: duration,
      records_returned: posts.length,
      user_id: req.user?.id
    });
    
    res.json(posts);
  } catch (error) {
    const duration = Date.now() - startTime;
    
    logger.error('request_failed', {
      service: 'blog-app',
      request_id: requestId,
      method: 'GET',
      path: '/api/posts',
      status: 500,
      duration_ms: duration,
      error_message: error.message,
      error_stack: error.stack,
      user_id: req.user?.id
    });
    
    res.status(500).json({ error: 'Internal server error' });
  }
});
```

## Kibana Dashboard for Blog

```json
{
  "dashboard": {
    "title": "Blog Application Logs",
    "panels": [
      {
        "title": "Request Volume",
        "type": "timeseries",
        "query": "service:blog-app",
        "metric": "count"
      },
      {
        "title": "Error Rate",
        "type": "stat",
        "query": "service:blog-app AND level:ERROR",
        "calculation": "percentage"
      },
      {
        "title": "Average Response Time",
        "type": "stat",
        "query": "service:blog-app",
        "metric": "avg(duration_ms)"
      },
      {
        "title": "Errors by Type",
        "type": "pie",
        "query": "service:blog-app AND level:ERROR",
        "groupBy": "error_message"
      },
      {
        "title": "Slowest Requests",
        "type": "table",
        "query": "service:blog-app",
        "sort": "duration_ms desc",
        "limit": 20
      },
      {
        "title": "Recent Errors",
        "type": "logs",
        "query": "service:blog-app AND level:ERROR",
        "columns": ["timestamp", "method", "path", "status", "error_message", "request_id"]
      }
    ]
  }
}
```

## Alert Rules for Blog

```json
// Alert: High error rate
PUT _watcher/watch/blog_high_error_rate
{
  "trigger": { "schedule": { "interval": "5m" } },
  "input": {
    "search": {
      "request": {
        "indices": ["logs-*"],
        "body": {
          "query": {
            "bool": {
              "must": [
                { "term": { "service": "blog-app" } },
                { "term": { "level": "ERROR" } },
                { "range": { "@timestamp": { "gte": "now-5m" } } }
              ]
            }
          },
          "aggs": { "error_count": { "value_count": { "field": "_id" } } }
        }
      }
    }
  },
  "condition": {
    "compare": { "ctx.payload.aggregations.error_count.value": { "gt": 50 } }
  },
  "actions": {
    "send_slack": {
      "slack": {
        "message": {
          "text": "Alert: Blog app high error rate ({{ ctx.payload.aggregations.error_count.value }} errors)"
        }
      }
    }
  }
}

// Alert: Slow responses
PUT _watcher/watch/blog_slow_responses
{
  "trigger": { "schedule": { "interval": "5m" } },
  "input": {
    "search": {
      "request": {
        "indices": ["logs-*"],
        "body": {
          "query": {
            "bool": {
              "must": [
                { "term": { "service": "blog-app" } },
                { "range": { "duration_ms": { "gte": 1000 } } },
                { "range": { "@timestamp": { "gte": "now-5m" } } }
              ]
            }
          },
          "aggs": { "slow_count": { "value_count": { "field": "_id" } } }
        }
      }
    }
  },
  "condition": {
    "compare": { "ctx.payload.aggregations.slow_count.value": { "gt": 20 } }
  },
  "actions": {
    "send_slack": {
      "slack": {
        "message": {
          "text": "Alert: Blog app slow responses ({{ ctx.payload.aggregations.slow_count.value }} requests > 1s)"
        }
      }
    }
  }
}
```

---

# 16. Learning Path for Elastic Stack

## Week 1: Fundamentals

```text
DAY 1:
├── Install Elasticsearch locally
├── Install Kibana
├── Access Kibana UI (localhost:5601)
└── Create test index

DAY 2:
├── Learn Elasticsearch mapping
├── Create index with fields
├── Insert test documents
└── Practice basic queries

DAY 3:
├── Install Filebeat
├── Configure to read files
├── Send logs to Elasticsearch
└── Search logs in Kibana

DAY 4-5:
├── Learn KQL (Kibana Query Language)
├── Create dashboards
├── Add visualizations
└── Project: Monitor local logs
```

## Week 2: Application Logging

```text
DAY 6-7:
├── Add logger to Node.js app
├── Send logs to Elasticsearch
├── Structured logging (JSON)
├── Fields and metadata

DAY 8-9:
├── Log aggregation setup
├── Multiple sources
├── Dashboard for app logs
└── Error tracking

DAY 10-12:
├── Alert on error patterns
├── Create Watcher rules
├── Slack notifications
└── Project: Full logging stack
```

## Week 3: Production Monitoring

```text
DAY 13-14:
├── Elasticsearch performance
├── Index lifecycle management
├── Log retention policies
├── Scaling Elasticsearch

DAY 15:
├── Production best practices
├── Security & access control
├── Backup & recovery
└── Team training
```

## Project Ideas

```text
PROJECT 1 (Week 1):
└── Log file aggregation from server

PROJECT 2 (Week 2):
├── Blog app logging
├── Elasticsearch + Kibana
├── Search & dashboards

PROJECT 3 (Week 2-3):
├── Multi-service logging
├── Blog app + database + cache
├── Correlated logging (request IDs)

PROJECT 4 (Week 3):
├── Full production stack
├── All services logged
├── Alerts + dashboards
├── 30-day retention
```

---

# 17. Best Practices

```text
LOGGING PRACTICES:

DO:
✓ Use structured logging (JSON)
✓ Include request IDs (trace requests)
✓ Log at appropriate levels (ERROR, WARN, INFO, DEBUG)
✓ Include context (service, environment, version)
✓ Log entry & exit of functions
✓ Log errors with stack trace
✓ Set log rotation policy
✓ Monitor log volume
✓ Archive old logs
✓ Use consistent field names

DON'T:
✗ Log sensitive data (passwords, tokens)
✗ Log redundant information
✗ Use unstructured log format
✗ Leave debug logs in production
✗ Log too much (expensive storage)
✗ Log too little (can't debug)
✗ Mix different log formats
✗ Forget to clean old logs
✗ Expose logs publicly
```

## Security

```text
SECURITY BEST PRACTICES:

✓ Redact sensitive fields (passwords, tokens, emails)
✓ Use RBAC for Kibana access
✓ Encrypt logs in transit (TLS)
✓ Encrypt logs at rest
✓ Audit log access
✓ Secure Elasticsearch cluster
✓ Use authentication & authorization
✓ Network isolation (VPC)
✓ Regular backups
✓ Monitoring access patterns
```

---

# 18. Elastic Stack vs Alternatives

```text
SCENARIO: Full-featured log management

Elastic Stack:
├── Most powerful ✓
├── Best search ✓
├── Largest ecosystem ✓
└── Best for everything

Loki:
├── Lighter weight
├── Kubernetes-only
└── Good if K8s-exclusive

Papertrail:
├── Easiest setup
├── But: Expensive

Graylog:
├── On-premise option
├── Complex setup

─────────────────────────────

SCENARIO: Learning cost

Free options:
├── Elastic Stack: FREE ✓ (all features)
├── Loki: FREE ✓ (K8s)
├── Graylog: FREE ✓ (self-hosted)
└── Papertrail: Paid ($14-500/month)

─────────────────────────────

SCENARIO: Job market

Elastic Stack:
├── Most job opportunities ✓
├── Most companies use
└── Best for career
```

---

# Quick Reference

```bash
# Elasticsearch operations

# Check health
curl -X GET "localhost:9200/_cluster/health"

# List indices
curl -X GET "localhost:9200/_cat/indices"

# Search
curl -X POST "localhost:9200/logs-*/_search" -d '
{
  "query": {
    "bool": {
      "must": [
        { "term": { "level": "ERROR" } },
        { "range": { "@timestamp": { "gte": "now-1h" } } }
      ]
    }
  }
}'

# Create index
curl -X PUT "localhost:9200/logs-2024.01.15"

# Delete old indices
curl -X DELETE "localhost:9200/logs-2023.01.*"

# Reindex
curl -X POST "localhost:9200/_reindex" -d '
{
  "source": { "index": "logs-old" },
  "dest": { "index": "logs-new" }
}'
```

---

# Summary: Log Management Decision

```
┌────────────────────────────────────────────┐
│                                            │
│  ✓ CHOICE: ELASTIC STACK                  │
│  ✓ COST: FREE ✓                           │
│  ✓ LEARNING TIME: 2-3 weeks               │
│  ✓ POWER: Most powerful solution           │
│  ✓ CAREER VALUE: Highest in market        │
│  ✓ START: Today with Docker Compose       │
│                                            │
│  COMPLETE LOG MANAGEMENT:                 │
│  ├─ Elasticsearch: Store & search         │
│  ├─ Kibana: Search & visualize            │
│  ├─ Beats: Collect from sources           │
│  ├─ Logstash: Parse & process             │
│  └─ Alerting: Notify on issues            │
│                                            │
│  WITH YOUR INFRASTRUCTURE:                │
│  ├─ Blog app logs (shipped via Beats)    │
│  ├─ Server logs (Node Exporter)          │
│  ├─ Database logs (custom exporter)      │
│  ├─ Load balancer logs                   │
│  └─ All searchable in Kibana!            │
│                                            │
└────────────────────────────────────────────┘
```

---

# Complete Learning Stack Final Summary

```
LESSON 1: cloud-serverless.md
├─ Deploy where (Vercel/Cloudflare)

LESSON 2: provisioning.md
├─ Provision what (Terraform)

LESSON 3: configuration-management.md
├─ Configure how (Ansible)

LESSON 4: ci-cd-tools.md
├─ Automate it (GitHub Actions)

LESSON 5: secret-management.md
├─ Secure it (Vault)

LESSON 6: infrastructure-monitoring.md
├─ Monitor metrics (Prometheus + Grafana)

LESSON 7: logs-management.md ← YOU ARE HERE
├─ Aggregate logs (Elastic Stack)

LESSON 8: integrated-devops-project.md
└─ Complete system (all together!)

═══════════════════════════════════════════

COMPLETE DEVOPS SYSTEM:
├─ Infrastructure: Provisioned (Terraform)
├─ Configuration: Automated (Ansible)
├─ Deployment: Continuous (GitHub Actions)
├─ Secrets: Secured (Vault)
├─ Metrics: Monitored (Prometheus)
├─ Logs: Aggregated (Elastic Stack)
└─ ALL INTEGRATED & WORKING TOGETHER! 🚀
```

---

# Resources & Learning

## Official Resources

- [Elasticsearch Docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/)
- [Kibana Docs](https://www.elastic.co/guide/en/kibana/current/)
- [Beats User Guide](https://www.elastic.co/guide/en/beats/libbeat/current/)
- [Logstash Reference](https://www.elastic.co/guide/en/logstash/current/)

## Learning Resources

- [Elasticsearch Getting Started](https://www.elastic.co/guide/en/elasticsearch/reference/current/getting-started.html)
- [Kibana Tutorials](https://www.elastic.co/guide/en/kibana/current/tutorial-sample-data.html)
- [Filebeat Quick Start](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-getting-started.html)
- [Elastic for Kubernetes](https://www.elastic.co/guide/en/cloud-on-k8s/current/)

## Community

- [Elastic Discuss Forum](https://discuss.elastic.co/)
- [Elastic Community Slack](https://elasticstack.slack.com/)
- [Stack Overflow #elasticsearch](https://stackoverflow.com/questions/tagged/elasticsearch)
- [GitHub Issues](https://github.com/elastic)

---

**Last Updated:** August 24, 2026
**Curated for:** DevOps Learning Path
**Integration:** Works with Terraform, Ansible, GitHub Actions, Prometheus
**Recommendation:** Choose Elastic Stack & start today!
**Perfect for:** Your complete blog application infrastructure!
