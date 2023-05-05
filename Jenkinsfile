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
        stage('Planejado') {
            steps {
                script {
                    echo "Planejado"

                    def userName = getBuildUser()
                    env.versaoTag ="${VersaoTag}"
                    currentBuild.description = "${env.versaoTag} ${userName}" 

                    def json = readFile(file: 'sqlConfig.json')                    

                    echo "Read File Config"

                    def map = parseJsonToMap(json)

                    env.urlConexao = "${map.uri}"
                    env.databaseConnect = "${map.target}"                                        

                    echo  "uri = ${map.uri}"
                    echo  "target = ${map.target}"
                    echo  "verifyDeploy = ${map.verifyDeploy}"                    

                    def jsonPlan = readJSON file: 'sqlPlan.json' 
                    echo "Read File Plan"
                    //echo "Parsing Json Plan : ${jsonPlan}"   
                    
                    def planejado = "FALSE"
                    jsonPlan.each {val ->
                        if (val.Git.Version == env.versaoTag)
                        {
                            planejado = "TRUE"
                            env.jsonPlanejado = val
                        }
                    }
                    if (planejado == "FALSE")
                    {
                        error "Versão Planejado não está no arquivo de planejamento"
                    }
                    
                }
            }
        }
        stage("Deploy") {
            steps {
                script {
                    echo "Deploy"
                    echo "${env.urlConexao}"
                    echo "${env.databaseConnect}"                
                    echo "${env.versaoTag}"
                    def v_planejado = "${env.jsonPlanejado}"                    
                    echo "Planejado ${v_planejado}"
                    def v_tarefa = "${v_planejado.Tarefas}";
                    echo "Tarefas ${v_tarefa}"
                
                    v_tarefa.each { val2 ->
                        println val2
                    }
                }
            }
        }
        stage("Verify"){
            steps {
                echo "Verify"
            }
        }
    }
}