pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                script{
                    //sh 'git clone https://github.com/Chamathka-Rush/spring-hello.git'
                    //sh 'git pull origin master'
                    //echo 'cloned the repository...'
                    sh "pwd" 
                    sh "ls -lh"
                    
                }
            }
        }
        
        stage('Setting the directory'){
            steps{
                script{
                    dir('/var/jenkins_home/workspace/springboot/spring-hello/'){
                        sh "pwd"
                    }
                }
            }
        }
        
        stage('Build the docker image'){
            steps{
                script{
                    dir("/var/jenkins_home/workspace/springboot/spring-hello/") {
                        sh "pwd"
                        //sh "docker build -t spring-hello:v2 ."
                        sh "docker images"
                    }
                }
            }
        }
        
        stage('Pushing the docker image to the containe registry')
        
        stage("Anchore container image scanning stage"){
            steps{
                script{
                     def imageLine = 'chamathka202602/springboot'
                     writeFile file: 'anchore_images', text: imageLine
                     anchore name: 'anchore_images'
                }
            }
        }
    }
}
