TOKEN="`cf oauth-token`"

#ORGANIZATION='CCDashboardTest'
#RUNTIME='CCDashboardTest'
#BUILD_ENVIRONMENT=MASTER_BUILD
#DEPLOY_ENVIRONMENT=STAGING
#BUILD_ID=master:30
#DLMS_SERVER=https://localhost:6009

if [ -z "$ORGANIZATION" ]; then
    echo "ORGANIZATION not set. Run 'export ORGANIZATION=<target org>'"
    exit 1
fi  
if [ -z "$RUNTIME" ]; then
    echo "RUNTIME not set. Run 'export RUNTIME=<runtime>'"
    exit 1
fi 
if [ -z "$BUILD_ID" ]; then
    echo "BUILD_ID not set. Run 'export BUILD_ID=<your build id>'"
    exit 1
fi 
if [ -z "$BRANCH" ]; then
    echo "BRANCH not set. Run 'export BRANCH=<branch name>'"
    exit 1
fi 
if [ -z "$BUILD_ENVIRONMENT" ]; then
    echo "BUILD_ENVIRONMENT not set. Run 'export BUILD_ENVIRONMENT=<build environment name>'"
    exit 1
fi 
if [ -z "$DEPLOY_ENVIRONMENT" ]; then
    echo "DEPLOY_ENVIRONMENT not set. Run 'export DEPLOY_ENVIRONMENT=<deploy environment name>'"
    exit 1
fi 
if [ -z "$DLMS_SERVER" ]; then
    echo "DLMS_SERVER not set. Run 'export DLMS_SERVER=<server url>'. (e.g https://dev-dlms.stage1.ng.bluemix.net, https://dlms.ng.bluemix.net, etc.)"
    exit 1
fi 

COMMIT_ID=7035df304135d746c71e92edaea9bd1fc8525644
JOB_URL='https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/38218d83-89ff-465b-bf40-de51a5286c6c/ce2c975f-7581-45c5-9ae8-5573b1fd99fe'

echo "\nPosting build information for $RUNTIME and $BRANCH and $BUILD_ID."

curl -X POST -H "Authorization: $TOKEN" -H "Content-Type: application/json" -d '{
    "build_id": "'$BUILD_ID'",
    "job_url": "'$JOB_URL'",
    "repository": {
        "repository_url": "https://github.ibm.com/oneibmcloud/dlms.git",
        "branch": "'$BRANCH'",
        "commit_id": "'$COMMIT_ID'"
    },
    "status": "pass",
    "custom_metadata": {
        "toolchain_id": "5-4257-a110-87bc3cd234"
    }
}' "$DLMS_SERVER/v1/organizations/$ORGANIZATION/environments/$BUILD_ENVIRONMENT/runtimes/$RUNTIME/builds"

sleep 5s

echo '\nPosting deploy information...'
# deploy record
curl -X POST -H "Authorization: $TOKEN" -H "Content-Type: application/json" -d '{
    "app_url": "https://dlms.ng.bluemix.net/docs",
    "job_url": "https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/7f388114-b91e-405d-a486-5e89105fffea/1d5b23d7-9926-47df-b066-3e73fa82071c",
    "status": "pass",
    "custom_metadata": {
        "toolchain_id": "5-4257-a110-87bc3cd234"
    }
}' "$DLMS_SERVER/v1/orgs/$ORGANIZATION/envs/$DEPLOY_ENVIRONMENT/runtimes/$RUNTIME/builds/$BUILD_ID/deployments"

sh print-message.sh