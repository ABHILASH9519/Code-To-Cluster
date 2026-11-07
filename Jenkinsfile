pipeline {
    agent any

    parameters {
        choice(
            name: 'TERRAFORM_ACTION',
            choices: ['apply', 'destroy'],
            description: 'Choose whether to create/update or destroy the dev EKS infrastructure.'
        )
    }

    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION = 'true'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Format and Initialize') {
            steps {
                dir('tf-aws-eks') {
                    sh 'terraform fmt -check -recursive'
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('tf-aws-eks') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('tf-aws-eks') {
                    script {
                        if (params.TERRAFORM_ACTION == 'destroy') {
                            sh 'terraform plan -input=false -destroy -var-file=variables/dev.tfvars -out=tfplan'
                        } else {
                            sh 'terraform plan -input=false -var-file=variables/dev.tfvars -out=tfplan'
                        }
                    }
                }
            }
        }

        stage('Approve Infrastructure Change') {
            steps {
                script {
                    input(
                        message: "Approve Terraform ${params.TERRAFORM_ACTION} for the dev EKS environment?",
                        ok: 'Approve'
                    )
                }
            }
        }

        stage('Apply Infrastructure Change') {
            steps {
                dir('tf-aws-eks') {
                    sh 'terraform apply -input=false -auto-approve tfplan'
                }
            }
        }

        stage('Deploy Nginx Application') {
            when {
                expression { params.TERRAFORM_ACTION == 'apply' }
            }
            steps {
                dir('manifest') {
                    sh 'aws eks update-kubeconfig --name my-eks-cluster --region "$AWS_DEFAULT_REGION"'
                    sh 'kubectl create namespace eks-nginx-app --dry-run=client -o yaml | kubectl apply -f -'
                    sh 'kubectl apply -f deployment.yaml -n eks-nginx-app'
                    sh 'kubectl apply -f service.yaml -n eks-nginx-app'
                }
            }
        }
    }

    post {
        always {
            dir('tf-aws-eks') {
                sh 'rm -f tfplan'
            }
        }
    }
}
