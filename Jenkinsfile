def image;
def commit;

echo "Spawning a slave for this job..."

node("docker") {
    stage("Clone") {
        git branch: 'development', url: "https://github.com/Artiax/kubernetes.git", changelog: false, poll: false
    }

    stage("Build") {
        dir('images/jenkins-slave') {
            image = docker.build "jenkins-slave"
        }
    }

    stage("Tag") {
        commit = sh(returnStdout: true, script: "git rev-parse HEAD").trim().take(8)

        image.tag "${commit}"
        image.tag "latest"
    }
}
