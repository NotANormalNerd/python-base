pipeline {
  agent { label 'jnlp-dind-slave' }
  environment {
    PIPELINE_UUID = UUID.randomUUID().toString()
  }
  stages{
      stage('Build') {
          when {
            beforeAgent true
            anyOf {
              branch 'master'
            }
          }
          environment {
            DOCKER_BUILDER_CREDS = credentials('mecodia-docker-hub')
            DOCKER_REPO = 'mecodia/python-base'
          }
          steps {
            script {
              docker.withRegistry('', 'mecodia-docker-hub') {
                env.GIT_VERSION = sh(returnStdout: true, script: "git describe --tags --long --dirty --always").trim()
                def customImage = docker.build("${env.DOCKER_REPO}:${env.GIT_VERSION}", ".")

                customImage.push("latest")
                customImage.push(env.GIT_VERSION)
              }
            }
            slackSend message: "Pushed new mecodia/python-base:${env.GIT_VERSION} image", channel: '#operations'
          }
       }
    }
}