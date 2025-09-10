pipeline {
    agent any

    environment {
        // Kubeconfig path inside workspace
        KUBECONFIG = "${env.WORKSPACE}/.kube/config"
        AWS_REGION = 'us-east-1'  // set your AWS region here
        TF_APPLY_REQUIRED = "false"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git url: 'https://github.com/SyedRehanAli25/k8s-fullstack.git', branch: 'main'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    withCredentials([
                        string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        withEnv(["AWS_REGION=${env.AWS_REGION}"]) {
                            sh 'terraform init -reconfigure'
                        }
                    }
                }
            }
        }

        stage('Terraform Plan & Check') {
            steps {
                dir('terraform') {
                    withCredentials([
                        string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        withEnv(["AWS_REGION=${env.AWS_REGION}"]) {
                            script {
                                def planResult = sh(script: 'terraform plan -detailed-exitcode', returnStatus: true)
                                
                                if (planResult == 0) {
                                    echo "No infrastructure changes detected."
                                    env.TF_APPLY_REQUIRED = "false"
                                } else if (planResult == 2) {
                                    echo "Terraform plan detected changes, apply will proceed."
                                    env.TF_APPLY_REQUIRED = "true"
                                } else {
                                    error("Terraform plan failed with error code ${planResult}")
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { env.TF_APPLY_REQUIRED == "true" }
            }
            steps {
                dir('terraform') {
                    withCredentials([
                        string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        withEnv(["AWS_REGION=${env.AWS_REGION}"]) {
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }

        stage('Configure Kubeconfig') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh """
                        mkdir -p ${env.WORKSPACE}/.kube
                        aws eks update-kubeconfig --name k8s-oneclick-cluster --region ${AWS_REGION} --kubeconfig ${KUBECONFIG}
                    """
                }
            }
        }

        stage('Show Cluster Nodes') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh """
                        sleep 15
                        kubectl get nodes -o wide --kubeconfig ${KUBECONFIG}
                    """
                }
            }
        }

        stage('Ansible Deploy') {
            steps {
                dir('ansible') {
                    withCredentials([
                        string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        sh """
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            export KUBECONFIG=${KUBECONFIG}
                            ansible-playbook -i localhost, deploy-attendance.yaml
                        """
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh """
                        kubectl get namespaces --kubeconfig ${KUBECONFIG}
                        kubectl get pods --all-namespaces --kubeconfig ${KUBECONFIG}
                        kubectl get svc --all-namespaces --kubeconfig ${KUBECONFIG}
                        kubectl get deployments --all-namespaces --kubeconfig ${KUBECONFIG}
                        kubectl get configmaps --all-namespaces --kubeconfig ${KUBECONFIG}
                    """
                }
            }
        }

        stage('Troubleshoot Pods') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh """
                        kubectl get pods --all-namespaces --field-selector=status.phase!=Running --kubeconfig ${KUBECONFIG} -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{"\\n"}{end}' | while read pod; do
                            ns=\$(echo \$pod | cut -d'/' -f1)
                            name=\$(echo \$pod | cut -d'/' -f2)
                            echo "----- Describing pod: \$name in namespace: \$ns -----"
                            kubectl describe pod \$name -n \$ns --kubeconfig ${KUBECONFIG}
                            echo "----- Logs for pod: \$name -----"
                            kubectl logs \$name -n \$ns --kubeconfig ${KUBECONFIG} || echo "No logs available"
                        done
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully! Cluster and app deployed.'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
