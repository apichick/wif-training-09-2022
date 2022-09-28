/**
 * Copyright 2022 apichick@
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

 locals {
    scope = "test"
 }

resource "okta_auth_server" "server" {
  audiences = [local.audience]
  name      = "oauth-server"
  status    = "ACTIVE"
}

resource "okta_auth_server_scope" "scope" {
  auth_server_id   = okta_auth_server.server.id
  metadata_publish = "ALL_CLIENTS"
  name             = local.scope
  consent          = "IMPLICIT"
}

resource "okta_auth_server_policy" "policy" {
  auth_server_id   = okta_auth_server.server.id
  status           = "ACTIVE"
  name             = "policy"
  description      = "policy"
  priority         = 1
  client_whitelist = ["ALL_CLIENTS"]
}

resource "okta_auth_server_policy_rule" "example" {
  auth_server_id       = okta_auth_server_policy.policy.auth_server_id
  policy_id            = okta_auth_server_policy.policy.id
  status               = "ACTIVE"
  name                 = "default"
  priority             = 1
  grant_type_whitelist = ["client_credentials"]
}

resource "okta_app_oauth" "app" {
  label          = "wif"
  type           = "service"
  grant_types    = ["client_credentials"]
  response_types = ["token"]
}
