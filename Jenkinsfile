#!/usr/bin/groovy
@Library('github.com/fabric8io/fabric8-pipeline-library@master')
def flow = new io.fabric8.Fabric8Commands()
def baseImageVerion = 'v27ab2ac'

clientsNode{
    checkout scm
    if (utils.isCI()){
        echo 'Running CI pipeline'
        snapshot = true
        def version = "SNAPSHOT-${env.BRANCH_NAME}-${env.BUILD_NUMBER}"

        container('docker') {
            stage ('build docs'){
                sh "docker build -t fabric8/fabric8-online-docs:${version} ."    
            }
            stage ('push to dockerhub'){
                sh "docker push fabric8/fabric8-online-docs:${version}"    
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
            def message = "@${changeAuthor} snapshot image is available for testing.  `docker pull fabric8/fabric8-online-docs:${version}`"
            container('docker'){
                flow.addCommentToPullRequest(message, pr, project)
            }
        }

    } else if (utils.isCD()){

        echo 'Running CD pipeline'
        def newVersion = getNewVersion {}

        container('docker') {
            stage ('build docs'){
                sh "docker build -t fabric8/fabric8-online-docs:${newVersion} ."    
            }
            stage ('push to dockerhub'){
                sh "docker push fabric8/fabric8-online-docs:${newVersion}"    
            }
        }

        pushPomPropertyChangePR {
            propertyName = 'caddy.version'
            projects = [
                    'fabric8-apps/caddy'
            ]
            version = newVersion
            containerName = 'clients'
        }
    }
}
