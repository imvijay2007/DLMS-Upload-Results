TOKEN="`cf oauth-token`"

#export ORGANIZATION='CCDashboardTest'
#export RUNTIME='CCDashboardTest'
#export BRANCH='master'
#export BUILD_ENVIRONMENT=MASTER_BUILD
#export DEPLOY_ENVIRONMENT=STAGING
#export BUILD_ID=master:30
#export DLMS_SERVER=https://localhost:6009

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
if [ -z "$BUILD_ENVIRONMENT" ]; then
    echo "BUILD_ENVIRONMENT not set. Run 'export BUILD_ID=<your build id>'"
    exit 1
fi 
if [ -z "$DEPLOY_ENVIRONMENT" ]; then
    echo "DEPLOY_ENVIRONMENT not set. Run 'export BUILD_ID=<your build id>'"
    exit 1
fi 
if [ -z "$DLMS_SERVER" ]; then
    echo "DLMS_SERVER not set. Run 'export DLMS_SERVER=<server url>'. (e.g https://dev-dlms.stage1.ng.bluemix.net, https://dlms.ng.bluemix.net, etc.)"
    exit 1
fi 

echo "\nPosting unit test results ."
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$BUILD_ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest.json "$DLMS_SERVER/v1/results_multipart"

sleep 5s
echo '\nPosting coverage results ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$BUILD_ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary.json -F contents_type=application/json -F contents=@coverage-summary.json "$DLMS_SERVER/v1/results_multipart"

sleep 10s

echo '\nPosting fvt(saucelabs) results ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test.json -F contents_type=application/json -F contents=@saucelab-test.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting scan(appscan) results ...'
# test result - scan
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=codescansummary -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=codescansumamry-test.json -F contents_type=application/json -F contents=@codescansumamry-test-stage.json "$DLMS_SERVER/v1/results_multipart"

sh print-message.sh
echo "VERIFY:"
echo "Build page: Should be empty."
echo "Deploy page: Both the build and deploy type environments are available in dropdown. When the deploy environment is selected, following needs to be visible with data -"
echo "- a runtime entry"
echo "- deployed build information: the build id from test uploaded should be displayed in BUILD # column."
echo "- FVT and code scan results should be available."
echo "When the build environment is selected, following needs to be visible with data -"
echo "- a runtime entry"
echo "- deployed build information: the build id from test uploaded should be displayed in BUILD # column."
echo "- Unit test and code coverage results should be available."
echo "---------------------------------------------------------------------------------------------------------"
