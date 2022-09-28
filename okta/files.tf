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

resource "local_file" "get_credential_file" {
  content = templatefile("${path.module}/templates/get_credential.sh.tpl", {
    org_name       = var.org_name
    auth_server_id = okta_auth_server.server.id
    project_number = module.prj.number
    client_id      = okta_app_oauth.app.client_id
    client_secret  = okta_app_oauth.app.client_secret
    pool_id        = google_iam_workload_identity_pool.pool.workload_identity_pool_id
    provider_id    = google_iam_workload_identity_pool_provider.provider.workload_identity_pool_provider_id
    sa             = module.sa.email
    scope          = local.scope
  })
  filename        = "${path.module}/get_credential.sh"
  file_permission = "0777"
}

resource "local_file" "get_access_token_file" {
  content = templatefile("${path.module}/templates/get_access_token.sh.tpl", {
    org_name       = var.org_name
    auth_server_id = okta_auth_server.server.id
    project_number = module.prj.number
    client_id      = okta_app_oauth.app.client_id
    client_secret  = okta_app_oauth.app.client_secret
    pool_id        = google_iam_workload_identity_pool.pool.workload_identity_pool_id
    provider_id    = google_iam_workload_identity_pool_provider.provider.workload_identity_pool_provider_id
    sa             = module.sa.email
    scope          = local.scope
  })
  filename        = "${path.module}/get_access_token.sh"
  file_permission = "0777"
}
