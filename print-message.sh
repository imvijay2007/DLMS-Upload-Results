ENV="`echo $DLMS_SERVER | awk -F  "//" '/1/ {print $2}' | awk -F  "-" '/1/ {print $1}'`"
echo "\n##################################################################################################"
echo "Data loaded for scenario. Goto https://$ENV-control-center.stage1.ng.bluemix.net and verify results!"
echo "##################################################################################################"