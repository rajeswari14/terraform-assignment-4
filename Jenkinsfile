pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action')
        choice(name: 'ENV', choices: ['dev', 'prod'], description: 'Target environment')
        string(name: 'REGION', defaultValue: 'us-east-1', description: 'AWS Region')
    }

    environment {
        TF_ENV = "${params.ENV}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Format Check') {
            steps {
                sh 'terraform fmt -check -recursive'
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("env/${TF_ENV}") {
                    sh 'terraform init -backend=false'
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir("env/${TF_ENV}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("env/${TF_ENV}") {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Manual Approval') {
            when {
                anyOf {
                    expression { params.ACTION == 'apply' }
                    expression { params.ACTION == 'destroy' }
                }
            }
            steps {
                input message: "Approve Terraform ${params.ACTION} for ${params.ENV}?"
            }
        }

        stage('Terraform Apply / Destroy') {
            when {
                expression { params.ACTION != 'plan' }
            }
            steps {
                dir("env/${TF_ENV}") {
                    sh '''
                        if [ "${ACTION}" = "apply" ]; then
                          terraform apply -auto-approve tfplan
                        elif [ "${ACTION}" = "destroy" ]; then
                          terraform destroy -auto-approve
                        fi
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/tfplan', allowEmptyArchive: true
        }
    }
}
