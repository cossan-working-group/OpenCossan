#!groovy

pipeline {

    // Run in docker container
    agent {
        docker {
            image   'friesischscott/gitlab-ci-matlab'
            args    '-v /opt/MATLAB/R2020a/:/usr/local/MATLAB/from-host -v /home/jenkins/.matlab/R2020a:/.matlab/R2020a --mac-address=2c:60:0c:e3:7e:8c'
            alwaysPull true
        }
    }

    stages {
        stage("Test") {
            parallel {
                stage("Unit") {
                    steps {
                        sh 'matlab -r run_unit_tests'
                    }
                    post {
                        success {
                            // archive and track test results
                            archiveArtifacts "unit_test_results.xml"
                            junit "unit_test_results.xml"

                            // archive code coverage
                            archiveArtifacts "cobertura.xml"

                            // upload to codecov.io
                            withCredentials([string(credentialsId: 'CODECOV_TOKEN', variable: 'CODECOV_TOKEN')]) {
                                sh '''
                                    set +x
                                    curl -s https://codecov.io/bash | bash
                                '''
                            }
                        }
                    }
                }

                stage("Integration") {
                    steps {
                        sh 'matlab -r run_integration_tests'
                    }
                    post {
                        success {
                            // archive and track test results
                            archiveArtifacts "integration_test_results.xml"
                            junit "integration_test_results.xml"
                        }
                    }
                }
            }
        }
    }
}
