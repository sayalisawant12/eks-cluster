pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'preprod', 'prod'], description: 'Choose the deployment environment.')
    }

    environment {
        AWS_ACCOUNT_ID = "586794476819"
        REGION = "ap-south-1"
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
        IMAGE_NAME = "satyam88/mfusion-ms:mfusion-ms-v.1.${env.BUILD_NUMBER}"
        ECR_IMAGE_NAME = "${ECR_URL}/mfusion-ms:mfusion-ms-v.1.${env.BUILD_NUMBER}"
        KUBECONFIG_ID = 'kubeconfig-aws-aks-k8s-cluster'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
    }

    tools {
        maven 'maven_3.9.4'
    }

    stages {
        stage('Build and Test') {
            stages {
                stage('Code Compilation') {
                    steps {
                        echo 'Code Compilation is In Progress!'
                        sh 'mvn clean compile'
                        echo 'Code Compilation is Completed Successfully!'
                    }
                }

                stage('Code QA Execution') {
                    steps {
                        echo 'JUnit Test Case Check in Progress!'
                        sh 'mvn clean test'
                        echo 'JUnit Test Case Check Completed!'
                    }
                }

                stage('Code Package') {
                    steps {
                        echo 'Creating WAR Artifact'
                        sh 'mvn clean package'
                        echo 'Artifact Creation Completed'
                    }
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                echo "Building Docker Image: ${env.IMAGE_NAME}"
                sh "docker build -t ${env.IMAGE_NAME} ."
                echo "Pushing Docker Image to DockerHub: ${env.IMAGE_NAME}"

                withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CRED', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"
                    sh "docker push ${env.IMAGE_NAME}"
                }

                echo "Tagging Docker Image for ECR: ${env.ECR_IMAGE_NAME}"
                sh "docker tag ${env.IMAGE_NAME} ${env.ECR_IMAGE_NAME}"

                withDockerRegistry([credentialsId: 'ecr:ap-south-1:ecr-credentials', url: "https://${ECR_URL}"]) {
                    sh "docker push ${env.ECR_IMAGE_NAME}"
                }
                echo "Docker Image Pushed to ECR"
            }
        }

        stage('Deploy to Selected Environment') {
            steps {
                script {
                    echo "Deploying to ${params.ENVIRONMENT.toUpperCase()} Environment"
                    def yamlFiles = ['00-ingress.yaml', '02-service.yaml', '03-service-account.yaml', '05-deployment.yaml', '06-configmap.yaml', '09.hpa.yaml']
                    def yamlDir = "kubernetes/${params.ENVIRONMENT}/"

                    if (params.ENVIRONMENT == 'dev') {
                        // Replace <latest> tag for the dev environment
                        sh "sed -i 's/<latest>/mfusion-ms-v.1.${BUILD_NUMBER}/g' ${yamlDir}05-deployment.yaml"
                    }

                    withCredentials([file(credentialsId: KUBECONFIG_ID, variable: 'KUBECONFIG'),
                                     [$class: 'AmazonWebServicesCredentialsBinding',
                                      credentialsId: 'aws-credentials',
                                      accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                                      secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                        yamlFiles.each { yamlFile ->
                            sh """
                                aws configure set aws_access_key_id \$AWS_ACCESS_KEY_ID
                                aws configure set aws_secret_access_key \$AWS_SECRET_ACCESS_KEY
                                aws configure set region ${REGION}

                                kubectl apply -f ${yamlDir}${yamlFile} --kubeconfig=\$KUBECONFIG -n ${params.ENVIRONMENT} --validate=false
                            """
                        }
                    }
                    echo "Deployment to ${params.ENVIRONMENT.toUpperCase()} Environment Completed"
                }
            }
        }
    }

    post {
        success {
            echo "Deployment to ${params.ENVIRONMENT} environment completed successfully"
        }
        failure {
            echo "Deployment to ${params.ENVIRONMENT} environment failed. Check logs for details."
        }
    }
}
