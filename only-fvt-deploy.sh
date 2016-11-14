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
if [ -z "$DEPLOY_ENVIRONMENT" ]; then
    echo "DEPLOY_ENVIRONMENT not set. Run 'export DEPLOY_ENVIRONMENT=<deploy environment name>'"
    exit 1
fi 
if [ -z "$DLMS_SERVER" ]; then
    echo "DLMS_SERVER not set. Run 'export DLMS_SERVER=<server url>'. (e.g https://dev-dlms.stage1.ng.bluemix.net, https://dlms.ng.bluemix.net, etc.)"
    exit 1
fi 

echo '\nPosting fvt(saucelabs) results ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test.json -F contents_type=application/json -F contents=@saucelab-test.json "$DLMS_SERVER/v1/results_multipart"

sh print-message.sh
echo "VERIFY:"
echo "Build page: Should be empty."
echo "Deploy page: When the deploy environment is selected, following needs to be visible with data -"
echo "- a runtime entry"
echo "- deployed build information: the build id from test uploaded should be displayed in BUILD # column."
echo "- FVT results should show up."
echo "---------------------------------------------------------------------------------------------------"