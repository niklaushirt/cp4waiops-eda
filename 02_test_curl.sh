
echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Initialization"

export TURBO_PASSWORD=P4ssw0rd!
export WORKFLOW_NAME="EDA_WEBHOOK"

export TURBO_URL=$(oc get route -n turbonomic api -o jsonpath={.spec.host})
echo "    🌏 TURBO_URL: $TURBO_URL"
echo ""

echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Login to Turbo"
export result=$(curl -XPOST -s -k -c /tmp/cookies -H 'accept: application/json' "https://$TURBO_URL/api/v3/login?disable_hateoas=true" -d "username=administrator&password=$TURBO_PASSWORD")
echo $result

echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Get Existing Workflows"
export workflows=$(curl -XGET -s -k "https://$TURBO_URL/api/v3/workflows" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json')
echo $workflows|jq
echo ""
echo ""
echo ""

echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Delete Existing EDA Workflow"
export existingWorkflow=$(echo $workflows|jq  '.[]|select(.displayName | contains("'$WORKFLOW_NAME'"))'| jq -r ".uuid")

if [[ $existingWorkflow != "" ]] ;
then
    echo "   ✅ Webhook already exists."
    #curl -XDELETE -s -k "https://$TURBO_URL/api/v3/workflows/$existingWorkflow" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'
    WF_ID=$existingWorkflow
else
    echo "------------------------------------------------------------------------------------------------------------------------------"
    echo " ❌ Workflow not defined! Aborting"
    exit 1
fi



export robotshop_id=$(curl -XGET -s -k "https://$TURBO_URL/api/v3/search?types=BusinessApplication" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'|jq '.[]|select(.displayName | contains("RobotShop"))'|jq -r ".uuid")
#echo $robotshop_id
#curl -XGET -s -k "https://$TURBO_URL/api/v3/entities/$robotshop_id/actions?limit=500&cursor=0" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'|jq ".[].uuid"
export actions=$(curl -XGET -s -k "https://$TURBO_URL/api/v3/entities/$robotshop_id/actions?limit=500&cursor=0" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json')
#echo $actions|jq


export actionID_resize=$(echo $actions|jq  '.[]|select(.actionType | contains("RESIZE"))'|jq  'select(.target.displayName | contains("catalogue"))'| jq -r ".uuid")
#echo $actionID_resize
export actionID_notresize=$(echo $actions|jq  '[.[]|select(.actionType | contains("RESIZE")| not)][0]'| jq -r ".uuid")
#echo $actionID_notresize




echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Test Event Catalogue"
echo "curl -XPOST -s -k 'https://$TURBO_URL/api/v3/workflows/$WF_ID' -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json' -d ' {\"operation\": \"TEST\",\"actionId\": $actionID_resize}'"
echo ""

echo " 📥 Test Event Other"
echo "curl -XPOST -s -k 'https://$TURBO_URL/api/v3/workflows/$WF_ID' -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json' -d ' {\"operation\": \"TEST\",\"actionId\": $actionID_notresize}'"
echo ""


echo ""
echo " 🧻 Delete Webhook"
echo "curl -XDELETE -s -k 'https://$TURBO_URL/api/v3/workflows/$WF_ID' -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'"
echo ""



