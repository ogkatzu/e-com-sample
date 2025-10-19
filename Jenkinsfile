@Library('shared-library') _

pipeline{
    agent any
    
    stages{
        stage("Checkout"){
            steps{
                checkout scm
            }
        }
        stage("Get Changed Services"){
            steps{
                script{
                    changedServices = getChangedServices()
                    echo "Services to build: ${changedServices}"
                }
            }
        }
        stage("Build and Unit Test Services"){
            steps{
                script{
                    if (changedServices.contains('products')) {
                        sh 'echo "========Building Products Service ========"'
                        buildNodeService('products-cna-microservice')
                    }
                    if (changedServices.contains('cart')) {
                        sh 'echo "========Building Cart Service ========"'
                        buildNodeService('search-cna-microservice')
                    }
                    if (changedServices.contains('store-ui')) {
                        sh 'echo "========Building UI Service ========"'
                        buildReactService()
                    }
                    else{
                        sh 'echo "========No services to build ========"'
                    }
                }
            }
        }
    }
    post{
        always{
            echo "========always========"
        }
        success{
            echo "========pipeline executed successfully ========"
        }
        failure{
            echo "========pipeline execution failed========"
        }
    }
}