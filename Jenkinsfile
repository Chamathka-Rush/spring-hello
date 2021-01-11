pipeline { 
    environment { 
        registry = "chamathka202602/one" 
        registryCredential = 'docker-hub-credentials' 
    }

    agent any 
    stages { 
        stage('Clone') { 
            steps { 
                echo "cloned the repository"
                //sh "git clone https://github.com/Chamathka-Rush/spring-hello.git"
            }
        } 

        stage('Docker Build') { 
            steps { 
                script { 
                    dockerImage = docker.build("${registry}:$BUILD_NUMBER")
                    echo "${dockerImage}"
                }
            } 
        }

        stage('Docker Push') { 
            steps { 
                script {
                    sh "docker push $registry:$BUILD_NUMBER"
                } 
            }
        }
        
        stage('Anchor Analysis') { 
          steps {
           script {
	    sh 'echo "docker.io/${registry}:$BUILD_NUMBER ${WORKSPACE}/Dockerfile" > anchore_images'
	    anchore forceAnalyze: true, bailOnFail: false, timeout: -1.0, name: 'anchore_images'
	    sh "docker rmi $registry:$BUILD_NUMBER"
	    updateStatusInInsight("demo", "Anchor Analysis")
	        	}
            }
        } 
        
        stage('jqassistant Analysis'){
            steps{
                script{
                    sh "/var/jenkins_home/jqassistant-commandline-neo4jv3-1.8.0/bin/jqassistant.sh analyze -f ${WORKSPACE}/target -r /var/jenkins_home/Rules/jqassistant/rules -reportDirectory /var/jenkins_home/Rules/jqassistant/reports"
                }
            }
        }
        
        // stage('Static Analysis'){
        //     agent {
        //             docker {
        //                 image 'sonar-scanner-custom'
        //                 args '--add-host era:10.2.164.24 -v /home/admingtoops/.sonar/cache:/root/.sonar/cache'
        //             }
        //         }
        //         steps {
        //             script {
        //                 sh "sh /sonar-scanner-3.2.0.1227/bin/sonar-scanner -Dsonar.login=d7a97e256ef0e7dc9cc4ac09ffb99753f8a7f5c3 -Dsonar.projectBaseDir=. -Dsonar.dependencyCheck.htmlReportPath=odc-reports/dependency-check-report.html -Dsonar.projectKey='${params.sonarProjectKey}' -Dsonar.sources=. -Dsonar.java.binaries=. -Dsonar.branch.name='${params.branch}' -Dsonar.verbose=false -Dsonar.exclusions=${params.sonarExclusions} -Dsonar.css.file.suffixes=.foo -Dsonar.jacoco.reportPath=${WORKSPACE}/target/jacoco.exec -DtoolStackRulesPath=/var/jenkins_home/rules/tool_stack_rules.xml -DserviceComplianceRulesPath=/var/jenkins_home/rules/service_compliance_rules.xml -DanchoreJsonParser=/var/jenkins_home/rules/anchoreengine-api-response-vulnerabilities-1.json -DconfigurationRulesPath=/var/jenkins_home/rules/config-compliance-rules.xml -DcicdComplianceRulesPath=/var/jenkins_home/rules/ci-cd_compliance_rules.xml -DenvironmentComplianceRulesPath=/var/jenkins_home/rules/environment_compliance.xml -DarchitectureComplianceReportPath=/var/jenkins_home/jqa/reports/jqassistant-report.xml"
        //                 updateStatusInInsight(params.sonarProjectKey, "AST Sonar Static Code Analyser")
        //             }
        //         }
        // }
    }
}


def updateStatusInInsight(String projectKey, String Stage){
    def checklisturl = "http://10.128.0.42:8089/compliant/mapper/api/v1/compliance-checklist/projects/ci-cd/"
    def checklistbody = [:]
    checklistbody.sonarProjectKey = projectKey
    checklistbody.sonarInstace = "sonar-01"
    checklistbody.checkListItem = Stage
    checklistbody.enabled = "true"
    def body = groovy.json.JsonOutput.toJson(checklistbody)
    echo(body)

    try {
        httpRequest consoleLogResponseBody: true, authentication: 'devsecops-insight-authentication', contentType: 'APPLICATION_JSON', httpMode: 'POST', requestBody: "${body}", url: "${checklisturl}", ignoreSslErrors: true
        echo("Updated insight")
    } catch(Exception e) {
        echo("Could not update insight")
    }
}
