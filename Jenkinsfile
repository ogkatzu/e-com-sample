@Library('shared-library') _

pipeline {
    agent none

    stages {
        stage("Checkout") {
            agent any
            steps {
                checkout scm
            }
        }

        stage("Get Changed Services") {
            agent any
            steps {
                script {
                    changedServices = getChangedServices()
                    echo "Services to build: ${changedServices}"
                }
            }
        }

        stage("Build Services") {
            steps {
                script {
                    def serviceConfigs = getServiceConfig()

                    // Create parallel stages dynamically
                    def parallelStages = [:]

                    changedServices.each { serviceName ->
                        if (serviceConfigs.containsKey(serviceName)) {
                            def config = serviceConfigs[serviceName]

                            parallelStages["Build ${serviceName}"] = {
                                if (config.agent == 'any') {
                                    node {
                                        checkout scm  // Checkout in each node
                                        buildService(serviceName, config)
                                    }
                                } else {
                                    node(config.agent) {
                                        checkout scm  // Checkout in each node
                                        buildService(serviceName, config)
                                    }
                                }
                            }
                        }
                    }

                    // Execute all builds in parallel
                    parallel parallelStages
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed"
        }
        success {
            echo "Pipeline executed successfully"
        }
        failure {
            echo "Pipeline execution failed"
        }
    }
}