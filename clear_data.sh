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
if [ -z "$DLMS_SERVER" ]; then
    echo "DLMS_SERVER not set. Run 'export DLMS_SERVER=<server url>'. (e.g https://dev-dlms.stage1.ng.bluemix.net, https://dlms.ng.bluemix.net, etc.)"
    exit 1
fi 

echo '\nPurging data for ORGANIZATION:'
echo $ORGANIZATION
# test result - scan
curl -X DELETE --header "Authorization: $TOKEN" --header "Content-Type: application/json" "$DLMS_SERVER/v1/organizations/$ORGANIZATION"
