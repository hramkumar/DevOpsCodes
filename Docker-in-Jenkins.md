# Docker in Jenkins

To allow jenkins execute and run docker commands Run Jenkins with these flags

    docker run -p 8080:8080 -p 50000:50000 -d \
    -v jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(which docker):/usr/bin/docker jenkins/jenkins:lts
    
If we try to pull any new image it will return "Permission Denied" error. To solve this we need to give rw permission to the file /var/run/docker.sock.

    docker pull redis
    
    Using default tag: latest
    Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post http://%2Fvar%2Frun%2Fdocker.sock/v1.24/images/create?fromImage=redis&tag=latest: dial unix /var/run/docker.sock: connect: permission denied
    jenkins@fe39ac48eced:/$
    
    ls -l /var/run/docker.sock
    
    srw-rw---- 1 root 119 0 Nov 28 11:39 /var/run/docker.sock
    jenkins@fe39ac48eced:/$

Setup necessary permissions using chmod command by accessing container as root user.

    # docker exec -it -u root fe39ac48eced /bin/bash
    # ls -l /var/run/docker.sock 
    srw-rw---- 1 root 119 0 Nov 28 11:39 /var/run/docker.sock
    # chmod 666 /var/run/docker.sock 
    # ls -l /var/run/docker.sock 
    srw-rw-rw- 1 root 119 0 Nov 28 11:39 /var/run/docker.sock
    root@fe39ac48eced:/# exit

In Jenkins Pipeline to build and push a Docker Image, use the below command(s):

    docker build . -t hramkumar/demo-app:jma-1.1
    echo $PASSWORD | docker login -u $USERNAME --password-stdin
    docker push hramkumar/demo-app:jma-1.1


Dynamically increment application version in Jenkins Pipeline

    pipeline {
    agent any
    tools {
        maven 'Maven'
    }
    stages {
        stage('increment version') {
            steps {
                script {
                    echo 'incrementing app version...'
                    sh 'mvn build-helper:parse-version versions:set \
                        -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                        versions:commit'
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "$version-$BUILD_NUMBER"
                }
            }
        }
        stage('build app') {
            steps {
                script {
                    echo "building the application..."
                    sh 'mvn clean package'
                }
            }
        }
        stage('build image') {
            steps {
                script {
                    echo "building the docker image..."
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-repo', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "docker build -t hramkumar/demo-app:${IMAGE_NAME} ."
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh "docker push hramkumar/demo-app:${IMAGE_NAME}"
                    }
                }
            }
        }
        stage('deploy') {
            steps {
                script {
                    echo 'deploying docker image to EC2...'
                }
            }
        }




