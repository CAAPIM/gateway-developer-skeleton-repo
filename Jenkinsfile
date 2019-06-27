pipeline {
    agent any

    environment {
        GIT_REPOSITORY = 'https://github.com/wynnel/gateway-developer-example'
        NEW_IMAGE_NAME = 'gateway'
        NEW_IMAGE_TAG = "${BUILD_NUMBER}"
        NEW_IMAGE_REGISTRY_REPOSITORY    = 'docker-hosted'
    }

    stages {
        stage('Pull from Git') {
            steps {
                git "${env.GIT_REPOSITORY}"
            }
        }
        stage('Gradle Preparation & Build') {
            steps {
                sh '''./gradlew clean
                        ./gradlew build'''

            }
        }
        stage('Build Image with Docker') {
            steps {
                sh """./gradlew -DimageName=${env.NEW_IMAGE_NAME} -DimageTag=${env.NEW_IMAGE_TAG} buildDockerImage"""
            }
        }
        stage('Testing Docker image') {
            steps {
                script {
                    def jobDir = pwd()
                    env.GATEWAY_CONTAINER_ID = sh script: """docker run \
                        --env ACCEPT_LICENSE=true \
                        --env EXTRA_JAVA_ARGS=-Dcom.l7tech.bootstrap.env.license.enable=true \
                        --env ENV.PROPERTY.gateway.template=docker \
                        --env ENV.CONTEXT_PROPERTY.env-configuration.example=example \
                        --env ENV.CONTEXT_VARIABLE_PROPERTY.env-configuration.example=example \
                        --env ENV.PASSWORD.password=secret \
                        --env ENV.CONTEXT_VARIABLE_PROPERTY.influxdb.influxdb=influxdb \
                        --env ENV.CONTEXT_VARIABLE_PROPERTY.influxdb.tags=env=design \
                        --env SSG_LICENSE=\$(cat $jobDir/../../license.xml | gzip | base64 --wrap=0) \
                        -p 8080 \
                        -p 8443 \
                        -d ${env.NEW_IMAGE_NAME}:${env.NEW_IMAGE_TAG} | cut -c 1-12""", returnStdout: true
                    env.GATEWAY_CONTAINER_IP = sh([script: "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${env.GATEWAY_CONTAINER_ID}", returnStdout: true]).trim()
                }

                timeout(4) {
                    waitUntil {
                        script {
                            def r = sh script: "wget http://${env.GATEWAY_CONTAINER_IP}:8080/env-configuration", returnStatus: true
                            return (r == 0);
                        }
                    }
                }
                sh "docker stop ${env.GATEWAY_CONTAINER_ID}"
            }
        }
	   stage('Login Docker, Tag and push docker image to Nexus') {
            steps {
		        sh """docker login ${env.NEW_IMAGE_REGISTRY_HOSTNAME} -u ${params.NEW_IMAGE_REGISTRY_USER} --password ${params.NEW_IMAGE_REGISTRY_PASSWORD}
                     docker tag ${env.NEW_IMAGE_NAME}:${env.NEW_IMAGE_TAG} ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/repository/${env.NEW_IMAGE_REGISTRY_REPOSITORY}/${env.NEW_IMAGE_NAME}:${env.NEW_IMAGE_TAG}
			         docker push ${env.NEW_IMAGE_REGISTRY_HOSTNAME}/repository/${env.NEW_IMAGE_REGISTRY_REPOSITORY}/${env.NEW_IMAGE_NAME}:${env.NEW_IMAGE_TAG}"""
            }
        }
    }
}