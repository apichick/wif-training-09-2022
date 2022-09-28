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
USERNAME=$2
PASSWORD=$3
PROJECT_NUMBER=$4
POOL_ID=$5
PROVIDER_ID=$6
SA=$7

RESOURCE="projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/providers/$PROVIDER_ID"

SUBJECT_TOKEN_TYPE="urn:ietf:params:oauth:token-type:saml2"

SUBJECT_TOKEN=$(curl -s https://$ADFS_DOMAIN_NAME/adfs/services/trust/13/usernamemixed  \
    -H "Content-Type:application/soap+xml"  \
    -d @- <<EOF | xmllint --xpath "//*[local-name()='Envelope']/*[local-name()='Body']/*[local-name()='RequestSecurityTokenResponseCollection']/*[local-name()='RequestSecurityTokenResponse']/*[local-name()='RequestedSecurityToken']/*[local-name()='Assertion']" - | base64
<?xml version="1.0" encoding="utf-8"?>
<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
    <s:Header>
        <a:Action s:mustUnderstand="1">http://docs.oasis-open.org/ws-sx/ws-trust/200512/RST/Issue</a:Action>
        <a:To s:mustUnderstand="1">https://server.com/adfs/services/trust/13/UsernameMixed</a:To>
        <o:Security s:mustUnderstand="1" xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" >
            <o:UsernameToken u:Id="uuid-6a13a244-dac6-42c1-84c5-cbb345b0c4c4-1">
                <o:Username>$USERNAME</o:Username>
                <o:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">$PASSWORD</o:Password>
            </o:UsernameToken>
        </o:Security>
    </s:Header>
    <s:Body>
        <trust:RequestSecurityToken xmlns:trust="http://docs.oasis-open.org/ws-sx/ws-trust/200512">
            <wsp:AppliesTo xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy">
                <a:EndpointReference>
                    <a:Address>https://iam.googleapis.com/$RESOURCE</a:Address>
                </a:EndpointReference>
            </wsp:AppliesTo>
            <trust:KeyType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Bearer</trust:KeyType>
            <trust:RequestType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Issue</trust:RequestType>
            <trust:TokenType>urn:oasis:names:tc:SAML:2.0:assertion</trust:TokenType>
        </trust:RequestSecurityToken>
    </s:Body>
</s:Envelope>
EOF)
echo $SUBJECT_TOKEN > assertion.txt
# STS_TOKEN=$(curl -s https://sts.googleapis.com/v1/token \
#     -H 'Content-Type: text/json; charset=utf-8' \
#     -d @- <<EOF | jq -r .access_token
#     {
#         "audience"           : "//iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/providers/$PROVIDER_ID",
#         "grantType"          : "urn:ietf:params:oauth:grant-type:token-exchange",
#         "requestedTokenType" : "urn:ietf:params:oauth:token-type:access_token",
#         "scope"              : "https://www.googleapis.com/auth/cloud-platform",
#         "subjectTokenType"   : "$SUBJECT_TOKEN_TYPE",
#         "subjectToken"       : "$SUBJECT_TOKEN"
#     }
# EOF)
# echo $STS_TOKEN
# ACCESS_TOKEN=$(curl -s https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${SA}:generateAccessToken \
#     -H "Content-Type: application/json; charset=utf-8" \
#     -H "Authorization: Bearer $STS_TOKEN" \
#     -d @- <<EOF | jq -r .accessToken
#     {
#         "scope": [ "https://www.googleapis.com/auth/cloud-platform" ]
#     }
# EOF)
# echo $ACCESS_TOKEN
gcloud iam workload-identity-pools create-cred-config \
    $RESOURCE \
    --service-account=$SA \
    --output-file=credential.json \
    --credential-source-file=assertion.txt \
    --credential-source-type=text \
    --subject-token-type=urn:ietf:params:oauth:token-type:saml2


