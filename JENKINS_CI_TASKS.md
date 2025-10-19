# Jenkins CI/CD Implementation Task List

This document outlines the tasks required to implement a Jenkins CI/CD pipeline for the e-commerce microservices application using Multibranch Pipeline, Shared Libraries, and Kind cluster for local deployment.

## Phase 1: Jenkins Shared Library Setup

### Task 1: Set up Jenkins Shared Library repository structure
- [ ] Create new Git repository for Jenkins Shared Library
- [ ] Create `vars/` directory for global variables and functions
- [ ] Create `src/` directory for Groovy classes (optional, for complex logic)
- [ ] Create `resources/` directory for non-Groovy files (scripts, configs)
- [ ] Initialize with README.md documenting the library structure
- [ ] Set up version control and branching strategy

### Task 2: Create buildNodeService() function in Shared Library
- [ ] Create `vars/buildNodeService.groovy` file
- [ ] Implement npm install step
- [ ] Implement npm run lint step (if applicable)
- [ ] Implement npm test step
- [ ] Add error handling and logging
- [ ] Accept parameters for service name and working directory
- [ ] Document function usage in comments

### Task 3: Create buildJavaService() function in Shared Library
- [ ] Create `vars/buildJavaService.groovy` file
- [ ] Implement Gradle build step
- [ ] Implement Gradle test step
- [ ] Handle Java 17 requirement verification
- [ ] Add error handling and logging
- [ ] Accept parameters for service name and working directory
- [ ] Document function usage in comments

### Task 4: Create buildPythonService() function in Shared Library
- [ ] Create `vars/buildPythonService.groovy` file
- [ ] Implement pipenv install step
- [ ] Implement Python test execution (if tests exist)
- [ ] Handle virtual environment activation
- [ ] Add error handling and logging
- [ ] Accept parameters for service name and working directory
- [ ] Document function usage in comments

### Task 5: Create buildReactUI() function in Shared Library
- [ ] Create `vars/buildReactUI.groovy` file
- [ ] Implement npm install step
- [ ] Implement npm test step
- [ ] Implement npm run build step for production bundle
- [ ] Add error handling and logging
- [ ] Accept parameters for service name and working directory
- [ ] Document function usage in comments

### Task 6: Create dockerBuild() function in Shared Library
- [ ] Create `vars/dockerBuild.groovy` file
- [ ] Implement Docker image build with service name and tag
- [ ] Use BUILD_NUMBER or GIT_COMMIT for image tagging
- [ ] Add image verification step
- [ ] Handle build context path parameter
- [ ] Add error handling and logging
- [ ] Document function usage in comments

### Task 7: Create deployToKind() function in Shared Library
- [ ] Create `vars/deployToKind.groovy` file
- [ ] Implement Kind cluster connectivity check
- [ ] Implement kubectl apply logic for Kustomize overlays
- [ ] Handle namespace creation if needed
- [ ] Add deployment verification step
- [ ] Accept parameters for environment and service name
- [ ] Add error handling and logging
- [ ] Document function usage in comments

### Task 8: Create getChangedServices() function in Shared Library
- [ ] Create `vars/getChangedServices.groovy` file
- [ ] Implement git diff logic to detect changed files
- [ ] Map changed files to microservice directories
- [ ] Return list of affected services
- [ ] Handle PR vs push scenarios
- [ ] Add logging for debugging
- [ ] Document function usage in comments

### Task 9: Create waitForHealthCheck() function in Shared Library
- [ ] Create `vars/waitForHealthCheck.groovy` file
- [ ] Implement HTTP health check polling logic
- [ ] Add timeout parameter (default 5 minutes)
- [ ] Add retry logic with exponential backoff
- [ ] Support custom health check endpoints per service
- [ ] Add error handling and meaningful failure messages
- [ ] Document function usage in comments

## Phase 2: Jenkinsfile Implementation

### Task 10: Create single Jenkinsfile at repository root
- [ ] Create `Jenkinsfile` in repository root
- [ ] Add @Library annotation to load Shared Library
- [ ] Define pipeline structure with declarative syntax
- [ ] Add agent configuration (label for required tools)
- [ ] Define environment variables (Kind cluster name, namespaces)
- [ ] Add post actions for cleanup
- [ ] Add pipeline description and comments

### Task 11: Implement change detection stage in Jenkinsfile
- [ ] Create "Detect Changes" stage
- [ ] Call getChangedServices() from Shared Library
- [ ] Store result in environment variable or parameter
- [ ] Add logging to show which services changed
- [ ] Handle case where no services changed (skip build)
- [ ] Add option to force build all services via parameter

### Task 12: Implement parallel build stages for each microservice
- [ ] Create "Build & Test Services" stage
- [ ] Use parallel directive for concurrent execution
- [ ] Add products-cna-microservice build step (call buildNodeService)
- [ ] Add cart-cna-microservice build step (call buildJavaService)
- [ ] Add users-cna-microservice build step (call buildPythonService)
- [ ] Add search-cna-microservice build step (call buildNodeService)
- [ ] Add store-ui build step (call buildReactUI)
- [ ] Conditionally skip services that haven't changed
- [ ] Add failFast option to stop on first failure

### Task 13: Implement Docker image build stage
- [ ] Create "Build Docker Images" stage
- [ ] Use parallel directive for concurrent image builds
- [ ] Call dockerBuild() for each microservice
- [ ] Tag images with BUILD_NUMBER
- [ ] Load images into Kind cluster (kind load docker-image)
- [ ] Conditionally skip images for unchanged services
- [ ] Add verification that images loaded successfully

### Task 14: Implement shared services deployment stage
- [ ] Create "Deploy Shared Services" stage
- [ ] Deploy MongoDB using Kustomize (infra/k8s/shared-services/overlays/local)
- [ ] Deploy Redis using Kustomize
- [ ] Deploy Elasticsearch using Kustomize
- [ ] Wait for shared services to be ready (kubectl wait)
- [ ] Add health checks for database services
- [ ] Add error handling for deployment failures

### Task 15: Implement application services deployment stage
- [ ] Create "Deploy Application Services" stage
- [ ] Use deployToKind() for each microservice
- [ ] Deploy in correct dependency order
- [ ] Inject environment variables via ConfigMaps/Secrets
- [ ] Wait for deployments to complete (kubectl rollout status)
- [ ] Conditionally deploy only changed services (or all for integration)
- [ ] Add error handling for deployment failures

### Task 16: Implement health check and verification stage
- [ ] Create "Health Check" stage
- [ ] Call waitForHealthCheck() for each service
- [ ] Verify all pods are running (kubectl get pods)
- [ ] Optionally run smoke tests or curl endpoints
- [ ] Add summary report of deployment status
- [ ] Add error handling with meaningful failure messages

## Phase 3: Jenkins Configuration

### Task 17: Configure Jenkins credentials for sensitive data
- [ ] Add credentials for Docker registry (if pushing images)
- [ ] Add credentials for MongoDB connection strings
- [ ] Add credentials for Redis connection strings
- [ ] Add credentials for Elasticsearch connection strings
- [ ] Add credentials for PostgreSQL connection strings
- [ ] Add credentials for AWS (if deploying to EKS later)
- [ ] Document credential IDs for reference in Jenkinsfile

### Task 18: Set up Jenkins agent with required tools
- [ ] Install Node.js (v18.x) on Jenkins agent
- [ ] Install Java 17 on Jenkins agent
- [ ] Install Python 3.x and pipenv on Jenkins agent
- [ ] Install Docker on Jenkins agent
- [ ] Install kubectl on Jenkins agent
- [ ] Install Kind on Jenkins agent
- [ ] Verify all tools are in PATH and accessible
- [ ] Create Jenkins agent label (e.g., 'microservices-agent')

### Task 19: Configure Multibranch Pipeline job in Jenkins
- [ ] Create new Multibranch Pipeline job
- [ ] Configure branch source (GitHub repository)
- [ ] Set branch discovery strategy (all branches + PRs)
- [ ] Configure build configuration (by Jenkinsfile)
- [ ] Set Jenkinsfile path (default: Jenkinsfile)
- [ ] Configure scan triggers (periodic or webhook)
- [ ] Add build parameters if needed (FORCE_BUILD_ALL, DEPLOY_ENV)
- [ ] Save and run initial scan

### Task 20: Configure GitHub webhook for automatic PR triggers
- [ ] Go to GitHub repository Settings > Webhooks
- [ ] Add new webhook with Jenkins URL
- [ ] Set payload URL to `<JENKINS_URL>/github-webhook/`
- [ ] Set content type to `application/json`
- [ ] Select "Pull requests" and "Pushes" events
- [ ] Verify webhook delivery in GitHub
- [ ] Test with a sample PR to verify trigger

### Task 21: Link Shared Library to Jenkins
- [ ] Go to Manage Jenkins > Configure System
- [ ] Navigate to "Global Pipeline Libraries" section
- [ ] Add new library with name (e.g., 'ecommerce-shared-lib')
- [ ] Set Git repository URL for Shared Library
- [ ] Configure default version (branch/tag, e.g., 'main')
- [ ] Enable "Load implicitly" (optional)
- [ ] Allow pipeline override of default version
- [ ] Save configuration

### Task 22: Create Kind cluster configuration file
- [ ] Create `kind-config.yaml` in repository or Shared Library
- [ ] Configure cluster with multiple worker nodes (optional)
- [ ] Expose ports for service access (NodePort mapping)
- [ ] Configure container runtime settings if needed
- [ ] Document how to create cluster: `kind create cluster --config kind-config.yaml`
- [ ] Add cluster creation to Jenkins pipeline or pre-requisite docs

## Phase 4: Testing & Validation

### Task 23: Test pipeline with a sample PR
- [ ] Create test branch with changes to one microservice only
- [ ] Open PR against main/master branch
- [ ] Verify Jenkins job triggers automatically
- [ ] Verify change detection identifies only modified service
- [ ] Verify only affected service builds and deploys
- [ ] Check build logs for errors
- [ ] Verify deployment to Kind cluster
- [ ] Run manual health checks on deployed services

### Task 24: Test full pipeline execution with all services modified
- [ ] Create test branch with changes across all microservices
- [ ] Open PR or push to branch
- [ ] Verify all services are detected as changed
- [ ] Verify parallel builds execute correctly
- [ ] Verify all Docker images build successfully
- [ ] Verify shared services deploy first
- [ ] Verify all application services deploy
- [ ] Verify health checks pass for all services
- [ ] Document any issues and refine pipeline

## Phase 5: Documentation & Optimization (Optional)

### Task 25: Document the CI/CD pipeline
- [ ] Create JENKINS_SETUP.md with setup instructions
- [ ] Document Shared Library functions and usage
- [ ] Document required Jenkins plugins
- [ ] Document environment variable requirements
- [ ] Add troubleshooting section for common issues
- [ ] Add pipeline diagram or flowchart

### Task 26: Add pipeline optimizations
- [ ] Implement caching for npm/gradle/pip dependencies
- [ ] Add build artifacts archiving
- [ ] Add test result publishing
- [ ] Add code coverage reporting
- [ ] Add build notifications (Slack, email)
- [ ] Add pipeline execution time metrics

---

## Notes

- This implementation uses a **single Jenkinsfile** approach with Shared Libraries handling polyglot complexity
- **Multibranch Pipeline** automatically discovers branches and PRs
- **Kind cluster** is used for local Kubernetes deployment
- Pipeline triggers automatically on PR creation/updates
- No rollback functionality is implemented initially (future enhancement)

## Prerequisites

Before starting, ensure you have:
- Jenkins server running (v2.400+)
- GitHub repository access
- Jenkins credentials configured for GitHub
- Docker, kubectl, and Kind installed on build agents
