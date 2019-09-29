#!/usr/bin/env bash

echo 'The following Maven command installs your Maven-built Java application'
echo 'into the local Maven repository, which will ultimately be stored in'
echo 'Jenkins''s local Maven repository (and the "maven-repository" Docker data'
echo 'volume).'
set -x
mvn jar:jar install:install help:evaluate -Dexpression=project.name
set +x

echo 'The following complex command extracts the value of the <name/> element'
echo 'within <project/> of your Java/Maven project''s "pom.xml" file.'
set -x
NAME=`mvn help:evaluate -Dexpression=project.name | grep "^[^\[]"`
set +x

echo 'The following complex command behaves similarly to the previous one but'
echo 'extracts the value of the <version/> element within <project/> instead.'
set -x
VERSION=`mvn help:evaluate -Dexpression=project.version | grep "^[^\[]"`
set +x

echo 'The following command runs and outputs the execution of your Java'
echo 'application (which Jenkins built using Maven) to the Jenkins UI.'
set -x
java -jar target/${NAME}-${VERSION}.jar

uploadPkgUser=$1
uploadPkgUserPassword=$2
nexusRestAPIURL=$3
nexusRepo=$4
nexusMvnGroupID=$5
artifactID=$6
artifactVersion=$7


curl --silent --output /dev/stderr --write-out "%{http_code}" -k -u ${uploadPkgUser}:${uploadPkgUserPassword} -X POST "${nexusRestAPIURL}/components?repository=${nexusRepo}" -H "accept: application/json" -H "Content-Type: multipart/form-data" -F "maven2.groupId=${nexusMvnGroupID}" -F "maven2.artifactId=${artifactID}" -F "maven2.version=${artifactVersion}" -F "maven2.generate-pom=false" -F "maven2.packaging=zip" -F "maven2.asset1=@${WORKSPACE}/target/${artifactID}.zip" -F "maven2.asset1.extension=zip"
                                               
