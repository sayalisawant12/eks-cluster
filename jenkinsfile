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
                // Pull the latest Terraform code from the repo
                checkout scm
            }
        }

        stage('Setup Terraform Backend') {
            steps {
                script {
                    // Create a backend.tf file dynamically
                    writeFile file: 'backend.tf', text: """
                    terraform {
                      backend "s3" {
                        bucket = "${TF_BACKEND_BUCKET}"
                        key    = "${TF_BACKEND_KEY}"
                        region = "${AWS_REGION}"
                      }
                    }
                    """
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
                    // Execute Terraform plan and output the details
                    sh 'terraform plan -var-file="terraform.tfvars"'
                }
            }
        }

        stage('Apply Infrastructure') {
            steps {
                script {
                    // Apply Terraform changes with confirmation
                    sh 'terraform apply -var-file="terraform.tfvars" -auto-approve'
                }
            }
        }

        stage('Post Deployment Outputs') {
            steps {
                script {
                    // Show the Terraform outputs
                    sh 'terraform output'
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up workspace."
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
