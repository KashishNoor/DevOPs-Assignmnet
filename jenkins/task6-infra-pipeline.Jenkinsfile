pipeline {
    agent { label 'linux-agent' }

    options {
        timestamps()
        skipDefaultCheckout(true)
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terraform action to run'
        )

        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Skip manual approval for apply/destroy'
        )
    }

    environment {
        TF_DIR = 'jenkins/terraform/01-base-infra'
        TF_CI_DIR = '.terraform-ci/01-base-infra'
        TF_IN_AUTOMATION = 'true'
        CURRENT_STAGE = 'Pipeline started'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    env.CURRENT_STAGE = 'Checkout'
                }

                checkout scm

                sh '''
                    echo "Checked out repository"
                    git rev-parse --short HEAD
                    echo "Terraform directory: ${TF_DIR}"
                    test -d "${TF_DIR}"

                    rm -rf .terraform-ci
                    mkdir -p "${TF_CI_DIR}"

                    cp "${TF_DIR}"/*.tf "${TF_CI_DIR}/"
                    if ls "${TF_DIR}"/*.tfvars >/dev/null 2>&1; then
                        cp "${TF_DIR}"/*.tfvars "${TF_CI_DIR}/"
                    fi
                    rm -f "${TF_CI_DIR}/versions.tf"

                    awk '
                        /backend "s3" {/ { skip = 1; depth = 1; next }
                        skip {
                            depth += gsub(/{/, "{")
                            depth -= gsub(/}/, "}")
                            if (depth == 0) { skip = 0 }
                            next
                        }
                        { print }
                    ' "${TF_DIR}/versions.tf" > "${TF_CI_DIR}/versions.tf"

                    echo "Prepared backend-free Terraform directory: ${TF_CI_DIR}"
                '''
            }
        }

        stage('Fmt & Validate') {
            steps {
                script {
                    env.CURRENT_STAGE = 'Fmt & Validate'
                }

                dir("${env.TF_CI_DIR}") {
                    sh '''
                        set -eux

                        rm -rf .terraform
                        terraform init -backend=false -input=false

                        terraform fmt -check -recursive

                        terraform validate -no-color
                    '''
                }
            }
        }

        stage('Security Scan (tfsec)') {
            steps {
                script {
                    env.CURRENT_STAGE = 'Security Scan (tfsec)'
                }

                sh '''
                    set -eux

                    rm -f tfsec-report.json tfsec-console.txt

                    set +e
                    docker run --rm \
                      -v "$PWD:/src" \
                      -w /src \
                      aquasec/tfsec:latest \
                      "${TF_DIR}" \
                      --minimum-severity HIGH \
                      --format json \
                      --out tfsec-report.json \
                      --no-colour > tfsec-console.txt 2>&1

                    TFSEC_EXIT_CODE=$?
                    set -e

                    echo "========== tfsec console output =========="
                    cat tfsec-console.txt || true
                    echo "=========================================="

                    if [ "$TFSEC_EXIT_CODE" -ne 0 ]; then
                        echo "tfsec reported findings. Review archived tfsec-report.json."
                    fi
                '''
            }
        }

        stage('Plan') {
            steps {
                script {
                    env.CURRENT_STAGE = 'Plan'
                }

                dir("${env.TF_CI_DIR}") {
                    sh '''
                        set -eux

                        rm -f tfplan tfplan.txt
                        rm -rf .terraform

                        terraform init -backend=false -input=false

                        if [ "${ACTION}" = "destroy" ]; then
                            terraform plan \
                              -destroy \
                              -input=false \
                              -refresh=false \
                              -lock-timeout=10m \
                              -out=tfplan
                        else
                            terraform plan \
                              -input=false \
                              -refresh=false \
                              -lock-timeout=10m \
                              -out=tfplan
                        fi

                        terraform show -no-color tfplan > tfplan.txt
                        cat tfplan.txt
                    '''
                }
            }
        }

        stage('Manual Approval') {
            when {
                expression {
                    return (params.ACTION == 'apply' || params.ACTION == 'destroy') && !params.AUTO_APPROVE
                }
            }

            steps {
                script {
                    env.CURRENT_STAGE = 'Manual Approval'
                }

                timeout(time: 30, unit: 'MINUTES') {
                    input message: "Approve Terraform ${params.ACTION} for ${env.TF_DIR}?",
                          ok: "Approve ${params.ACTION}"
                }
            }
        }

        stage('Apply/Destroy') {
            when {
                expression {
                    return params.ACTION == 'apply' || params.ACTION == 'destroy'
                }
            }

            steps {
                script {
                    env.CURRENT_STAGE = 'Apply/Destroy'
                }

                dir("${env.TF_CI_DIR}") {
                    sh '''
                        set -eux

                        terraform apply \
                          -input=false \
                          -lock-timeout=10m \
                          tfplan
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'tfsec-report.json, tfsec-console.txt, **/tfplan, **/tfplan.txt', allowEmptyArchive: true
        }

        success {
            echo "SUCCESS: Terraform ${params.ACTION} completed successfully."
        }

        failure {
            echo "FAILURE: Terraform pipeline failed at stage: ${env.CURRENT_STAGE}"
        }
    }
}
