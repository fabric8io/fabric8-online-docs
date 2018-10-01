#!/usr/bin/groovy
@Library('github.com/fabric8io/fabric8-pipeline-library@master')
def flow = new io.fabric8.Fabric8Commands()
def utils = new io.fabric8.Utils()
def imageName
dockerTemplate{
    clientsNode{
        ws{
            checkout scm
            if (utils.isCI()){
                echo 'Running CI pipeline'
                imageName = "fabric8/fabric8-online-docs:SNAPSHOT-${env.BRANCH_NAME}-${env.BUILD_NUMBER}"

                dir('./'){
                    container('clients') {
                        stage ('test & build docs'){
                            sh 'scripts/build_guides.sh'
                        }
                    }
                    container('docker') {
                        stage ('build image'){
                            sh "docker build -t ${imageName} -f Dockerfile.deploy ."
                        }
                        stage ('push to dockerhub'){
                            sh "docker push ${imageName}"
                        }
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
                    def message = "@${changeAuthor} snapshot ${imageName} is available for testing"
                    container('clients'){
                        flow.addCommentToPullRequest(message, pr, 'fabric8io/fabric8-online-docs')
                    }
                }

            } else if (utils.isCD()){
                echo 'release provided by CI centos not fabric8 pipelines'
            }
        }
    }
}

