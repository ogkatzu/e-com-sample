@Library('shared-library') _

pipeline{
    agent none
    
    stages{
        stage("Checkout"){
            agent any
            steps{
                checkout scm
            }
        }
        stage("Get Changed Services"){
            agent any
            steps{
                script{
                    changedServices = getChangedServices()
                    echo "Services to build: ${changedServices}"
                }
            }
        }
        stage("Build and Unit Test Javascript Services"){
            parallel{
                stage("Build products Service"){
                    agent any
                    when {
                        expression { changedServices.contains('products') }
                    }
                    steps {
                        script{
                            sh 'echo "========Building Products Service ========"'
                            buildNodeService('products-cna-microservice')
                        }
                    }
                }
                stage("Build UI Service") {
                    agent any
                    when {
                        expression { changedServices.contains('store-ui') }
                    }
                    steps {
                        sh 'echo "========Building UI Service ========"'
                        buildReactService('store-ui')
                    }
                }
                stage("Build search Service"){
                    agent any
                    when {
                        expression { changedServices.contains('search') }
                    }
                    steps {
                        sh 'echo "========Building search Service ========"'
                        buildNodeService('search-cna-microservice')
                    }
                }
                stage("Build cart Service"){
                    agent {
                        label 'jdk-17'
                    }
                    when {
                        expression { changedServices.contains('cart') }
                    }
                    steps {
                        sh 'echo "========Building cart Service ========"'
                        buildJavaService('cart-cna-microservice')
                    }
                }
                stage("Build Users Service") {
                    agent {
                        label 'python'
                    }
                    when {
                        expression { changedServices.contains('users') }
                    }
                    steps {
                        sh 'echo "========Building Users Service ========"'
                        buildNodeService('users-cna-microservice')
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