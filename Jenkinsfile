pipeline {

    agent any

    options { 
        buildDiscarder(logRotator(numToKeepStr: '300'))
        ansiColor('xterm')  /* This requires AnsiColor plugin */
    }
    triggers {
        gitlab(triggerOnPush: true, triggerOnMergeRequest: false, secretToken: '', branchFilterType: 'All')
    } 

    stages {
        stage('Clean up') {
            steps {
                warnError('Stage failed. Continue...') {
                    build job: 'dev - FortiSASE Automation Telefonica - clean infra'
                }
            }
        }
        stage('Wait before Configure') {
            steps {
                sleep(time: 0, unit: 'SECONDS')
            }
        }
        stage('Configure') {
            steps {
                warnError('Stage failed. Continue...') {
                    build job: 'dev - FortiSASE Automation Telefonica - configure infra'
                }
            }
        }
        stage('Wait before Destroy') {
            steps {
                sleep(time: 0, unit: 'SECONDS')
            }
        }
        stage('Generate test results') {
            steps {
                warnError('Stage failed. Continue...') {
                    /* Note this requires "Copy Artifact" plugin installed */
                    copyArtifacts(
                        projectName: 'dev - FortiSASE Automation Telefonica - configure infra',
                        selector: lastCompleted(),
                        filter: '**/*',
                        fingerprintArtifacts: true
                    )
                    script {
                        sh '''./check_created_resources.py || true'''
                    }
                    archiveArtifacts artifacts: '**/test_results.*',
                                allowEmptyArchive: true
                }
            }
        }
        stage('Destroy') {
            steps {
                warnError('Stage failed. Continue...') {
                    build job: 'dev - FortiSASE Automation Telefonica - destroy infra'
                }
            }
        }
    }
    post {
        always {
            junit '**/test_results.xml'
            allure includeProperties:
                false,
                jdk: '',
                results: [[path: 'build/allure-results']]
        }
    }
}