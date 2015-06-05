#!/usr/bin/env bash
#setup variables
GIT_REPO=/tmp/git-repo
LUMIFY_ALL=$GIT_REPO/lumify-all
SEC_GRAPH=$GIT_REPO/securegraph
LUMIFY_PUBLIC=$LUMIFY_ALL/lumify-public
LUMIFY_VERSION=0.5.0-SNAPSHOT
SECUREGRAPH_VERSION=0.10.0-SNAPSHOT
export GIT_REPO LUMIFY_ALL SEC_GRAPH LUMIFY_PUBLIC LUMIFY_VERSION SECUREGRAPH_VERSION

#remove old artifacts and clone
echo "Setting up the git clones at $LUMIFY_ALL, $SEC_GRAPH $LUMIFY_PUBLIC"
rm -rfd $GIT_REPO
mkdir $GIT_REPO
cd $GIT_REPO
git clone ssh://git@github.com/altamiracorp/lumify-all
cd $LUMIFY_ALL
git clone ssh://git@github.com/lumifyio/lumify lumify-public
cd $GIT_REPO
git clone ssh://git@github.com/lumifyio/securegraph


# Build lumify artifacts
echo "Building Lumify"
cd $LUMIFY_ALL/lumify-public
mvn -DskipTests=true -Pweb-war clean install

echo "Building Secure graph"
cd $SEC_GRAPH
mvn -DskipTests=true clean install

echo "Preparing for deplolymnent"
echo "Copying Web artifacts "
# Create a directory for the cluster deployment and copy files needed for deployment
cd $LUMIFY_ALL
mkdir deployment/lumify_demo_0Y
cp $LUMIFY_PUBLIC/web/war/target/lumify-web-war-${LUMIFY_VERSION}.war deployment/lumify_demo_0Y/lumify.war

cp $LUMIFY_PUBLIC/tools/cli/target/lumify-cli-${LUMIFY_VERSION}-with-dependencies.jar \
	          deployment/lumify_demo_0Y

echo "Copying Secure grpah artifacts "
cp $SEC_GRAPH/securegraph-elasticsearch-plugin/target/release/elasticsearch-securegraph-${SECUREGRAPH_VERSION}.zip \
	          deployment/lumify_demo_0Y

mkdir deployment/lumify_demo_0Y/weblib

echo "Copying Web plugins "
cp $LUMIFY_PUBLIC/web/plugins/terms-of-use/target/lumify-terms-of-use-${LUMIFY_VERSION}.jar \
			  $LUMIFY_PUBLIC/web/plugins/auth-social/target/lumify-web-auth-social-${LUMIFY_VERSION}-jar-with-dependencies.jar \
			  $LUMIFY_PUBLIC/web/plugins/dev-tools/target/lumify-web-dev-tools-${LUMIFY_VERSION}.jar \
			  $LUMIFY_PUBLIC/core/plugins/model-bigtable/target/lumify-model-bigtable-${LUMIFY_VERSION}-jar-with-dependencies.jar \
	          deployment/lumify_demo_0Y/weblib

echo "Copying Graph Property workers for YARN "
mkdir deployment/lumify_demo_0Y/gpw

cp `find $LUMIFY_PUBLIC/graph-property-worker/plugins -name "lumify-gpw-*-with-dependencies.jar"` \
	          deployment/lumify_demo_0Y/gpw

mkdir deployment/lumify_demo_0Y/yarn

cp $LUMIFY_PUBLIC/tools/long-running-process-yarn/target/lumify-long-running-process-yarn-${LUMIFY_VERSION}-with-dependencies.jar \
	             $LUMIFY_PUBLIC/graph-property-worker/graph-property-worker-yarn/lumify-graph-property-worker-yarn-${LUMIFY_VERSION}-with-dependencies.jar \
	             deployment/lumify_demo_0Y/yarn


