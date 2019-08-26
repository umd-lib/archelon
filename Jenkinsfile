pipeline {
  // Jenkins configuration dependencies
  //
  //   Global Tool Configuration:
  //     Git
  //
  // This configuration utilizes the following Jenkins plugins:
  //
  //   * Warnings Next Generation
  //   * Email Extension Plugin
  //
  // This configuration also expects the following environment variables
  // to be set (typically in /apps/ci/config/env:
  //
  // JENKINS_EMAIL_SUBJECT_PREFIX
  //     The Email subject prefix identifying the server.
  //     Typically "[Jenkins - <HOSTNAME>]" where <HOSTNAME>
  //     is the name of the server, i.e. "[Jenkins - cidev]"
  //
  // JENKINS_DEFAULT_EMAIL_RECIPIENTS
  //     A comma-separated list of email addresses that should
  //    be the default recipients of Jenkins emails.

  agent any

  options {
    buildDiscarder(
      logRotator(
        artifactDaysToKeepStr: '',
        artifactNumToKeepStr: '',
        numToKeepStr: '20'))
  }

  environment {
    DEFAULT_RECIPIENTS = "${ \
      sh(returnStdout: true, \
         script: 'echo $JENKINS_DEFAULT_EMAIL_RECIPIENTS').trim() \
    }"

    EMAIL_SUBJECT_PREFIX = "${ \
      sh(returnStdout: true, script: 'echo $JENKINS_EMAIL_SUBJECT_PREFIX').trim() \
    }"

    EMAIL_SUBJECT = "$EMAIL_SUBJECT_PREFIX - " +
                    '$PROJECT_NAME - ' +
                    'GIT_BRANCH_PLACEHOLDER - ' +
                    '$BUILD_STATUS! - ' +
                    "Build # $BUILD_NUMBER"

    EMAIL_CONTENT =
        '''$PROJECT_NAME - GIT_BRANCH_PLACEHOLDER - $BUILD_STATUS! - Build # $BUILD_NUMBER:
           |
           |Check console output at $BUILD_URL to view the results.
           |
           |There are ${ANALYSIS_ISSUES_COUNT} static analysis issues in this build.'''.stripMargin()
  }

  stages {
    stage('Initialize') {
      steps {
        script {
          // Retrieve the actual Git branch being built for use in email.
          //
          // For pull requests, the actual Git branch will be in the
          // CHANGE_BRANCH environment variable.
          //
          // For actual branch builds, the CHANGE_BRANCH variable won't exist
          // (and an exception will be thrown) but the branch name will be
          // part of the PROJECT_NAME variable, so it is not needed.

          ACTUAL_GIT_BRANCH = ''

          try {
            ACTUAL_GIT_BRANCH = CHANGE_BRANCH + ' - '
          } catch (groovy.lang.MissingPropertyException mpe) {
            // Do nothing. A branch (as opposed to a pull request) is being
            // built
          }

          // Replace the "GIT_BRANCH_PLACEHOLDER" in email variables
          EMAIL_SUBJECT = EMAIL_SUBJECT.replaceAll('GIT_BRANCH_PLACEHOLDER - ', ACTUAL_GIT_BRANCH )
          EMAIL_CONTENT = EMAIL_CONTENT.replaceAll('GIT_BRANCH_PLACEHOLDER - ', ACTUAL_GIT_BRANCH )
        }
      }
    }

    stage('Build') {
      steps {
        // Run the build
        sh '''#!/bin/bash --login

          # Set "fail on error" in bash
          set -e

          # Clear the "coverage" and "reports" directories
          rm -rf coverage
          rm -rf reports

          # Use the correct ruby and gemset (creating if necessary)
          # Use the correct ruby and gemset, derived from .ruby-version and .ruby-gemset
          RUBY_VERSION=$(cat .ruby-version)
          RUBY_GEMSET=$(cat .ruby-gemset)
          RVM_GEMSET=$RUBY_VERSION@$RUBY_GEMSET

          rvm --create use "$RVM_GEMSET"

          # Disable Spring, as it should not be needed, and may interfere with tests
          export DISABLE_SPRING=true

          # Do any setup
          # e.g. possibly do 'rake db:migrate db:test:prepare' here
          bundle install --without production

          FULL_RAILS_VERSION=`rails -v`
          RAILS_VERSION=`echo $FULL_RAILS_VERSION | grep -oP "\\d+.\\d+.\\d+"`

          echo FULL_RAILS_VERSION=$FULL_RAILS_VERSION
          echo RAILS_VERSION=$RAILS_VERSION

          bundle exec rails db:reset

          TESTS_TO_RUN="test"
          if [ -d "$WORKSPACE/test/system" ]; then
            # Run system tests if directory exists
            TESTS_TO_RUN="test:system $TESTS_TO_RUN"
          fi

          echo "Running 'bundle exec rails $TESTS_TO_RUN'"
          bundle exec rails $TESTS_TO_RUN

          # Run RuboCop
          # Send output to standard out for "Record compiler warnings and static analysis results"
          # post-build action
          #
          # Using "|| true" so that build will be considered successful, even if there are Rubocop
          # violation.
          bundle exec rubocop -D --format clang || true
        '''
      }
      post {
        always {
          // Collect Rubocop reports
          recordIssues(tools: [ruboCop(reportEncoding: 'UTF-8')], unstableTotalAll: 1)

          publishHTML (target: [
            allowMissing: true,
            alwaysLinkToLastBuild: false,
            keepAll: true,
            reportDir: 'coverage/rcov',
            reportFiles: 'index.html',
            reportName: "RCov Report"
          ])
        }
      }
    }

    stage('CleanWorkspace') {
      steps {
        cleanWs()
      }
    }
  }

  post {
    always {
      emailext to: "$DEFAULT_RECIPIENTS",
               subject: "$EMAIL_SUBJECT",
               body: "$EMAIL_CONTENT"
    }
  }
}
