def image;
def commit;

echo "Spawning a slave for this job..."

node("docker") {
    stage("Clone") {
        git branch: 'master', url: "https://github.com/Artiax/jenkins-slave.git", changelog: false, poll: false
    }

    stage("Build") {
        image = docker.build "jenkins-slave"
    }

    stage("Tag") {
        commit = sh(returnStdout: true, script: "git rev-parse HEAD").trim().take(8)

        image.tag "${commit}"
        image.tag "latest"
    }
}
