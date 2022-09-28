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



ADFS_DOMAIN_NAME=$1
CLIENT_ID=$2
CLIENT_SECRET=$3
PROJECT_NUMBER=$4
POOL_ID=$5
PROVIDER_ID=$6
SA=$7

RESOURCE="projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/providers/$PROVIDER_ID"

curl -s -v https://$ADFS_DOMAIN_NAME/adfs/oauth2/token/ \
-d "client_id=$CLIENT_ID" \
-d "client_secret=$CLIENT_SECRET" \
-d "resource=https://iam.googleapis.com/$RESOURCE" \
-d "grant_type=client_credentials" \
-d "scope=openid" \
| jq -r '.access_token' > access_token.txt

gcloud iam workload-identity-pools create-cred-config \
$RESOURCE \
--service-account=$SA \
--output-file=credential.json \
--credential-source-file=access_token.txt \
--credential-source-type=text


#./get_credential_aws_oidc.sh adfs.cool-demos.space c2e89177-c942-493a-8f80-486831fcf153 1EUXxcXWZrRhxCl87Ul54gWdi2PKHskx6NBWlzXr 673362301501 pool1 provider1 sa-test@g-prj-cd-sb-wif-training-adfs.iam.gserviceaccount.com
