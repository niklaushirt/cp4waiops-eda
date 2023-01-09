
echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Initialization"


export TURBO_PASSWORD=P4ssw0rd!


export EDA_URL=$(oc get route -n eda eda-instance -o jsonpath={.spec.host})
echo $EDA_URL

export TURBO_URL=$(oc get route -n turbonomic api -o jsonpath={.spec.host})
echo $TURBO_URL


echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Login to Turbo"
export result=$(curl -XPOST -s -k -c /tmp/cookies -H 'accept: application/json' "https://$TURBO_URL/api/v3/login?disable_hateoas=true" -d "username=administrator&password=$TURBO_PASSWORD")
echo $result

echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Get Existing Workflows"
export result=$(curl -XGET -s -k "https://$TURBO_URL/api/v3/workflows" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json')
echo $result|jq
echo ""
echo ""



echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Create EDA Webhook"
result=$(curl -XPOST -s -k "https://$TURBO_URL/api/v3/workflows" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json' -d ' {
        "displayName": "EDA-Test Webhook1",
        "className": "Workflow",
        "description": "EDA-Test Webhook",
        "discoveredBy":
        {
            "readonly": false
        },
       "type": "WEBHOOK",
       "typeSpecificDetails": {
       "url": "http://'$EDA_URL'/endpoint",
          "method": "POST",
          "template": "{  \"uuid\":\"$action.uuid\",  \"createTime\":\"$action.createTime\",  \"actionType\":\"$action.actionType\",  \"actionState\":\"$action.actionState\",  \"actionMode\":\"$action.actionMode\",  \"details\":\"$action.details\",  \"importance\": \"$action.importance\",  \"target\":{    \"uuid\":\"$action.target.uuid\",    \"displayName\":\"$action.target.displayName\",    \"className\":\"$action.target.className\",    \"environmentType\":\"$action.target.environmentType\"  },  \"currentEntity\":{    \"uuid\":\"$action.currentEntity.uuid\",    \"displayName\":\"$action.currentEntity.displayName\",    \"className\":\"$action.currentEntity.className\",    \"environmentType\":\"$action.currentEntity.environmentType\"  },  \"newEntity\":{    \"uuid\":\"$action.newEntity.uuid\",    \"displayName\":\"$action.newEntity.displayName\",    \"className\":\"$action.newEntity.className\",    \"environmentType\":\"$action.newEntity.environmentType\"  },  \"risk\":{      \"subCategory\":\"$action.risk.subCategory\",    \"description\":\"$action.risk.description\",    \"severity\":\"$action.risk.severity\",    \"importance\": \"$action.risk.importance\"  }}",
          "type": "WebhookApiDTO"
       }
    }')

echo $result| jq -r ".uuid"

export WF_ID=$(echo $result| jq -r ".uuid")
echo $WF_ID



curl -XPOST -s -k 'https://api-turbonomic.itzroks-270003bu3k-48ptnn-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-de.containers.appdomain.cloud/api/v3/workflows/637754478575168' -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json' -d ' {"operation": "TEST","actionId": 637753244134084}'

export robotshop_id=$(curl -XGET -s -k "https://$TURBO_URL/api/v3/search?types=BusinessApplication" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'|jq '.[]|select(.displayName | contains("RobotShop"))'|jq -r ".uuid")
echo $robotshop_id
curl -XGET -s -k "https://$TURBO_URL/api/v3/entities/$robotshop_id/actions?limit=500&cursor=0" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'|jq ".[].uuid"
export actions=$(curl -XGET -s -k "https://$TURBO_URL/api/v3/entities/$robotshop_id/actions?limit=500&cursor=0" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json')
echo $actions



echo $actions|jq ".[]" |jq ' .uuid'
echo $actions|jq ".[]" |jq '.target.displayName'




echo "------------------------------------------------------------------------------------------------------------------------------"
echo " 📥 Test Event"
echo "curl -XPOST -s -k 'https://$TURBO_URL/api/v3/workflows/$WF_ID' -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json' -d ' {\"operation\": \"TEST\",\"actionId\": CHANGEME}'"
echo ""
echo " 🧻 Delete Webhook"
echo "curl -XDELETE -s -k 'https://$TURBO_URL/api/v3/workflows/$WF_ID' -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'"






exit 1





curl -XGET -s -k "https://$TURBO_URL/api/v3/search?types=BusinessApplication" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'|jq

curl -XPOST -s -k 'https://api-turbonomic.itzroks-270003bu3k-48ptnn-6ccd7f378ae819553d37d5f2ee142bd6-0000.eu-de.containers.appdomain.cloud/api/v3/workflows/637754690295888' -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json' -d ' {"operation": "TEST","actionId": 637753244134084}'

curl -XGET -s -k "https://$TURBO_URL/api/v3/entities/74795016031708/actions?limit=500&cursor=0" -b /tmp/cookies  -H 'Content-Type: application/json;' -H 'accept: application/json'|jq ".[].uuid"



"637745209180227"
"637745209180228"
"637745209180229"
"637745209180230"
"637745209180231"
"637745209180232"
"637745209180233"
"637746351351085"
"637746351351110"
"637746351351308"
"637747973748983"
"637746514542658"
"637746351351133"
"637752687340700"
"637753244134084"
"637746351351293"


