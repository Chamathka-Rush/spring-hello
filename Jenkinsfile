pipeline { 
    environment { 
        registry = "chamathka202602/one" 
        registryCredential = 'docker-hub-credentials' 
    }

    agent any 
    stages { 
        stage('Checkout') { 
            steps { 
		script{
			try{
			git(
                                url: 'https://github.com/Chamathka-Rush/spring-hello.git',
				branch: 'main',
                                changelog: false,
                                credentialsId: 'github-credentials',
                                poll: true
                        )  	
			} catch (Exception e){
				throw e
			}
		  }
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
            echo '${WORKSPACE}' 
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
	    
	    
         stage('DAST Scan') {
                 steps {
		       script{
           		sh "chmod -R 777 /var/jenkins_home/zap"
           		sh "cd /var/jenkins_home/zap && rm -rf *"
           		sh "docker run --rm -v /var/jenkins_home/zap/:/zap/wrk/:rw -t owasp/zap2docker-stable zap-full-scan.py -i -t http://10.128.0.42:8089/insightlive-dashboard/ -g gen.conf -x testreport.xml"
              }
           }
        }
	    
	    
	    
         stage('Static Analysis'){
                 steps {
                    script {
                        try {
                            sh "sh /var/jenkins_home/sonar-scanner-3.2.0.1227-linux/bin/sonar-scanner -Dsonar.login=a77ef296422c3e04cdf03d0c0e53547f9b260f2c -Dsonar.projectBaseDir=. -Dsonar.dependencyCheck.htmlReportPath=odc-reports/dependency-check-report.html -Dsonar.dependencyCheck.jsonReportPath=odc-reports/dependency-check-report.json -Dsonar.projectKey=demo -Dsonar.sources=. -Dsonar.java.binaries=. -DtoolStackRulesPath=/var/jenkins_home/Rules/tool_stack_rules.xml -DserviceComplianceRulesPath=/var/jenkins_home/Rules/service_compliance_rules.xml -DanchoreJsonParser=/var/jenkins_home/Rules/anchoreengine-api-response-vulnerabilities-1.json -DconfigurationRulesPath=/var/jenkins_home/Rules/config_compliance_rules.xml -DcicdComplianceRulesPath=/var/jenkins_home/Rules/ci-cd_compliance_rules.xml -DarchitectureComplianceReportPath=/var/jenkins_home/Rules/jqassistant/reports/jqassistant-report.xml -Dsonar.zaproxy.reportPath=/var/jenkins_home/zap/testreport.xml"
			    updateStatusInInsight("demo", "AST Sonar Static Code Analyser")
                        } catch (Exception e) {
                            throw e
                        }
                    }
                }
            }
	    
	 
         
    }
}

def updateStatusInInsight(String projectKey, String Stage){
  def checklisturl = "http://10.128.0.42:8083/mapper/api/v1/compliance-checklist/projects/ci-cd"
  def checklistbody = [: ]
  checklistbody.sonarProjectKey = projectKey
  checklistbody.sonarInstace = "sonar-01"
  checklistbody.checkListItem = Stage
  checklistbody.enabled = "true"
  def body = groovy.json.JsonOutput.toJson(checklistbody)
  echo(body)

  try {
    httpRequest consoleLogResponseBody: true,
    contentType: 'APPLICATION_JSON',
    httpMode: 'POST',
    requestBody: "${body}",
    url: "${checklisturl}",
    ignoreSslErrors: true
    echo("Updated insight")
  } catch(Exception e) {
    echo("Could not update insight")
  }
    
}
