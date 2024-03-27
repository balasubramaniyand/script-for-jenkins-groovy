pipeline {
  agent any  // Or a specific agent if required

  stages {
    stage('Clone') {
      steps {
        git credentialsId: 'gitlabaccess', url: 'https://pexgit.growipx.com/supportfirst/supportfirst-api-service.git', branch: 'main'
      }
    }
    stage('Maven Build') {
      steps {
        script {
          def mvnHome = tool name: 'Maven', type: 'maven'
          sh "${mvnHome}/bin/mvn clean package"
        }
      }
    }
    stage('Execute JAR') {
      steps {
        // Retrieve actual version number dynamically (recommended for future-proofing):
        script {
          def buildVersion = sh(returnStdout: true, script: 'find /var/lib/jenkins/workspace/gitlab/target -name "*.war" | tail -n 1 | awk -F"/" '{print $NF}') // Get latest WAR file name
          sh "nohup java -jar /var/lib/jenkins/workspace/gitlab/target/${buildVersion} &"  // Use retrieved version
        }

        // OR (less flexible but can be used if version number is known):
        // sh 'nohup java -jar /var/lib/jenkins/workspace/gitlab/target/supportfrist-<actual_version>.war & ' // Replace <actual_version> with the correct version number
      }
    }
  }
}
