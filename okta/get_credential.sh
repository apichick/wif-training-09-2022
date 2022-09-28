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

ORG_NAME=trial-4323962
AUTH_SERVER_ID=aus2j9h26gcZOoWYV697
CLIENT_ID=0oa2ju0nzblUBGlwr697
CLIENT_SECRET=WMIPv0BEZ-rAL2BCkCsXbiPv2XXwVXVHNrLXd1zA
PROJECT_NUMBER=47281451066
POOL_ID=test-pool
PROVIDER_ID=test-provider
SA=sa-test@g-prj-cd-sb-wif-training-okta.iam.gserviceaccount.com
SCOPE=test

RESOURCE="projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/providers/$PROVIDER_ID"

curl -s https://$ORG_NAME.okta.com/oauth2/$AUTH_SERVER_ID/v1/token \
-d "client_id=$CLIENT_ID" \
-d "client_secret=$CLIENT_SECRET" \
-d "grant_type=client_credentials" \
-d "scope=$SCOPE" \
| jq -r '.access_token' > access_token.txt

gcloud iam workload-identity-pools create-cred-config \
$RESOURCE \
--service-account=$SA \
--output-file=credential.json \
--credential-source-file=access_token.txt \
--credential-source-type=text


# ./get_credential_okta_oidc.sh trial-4323962.okta.com aus2j9h26gcZOoWYV697 0oa2jtlen8aQ9k6b4697 Ea3u5NDMdgJe2EZbcslIk2ubfsr9XZltIMN1rS1j 47281451066  test-pool test-provider sa-test@g-prj-cd-sb-wif-training-okta.iam.gserviceaccount.com 
