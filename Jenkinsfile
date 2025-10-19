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
        stage("Build"){
            steps{
                script{
                    if (changedServices.contains('products')) {
                        sh 'echo "========Building Node Service ========"'
                        buildNodeService()
                    }
                    if (changedServices.contains(store-ui)) {
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