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
    options {
        skipDefaultCheckout(true)
    }

    stages {
        stage("Checkout SCM") {
            steps {
                script {
                    echo "Checkout SCM"
                    env.GITMYBRANCH = "${BranchDeploy}"
                    //echo "Git Branch ${env.GITMYBRANCH}"
                    //echo "Git Branch env ${scm.branches[0].name}"                  
                    //checkout scm
                    checkout scm: ([
                        $class: 'GitSCM',
                        branches: [[name: env.GITMYBRANCH]],
                         doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                         extensions: scm.extensions,
                         userRemoteConfigs: scm.userRemoteConfigs
                    ])
                    
                }
            }
        }
        stage('Planejado') {
            steps {
                script {
                    echo "Planejado"

                    def userName = getBuildUser()
                    env.versaoTag ="${VersaoTag}"
                    env.dbDeploy ="${DataBaseDeploy}"                     
                    echo "Git Branch ${env.GITMYBRANCH}"

                    currentBuild.description = "${env.versaoTag} ${userName} ${env.dbDeploy} ${env.GITMYBRANCH}" 

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
                        if(fileExists(file:'Verify/'+ "${val2.Arquivo}"))
                        {
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
                        else{
                            echo "Não existe arquivo na pasta Verify: ${val2.Arquivo}"
                        }

                    }
                }
            }
        }
        stage("Git Tag Message"){
            steps {
                script {
                    echo "Git Tag Message"
                    def v_planejado = env.jsonPlanejado                                        
                    def v_tarefa = parseJsonToMap(v_planejado)
                    def setMessage = ""                    
                
                    v_tarefa.Tarefas.each { val3 ->
                        setMessage = setMessage + "#Autor:" + val3.Autor + " " + val3.Descricao 
                    }   
                                    
                    echo "Setando a descricao da tag ${env.versaoTag}"
                    withCredentials([gitUsernamePassword(credentialsId: 'ErnaniUlsenheimer', gitToolName: 'Default')]) {                       
                        sh "git tag ${env.versaoTag} -f -m \"meu teste 3\""
                        sh "git push -f -u origin ${env.versaoTag}"
                    }               
                    
                }
            }
        }
    }
}