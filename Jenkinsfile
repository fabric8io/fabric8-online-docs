#!/usr/bin/groovy
@Library('github.com/fabric8io/fabric8-pipeline-library@master')
def flow = new io.fabric8.Fabric8Commands()
def utils = new io.fabric8.Utils()
def baseImageVerion = 'v27ab2ac'
def snapshot = false
def imageName
dockerTemplate{
    clientsNode{
        ws{
            checkout scm
            if (utils.isCI()){
                echo 'Running CI pipeline'
                imageName = "fabric8/fabric8-online-docs:SNAPSHOT-${env.BRANCH_NAME}-${env.BUILD_NUMBER}"

                dir('user_guide'){
                    container('clients') {
                        stage ('build docs'){
                            sh 'asciidoctor --doctype=book --section-numbers --attribute=toc master.adoc'
                        }
                    }
                    container('docker') {
                        stage ('build image'){
                            sh "docker build -t ${imageName} ."    
                        }
                        stage ('push to dockerhub'){
                            sh "docker push ${imageName}"    
                        }
                    }
                }

                snapshot = true

            } else if (utils.isCD()){

                echo 'Running CD pipeline'
                def newVersion = getNewVersion {}
                imageName = "fabric8/fabric8-online-docs:${newVersion}"
                dir('user_guide'){
                    container('clients') {
                        stage ('build docs'){
                            sh 'asciidoctor --doctype=book --section-numbers --attribute=toc master.adoc'
                        }
                    }
                    container('docker') {
                        stage ('build image'){
                            sh "docker build -t fabric8/fabric8-online-docs:${newVersion} ."    
                        }
                        stage ('push to dockerhub'){
                            sh "docker push fabric8/fabric8-online-docs:${newVersion}"    
                        }
                    }
                }

                pushPomPropertyChangePR {
                    propertyName = 'fabric8-online-docs.version'
                    projects = [
                            'fabric8-apps/fabric8-online-docs-app'
                    ]
                    version = newVersion
                    autoMerge = true
                    containerName = 'clients'
                }
            }
        }
    }
}

if (snapshot){
   def prj = env.BRANCH_NAME
   prj = prj.toLowerCase()
   def route
   deployOpenShiftNode(openshiftConfigSecretName: 'fabric8-intcluster-config'){
        stage("deploy ${prj}"){
           route = deployOpenShiftSnapshot{
               mavenRepo = 'http://central.maven.org/maven2/io/fabric8/apps/fabric8-online-docs-app'
               githubRepo = 'fabric8-online-docs-app'
               originalImageName = 'fabric8/fabric8-online-docs'
               newImageName = imageName
               openShiftProject = prj
           }
        }

        stage('notify'){
            def changeAuthor = env.CHANGE_AUTHOR
            if (!changeAuthor){
                error "no commit author found so cannot comment on PR"
            }
            def pr = env.CHANGE_ID
            if (!pr){
                error "no pull request number found so cannot comment on PR"
            }
            def message = "@${changeAuthor} snapshot ${imageName} is available for testing at http://${route}"
            container('clients'){
                flow.addCommentToPullRequest(message, pr, 'fabric8io/fabric8-online-docs')
            }
        }
   }
}