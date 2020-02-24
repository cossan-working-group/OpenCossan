#!groovy

pipeline {

    // Run in docker container
    agent {
        docker {
            image   'friesischscott/gitlab-ci-matlab'
            args    '-v /opt/MATLAB/R2019b/:/usr/local/MATLAB/from-host -v /home/jenkins/.matlab/R2019b:/.matlab/R2019b --mac-address=2c:60:0c:e3:7e:8c'
        }
    }

    stages {
        stage("Test") {
            parallel {
                stage("Integration") {
                    steps {
                        sh 'matlab -r run_integration_tests'
                    }
                    post {
                        success {
                            // archive and track test results
                            archiveArtifacts "integrationResults.xml"
                            junit "integrationResults.xml"
                        }
                    }
                }
            }
        }
    }
}
