# Copyright 2022 apichick@

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
 
#!/bin/bash

ORG_NAME=${org_name}
AUTH_SERVER_ID=${auth_server_id}
CLIENT_ID=${client_id}
CLIENT_SECRET=${client_secret}
PROJECT_NUMBER=${project_number}
POOL_ID=${pool_id}
PROVIDER_ID=${provider_id}
SA=${sa}
SCOPE=${scope}

RESOURCE="projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/providers/$PROVIDER_ID"

SUBJECT_TOKEN_TYPE="urn:ietf:params:oauth:token-type:jwt"

SUBJECT_TOKEN=$(curl -s https://$ORG_NAME.okta.com/oauth2/$AUTH_SERVER_ID/v1/token \
-d "client_id=$CLIENT_ID" \
-d "client_secret=$CLIENT_SECRET" \
-d "grant_type=client_credentials" \
-d "scope=$SCOPE"
| jq -r '.access_token')
echo "OKTA TOKEN"
echo "****************************************"
echo $SUBJECT_TOKEN
echo "****************************************"
STS_TOKEN=$(curl -s https://sts.googleapis.com/v1/token \
    -H 'Content-Type: text/json; charset=utf-8' \
    -d @- <<EOF | jq -r .access_token
    {
        "audience"           : "//iam.googleapis.com/$RESOURCE",
        "grantType"          : "urn:ietf:params:oauth:grant-type:token-exchange",
        "requestedTokenType" : "urn:ietf:params:oauth:token-type:access_token",
        "scope"              : "https://www.googleapis.com/auth/cloud-platform",
        "subjectTokenType"   : "$SUBJECT_TOKEN_TYPE",
        "subjectToken"       : "$SUBJECT_TOKEN"
     }
 EOF)
echo "GOOGLE STS TOKEN"
echo "****************************************"
echo $STS_TOKEN
echo "****************************************"
ACCESS_TOKEN=$(curl -s https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/$SA:generateAccessToken \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Authorization: Bearer $STS_TOKEN" \
    -d @- <<EOF | jq -r .accessToken
    {
        "scope": [ "https://www.googleapis.com/auth/cloud-platform" ]
    }
EOF)
echo "GOOGLE ACCESS TOKEN"
echo "****************************************"
echo $ACCESS_TOKEN
echo "****************************************"
