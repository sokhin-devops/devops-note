# Cloud Serverless Computing

## Serverless Platforms: AWS Lambda, Azure Functions, Netlify, Vercel, and Cloudflare Workers

Serverless computing allows you to run code without provisioning or managing servers. You write functions, upload them to a platform, and pay only for the resources consumed during execution.

The major serverless platforms covered in this guide are:

* AWS Lambda
* Azure Functions
* Netlify Functions
* Vercel Functions
* Cloudflare Workers

---

# 1. What Is Serverless Computing?

## Traditional Server Management

```text
Your Application
     │
     ▼
Provision Server
     │
     ├── Choose OS
     ├── Install Runtime
     ├── Configure Network
     ├── Setup Database
     ├── Deploy Code
     └── Monitor & Scale
     
Ongoing: Patches, Updates, Scaling
```

You manage infrastructure, patches, and scaling.

## Serverless Computing

```text
Your Application
     │
     ▼
Write Function Code
     │
     ▼
Deploy to Serverless Platform
     │
     ▼
Platform Handles Everything
     │
     ├── Provisioning
     ├── Scaling
     ├── Patching
     └── Monitoring

You Pay: Only for execution time
```

The platform manages all infrastructure automatically.

---

# 2. Serverless vs. Traditional Computing

```text
┌─────────────────────────┬──────────────────────┬──────────────────────┐
│      Attribute          │  Traditional Server  │    Serverless        │
├─────────────────────────┼──────────────────────┼──────────────────────┤
│ Server Management       │ You manage           │ Provider manages     │
│ Scaling                 │ Manual               │ Automatic            │
│ Pricing Model           │ Per hour/month       │ Per execution        │
│ Cold Start              │ Always hot           │ May have delay       │
│ Language Support        │ Many options         │ Limited languages    │
│ Deployment Time         │ Minutes/Hours        │ Seconds              │
│ Best For                │ Always-on apps       │ Event-driven apps    │
└─────────────────────────┴──────────────────────┴──────────────────────┘
```

---

# 3. When to Use Serverless

## Ideal Use Cases

```text
GOOD FOR SERVERLESS:
├── API endpoints (REST/GraphQL)
├── Scheduled tasks/cron jobs
├── File uploads/processing
├── Webhooks & event handlers
├── Real-time data processing
├── Microservices
└── Temporary workloads
```

## NOT Ideal for Serverless

```text
AVOID SERVERLESS FOR:
├── Long-running processes (>15 min)
├── 24/7 always-on services
├── Low-latency real-time apps
├── Complex stateful operations
├── Custom OS requirements
└── High concurrent connections
```

---

# 4. AWS Lambda

## Overview

AWS Lambda is Amazon's serverless compute service. You write code, upload it, and Lambda runs it in response to events.

## How AWS Lambda Works

```text
Event Source
     │
     ├── API Gateway (HTTP request)
     ├── S3 (file upload)
     ├── DynamoDB (database change)
     ├── SNS (notification)
     ├── SQS (queue message)
     └── CloudWatch (schedule)
     │
     ▼
Lambda Function
(Your Code)
     │
     ├── Python
     ├── Node.js
     ├── Java
     ├── Go
     ├── C#
     └── Ruby
     │
     ▼
Auto-scaling & Execution
     │
     ▼
Result/Response
```

## Key Features

```text
LAMBDA FEATURES:

Runtimes:        Python, Node.js, Java, Go, C#, Ruby
Memory:          128 MB - 10,240 MB (configurable)
Timeout:         15 minutes max
Execution Role:  IAM role for AWS service access
Layers:          Share code/libraries across functions
Versions:        Manage function versions and aliases
Concurrency:     Reserved & provisioned concurrency
Cost:            $0.20 per 1M requests + compute time
```

## Lambda Function Example

```python
# Python Lambda Function
def lambda_handler(event, context):
    """
    event: Input data from event source
    context: Runtime information
    """
    name = event.get('name', 'World')
    message = f'Hello, {name}!'
    
    return {
        'statusCode': 200,
        'body': message
    }
```

## Lambda Pricing Model

```text
PRICING COMPONENTS:

1. Request Charges
   └── $0.20 per 1,000,000 requests

2. Duration Charges
   └── $0.0000166667 per GB-second
   └── Billed in 1ms increments
   └── Free tier: 1,000,000 requests + 400,000 GB-seconds/month

Example Cost Calculation:
   Function Duration:     500ms (0.5 seconds)
   Memory Allocated:      512 MB (0.5 GB)
   Monthly Requests:      10,000
   
   Cost = (10,000 × $0.20 / 1M) + (10,000 × 0.5s × 0.5 × $0.0000166667)
        ≈ $0.002 + $0.042 = $0.044/month
```

## AWS Lambda Limitations

```text
CONSTRAINTS:

Timeout:           Maximum 15 minutes
Memory:            128 MB - 10,240 MB (256 MB increments)
Disk Space:        512 MB in /tmp
Package Size:      50 MB zipped, 250 MB unzipped
Environment Vars:  4 KB total size
Layers:            Up to 5 layers
Connections:       Limited concurrent connections
Cold Start:        Can take 1-2 seconds for new runtimes
```

---

# 5. Azure Functions

## Overview

Azure Functions is Microsoft's serverless platform. Integrated with Azure ecosystem and supports multiple triggers.

## How Azure Functions Work

```text
Trigger Types
     │
     ├── HTTP (REST API)
     ├── Timer (schedule)
     ├── Blob Storage (file)
     ├── Queue (message)
     ├── Service Bus (messaging)
     ├── Cosmos DB (database)
     └── Event Grid (events)
     │
     ▼
Azure Function
(Your Code)
     │
     ├── C#
     ├── Node.js
     ├── Python
     ├── Java
     ├── PowerShell
     └── TypeScript
     │
     ▼
Execution & Auto-scale
```

## Key Features

```text
AZURE FUNCTIONS FEATURES:

Hosting Plans:     Consumption, Premium, Dedicated
Runtimes:          C#, Node.js, Python, Java, PowerShell
Memory:            Auto-managed based on plan
Timeout:           10 minutes (Consumption), unlimited (Premium)
Bindings:          40+ built-in integrations
Durable Functions: Orchestration & workflows
Monitoring:        Application Insights integration
Cost:              Pay-per-execution or reserved capacity
```

## Azure Function Example (Node.js)

```javascript
// Azure Function - HTTP Trigger
module.exports = async function (context, req) {
    const name = (req.query.name || (req.body && req.body.name));
    
    if (name) {
        context.res = {
            status: 200,
            body: `Hello, ${name}!`
        };
    } else {
        context.res = {
            status: 400,
            body: "Please provide a name"
        };
    }
};
```

## Azure Function Pricing

```text
CONSUMPTION PLAN:
└── Execution Count: $0.20 per 1M executions
└── Compute Time:    $0.000016 per GB-second
└── Free Tier:       1M requests + 400,000 GB-seconds/month

PREMIUM PLAN:
└── Hourly Charge:   $0.096 - $1.248/hour (instance dependent)
└── Better Performance & Guaranteed Resources

DEDICATED PLAN:
└── App Service Plan pricing
└── Always-on instances
└── Lowest cost for high-volume workloads
```

## Azure Functions Advantages

```text
PROS:
✓ Tight Azure ecosystem integration
✓ Durable Functions for complex workflows
✓ Strong C#/PowerShell support
✓ Application Insights built-in
✓ Multiple hosting options
✓ Fast deployment

CONS:
✗ Smaller ecosystem than AWS
✗ Steeper learning curve for Azure services
✗ Limited free tier
```

---

# 6. Netlify Functions

## Overview

Netlify Functions make it easy to deploy serverless backend functions alongside static sites. Built on AWS Lambda but simplified.

## How Netlify Functions Work

```text
Deploy Static Site + Functions
     │
     ▼
Netlify Platform
     │
     ├── Builds your site
     ├── Deploys functions to AWS Lambda
     └── Routes requests to both
     │
     ▼
Your Users
     │
     ├── Static assets served from CDN
     └── Function calls to Lambda
```

## Key Features

```text
NETLIFY FUNCTIONS:

Language:          JavaScript/Node.js, Go, TypeScript
Deployment:        Simple file-based structure
Location:          /netlify/functions/*.js directory
HTTP Handler:      event-based (like Lambda)
Environment:       Netlify env variables
Local Dev:         netlify dev command
Cost:              Included in Netlify plan or pay-per-execution
```

## Netlify Function Example

```javascript
// netlify/functions/hello.js

exports.handler = async (event, context) => {
    const name = event.queryStringParameters?.name || 'World';
    
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: `Hello, ${name}!`
        })
    };
};
```

## Netlify Functions Advantages

```text
PROS:
✓ Super simple deployment
✓ No Lambda configuration needed
✓ Great for jamstack sites
✓ Built-in CI/CD
✓ Environment variable management
✓ Automatic HTTPS

CONS:
✗ Less powerful than raw Lambda
✗ Limited customization
✗ Depends on Netlify hosting
✗ Smaller community than AWS
```

## Netlify Function Limits

```text
EXECUTION:
├── Timeout: 26 seconds (Pro), 10 seconds (free)
├── Memory: ~1.8 GB (fixed)
├── Concurrency: Limited by Netlify plan
└── Disk: 512 MB /tmp

DEPLOYMENT:
├── Max size: 52 MB (with all dependencies)
├── Cold start: Usually fast
└── Region: Depends on Netlify setup
```

---

# 7. Vercel Functions

## Overview

Vercel Functions enable serverless backend code deployment alongside Next.js applications. Purpose-built for JavaScript/TypeScript web apps.

## How Vercel Functions Work

```text
Next.js App + API Routes
     │
     ▼
Vercel Platform
     │
     ├── Builds Next.js app
     ├── Deploys routes to serverless
     └── Routes requests intelligently
     │
     ▼
Global CDN + Serverless Compute
```

## Key Features

```text
VERCEL FUNCTIONS:

Language:          JavaScript/Node.js, TypeScript
Integration:       Native to Next.js API Routes
Directory:         /api/*.js in your project
HTTP Handler:      req/res (Express-like)
Environment:       .env.local, .env.production
Local Dev:         next dev command
Deployment:        Single command or Git push
Cost:              Free tier generous, then pay-per-execution
```

## Vercel Function Example (Next.js API Route)

```javascript
// pages/api/hello.js

export default function handler(req, res) {
    const { name = 'World' } = req.query;
    
    res.status(200).json({
        message: `Hello, ${name}!`
    });
}
```

## Vercel Advantages

```text
PROS:
✓ Seamless Next.js integration
✓ Express-like req/res API (familiar)
✓ Excellent DX (developer experience)
✓ Edge Functions for low latency
✓ Free tier is very generous
✓ Quick deployments
✓ Built-in analytics

CONS:
✗ Optimized for Next.js/JavaScript
✗ Less suitable for other frameworks
✗ Smaller ecosystem than AWS
```

## Vercel Function Limits

```text
EXECUTION:
├── Timeout: 60 seconds (Pro), 10 seconds (free hobby)
├── Memory: 512 MB base, up to 3008 MB
├── Execution: Max 1000/month (free), unlimited (Pro+)
└── Disk: 512 MB /tmp

EDGE FUNCTIONS:
├── Timeout: 30 seconds
├── Memory: 128 MB
├── Global distribution
└── Lower latency
```

## Vercel Pricing

```text
FREE TIER:
├── 100 GB bandwidth/month
├── 1000 Function executions/month
├── 6 deployments/day
└── Great for learning

PRO TIER:
├── $20/month or usage-based
├── Unlimited deployments
├── $0.50 per 1M function invocations
└── Advanced analytics

ENTERPRISE:
└── Custom pricing & SLA
```

---

# 8. Cloudflare Workers

## Overview

Cloudflare Workers run JavaScript/WebAssembly code on Cloudflare's global edge network. Extremely fast, low-latency execution worldwide.

## How Cloudflare Workers Work

```text
User Request
     │
     ▼
Cloudflare Global Network (200+ data centers)
     │
     ├── Execute Worker code instantly
     ├── No cold start (always warm)
     └── Return response
     │
     ▼
Ultra-low latency response
     │
     └── Typical: <100ms anywhere globally
```

## Key Features

```text
CLOUDFLARE WORKERS:

Language:          JavaScript, TypeScript, Rust, Python
Execution:         Edge (globally distributed)
Latency:           <100ms worldwide
Cold Start:        None (instant)
CPU Timeout:       30 seconds
Memory:            128 MB
Cost:              $5/month base + pay-per-request
Storage:           KV (distributed cache), Durable Objects, D1

PERFECT FOR:
├── API middleware
├── Rate limiting
├── Request routing
├── Content caching
├── DDoS mitigation
├── Auth headers
└── A/B testing
```

## Cloudflare Worker Example

```javascript
// src/index.js

export default {
    async fetch(request, env, ctx) {
        const url = new URL(request.url);
        
        if (url.pathname === '/api/hello') {
            const name = url.searchParams.get('name') || 'World';
            return new Response(
                JSON.stringify({ message: `Hello, ${name}!` }),
                { headers: { 'Content-Type': 'application/json' } }
            );
        }
        
        return new Response('Not Found', { status: 404 });
    }
};
```

## Cloudflare Workers Advantages

```text
PROS:
✓ NO cold start (always warm)
✓ Global distribution (200+ locations)
✓ Ultra-low latency (<100ms)
✓ Instant scaling
✓ Affordable pricing
✓ Great for edge cases
✓ KV storage built-in
✓ You have an account!

CONS:
✗ JavaScript/WebAssembly only
✗ 30 second timeout
✗ 128 MB memory limit
✗ Smaller ecosystem
```

## Cloudflare Worker Pricing

```text
FREE TIER:
├── 100,000 requests/day free
├── Cloudflare KV: 3GB namespace
└── Perfect for learning

PAID TIER (Workers Unbound):
├── $5/month base
├── $0.50 per 1M requests
├── 30 second timeout
└── More powerful

BUNDLED:
├── Free in some Cloudflare plans
└── Check your current plan
```

---

# 9. Comparison Table

```text
┌──────────────┬──────────────┬──────────────┬──────────────┬─────────────┐
│   Feature    │  AWS Lambda  │  Azure Fn    │   Netlify    │  Vercel     │
├──────────────┼──────────────┼──────────────┼──────────────┼─────────────┤
│ Languages    │ 6+ languages │ 5+ languages │ JS/Go        │ JS/TS       │
│ Memory       │ 128-10240MB  │ Auto/varies  │ ~1.8 GB      │ 512-3008MB  │
│ Timeout      │ 15 minutes   │ 10+ minutes  │ 26 seconds   │ 60 seconds  │
│ Cold Start   │ 1-2 seconds  │ 1-2 seconds  │ <1 second    │ <1 second   │
│ Free Tier    │ 1M/400GB-sec │ 1M/400GB-sec │ Generous     │ Very good   │
│ Pricing      │ Per exec+mem │ Per exec+mem │ Per sec      │ Per exec    │
│ Best For     │ Everything   │ Azure stack  │ jamstack     │ Next.js     │
│ Ecosystem    │ Largest      │ Medium       │ Small        │ Small       │
│ Learning     │ Medium       │ Medium       │ Easy         │ Easy        │
└──────────────┴──────────────┴──────────────┴──────────────┴─────────────┘

┌──────────────┬──────────────┬──────────────┐
│   Feature    │ Cloudflare   │ Recommended  │
├──────────────┼──────────────┼──────────────┤
│ Languages    │ JS/TS/WASM   │ Start simple │
│ Memory       │ 128 MB       │ Edge compute │
│ Timeout      │ 30 seconds   │ API routes   │
│ Cold Start   │ NONE! ✓      │ Low latency  │
│ Free Tier    │ 100k/day     │ FREE first   │
│ Pricing      │ $5+/month    │ Cloudflare✓  │
│ Best For     │ Edge logic   │ CDN-based    │
│ Ecosystem    │ Growing      │ Middleware   │
│ Learning     │ Easy         │ Great DX     │
└──────────────┴──────────────┴──────────────┘
```

---

# 10. Your Accounts: Vercel & Cloudflare

Since you have accounts with Vercel and Cloudflare, here's how to leverage them:

## Vercel Strategy

```text
USE CASE: Full-stack JavaScript web apps

SETUP:
├── Create Next.js project (or existing)
├── Create /pages/api/YOUR_ENDPOINT.js
├── Deploy with: vercel deploy
└── Function runs instantly

EXAMPLE:
pages/api/users.js    → GET /api/users
pages/api/data.js     → POST /api/data

ADVANTAGES:
✓ Runs with your Next.js app
✓ Same deployment command
✓ Excellent DX
✓ Free tier generous
✓ Edge Functions available
```

## Cloudflare Workers Strategy

```text
USE CASE: Lightweight APIs, middleware, edge logic

SETUP:
├── Create worker: wrangler generate my-worker
├── Edit src/index.js
├── Deploy: wrangler publish
└── Instant execution on edge

EXAMPLE:
Worker routes → /api/* requests
KV Storage   → Cache API responses
D1 Database  → SQLite on edge

ADVANTAGES:
✓ NO cold start
✓ Global distribution
✓ Ultra-fast
✓ $5/month affordable
✓ KV storage for caching
```

## Combined Architecture

```text
USER REQUEST
     │
     ▼
Cloudflare Worker (Edge)
     │
     ├── Check request (middleware)
     ├── Rate limit
     ├── Route to origin
     └── Cache response
     │
     ▼
     ├─→ Vercel (if your main app)
     │   └── Next.js + API Routes
     │
     └─→ Third-party API
         └── If needed

BENEFITS:
✓ Edge logic runs in Cloudflare (instant)
✓ App logic runs in Vercel (scalable)
✓ Responses cached in Cloudflare
✓ Ultra-low latency
```

---

# 11. Getting Started: Step by Step

## Start with Vercel (Recommended for Learning)

### Step 1: Create Next.js Project
```bash
npx create-next-app@latest my-serverless-app
cd my-serverless-app
```

### Step 2: Create API Route
```javascript
// pages/api/hello.js

export default function handler(req, res) {
    const { name = 'User' } = req.query;
    res.status(200).json({ message: `Hello, ${name}!` });
}
```

### Step 3: Test Locally
```bash
npm run dev
# Visit: http://localhost:3000/api/hello?name=Alice
```

### Step 4: Deploy to Vercel
```bash
npm install -g vercel
vercel login
vercel deploy
```

## Then Expand with Cloudflare

### Step 1: Create Worker
```bash
npm create cloudflare@latest my-worker
cd my-worker
```

### Step 2: Create Worker Logic
```javascript
// src/index.js

export default {
    async fetch(request, env, ctx) {
        // Add your edge logic here
        return new Response('Hello from the edge!');
    }
};
```

### Step 3: Deploy
```bash
wrangler publish
```

---

# 12. Common Patterns

## Pattern 1: API Backend + Database

```text
Request → API Function → Database → Response
         (Vercel)        (Postgres)
         
Example: User signup endpoint
```

```javascript
// pages/api/signup.js

export default async function handler(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).end();
    }
    
    const { email, password } = req.body;
    
    // Save to database
    // const user = await db.users.create({ email, password });
    
    return res.status(201).json({ userId: 123 });
}
```

## Pattern 2: Scheduled Tasks

### Using Vercel Cron Functions

```javascript
// pages/api/cron/cleanup.js

export default function handler(req, res) {
    // Check the cron secret
    if (req.headers['authorization'] !== `Bearer ${process.env.CRON_SECRET}`) {
        return res.status(401).end('Unauthorized');
    }
    
    // Do your cleanup work
    console.log('Running cleanup at:', new Date());
    
    res.status(200).json({ cleaned: true });
}
```

Configure in vercel.json:
```json
{
    "crons": [{
        "path": "/api/cron/cleanup",
        "schedule": "0 0 * * *"
    }]
}
```

## Pattern 3: Middleware / Rate Limiting (Cloudflare)

```javascript
// src/index.js - Cloudflare Worker

const RATE_LIMIT = 10; // requests
const RATE_LIMIT_WINDOW = 60; // seconds

export default {
    async fetch(request, env, ctx) {
        const ip = request.headers.get('cf-connecting-ip');
        const key = `rate-limit:${ip}`;
        
        // Get current count
        const count = await env.RATE_LIMIT_KV.get(key) || 0;
        
        if (count >= RATE_LIMIT) {
            return new Response('Too many requests', { status: 429 });
        }
        
        // Increment count
        await env.RATE_LIMIT_KV.put(key, String(parseInt(count) + 1), {
            expirationTtl: RATE_LIMIT_WINDOW
        });
        
        return new Response('OK', { status: 200 });
    }
};
```

## Pattern 4: File Upload Handler

```javascript
// pages/api/upload.js (Vercel)

export const config = {
    api: {
        bodyParser: {
            sizeLimit: '50mb',
        },
    },
};

export default async function handler(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).end();
    }
    
    const { filename, file } = req.body;
    
    // Upload to S3 or other storage
    // const url = await uploadToS3(filename, file);
    
    return res.status(200).json({ url: 'https://...' });
}
```

---

# 13. Debugging & Monitoring

## Vercel Monitoring

```text
VIEWING LOGS:
├── Vercel Dashboard → Functions → Logs
├── Or: vercel logs
└── Or: Check Application Insights (integrations)

DEBUGGING LOCALLY:
└── vercel dev
```

## Cloudflare Monitoring

```text
VIEWING LOGS:
├── Cloudflare Dashboard → Workers → Analytics
├── Real-time logs: wrangler tail
└── Or: Check Tail service

DEBUGGING:
├── Local: wrangler dev
├── Console.log() → wrangler tail
└── Remote: CF dashboard
```

## Common Issues

```text
COLD START:
├── Lambda/Azure: 1-2 seconds initially
├── Vercel: Usually warm
├── Cloudflare: Never cold! ✓
└── Solution: Keep functions warm or use edge

TIMEOUT ERRORS:
├── Check function duration
├── Lambda limit: 15 minutes
├── Vercel limit: 60 seconds (free: 10s)
├── Solution: Optimize code, use async tasks

MEMORY ISSUES:
├── Check memory allocation
├── Monitor execution in logs
├── Reduce payload size
└── Use streaming for large responses

COLD START SOLUTIONS:
├── Use Vercel (warm by default)
├── Use Cloudflare (edge compute, no cold start)
├── Enable provisioned concurrency (Lambda)
├── Keep functions small & fast
```

---

# 14. Cost Comparison For You

Your accounts: **Vercel** + **Cloudflare**

```text
SCENARIO: 10,000 API requests/month, average 500ms

VERCEL (Pro: $20/month):
├── Base: $20/month
├── Executions: (10,000 × $0.50 / 1M) ≈ $0.005
└── Total: ≈$20/month ✓ (good for web apps)

CLOUDFLARE (Workers):
├── Base: $5/month or free (100k/day)
├── Executions: (10,000 × $0.50 / 1M) ≈ $0.005
└── Total: ≈$5/month or FREE! ✓ (best value)

COMBINED STRATEGY:
├── Vercel: Run your Next.js app ($20/month)
├── Cloudflare: Run edge middleware/caching (FREE)
└── Total: $20/month (excellent value)
```

---

# 15. Learning Path Recommendation

```text
WEEK 1: Vercel (Already have account)
├── Create Next.js project
├── Build 2-3 simple API endpoints
├── Learn req/res pattern
└── Deploy to Vercel

WEEK 2: Cloudflare Workers (Already have account)
├── Create your first Worker
├── Build API endpoint
├── Learn edge computing concepts
├── Deploy and compare performance

WEEK 3: Advanced (Optional)
├── Vercel + Cloudflare integration
├── Learn about caching strategies
├── KV storage in Cloudflare
├── D1 database (SQLite on edge)

WEEK 4: AWS Lambda (Optional)
├── Understand Lambda for comparison
├── Learn Lambda-specific features
├── Understand when to use each platform
└── Appreciate the value of Vercel/Cloudflare ✓
```

---

# Key Takeaways

```text
SERVERLESS IS GREAT FOR:
✓ APIs and microservices
✓ Event-driven tasks
✓ Rapid prototyping
✓ Cost-efficient scaling
✓ No infrastructure management

YOUR ADVANTAGE:
✓ Vercel: Perfect for full-stack Next.js apps
✓ Cloudflare: Perfect for edge compute & caching
✓ Both: Generous free tiers
✓ Combined: Powerful & affordable architecture

GET STARTED:
└── Next: Pick Vercel or Cloudflare
    └── Build your first function today
    └── Deploy in minutes
    └── Scale to millions of requests
```

---

# Resources & Links

## Official Documentation

- [AWS Lambda Docs](https://docs.aws.amazon.com/lambda/)
- [Azure Functions Docs](https://docs.microsoft.com/en-us/azure/azure-functions/)
- [Netlify Functions Docs](https://docs.netlify.com/functions/overview/)
- [Vercel Functions Docs](https://vercel.com/docs/concepts/functions/serverless-functions)
- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)

## Getting Started

- [Vercel Next.js Template](https://vercel.com/new)
- [Cloudflare Worker Templates](https://developers.cloudflare.com/workers/templates/)
- [Netlify Functions Guide](https://docs.netlify.com/functions/overview/)

## Community & Help

- AWS Lambda: [AWS Forums](https://forums.aws.amazon.com/forum.jspa?forumID=185)
- Vercel: [Discord Community](https://vercel.com/discord)
- Cloudflare: [Discord Community](https://discord.gg/cloudflaredev)

---

**Last Updated:** August 24, 2026
**Curated for:** DevOps Learning Path
