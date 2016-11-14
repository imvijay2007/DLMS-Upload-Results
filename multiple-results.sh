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

echo "\nPosting unit test results ."
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$BUILD_ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest.json "$DLMS_SERVER/v1/results_multipart"

echo "\nPosting unit test results 1."
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$BUILD_ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest1.json -F contents_type=application/json -F contents=@mochatest1.json "$DLMS_SERVER/v1/results_multipart"

echo "\nPosting unit test results 2."
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$BUILD_ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest2.json -F contents_type=application/json -F contents=@mochatest2.json "$DLMS_SERVER/v1/results_multipart"

sleep 5s

echo '\nPosting coverage results ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$BUILD_ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary.json -F contents_type=application/json -F contents=@coverage-summary.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting coverage results 1 ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$BUILD_ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary1.json -F contents_type=application/json -F contents=@coverage-summary1.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting coverage results 2 ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$BUILD_ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary2.json -F contents_type=application/json -F contents=@coverage-summary2.json "$DLMS_SERVER/v1/results_multipart"

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

sleep 5s

echo '\nPosting fvt(saucelabs) results ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test.json -F contents_type=application/json -F contents=@saucelab-test.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting fvt(saucelabs) results 1 ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test1.json -F contents_type=application/json -F contents=@saucelab-test1.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting fvt(saucelabs) results 2 ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test2.json -F contents_type=application/json -F contents=@saucelab-test2.json "$DLMS_SERVER/v1/results_multipart"

sleep 5s

echo '\nPosting scan(appscan) results ...'
# test result - scan
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=codescansummary -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=codescansumamry-test.json -F contents_type=application/json -F contents=@codescansumamry-test-stage.json "$DLMS_SERVER/v1/results_multipart"

sh print-message.sh
echo "VERIFY:"
echo "Build page: When the branch is selected, following needs to be visible with data -"
echo "- a runtime entry with owner"
echo "- latest build information: build id, status of build(icon)and build date"
echo "- last reported build information: build id and build date"
echo "- A test of type 'MULTIPLE' should be displayed. The chevron shows up, clicking on which will show detailed result of multiple unit test results. Also the code coverage values should be the average of individual code coverages."
echo "Deploy page: When the deploy environment is selected, following needs to be visible with data -"
echo "- a runtime entry"
echo "- deployed build information: deployed build id, status of deployment(icon), and date when build for deployment happened."
echo "- A test of type 'MULTIPLE' should be displayed. The chevron shows up, clicking on which will show detailed result of multiple FVT results. Also the appscan results should show up."
echo "---------------------------------------------------------------------------------------------------------"