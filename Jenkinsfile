#!/usr/bin/env groovy

podTemplate(label: 'docker',
    containers: [
      containerTemplate(name: 'docker', image: 'docker:18.03', ttyEnabled: true, command: 'cat'),
    ],
    volumes: [hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock')]
) {

    node('docker') {
        def projectName = 'alpine-node'
        def scmVars = checkout scm
        def branchName = scmVars.GIT_BRANCH
        def shortCommit = scmVars.GIT_COMMIT.take(7)
        int unixEpoch = System.currentTimeMillis()/1000
        def buildTag = "${branchName}-${shortCommit}-${unixEpoch}"

        stage('Build Docker Image') {
            container('docker') {
                sh "docker build -t moven/${projectName}:${buildTag} ."
            }
        }

        if (!branchName.startsWith("PR-")) {
            stage('Push Docker Image to Registry') {

              def secrets = [
                [$class: 'VaultSecret', path: 'secret/jenkins/docker-registry', secretValues: [
                  [$class: 'VaultSecretValue', envVar: 'DOCKER_USERNAME', vaultKey: 'username'],
                  [$class: 'VaultSecretValue', envVar: 'DOCKER_PASSWORD', vaultKey: 'password']
                ]]
              ]

              container('docker') {
                wrap([$class: 'VaultBuildWrapper', vaultSecrets: secrets]) {
                  sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
                        sh "docker push moven/${projectName}:${buildTag}"
                }
              }
            }

            milestone()
        }
    }
}
