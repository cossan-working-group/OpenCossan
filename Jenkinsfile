#!groovy

pipeline {

    // Run in docker container
    agent {
        docker {
            image   'friesischscott/gitlab-ci-matlab'
            args    '-v /opt/MATLAB/R2019a/:/usr/local/MATLAB/from-host -v /home/jenkins/.matlab/R2019a:/.matlab/R2019a --mac-address=2c:60:0c:e3:7e:8c'
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
