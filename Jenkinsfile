pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terraform action'
        )
        choice(
            name: 'ENV',
            choices: ['dev', 'prod'],
            description: 'Target environment'
        )
        string(
            name: 'REGION',
            defaultValue: 'us-east-1',
            description: 'AWS Region'
        )
    }

    environment {
        AWS_DEFAULT_REGION = "${params.REGION}"
        TF_ENV_DIR = "env/${params.ENV}"
        TF_VARS    = "${params.ENV}.tfvars"
    }

    stages {

        stage('Clean Workspace') {
  steps {
    deleteDir()
  }
}


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

        stage('Terraform Init') {
            steps {
                dir("${TF_ENV_DIR}") {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${TF_ENV_DIR}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { params.ACTION != 'destroy' }
            }
            steps {
                dir("${TF_ENV_DIR}") {
                    sh """
                      terraform plan \
                        -var-file=${TF_VARS} \
                        -out=tfplan
                    """
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

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir("${TF_ENV_DIR}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir("${TF_ENV_DIR}") {
                    sh 'terraform destroy -auto-approve -var-file=${TF_VARS}'
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/tfplan', allowEmptyArchive: true
        }
        success {
            echo "Terraform ${params.ACTION} completed successfully for ${params.ENV}"
        }
        failure {
            echo "Terraform ${params.ACTION} failed for ${params.ENV}"
        }
    }
}
