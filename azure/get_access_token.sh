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

APP_ID_URI=api://test-app
PROJECT_NUMBER=1018305567035
POOL_ID=test-pool
PROVIDER_ID=test-provider
SA=sa-test@g-prj-cd-sb-wif-training-az.iam.gserviceaccount.com

RESOURCE="projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/providers/$PROVIDER_ID"

SUBJECT_TOKEN_TYPE="urn:ietf:params:oauth:token-type:jwt"

SUBJECT_TOKEN=$(curl \
  "http://169.254.169.254/metadata/identity/oauth2/token?resource=$APP_ID_URI&api-version=2018-02-01" \
  -H "Metadata: true" | jq -r .access_token)
echo $SUBJECT_TOKEN

echo "AZURE TOKEN"
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
