//WARNING: Initialize with production variables, staging / dev variables are assigned in the Init stage!!!
def getCurrentBranch () {
    return scm.branches[0].name.trim().split("/").last()
}

def getGitTag () {
    return sh (
            script: 'git rev-parse --short HEAD',
            returnStdout: true
    ).trim()
}

def APP_ENV = "production"
def GATEWAY_DOMAIN = "gateway.authmarshal.com"
def GATEWAY_PREFIX='/proxy'
def SERVICE_NAME='authmarshal-proxy-service'
def SERVICE_PORT=4305
def GIT_TAG=''
def BRANCH_NAME=''
def AGENT_LABEL = ''
def STAGING_NODE_LABEL = 'bumblebee'
def PRODUCTION_NODE_LABEL = 'prime'



node("${STAGING_NODE_LABEL}") {

    stage('Checkout and set agent') {
        script{
            checkout scm
             GIT_TAG= getGitTag()
             BRANCH_NAME= getCurrentBranch()
            echo "init with ${BRANCH_NAME} and git tag ${GIT_TAG}"

            if (BRANCH_NAME == 'master' || BRANCH_NAME == 'main') {
                AGENT_LABEL = "${PRODUCTION_NODE_LABEL}"
                echo "production branch detected!: node  will be: $AGENT_LABEL"
            }else if(BRANCH_NAME == 'staging' || BRANCH_NAME == 'dev') {
                AGENT_LABEL = "${STAGING_NODE_LABEL}"
                echo "production branch detected!: node  will be: $AGENT_LABEL"
            }else{
                echo "no branch detected! as branch is ${BRANCH_NAME}: node  will be: $AGENT_LABEL"

            }
        }
    }
}

pipeline {
    agent {
        label "${AGENT_LABEL}"
    }

    environment {
        PRIVATE_REGISTRY_URL='127.0.0.1:5001'
        NETWORK_NAME='gds-centriqo-lms-infrastructure_centriqo'
    }
    stages {

        stage('Git') {
            steps {
                checkout scm
            }
        }
        stage('Init') {
            steps{
                script{
                    if (BRANCH_NAME == 'master' || BRANCH_NAME == 'main') {
                        APP_ENV = "production"
                        echo "production branch detected!: gateway will be: $GATEWAY_DOMAIN"
                    }else if(BRANCH_NAME == 'staging' || BRANCH_NAME == 'dev') {
                        APP_ENV = "staging"
                        GATEWAY_DOMAIN = "staging.$GATEWAY_DOMAIN"
                        SERVICE_NAME  = "$SERVICE_NAME-dev"
                        SERVICE_PORT = SERVICE_PORT + 1
                        echo "staging branch detected!: gateway will be: $GATEWAY_DOMAIN"
                    }
                }
            }
        }

        stage('Build') {
            steps {

                script {
                        sh "docker build \
                          --build-arg SPRING_PROFILES_ACTIVE=$APP_ENV \
                         -t $PRIVATE_REGISTRY_URL/$SERVICE_NAME:$GIT_TAG ."


                    sh "docker push $PRIVATE_REGISTRY_URL/$SERVICE_NAME:$GIT_TAG"
                }


            }
        }

        stage('Deploy') {
            steps {
                script{

                    sh "docker stop $SERVICE_NAME || true && docker rm $SERVICE_NAME || true"

                    sh "docker run --log-opt max-size=10m --log-opt max-file=5 -d \
                          -p $SERVICE_PORT:$SERVICE_PORT \
                          -e SPRING_PROFILES_ACTIVE=$APP_ENV \
                          -e SERVER_PORT=$SERVICE_PORT \
                          --label 'traefik.http.routers.${SERVICE_NAME}.rule=Host(`$GATEWAY_DOMAIN`) && PathPrefix(`$GATEWAY_PREFIX`)' \
                          --label traefik.http.routers.${SERVICE_NAME}.tls=true \
                          --label traefik.http.routers.${SERVICE_NAME}.tls.certresolver=lets-encrypt \
                          --label 'traefik.http.middlewares.${SERVICE_NAME}.stripprefix.prefixes=$GATEWAY_PREFIX' \
                          --label 'traefik.http.middlewares.${SERVICE_NAME}.stripprefix.forceSlash=false' \
                          --label 'traefik.http.routers.${SERVICE_NAME}.middlewares=$SERVICE_NAME' \
                          --label traefik.port=80 \
                          --label traefik.enable=true \
                          --name $SERVICE_NAME \
                          --network $NETWORK_NAME  \
                            $PRIVATE_REGISTRY_URL/$SERVICE_NAME:$GIT_TAG"

                }
            }
        }
    }
}
