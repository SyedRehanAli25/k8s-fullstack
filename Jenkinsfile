pipeline {
    agent any

    environment {
        ANSIBLE_INVENTORY = 'ansible/inventory.ini'
        ANSIBLE_PLAYBOOK = 'ansible/deploy-attendance.yaml'
        KUBECONFIG = '/home/jenkins/.kube/config'  // Adjust if needed
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Deploy Attendance Service') {
            steps {
                echo "Running Ansible playbook to deploy attendance service"
                sh """
                    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK}
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "Verifying pods and service status"
                sh """
                    kubectl get pods -n default -l app=attendance
                    kubectl get svc -n default attendance
                """
            }
        }
    }

    post {
        success {
            echo 'Deployment successful! Attendance service is up.'
        }
        failure {
            echo 'Deployment failed. Please check logs.'
        }
    }
}
