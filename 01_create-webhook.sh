
echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Initialization"

export TURBO_PASSWORD=P4ssw0rd!
export WORKFLOW_NAME="EDA_WEBHOOK"

export EDA_URL=$(oc get route -n eda eda-instance -o jsonpath={.spec.host})
echo "    🌏 EDA_URL:   $EDA_URL"

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
echo $existingWorkflow
curl -XDELETE -s -k "https://$TURBO_URL/api/v3/workflows/$existingWorkflow" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'



echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Create EDA Workflow"
result=$(curl -XPOST -s -k "https://$TURBO_URL/api/v3/workflows" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json' -d ' {
        "displayName": "'$WORKFLOW_NAME'",
        "className": "Workflow",
        "description": "'$WORKFLOW_NAME'",
        "discoveredBy":
        {
            "readonly": false
        },
       "type": "WEBHOOK",
       "typeSpecificDetails": {
       "url": "http://'$EDA_URL'/endpoint",
          "method": "POST",
          "template": "{  \"uuid\":\"$action.uuid\",  \"createTime\":\"$action.createTime\",  \"actionType\":\"$action.actionType\",  \"actionState\":\"$action.actionState\",  \"actionMode\":\"$action.actionMode\",  \"details\":\"$action.details\",  \"importance\": \"$action.importance\",  \"target\":{    \"uuid\":\"$action.target.uuid\",    \"displayName\":\"$action.target.displayName\",    \"className\":\"$action.target.className\",    \"environmentType\":\"$action.target.environmentType\"  },  \"currentEntity\":{    \"uuid\":\"$action.currentEntity.uuid\",    \"displayName\":\"$action.currentEntity.displayName\",    \"className\":\"$action.currentEntity.className\",    \"environmentType\":\"$action.currentEntity.environmentType\"  },  \"risk\":{      \"subCategory\":\"$action.risk.subCategory\",    \"description\":\"$action.risk.description\",    \"severity\":\"$action.risk.severity\",    \"importance\": \"$action.risk.importance\"  }}",
          "type": "WebhookApiDTO"
       }
    }')

echo $result| jq -r ".uuid"

export WF_ID=$(echo $result| jq -r ".uuid")
echo "    🛠️ Webhook ID: $WF_ID"
echo ""




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



