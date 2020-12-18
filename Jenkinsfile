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
                //sh "git clone https://github.com/Chamathka-Rush/spring-hello.git"
                sh "echo git repository cloned"
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
                        dockerImage.push()
                        anchore forceAnalyze: true, bailOnFail: false, timeout: -1.0, name: 'anchore_images'
                        sh "docker rmi $registry:$BUILD_NUMBER" 
                        sh "echo ${dockerImage} ${WORKSPACE}/Dockerfile > anchore_images"
                        //sh 'echo "docker.io/exampleuser/examplerepo:latest `pwd`/Dockerfile" > anchore_images'
                       // anchore name: 'anchore_images'
                    }
                } 
            }
        } 

        stage("Anchore container image scanning stage"){
            steps{
                script{
                     def imageLine = dockerImage
                     writeFile file: 'anchore_images', text: imageLine
                     anchore name: 'anchore_images'
                }
            }
       }
    }
}
