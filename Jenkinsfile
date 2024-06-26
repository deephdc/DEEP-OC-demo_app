#!/usr/bin/groovy

@Library(['github.com/indigo-dc/jenkins-pipeline-library@1.4.0']) _

pipeline {
    agent {
        label 'docker-build'
    }

    environment {
        dockerhub_repo = "deephdc/deep-oc-demo_app"
        base_cpu_tag = "2.16.1"
        base_gpu_tag = "2.16.1-gpu"
    }

    stages {
        stage('Validate metadata') {
            steps {
                checkout scm
                sh 'deep-app-schema-validator metadata.json'
            }
        }
        stage('Docker image building') {
            when {
                anyOf {
                    branch 'master'
                    branch 'return-files'
                    buildingTag()
                }
            }
            steps{

                dir('check_oc_artifact'){
                    // clone checking scripts
                    git url: 'https://github.com/deephdc/deep-check_oc_artifact'
                }

                dir('deep-oc-user_app'){
                    checkout scm
                    script {
                        // build different tags
                        id = "${env.dockerhub_repo}"

                        if (env.BRANCH_NAME == 'master') {
                           // CPU (aka latest, i.e. default)
                           id_cpu = DockerBuild(id,
                                            tag: ['latest', 'cpu'],
                                            build_args: ["tag=${env.base_cpu_tag}",
                                                         "branch=master"])

                           // Check that the image starts and get_metadata responses correctly
                           sh "bash ../check_oc_artifact/check_artifact.sh ${env.dockerhub_repo}"

                           // GPU
                           id_gpu = DockerBuild(id,
                                            tag: ['gpu'],
                                            build_args: ["tag=${env.base_gpu_tag}",
                                                         "branch=master"])
                        }

                        if (env.BRANCH_NAME == 'return-files') {
                           // CPU
                           id_cpu = DockerBuild(id,
                                            tag: ['return-files', 'cpu-return-files'],
                                            build_args: ["tag=${env.base_cpu_tag}",
                                                         "branch=return-files"])

                           // Check that the image starts and get_metadata responses correctly
                           sh "bash ../check_oc_artifact/check_artifact.sh ${env.dockerhub_repo}:return-files"

                           // GPU
                           id_gpu = DockerBuild(id,
                                            tag: ['gpu-return-files'],
                                            build_args: ["tag=${env.base_gpu_tag}",
                                                         "branch=return-files"])
                        }
                    }
                }
            }
            post {
                failure {
                    DockerClean()
                }
            }
        }

        stage('Docker Hub delivery') {
            when {
                anyOf {
                   branch 'master'
                   branch 'return-files'
                   buildingTag()
               }
            }
            steps{
                script {
                    DockerPush(id_cpu)
                    DockerPush(id_gpu)
                }
            }
            post {
                failure {
                    DockerClean()
                }
                always {
                    cleanWs()
                }
            }
        }

        stage("Render metadata on the marketplace") {
            when {
                allOf {
                    branch 'master'
                    changeset 'metadata.json'
                }
            }
            steps {
                script {
                    def job_result = JenkinsBuildJob("Pipeline-as-code/deephdc.github.io/pelican")
                    job_result_url = job_result.absoluteUrl
                }
            }
        }
    }
}
