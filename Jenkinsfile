import groovy.json.JsonOutput
 
def currentComponent = [: ]

pipeline { 
    environment { 
        registry = "chamathka202602/one" 
        registryCredential = 'docker-hub-credentials'
	application_name = "InsightLive"
	application_url = "http://10.128.0.42:8089/insightlive-dashboard/"
	insightlive_ci_url = "http://10.128.0.42:8087/devops/api/ci/upsert-ci-data"
        insightlive_md_url = "http://10.128.0.42:8087/devops/api/md/upsert-md-data"
        insightlive_cd_url = "http://10.128.0.42:8087/devops/api/cd/upsert-cd-data"
	sonar_project_key = "demo"
	repository = "https://github.com/Chamathka-Rush/spring-hello.git"
	code_branch = "main"
	component = "demo"
    }

    agent any 
    stages { 
        stage('Checkout') { 
            steps { 
		script{
			job = "${env.JOB_NAME}".contains("/") ? "${env.JOB_NAME}".split("/")[1] : "${env.JOB_NAME}"
			link = "${env.JOB_URL}".replaceAll("${env.JENKINS_URL}", "") + "${env.BUILD_NUMBER}"
			id = application_name + "-" + component + "#" + "${env.BUILD_NUMBER}"
			try{
				currentComponent.id = "${id}"
				def timestamp = getTimestamp()
				def onStart = JsonOutput.toJson([application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", stage_checkout_start_time: timestamp, overall_status: "Executing", link: "${link}", build_number: "${env.BUILD_NUMBER}", id: "${id}", current_stage: "Checkout", job: "${job}", stage_checkout_status: "Executing", timestamp: timestamp])
				echo onStart;
				sendDevopsData(onStart, "${insightlive_ci_url}")
			git(
                                url: 'https://github.com/Chamathka-Rush/spring-hello.git',
				branch: 'main',
                                changelog: false,
                                credentialsId: 'github-credentials',
                                poll: true
                        )
				def end_time = getTimestamp()
                        	def onEnd = JsonOutput.toJson([application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", stage_checkout_start_time: end_time, overall_status: "Executing", link: "${link}", end_time: end_time, build_number: "${env.BUILD_NUMBER}", id: "${id}", current_stage: "Checkout", job: "${job}", stage_checkout_status: "Passed", timestamp: end_time])
                        	sendDevopsData(onEnd, "${insightlive_ci_url}")
			} catch (Exception e){
                        	def onError = JsonOutput.toJson([application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", stage_checkout_end_time: end_time, overall_status: "Executing", link: "${link}", end_time: end_time, build_number: "${env.BUILD_NUMBER}", id: "${id}", current_stage: "Checkout", job: "${job}", stage_checkout_status: "Error", timestamp: end_time])
                        	sendDevopsData(onError, "${insightlive_ci_url}")
                        	throw e
			}
		  }
            }
        } 

        stage('Docker Build') { 
            steps { 
                script {
		   def start_timestamp = getTimestamp()
                   def onStart = JsonOutput.toJson([application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", stage_dockerbuild_start_time: start_timestamp, overall_status: "Executing", link: "${link}", build_number: "${env.BUILD_NUMBER}", id: "${id}", current_stage: "Docker Build", job: "${job}", stage_dockerbuild_status: "Executing", timestamp: start_timestamp])
                   echo onStart
                   sendDevopsData(onStart, "${insightlive_ci_url}")
			
                    dockerImage = docker.build("${registry}:$BUILD_NUMBER")
                    echo "${dockerImage}"
			
		    def end_time = getTimestamp()
                    def onEnd = JsonOutput.toJson([application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", overall_status: "Executing", link: "${link}", end_time: end_time, build_number: "${env.BUILD_NUMBER}", stage_dockerbuild_end_time: end_time, id: "${id}", current_stage: "Docker Build", job: "${job}", stage_dockerbuild_status: "Passed", timestamp: end_time])
                    echo onEnd
                    sendDevopsData(onEnd, "${insightlive_ci_url}")
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
	    
	    
         stage('DEPENDANCY Scan') {
                 steps {
		       script{
				try {
				    echo "=============================="
				    echo "Starting Dependency Scan Stage"
				    echo "=============================="
				    def start_timestamp = getTimestamp()
                        	    def onStart = JsonOutput.toJson([application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", stage_sast_odc_start_time: start_timestamp, overall_status: "Executing", link: "${link}", build_number: "${env.BUILD_NUMBER}", id: "${id}", current_stage: "Dependency Scan", job: "${job}", stage_sast_odc_status: "Executing", timestamp: start_timestamp])
                        	    sendDevopsData(onStart, "${insightlive_ci_url}")
					
				    sh "rm -rf ./.scannerwork"
				    def hostWs = WORKSPACE

				    print(hostWs + "-----------------------------+")

				    sh "docker run --rm --volume '${hostWs}':/src:rw --volume '${hostWs}'/OWASP-Dependency-Check/data/:/usr/share/dependency-check/data:rw --volume '${hostWs}'/odc-reports:/report:rw owasp/dependency-check:latest --scan /src --exclude '/src/.scannerwork/**' --format 'ALL' --project 'demo' --out /report -debug"
				    echo "docker run executed-------------------"

				    def end_time = getTimestamp()
                        	    def onEnd = JsonOutput.toJson([application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", stage_sast_odc_end_time: end_time, overall_status: "Executing", link: "${link}", build_number: "${env.BUILD_NUMBER}", id: "${id}", current_stage: "Dependency Scan", job: "${job}", stage_sast_odc_status: "Passed", timestamp: end_time])
                        	    echo onEnd;
                        	    sendDevopsData(onEnd, "${insightlive_ci_url}")
				    updateStatusInInsight("demo", "SAST OWASP-Dependency-Check")
				} catch(Exception e) {
				    def end_time = getTimestamp()
				    def onError = JsonOutput.toJson([application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", stage_sast_odc_end_time: end_time, overall_status: "Executing", link: "${link}", build_number: "${env.BUILD_NUMBER}", id: "${id}", current_stage: "Dependency Scan", job: "${job}", stage_sast_odc_status: "Error", timestamp: end_time])
				    echo onError;
				    sendDevopsData(onError, "${insightlive_ci_url}")
				    throw e
				}
              		}
           	}
        }
	    
	stage('DAST Scan') {
	      agent any
	      steps {
		script {
		  try {
		    echo "=============================="
		    echo "Starting Dependency Scan Stage"
		    echo "=============================="
		    def hostWs = WORKSPACE
	            print(hostWs + "-----------------------------+")
		    echo "=============================="
		    def start_timestamp = getTimestamp()
                    def onStart = JsonOutput.toJson([application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", stage_dast_status: "Executing", overall_status: "Executing", link: "${link}", build_number: "${env.BUILD_NUMBER}", id: "${id}", current_stage: "DAST Scan", job: "${job}", stage_dast_start_time: start_timestamp, timestamp: start_timestamp])
                    echo onStart;
                    sendDevopsData(onStart, "${insightlive_ci_url}")
		    sh "chmod -R 777 /var/jenkins_home/zap"
                    sh "cd /var/jenkins_home/zap && rm -rf *"
                    sh "docker run --rm -v /var/jenkins_home/zap/:/zap/wrk/:rw -t owasp/zap2docker-stable zap-full-scan.py -i -t http://10.128.0.42:8089/insightlive-dashboard/ -g gen.conf -x testreport.xml"
		    def end_time = getTimestamp()
                    def onEnd = JsonOutput.toJson([application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", stage_dast_status: "Passed", overall_status: "Executing", link: "${link}", build_number: "${env.BUILD_NUMBER}", id: "${id}", current_stage: "DAST Scan", job: "${job}", stage_dast_end_time: end_time, timestamp: end_time])
                    sendDevopsData(onEnd, "${insightlive_ci_url}")
		  } catch(Exception e) {
		    def end_time = getTimestamp()
                        def onError = JsonOutput.toJson([application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", stage_dast_status: "Failed", overall_status: "Executing", link: "${link}", build_number: "${env.BUILD_NUMBER}", id: "${id}", current_stage: "DAST Scan", job: "${job}", stage_dast_end_time: end_time, timestamp: end_time])
                        echo onError;
                        sendDevopsData(onError, "${insightlive_ci_url}")
		  }
		}
	      }
	 }

         stage('Static Analysis'){
                 steps {
                    script {
                        try {
			    def start_timestamp = getTimestamp()
                            def onStart = JsonOutput.toJson([application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", stage_sast_sonar_status: "Executing", overall_status: "Executing", link: "${link}", build_number: "${env.BUILD_NUMBER}", id: "${id}", current_stage: "Static Analysis", job: "${job}", stage_sast_sonar_start_time: start_timestamp, timestamp: start_timestamp])
                            sendDevopsData(onStart, "${insightlive_ci_url}")
                            sh "sh /var/jenkins_home/sonar-scanner-3.2.0.1227-linux/bin/sonar-scanner -Dsonar.login=a77ef296422c3e04cdf03d0c0e53547f9b260f2c -Dsonar.projectBaseDir=. -Dsonar.dependencyCheck.htmlReportPath=odc-reports/dependency-check-report.html -Dsonar.dependencyCheck.jsonReportPath=odc-reports/dependency-check-report.json -Dsonar.projectKey=demo -Dsonar.sources=. -Dsonar.java.binaries=. -DtoolStackRulesPath=/var/jenkins_home/Rules/tool_stack_rules.xml -DserviceComplianceRulesPath=/var/jenkins_home/Rules/service_compliance_rules.xml -DanchoreJsonParser=/var/jenkins_home/Rules/anchoreengine-api-response-vulnerabilities-1.json -DconfigurationRulesPath=/var/jenkins_home/Rules/config_compliance_rules.xml -DcicdComplianceRulesPath=/var/jenkins_home/Rules/ci-cd_compliance_rules.xml -DarchitectureComplianceReportPath=/var/jenkins_home/Rules/jqassistant/reports/jqassistant-report.xml -Dsonar.zaproxy.reportPath=/var/jenkins_home/zap/testreport.xml"
			    def end_time = getTimestamp()
                            def onEnd = JsonOutput.toJson([stage_sast_sonar_end_time: end_time, application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", stage_sast_sonar_status: "Passed", overall_status: "Executing", link: "${link}", end_time: end_time, build_number: "${env.BUILD_NUMBER}", id: "${id}", current_stage: "Static Analysis", job: "${job}", timestamp: end_time])
                            echo onEnd;
                            sendDevopsData(onEnd, "${insightlive_ci_url}")
			    updateStatusInInsight("demo", "AST Sonar Static Code Analyser")
                        } catch (Exception e) {
                            def end_time = getTimestamp()
                        def onError = JsonOutput.toJson([stage_sast_sonar_end_time: end_time, application_name: "${application_name}", sonar_project_key: "${sonar_project_key}", repository: "${repository}", branch: "${code_branch}", stage_sast_sonar_status: "Failed", overall_status: "Executing", link: "${link}", end_time: end_time, build_number: "${env.BUILD_NUMBER}", id: "${id}", current_stage: "Static Analysis", job: "${job}", timestamp: end_time])
                        echo onError;
                        sendDevopsData(onError, "${insightlive_ci_url}")
                        throw e
                        }
                    }
                }
            }
	    post {
		always {
		    script {
			echo "============="
			echo "Starting Post"
			echo "============="
			def end_timestamp = getTimestamp()
			def finalResult = "Passed"
			def result = currentBuild.currentResult
			echo result

			if (result.toLowerCase() == 'failure') {
			    finalResult = "Failed"
			} else if (result.toLowerCase() == 'success') {
			    finalResult = "Passed"
			} else {
			    finalResult = "Aborted"
			}
			def onEnd = JsonOutput.toJson([overall_status: finalResult, id: "${currentComponent.id}", timestamp: end_timestamp, end_time: end_timestamp])
			echo onEnd;
			sendDevopsData(onEnd, "${insightlive_ci_url}")
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

def getTimestamp() {
    return System.currentTimeMillis();
}

def sendDevopsData(String data, String url) {
    try {
        httpRequest consoleLogResponseBody: true,
                contentType: 'APPLICATION_JSON',
                httpMode: 'POST',
                requestBody: "${data}",
                url: "${url}"
	echo("Updated devops")
    } catch(Exception e) {
        echo(e.toString())
        echo("Could not send data to devops")
    }
}
