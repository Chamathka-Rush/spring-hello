pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                script{
                    sh 'git clone https://github.com/Chamathka-Rush/spring-hello.git'
                    sh 'git pull origin master'
                    echo 'cloned the repository...'
                    sh "pwd" 
                    sh "ls -lh"
                    
                }
            }
        }
        
        stage('Setting the directory'){
            steps{
                script{
                    dir('/var/jenkins_home/workspace/test/spring-hello/'){
                        sh "pwd"
                    }
                }
            }
        }
        
        stage('Build the docker image'){
            steps{
                script{
                    dir("/var/jenkins_home/workspace/test/spring-hello/") {
                        sh "pwd"
                        sh "docker build -t spring-hello-jenkins:v1 ."
                        sh "docker images"
                    }
                }
            }
        }
    }
}
