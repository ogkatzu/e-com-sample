# Jenkins Local Setup Guide

This guide walks you through setting up Jenkins locally on your Mac M4 using Docker Compose.

## Prerequisites

- Docker Desktop installed and running on Mac M4
- Git installed
- At least 4GB of RAM available for Docker

## Quick Start

### 1. Build and Start Jenkins

From the repository root, run:

```bash
docker-compose -f docker-compose.jenkins.yml up -d --build
```

This will:
- Build a custom Jenkins image with all required tools (Node.js, Java 17, Python, Docker CLI, kubectl, Kind, Gradle, Kustomize)
- Start Jenkins container on port 8080
- Mount Docker socket for building images
- Create a persistent volume for Jenkins data

### 2. Get Initial Admin Password

Wait about 60 seconds for Jenkins to start, then retrieve the initial admin password:

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Copy this password - you'll need it for the next step.

### 3. Access Jenkins

Open your browser to: `http://localhost:8080`

- Paste the initial admin password
- Select "Install suggested plugins" (or customize if you prefer)
- Create your first admin user
- Keep the default Jenkins URL: `http://localhost:8080`

## Verify Tools Installation

Once Jenkins is running, verify all tools are installed:

```bash
docker exec jenkins node --version
docker exec jenkins npm --version
docker exec jenkins java -version
docker exec jenkins gradle --version
docker exec jenkins python3 --version
docker exec jenkins pipenv --version
docker exec jenkins docker --version
docker exec jenkins kubectl version --client
docker exec jenkins kind version
docker exec jenkins kustomize version
```

## What's Included

The custom Jenkins image includes:

- **Jenkins LTS** - Latest long-term support version
- **Node.js 18.x** - For products and search microservices
- **Java 17** - For cart microservice (Spring Boot)
- **Python 3 + pipenv** - For users microservice (FastAPI)
- **Gradle 8.5** - Build tool for Java service
- **Docker CLI** - For building container images
- **kubectl** - Kubernetes command-line tool
- **Kind** - Kubernetes in Docker (local cluster)
- **Kustomize** - Kubernetes manifest management
- **Jenkins Plugins**:
  - Git & GitHub integration
  - Pipeline & Blue Ocean
  - Docker & Kubernetes plugins
  - Credentials binding

## Managing Jenkins

### Stop Jenkins
```bash
docker-compose -f docker-compose.jenkins.yml stop
```

### Start Jenkins
```bash
docker-compose -f docker-compose.jenkins.yml start
```

### View Logs
```bash
docker-compose -f docker-compose.jenkins.yml logs -f jenkins
```

### Restart Jenkins
```bash
docker-compose -f docker-compose.jenkins.yml restart
```

### Remove Jenkins (keeps data)
```bash
docker-compose -f docker-compose.jenkins.yml down
```

### Remove Jenkins and all data (WARNING: deletes everything)
```bash
docker-compose -f docker-compose.jenkins.yml down -v
```

## Create Kind Cluster

Before running your Jenkins pipelines, create a Kind cluster:

```bash
docker exec jenkins kind create cluster --name microservices-local
```

Verify cluster is running:
```bash
docker exec jenkins kubectl cluster-info --context kind-microservices-local
```

## Troubleshooting

### Port 8080 Already in Use
If you get a port conflict error:

1. Check what's using port 8080: `lsof -i :8080`
2. Either stop that service or change Jenkins port in `docker-compose.jenkins.yml`:
   ```yaml
   ports:
     - "8081:8080"  # Change 8081 to any available port
   ```

### Docker Socket Permission Issues
If Jenkins can't access Docker:

```bash
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

### Jenkins Won't Start
Check logs for errors:
```bash
docker-compose -f docker-compose.jenkins.yml logs jenkins
```

### Out of Memory
Increase Docker Desktop memory allocation:
- Open Docker Desktop
- Go to Settings > Resources
- Increase Memory to at least 6GB
- Click "Apply & Restart"

### Kind Cluster Won't Create
Ensure Docker Desktop is running and has enough resources. Try creating the cluster from your host machine first:
```bash
kind create cluster --name microservices-local
```

## Next Steps

After Jenkins is running:

1. **Set up Shared Library** - Follow `JENKINS_CI_TASKS.md` Phase 1
2. **Configure Credentials** - Add database connection strings and secrets
3. **Create Multibranch Pipeline Job** - Point to this repository
4. **Configure GitHub Webhook** - Enable automatic PR triggers
5. **Test Pipeline** - Create a test branch and PR

## File Locations

- **Jenkins Home**: `/var/jenkins_home` (inside container)
- **Docker Socket**: `/var/run/docker.sock` (mounted from host)
- **Custom Scripts**: `./jenkins-scripts` (mounted to `/usr/local/bin/jenkins-scripts`)

## Accessing Jenkins Container Shell

If you need to run commands inside Jenkins:

```bash
docker exec -it jenkins bash
```

Or as root user:
```bash
docker exec -it -u root jenkins bash
```

## Backup and Restore

### Backup Jenkins Data
```bash
docker run --rm -v jenkins_home:/data -v $(pwd):/backup alpine tar czf /backup/jenkins-backup.tar.gz -C /data .
```

### Restore Jenkins Data
```bash
docker run --rm -v jenkins_home:/data -v $(pwd):/backup alpine tar xzf /backup/jenkins-backup.tar.gz -C /data
```

## Production Considerations

This setup is for **local development only**. For production:

- Use persistent volume mounts instead of Docker socket
- Enable Jenkins authentication and authorization
- Use secrets management (HashiCorp Vault, AWS Secrets Manager)
- Set up Jenkins behind a reverse proxy with SSL
- Configure backup automation
- Use external PostgreSQL for Jenkins data (instead of default XML)
- Implement proper monitoring and alerting
