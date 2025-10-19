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
                sh 'echo "========Building Node Service ========"'
                buildNodeService()
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