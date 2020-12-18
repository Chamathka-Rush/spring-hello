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
                        //sh "docker build -t springdemo:v1 ."
                        sh "docker images"
                    }
                }
            }
        }
        
        stage('Push image') {
            steps{
                script{
                    withCredentials([usernamePassword( credentialsId: 'docker-hub-credentials', usernameVariable: 'USER', passwordVariable: 'PASSWORD')]) {
                    def registry_url = "registry.hub.docker.com/"
                    sh "docker login -u $USER -p $PASSWORD ${registry_url}"
                    docker.withRegistry("http://${registry_url}", "docker-hub-credentials") {
                    // Push your image now
                    sh "docker tag springdemo:v1 chamathka202602/springdemo:v1"
                    sh "docker push chamathka202602/springdemo:v1"
                    sh "docker rmi chamathka202602/springdemo:v1"
                    sh "echo chamathka202602/springdemo:v1 ${WORKSPACE}/Dockerfile > anchore_images"
                    anchore forceAnalyze: true, bailOnFail: false, timeout: -1.0, name: 'anchore_images'
                }   
            }
        }
    }
}
        
       // stage('Pushing the docker image to the container registry'){
            //steps{
               // script{
                     //sh "docker tag springdemo:v1 chamathka202602/springdemo:v1"
                     //sh "docker login --username=chamathka202602"
                     //sh "docker push chamathka202602/springdemo:v1"
                     //sh "docker rmi chamathka202602/springdemo:v1"
                     //sh "echo chamathka202602/springdemo:v1 ${WORKSPACE}/Dockerfile > anchore_images"
                     //anchore forceAnalyze: true, bailOnFail: false, timeout: -1.0, name: 'anchore_images'
               // }
           // }
       // }
        
        stage("Anchore container image scanning stage"){
            steps{
                script{
                     def imageLine = 'chamathka202602/springdemo:v1'
                     writeFile file: 'anchore_images', text: imageLine
                     anchore name: 'anchore_images'
                }
            }
        }
    }
}
