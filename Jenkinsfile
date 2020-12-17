pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                script{
                    //sh 'git clone https://github.com/Chamathka-Rush/spring-hello.git'
                    echo 'cloned the repository...'
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
                        //sh "docker build -t springdemo ."
                        sh "docker images"
                    }
                }
            }
        }
        
        stage('Pushing the docker image to the container registry'){
            steps{
                script{
                       sh "docker tag springdemo chamathka202602/springdemo"
                       //sh "docker login --username=chamathka202602"
                       sh "docker push chamathka202602/springdemo"
                       sh "docker rmi chamathka202602/springdemo"
                       sh "echo chamathka202602/springdemo ${WORKSPACE}/Dockerfile > anchore_images"
                       anchore forceAnalyze: true, bailOnFail: false, timeout: -1.0, name: 'anchore_images'
                }
            }
        }
        
        stage("Anchore container image scanning stage"){
            steps{
                script{
                     def imageLine = 'chamathka202602/springdemo'
                     writeFile file: 'anchore_images', text: imageLine
                     anchore name: 'anchore_images'
                }
            }
        }
    }
}
