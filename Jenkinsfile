pipeline {
    agent any

    environment {
        AWS_REGION        = 'ap-south-1'
        TF_BACKEND_BUCKET = 'my-terraformeks-state-bucket'
        TF_BACKEND_KEY    = 'terraform/eks-cluster/terraform.tfstate'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Validate Terraform Configuration') {
            steps {
                script {
                    sh 'terraform validate' // Validate files before init
                }
            }
        }

        stage('Initialize Terraform') {
            steps {
                script {
                    sh 'terraform init'
                }
            }
        }

        stage('Plan Infrastructure') {
            steps {
                script {
                    sh 'terraform plan -var-file="terraform.tfvars"'
                }
            }
        }

        stage('Apply Infrastructure') {
            steps {
                script {
                    sh 'terraform apply -var-file="terraform.tfvars" -auto-approve'
                }
            }
        }

        stage('Post Deployment Outputs') {
            steps {
                script {
                    sh 'terraform output'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Terraform deployment successful!"
        }
        failure {
            echo "Terraform deployment failed. Check logs for details."
        }
    }
}
