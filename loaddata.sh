TOKEN='bearer eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJhOWUwY2ViNC1jMzA3LTQ4ZGUtYmFlMS04N2U5NjlhZjY2YWYiLCJzdWIiOiI0MjcxMTA1ZS00OWJjLTRkN2QtYThkMS0zNjRhYzk1OTVkOGMiLCJzY29wZSI6WyJjbG91ZF9jb250cm9sbGVyLnJlYWQiLCJwYXNzd29yZC53cml0ZSIsImNsb3VkX2NvbnRyb2xsZXIud3JpdGUiLCJvcGVuaWQiXSwiY2xpZW50X2lkIjoiY2YiLCJjaWQiOiJjZiIsImF6cCI6ImNmIiwiZ3JhbnRfdHlwZSI6InBhc3N3b3JkIiwidXNlcl9pZCI6IjQyNzExMDVlLTQ5YmMtNGQ3ZC1hOGQxLTM2NGFjOTU5NWQ4YyIsIm9yaWdpbiI6InVhYSIsInVzZXJfbmFtZSI6InZqZWdhc2VAdXMuaWJtLmNvbSIsImVtYWlsIjoidmplZ2FzZUB1cy5pYm0uY29tIiwicmV2X3NpZyI6ImUzZWVjZWY4IiwiaWF0IjoxNDc0OTI5NjkyLCJleHAiOjE0NzYxMzkyOTIsImlzcyI6Imh0dHBzOi8vdWFhLnN0YWdlMS5uZy5ibHVlbWl4Lm5ldC9vYXV0aC90b2tlbiIsInppZCI6InVhYSIsImF1ZCI6WyJjbG91ZF9jb250cm9sbGVyIiwicGFzc3dvcmQiLCJjZiIsIm9wZW5pZCJdfQ.a7107YJQzNq4qZOYV_IPu7ax-YGVP2i36IMsXL5nGDU'

ORG=bair@us.ibm.com
ENVIRONMENT=MASTER_BUILD
RUNTIME='Catalog_API'
BUILD_ID=master:30
COMMIT_ID=7035df304135d746c71e92edaea9bd1fc8525644
JOB_URL='https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/38218d83-89ff-465b-bf40-de51a5286c6c/ce2c975f-7581-45c5-9ae8-5573b1fd99fe'
BRANCH=master
DLMS_SERVER=http://localhost:6009

echo "\nPosting build information for $RUNTIME and $BRANCH and $BUILD_ID."

# build record
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
}' "$DLMS_SERVER/v1/organizations/$ORG/environments/$ENVIRONMENT/runtimes/$RUNTIME/builds"

echo "Posting unit test results ."
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest.json "$DLMS_SERVER/v1/results_multipart"

#sleep 1s
echo '\nPosting coverage results ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary.json -F contents_type=application/json -F contents=@coverage-summary.json "$DLMS_SERVER/v1/results_multipart"

DEPLOY_ENVIRONMENT=STAGING

echo '\nPosting deploy information...'
# deploy record
curl -X POST -H "Authorization: $TOKEN" -H "Content-Type: application/json" -d '{
    "app_url": "https://new-dlms.stage1.ng.bluemix.net/docs",
    "job_url": "https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/7f388114-b91e-405d-a486-5e89105fffea/1d5b23d7-9926-47df-b066-3e73fa82071c",
    "status": "pass",
    "custom_metadata": {
        "toolchain_id": "5-4257-a110-87bc3cd234"
    }
}' "$DLMS_SERVER/v1/orgs/$ORG/envs/$DEPLOY_ENVIRONMENT/runtimes/$RUNTIME/builds/$BUILD_ID/deployments"

echo '\nPosting fvt(saucelabs) results ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test.json -F contents_type=application/json -F contents=@saucelab-test.json "$DLMS_SERVER/v1/results_multipart"


#sleep 1s

BUILD_ID=master:31
COMMIT_ID=dff7884b9168168d91cb9e5aec78e93db0fa80d8

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
}' "$DLMS_SERVER/v1/organizations/$ORG/environments/$ENVIRONMENT/runtimes/$RUNTIME/builds"

echo '\nPosting unit-test results ...'
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest.json "$DLMS_SERVER/v1/results_multipart"

#sleep 1s
echo '\nPosting coverage results ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary.json -F contents_type=application/json -F contents=@coverage-summary.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting deploy information...'
# deploy record
curl -X POST -H "Authorization: $TOKEN" -H "Content-Type: application/json" -d '{
    "app_url": "https://new-dlms.stage1.ng.bluemix.net/docs",
    "job_url": "https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/7f388114-b91e-405d-a486-5e89105fffea/1d5b23d7-9926-47df-b066-3e73fa82071c",
    "status": "pass",
    "custom_metadata": {
        "toolchain_id": "5-4257-a110-87bc3cd234"
    }
}' "$DLMS_SERVER/v1/orgs/$ORG/envs/$DEPLOY_ENVIRONMENT/runtimes/$RUNTIME/builds/$BUILD_ID/deployments"

echo '\nPosting fvt(saucelabs) results ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test.json -F contents_type=application/json -F contents=@saucelab-test.json "$DLMS_SERVER/v1/results_multipart"


#sleep 1s 

RUNTIME='Catalog_UI'
BUILD_ID=master:21

echo "\nPosting build information for $RUNTIME and $BRANCH and $BUILD_ID."
# build record
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
}' "$DLMS_SERVER/v1/organizations/$ORG/environments/$ENVIRONMENT/runtimes/$RUNTIME/builds"

echo '\nPosting unit-test results ...'
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest.json "$DLMS_SERVER/v1/results_multipart"

#sleep 1s
echo '\nPosting coverage results ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary.json -F contents_type=application/json -F contents=@coverage-summary.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting deploy information...'
# deploy record
curl -X POST -H "Authorization: $TOKEN" -H "Content-Type: application/json" -d '{
    "app_url": "https://new-dlms.stage1.ng.bluemix.net/docs",
    "job_url": "https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/7f388114-b91e-405d-a486-5e89105fffea/1d5b23d7-9926-47df-b066-3e73fa82071c",
    "status": "pass",
    "custom_metadata": {
        "toolchain_id": "5-4257-a110-87bc3cd234"
    }
}' "$DLMS_SERVER/v1/orgs/$ORG/envs/$DEPLOY_ENVIRONMENT/runtimes/$RUNTIME/builds/$BUILD_ID/deployments"

echo '\nPosting fvt(saucelabs) results ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test.json -F contents_type=application/json -F contents=@saucelab-test.json "$DLMS_SERVER/v1/results_multipart"


#sleep 1s 

BUILD_ID=master:22
COMMIT_ID=dff7884b9168168d91cb9e5aec78e93db0fa80d8

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
}' "$DLMS_SERVER/v1/organizations/$ORG/environments/$ENVIRONMENT/runtimes/$RUNTIME/builds"

echo '\nPosting unit-test results ...'
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest.json "$DLMS_SERVER/v1/results_multipart"

#sleep 1s
echo '\nPosting coverage results ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary.json -F contents_type=application/json -F contents=@coverage-summary.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting deploy information...'
# deploy record
curl -X POST -H "Authorization: $TOKEN" -H "Content-Type: application/json" -d '{
    "app_url": "https://new-dlms.stage1.ng.bluemix.net/docs",
    "job_url": "https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/7f388114-b91e-405d-a486-5e89105fffea/1d5b23d7-9926-47df-b066-3e73fa82071c",
    "status": "pass",
    "custom_metadata": {
        "toolchain_id": "5-4257-a110-87bc3cd234"
    }
}' "$DLMS_SERVER/v1/orgs/$ORG/envs/$DEPLOY_ENVIRONMENT/runtimes/$RUNTIME/builds/$BUILD_ID/deployments"

echo '\nPosting fvt(saucelabs) results ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test.json -F contents_type=application/json -F contents=@saucelab-test.json "$DLMS_SERVER/v1/results_multipart"


# Posting for different branch
#sleep 1s 

RUNTIME='Catalog_API'
BRANCH=release
BUILD_ID=release:10
ENVIRONMENT=RELEASE_BUILD

echo "\nPosting build information for $RUNTIME and $BRANCH and $BUILD_ID."
# build record
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
}' "$DLMS_SERVER/v1/organizations/$ORG/environments/$ENVIRONMENT/runtimes/$RUNTIME/builds"

echo '\nPosting unit-test results ...'
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest.json "$DLMS_SERVER/v1/results_multipart"

#sleep 1s
echo '\nPosting coverage results ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary.json -F contents_type=application/json -F contents=@coverage-summary.json "$DLMS_SERVER/v1/results_multipart"

DEPLOY_ENVIRONMENT=PRODUCTION

echo '\nPosting deploy information...'
# deploy record
curl -X POST -H "Authorization: $TOKEN" -H "Content-Type: application/json" -d '{
    "app_url": "https://new-dlms.stage1.ng.bluemix.net/docs",
    "job_url": "https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/7f388114-b91e-405d-a486-5e89105fffea/1d5b23d7-9926-47df-b066-3e73fa82071c",
    "status": "pass",
    "custom_metadata": {
        "toolchain_id": "5-4257-a110-87bc3cd234"
    }
}' "$DLMS_SERVER/v1/orgs/$ORG/envs/$DEPLOY_ENVIRONMENT/runtimes/$RUNTIME/builds/$BUILD_ID/deployments"

echo '\nPosting fvt(saucelabs) results ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test.json -F contents_type=application/json -F contents=@saucelab-test.json "$DLMS_SERVER/v1/results_multipart"


#sleep 1s 

BUILD_ID=release:11
COMMIT_ID=dff7884b9168168d91cb9e5aec78e93db0fa80d8

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
}' "$DLMS_SERVER/v1/organizations/$ORG/environments/$ENVIRONMENT/runtimes/$RUNTIME/builds"

echo '\nPosting unit-test results ...'
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest.json "$DLMS_SERVER/v1/results_multipart"

#sleep 1s
echo '\nPosting coverage results ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary.json -F contents_type=application/json -F contents=@coverage-summary.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting deploy information...'
# deploy record
curl -X POST -H "Authorization: $TOKEN" -H "Content-Type: application/json" -d '{
    "app_url": "https://new-dlms.stage1.ng.bluemix.net/docs",
    "job_url": "https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/7f388114-b91e-405d-a486-5e89105fffea/1d5b23d7-9926-47df-b066-3e73fa82071c",
    "status": "pass",
    "custom_metadata": {
        "toolchain_id": "5-4257-a110-87bc3cd234"
    }
}' "$DLMS_SERVER/v1/orgs/$ORG/envs/$DEPLOY_ENVIRONMENT/runtimes/$RUNTIME/builds/$BUILD_ID/deployments"

echo '\nPosting fvt(saucelabs) results ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test.json -F contents_type=application/json -F contents=@saucelab-test.json "$DLMS_SERVER/v1/results_multipart"


#sleep 1s 

RUNTIME='Catalog_UI'
BUILD_ID=release:5

echo "\nPosting build information for $RUNTIME and $BRANCH and $BUILD_ID."
# build record
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
}' "$DLMS_SERVER/v1/organizations/$ORG/environments/$ENVIRONMENT/runtimes/$RUNTIME/builds"

echo '\nPosting unit-test results ...'
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest.json "$DLMS_SERVER/v1/results_multipart"

#sleep 1s
echo '\nPosting coverage results ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary.json -F contents_type=application/json -F contents=@coverage-summary.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting deploy information...'
# deploy record
curl -X POST -H "Authorization: $TOKEN" -H "Content-Type: application/json" -d '{
    "app_url": "https://new-dlms.stage1.ng.bluemix.net/docs",
    "job_url": "https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/7f388114-b91e-405d-a486-5e89105fffea/1d5b23d7-9926-47df-b066-3e73fa82071c",
    "status": "pass",
    "custom_metadata": {
        "toolchain_id": "5-4257-a110-87bc3cd234"
    }
}' "$DLMS_SERVER/v1/orgs/$ORG/envs/$DEPLOY_ENVIRONMENT/runtimes/$RUNTIME/builds/$BUILD_ID/deployments"

echo '\nPosting fvt(saucelabs) results ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test.json -F contents_type=application/json -F contents=@saucelab-test.json "$DLMS_SERVER/v1/results_multipart"


#sleep 1s 

BUILD_ID=release:6
COMMIT_ID=dff7884b9168168d91cb9e5aec78e93db0fa80d8

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
}' "$DLMS_SERVER/v1/organizations/$ORG/environments/$ENVIRONMENT/runtimes/$RUNTIME/builds"

echo '\nPosting unit-test results ...'
# test result - mocha
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=unittest -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=mochatest.json -F contents_type=application/json -F contents=@mochatest.json "$DLMS_SERVER/v1/results_multipart"

#sleep 1s
echo '\nPosting coverage results ...'
# test result - istanbul
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$ENVIRONMENT -F lifecycle_stage=code -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=coverage-summary.json -F contents_type=application/json -F contents=@coverage-summary.json "$DLMS_SERVER/v1/results_multipart"

echo '\nPosting deploy information...'
# deploy record
curl -X POST -H "Authorization: $TOKEN" -H "Content-Type: application/json" -d '{
    "app_url": "https://new-dlms.stage1.ng.bluemix.net/docs",
    "job_url": "https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/7f388114-b91e-405d-a486-5e89105fffea/1d5b23d7-9926-47df-b066-3e73fa82071c",
    "status": "pass",
    "custom_metadata": {
        "toolchain_id": "5-4257-a110-87bc3cd234"
    }
}' "$DLMS_SERVER/v1/orgs/$ORG/envs/$DEPLOY_ENVIRONMENT/runtimes/$RUNTIME/builds/$BUILD_ID/deployments"

echo '\nPosting fvt(saucelabs) results ...'
# test result - saucelabs
curl -X POST --header "Authorization: $TOKEN" --header "Content-Type: multipart/form-data" -F org_name=$ORG -F project_name=$RUNTIME -F runtime_name=$RUNTIME -F build_id=$BUILD_ID -F environment_name=$DEPLOY_ENVIRONMENT -F lifecycle_stage=fvt -F module_name=$RUNTIME -F url=https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/e4a5b9d7-dc0c-4925-8335-85bea17c717d/696d3338-ac7f-44d3-ab6f-e56251c5cb0e,https://hub.jazz.net/pipeline/devopsanalytics/DLMS-ci/8cb8a343-68b7-4f4b-8810-a12ded2a8c96/aa6b944f-de84-47f9-83e5-3f4a72d62458 -F artifact_name=saucelab-test.json -F contents_type=application/json -F contents=@saucelab-test.json "$DLMS_SERVER/v1/results_multipart"


# Posting for different branch - end

exit 1;





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
