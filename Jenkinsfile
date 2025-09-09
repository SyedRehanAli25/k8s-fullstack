pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        KUBECONFIG = "${WORKSPACE}/.kube/config"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/SyedRehanAli25/k8s-fullstack.git', branch: 'main'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    dir('terraform') {
                        sh '''
                            echo "Using AWS credentials..."
                            terraform init
                            terraform apply -auto-approve
                        '''
                    }
                }
            }
        }

        stage('Configure Kubeconfig') {
            steps {
                echo 'Updating kubeconfig using workspace path...'
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        mkdir -p $WORKSPACE/.kube
                        aws eks update-kubeconfig \
                            --name k8s-oneclick-cluster \
                            --region us-east-1 \
                            --kubeconfig $WORKSPACE/.kube/config
                    '''
                }
            }
        }

        stage('Show Cluster Nodes') {
            steps {
                echo 'Waiting for cluster nodes to be ready...'
                sh 'sleep 15'
                sh 'kubectl get nodes -o wide'
            }
        }

        stage('Ansible Deploy') {
            steps {
                dir('ansible') {
                    sshagent(['k8s-oneclick-key']) {
                        sh 'ansible-playbook -i inventory.ini deploy-attendance.yaml'
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Checking deployed services and pods...'
                sh 'kubectl get pods --all-namespaces'
                sh 'kubectl get svc --all-namespaces'
            }
        }
    }

    post {
        success {
            echo ' Pipeline completed successfully! Cluster and app deployed.'
        }
        failure {
            echo ' Pipeline failed. Check logs above.'
        }
    }
}
