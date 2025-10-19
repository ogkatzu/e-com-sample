# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a polyglot microservices-based e-commerce application demonstrating Cloud Native Architecture (CNA) patterns. The system consists of 5 independent services (4 backend microservices + 1 frontend UI) that can be deployed to local Kubernetes (Minikube) or AWS (EKS).

## Architecture

### Microservices Structure

Each microservice is a bounded context with its own technology stack, database, and deployment lifecycle:

1. **products-cna-microservice** (Node.js/Express + MongoDB)
   - Product catalog and deals management
   - Loads seed data on startup from `data/` directory
   - Entry point: `server.js`

2. **cart-cna-microservice** (Java 17/Spring Boot + Redis)
   - Shopping cart and checkout operations
   - Uses Spring Cloud (Resilience4j, Sleuth) for observability
   - Build tool: Gradle
   - Package structure: `com.ecommerce.cart`

3. **users-cna-microservice** (Python/FastAPI + PostgreSQL)
   - User profile and account management
   - Uses SQLAlchemy ORM
   - Entry point: `app.py`
   - Virtual environment: pipenv

4. **search-cna-microservice** (Node.js + Elasticsearch)
   - Search proxy service for typeahead, autocomplete, faceted search

5. **store-ui** (React + TypeScript + Material-UI)
   - Frontend e-commerce web application
   - Created with Create React App
   - Component structure: `src/components/`, `src/pages/`, `src/api/`

### Key Architectural Patterns

- **Polyglot Persistence**: Each service owns its data store (MongoDB, Redis, PostgreSQL, Elasticsearch)
- **Containerization**: All services have Dockerfiles for container deployment
- **Infrastructure as Code**: Kubernetes manifests use Kustomize (base + overlays pattern)
- **Environment Configuration**: Services use `.env.development.local` files for local development (not committed to Git)

## Development Commands

### Products Microservice (Node.js)

```bash
cd products-cna-microservice
npm install
npm install -g nodemon  # Required for development
npm start               # Run with hot-reload
npm run lint            # ESLint
npm run format          # Prettier check
npm test
```

**Data seeding**: MongoDB is populated via `mongoimport` (see README) or auto-loaded on server startup from `data/deals.json` and `data/products.json`.

### Cart Microservice (Java/Spring Boot)

```bash
cd cart-cna-microservice
export $(cat .env | xargs)  # Load Redis connection vars
gradle build
gradle bootRun
gradle test
```

**Note**: Requires Java 17. Uses `.env` file (not committed) for Redis configuration.

### Users Microservice (Python)

```bash
cd users-cna-microservice
pipenv install
pipenv shell            # Activate virtual environment
python app.py
```

**Note**: Requires Python 3.x and pipenv installed.

### Search Microservice (Node.js)

```bash
cd search-cna-microservice
npm install
npm install -g nodemon
npm start
```

### Store UI (React)

```bash
cd store-ui
npm install
npm start               # Development server (http://localhost:3000)
npm test                # Interactive test runner
npm run build           # Production build
```

## Deployment

### Local Kubernetes (Minikube)

**Prerequisites**: Minikube installed and running
- MacOS: `minikube start --driver=hyperkit`
- Windows: `minikube start --driver=hyperv`

**Deploy platform services** (databases):
```bash
cd infra/k8s
kubectl apply -k shared-services/overlays/local
```

This deploys MongoDB, Redis, Elasticsearch with NodePort services.

**Deploy application microservices**:
```bash
kubectl apply -k apps/overlays/local
```

**View services**:
```bash
minikube service list -n shared-services
```

### Docker Image Building

For local Kubernetes, Docker images must be built within Minikube's Docker daemon:

```bash
# MacOS
eval $(minikube docker-env)
# Windows
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# Build images
cd products-cna-microservice && docker build -t products:latest .
cd cart-cna-microservice && docker build -t cart:latest .
cd users-cna-microservice && docker build -t users:latest .
cd search-cna-microservice && docker build -t search:latest .
cd store-ui && docker build -t store-ui:latest .
```

### AWS Deployment

Terraform scripts are available in `infra/terraform/` for deploying to AWS EKS. Structure:
- `environments/`: Environment-specific configurations
- `modules/`: Reusable Terraform modules

## Infrastructure Organization

### Kustomize Structure

Uses base + overlays pattern for environment-specific configurations:

```
infra/k8s/
├── shared-services/
│   ├── base/           # MongoDB, Redis, Elasticsearch base configs
│   └── overlays/local/ # Local environment overrides (NodePort services)
└── apps/
    ├── base/           # Microservice base configs
    └── overlays/local/ # Local environment overrides
```

**Namespace**: Platform services deployed to `shared-services` namespace.

## CI/CD

GitHub Actions workflow (`.github/workflows/node.js.yml`) runs CI for `products-cna-microservice`:
- Triggered on push/PR to master branch
- Node.js 18.x
- Runs: `npm ci`, `npm run build`, `npm test`

## Important Notes

- **Environment files**: Each service requires a `.env` or `.env.development.local` file for local development. These contain database connection strings and are gitignored.
- **Postman collections**: API testing collection available in `cart-cna-microservice/CartAPI.postman_collection.json`
- **Service ports**: Check individual service READMEs for default port assignments
- **Data initialization**: Products service clears and reloads data on every startup (see `server.js:loadData()`)

## Testing

- **Products/Search**: `npm test` (currently placeholder)
- **Cart**: `gradle test` (JUnit tests in `src/test/`)
- **Store UI**: `npm test` (Jest + React Testing Library)

## Code Style

- **Node.js services**: ESLint + Prettier configured, pre-commit hooks via Husky and lint-staged
- **React UI**: ESLint extends `react-app` config
- **Java**: Spring Boot conventions, Lombok annotations used for boilerplate reduction
