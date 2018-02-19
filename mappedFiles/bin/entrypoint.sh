#!/bin/bash

dockerd &

curl -fsSL "${JENKINS_URL}/jnlpJars/slave.jar" -o ${JENKINS_HOME}/slave.jar
exec java -cp ${JENKINS_HOME}/slave.jar hudson.remoting.jnlp.Main \
    -headless \
    -workDir $JENKINS_HOME \
    -url $JENKINS_URL \
    $JENKINS_SECRET \
    $JENKINS_NAME
