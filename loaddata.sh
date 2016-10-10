TOKEN='berer <hex>'

ORG=bair@us.ibm.com
ENVIRONMENT=DEV
RUNTIME=Test_09222016_1
BUILD_ID=30
DLMS_SERVER=https://dlms-test.stage1.ng.bluemix.net

echo 'Posting build information ...'
# build record
curl -X POST -H "Authorization: $TOKEN" -H "Content-Type: application/json" -d '{
    "build_id": "'$BUILD_ID'",
    "job_url": "https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/38218d83-89ff-465b-bf40-de51a5286c6c/ce2c975f-7581-45c5-9ae8-5573b1fd99fe",
    "repositories": [{
        "repository_url": "https://github.ibm.com/oneibmcloud/dlms.git",
        "branch": "master",
        "commit_id": "7035df304135d746c71e92edaea9bd1fc8525644"
    }],
    "status": "pass",
    "custom_metadata": {
        "toolchain_id": "5-4257-a110-87bc3cd234"
    }
}' "$DLMS_SERVER/v1/organizations/$ORG/environments/$ENVIRONMENT/runtimes/$RUNTIME/builds"

sleep 5s
echo '\nPosting unit-test results ...'
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest.json "$DLMS_SERVER/v1/results_multipart"

sleep 5s
echo '\nPosting coverage results ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary.json -F contents_type=application/json -F contents=@coverage-summary.json "$DLMS_SERVER/v1/results_multipart"

sleep 40s
echo '\nPosting fvt(saucelabs) results ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test.json -F contents_type=application/json -F contents=@saucelab-test.json "$DLMS_SERVER/v1/results_multipart"

sleep 5s
echo '\nPosting deploy information...'
# deploy record
curl -X POST -H "Authorization: $TOKEN" -H "Content-Type: application/json" -d '{
    "app_url": "https://new-dlms.stage1.ng.bluemix.net/docs",
    "job_url": "https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/7f388114-b91e-405d-a486-5e89105fffea/1d5b23d7-9926-47df-b066-3e73fa82071c",
    "status": "pass",
    "custom_metadata": {
        "toolchain_id": "5-4257-a110-87bc3cd234"
    }
}' "$DLMS_SERVER/v1/orgs/$ORG/envs/$ENVIRONMENT/runtimes/$RUNTIME/builds/$BUILD_ID/deployments"
