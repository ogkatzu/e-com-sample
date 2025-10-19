@Library('shared-library') _

pipeline{
    agent any
    
    stages{
        stage("Build"){
            steps{
                sh 'echo "========Building Node Service ========"'
                sh 'pwd'
                sh 'ls -lah'
                sh 'cd products-cna-microservice && ls -la'
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