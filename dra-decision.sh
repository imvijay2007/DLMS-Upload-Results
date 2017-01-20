TOKEN="`cf oauth-token | sed -n 's/.*\(bearer .*\)/\1/p'`"

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
if [ -z "$DRA_SERVER" ]; then
    echo "DRA_SERVER not set. Run 'export DRA_SERVER=<server url>'. (e.g https://dev-dra.stage1.ng.bluemix.net, https://dra.ng.bluemix.net, etc.)"
    exit 1
fi 

echo "\nPosting GOOD unit test results ."
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$BUILD_ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting GOOD coverage results ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$BUILD_ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary.json -F contents_type=application/json -F contents=@coverage-summary.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting GOOD fvt(saucelabs) results in MOCHA FORMAT...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting GOOD dynamic scan results...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=dynamicsecurityscan -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=appscan-dynamic-pass.xml -F contents_type=application/xml -F contents=@appscan-dynamic-pass.xml "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting GOOD static scan results...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=staticsecurityscan -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=appscan-static-pass.xml -F contents_type=application/xml -F contents=@appscan-static-pass.xml "$DLMS_SERVER/v1/results_multipart"

sleep 5s

echo '\nASKING FOR GOOD DECISION ...'
curl -k -X POST --header "Authorization: $TOKEN" --header "Content-Type: application/json" --data '{"org_name":"'$ORGANIZATION'", "project_name":"'$RUNTIME'", "runtime_name":"'$RUNTIME'","build_id":"'$BUILD_ID'","module_name":"'$RUNTIME'","criteria_name":"DRA_Check" }' $DRA_SERVER/api/v3/decision?org_name=$ORGANIZATION

echo '\n##########################################################################################\n'
sleep 5s

BUILD_ID=master:102
echo '\nPosting BAD unit test results .'
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$BUILD_ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest1.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting BAD coverage results ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$BUILD_ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary.json -F contents_type=application/json -F contents=@coverage-summary1.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting BAD fvt(saucelabs) results in MOCHA FORMAT...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest1.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting GOOD dynamic scan results...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=dynamicsecurityscan -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=appscan-dynamic-fail.xml -F contents_type=application/xml -F contents=@appscan-dynamic-fail.xml "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting GOOD static scan results...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORGANIZATION -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=staticsecurityscan -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=appscan-static-fail.xml -F contents_type=application/xml -F contents=@appscan-static-fail.xml "$DLMS_SERVER/v1/results_multipart"

sleep 5s

echo '\nASKING FOR BAD DECISION ...'
curl -k -X POST --header "Authorization: $TOKEN" --header "Content-Type: application/json" --data '{"org_name":"'$ORGANIZATION'", "project_name":"'$RUNTIME'", "runtime_name":"'$RUNTIME'","build_id":"'$BUILD_ID'","module_name":"'$RUNTIME'","criteria_name":"DRA_Check" }' $DRA_SERVER/api/v3/decision?org_name=$ORGANIZATION
