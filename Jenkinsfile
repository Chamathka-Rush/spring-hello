
pipeline { 
    environment { 
        registry = "chamathka202602/one" 
        registryCredential = 'docker-hub-credentials' 
        dockerImage = '' 
    }
    agent any 
    stages { 
        stage('Cloning our Git') { 
            steps { 
                echo "cloned the repository"
                //sh "git clone https://github.com/Chamathka-Rush/spring-hello.git"
            }
        } 
        stage('Building our image') { 
            steps { 
                script { 
                    dockerImage = docker.build registry + ":$BUILD_NUMBER" 
                }
            } 
        }
        stage('Deploy our image') { 
            steps { 
                script { 
                    docker.withRegistry( '', registryCredential ) { 
                        echo "docker image name = ${dockerImage}"
                        dockerImage.push() 
                        sh "echo ${dockerImage} ${WORKSPACE}/Dockerfile > anchore_images"
                        anchore forceAnalyze: true, bailOnFail: false, timeout: -1.0, name: 'anchore_images'
                    }
                } 
            }
        }
        
        stage('Cleaning up') { 
            steps { 
                sh "docker rmi $registry:$BUILD_NUMBER" 
            }
        } 
    }
}
