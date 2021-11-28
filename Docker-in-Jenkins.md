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

