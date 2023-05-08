import groovy.json.JsonSlurperClassic
import java.sql.DriverManager
import groovy.sql.Sql
import java.util.ServiceLoader;
import java.sql.Driver;

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

def repoUrl = 'https://github.com/ErnaniUlsenheimer/CI_CD_ORACLE.git'

pipeline {
    agent any
    environment {
        STRING_CONNCETION_DB=credentials('fepamusername')
    }

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
                    //echo "${env.versaoTag}"
                    def v_planejado = env.jsonPlanejado                    
                    //echo "Planejado ${v_planejado}"
                    def v_tarefa = parseJsonToMap(v_planejado)
                    //echo "Tarefas ${v_tarefa.Tarefas}"
                
                    v_tarefa.Tarefas.each { val2 ->
                        println "Arquivo Deploy: ${val2.Arquivo}"
                        def tarefaArquivo = readFile(file: 'Deploy/'+ "${val2.Arquivo}") 
                        echo "Tarefa Arquivo : ${tarefaArquivo}" 

                        def classLoader = this.class.classLoader
                        while (classLoader.parent) {
                            classLoader = classLoader.parent
                            if(classLoader.getClass() == java.net.URLClassLoader)
                            {
                                // load our jar into the urlclassloader
                                classLoader.addURL(new File("/usr/share/jenkins/WEB-INF/lib/ojdbc11.jar").toURI().toURL())
                                break;
                            }
                        }
                        Class.forName("oracle.jdbc.OracleDriver")
                        //TimeZone timeZone = TimeZone.getTimeZone("America/Sao_Paulo");
                        //TimeZone.setDefault(timeZone);
                        def url_connect = "${env.urlConexao}" + '/' + "${env.databaseConnect}"
                        echo "url connect: ${url_connect}"
                      
                        def conn = DriverManager.getConnection("${url_connect}", "$STRING_CONNCETION_DB_USR", "$STRING_CONNCETION_DB_PSW")
                        def statement = conn.createStatement()
                        def state_execute_DB = statement.execute("${tarefaArquivo}")
                        echo "Estatdo execute ${state_execute_DB}"
                    }
                }
            }
        }
        stage("Verify"){
            steps {
                script {
                    echo "Verify"
                    echo "${env.urlConexao}"
                    echo "${env.databaseConnect}"                
                    //echo "${env.versaoTag}"
                    def v_planejado = env.jsonPlanejado                    
                    //echo "Planejado ${v_planejado}"
                    def v_tarefa = parseJsonToMap(v_planejado)
                    //echo "Tarefas ${v_tarefa.Tarefas}"
                
                    v_tarefa.Tarefas.each { val2 ->
                        println "Arquivo Verify: ${val2.Arquivo}"
                        def tarefaArquivo = readFile(file: 'Verify/'+ "${val2.Arquivo}") 
                        echo "Tarefa Arquivo : ${tarefaArquivo}" 

                        def classLoader = this.class.classLoader
                        while (classLoader.parent) {
                            classLoader = classLoader.parent
                            if(classLoader.getClass() == java.net.URLClassLoader)
                            {
                                // load our jar into the urlclassloader
                                classLoader.addURL(new File("/usr/share/jenkins/WEB-INF/lib/ojdbc11.jar").toURI().toURL())
                                break;
                            }
                        }
                        Class.forName("oracle.jdbc.OracleDriver")
                        //TimeZone timeZone = TimeZone.getTimeZone("America/Sao_Paulo");
                        //TimeZone.setDefault(timeZone);
                        def url_connect = "${env.urlConexao}" + '/' + "${env.databaseConnect}"
                        echo "url connect: ${url_connect}"
                       

                        def conn = DriverManager.getConnection("${url_connect}", "$STRING_CONNCETION_DB_USR", "$STRING_CONNCETION_DB_PSW")

                        def statement = conn.prepareStatement("${tarefaArquivo}")
                        def state_execute_DB = statement.executeQuery()  
                        while (state_execute_DB.next()) {
                            echo "Result: ${state_execute_DB.getString(1)}"
                            
                        }                     
                        echo "Estatdo execute ${state_execute_DB}"
                    }
                }
            }
        }
        stage("Git Tag Message"){
            steps {
                script {
                    def v_planejado = env.jsonPlanejado                                        
                    def v_tarefa = parseJsonToMap(v_planejado)
                    def setMessage = ""                    
                
                    v_tarefa.Tarefas.each { val3 ->
                        setMessage = setMessage + "#Autor:" + val3.Autor + " " + val3.Descricao 
                    }

                    withCredentials([usernamePassword(
                        credentialsId: "ERNANIULSENHEIMER",
                        passwordVariable: 'GIT_PASSWORD',
                        usernameVariable: 'GIT_USERNAME')]) 
                    {
                        sh '''
                            git config --global credential.username $GIT_USERNAME
                            git config --global credential.helper '!f() { echo password=$GIT_PASSWORD; }; f'
                            
                        '''
                        sh """
                            git config remote.origin.url ${repoUrl}
                            git tag -d ${env.versaoTag}
                            git push origin HEAD:master --force
                            git tag -a ${env.versaoTag} -m \\"${setMessage}\\"
                            git push origin HEAD:master --force
                        """ 
                    }
                    
                }
            }
        }
    }
}