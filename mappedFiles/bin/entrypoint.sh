#!/bin/bash

dockerd &

curl -fsSL "${JENKINS_URL}/jnlpJars/slave.jar" -o ${JENKINS_HOME}/slave.jar
exec java -jar ${JENKINS_HOME}/slave.jar -jnlpUrl ${JENKINS_JNLP_URL}
