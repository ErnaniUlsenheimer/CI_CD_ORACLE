import groovy.json.JsonSlurperClassic

/**
 * Parse JSON to a map.
 *
 * It needs script approvals:
 *
 *  'method groovy.json.JsonSlurperClassic parseText java.lang.String'
 *  'new groovy.json.JsonSlurperClassic'
 *  'new java.util.HashMap java.util.Map'
 *
 * Also see:
 * http://stackoverflow.com/questions/37864542/jenkins-pipeline-notserializableexception-groovy-json-internal-lazymap
 *
 * @param json Json string to parse with name / value properties
 * @return A map of properties
 */
@NonCPS
def parseJsonToMap(String json) {
    final slurper = new JsonSlurperClassic()
    return new HashMap<>(slurper.parseText(json))
}

@NonCPS
def getBuildUser() {
    return currentBuild.rawBuild.getCause(Cause.UserIdCause).getUserId()
}

pipeline {

    agent any

    stages {
        stage('Planejamento') {
            steps {
                script {

                    def userName = getBuildUser()
                    env.versaoTag ="${VersaoTag}"
                    currentBuild.description = "${env.versaoTag} ${userName}" 

                    def json = readFile(file: 'sqlConfig.json')                    

                    echo "Parsing JSON Config: ${json}"

                    def map = parseJsonToMap(json)

                    env.urlConexao = "${map.uri}"
                    env.databaseConnect = "${map.target}"                                        

                    echo  "uri = ${map.uri}"
                    echo  "target = ${map.target}"
                    echo  "verifyDeploy = ${map.verifyDeploy}"                    

                    def jsonPlan = readJSON file: 'sqlPlan.json' 
                    echo "Parsing Json Plan : ${jsonPlan}"   
                    
                    jsonPlan.each {val ->
                        println val
                    }
                    
                }
            }
        }
        stage("Deploy") {
            steps {
                echo "${env.urlConexao}"
                echo "${env.databaseConnect}"                
                echo "${env.versaoTag}"
            }
        }
        stage("Verify"){
            steps {
                echo "Verify"
            }
        }
    }
}