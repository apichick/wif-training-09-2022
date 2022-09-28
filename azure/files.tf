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

resource "local_file" "credential_file" {
  content = templatefile("${path.module}/templates/credential.json.tpl", {
    project_number        = module.prj.number
    app_id_uri            = "api://${local.app_name}"
    pool_id               = google_iam_workload_identity_pool.pool.workload_identity_pool_id
    provider_id           = google_iam_workload_identity_pool_provider.provider.workload_identity_pool_provider_id
    service_account_email = module.sa.email
  })
  filename        = "${path.module}/credential.json"
  file_permission = "0777"
}

resource "local_file" "get_credential_file" {
  content = templatefile("${path.module}/templates/get_credential.sh.tpl", {
    app_id_uri     = "api://${local.app_name}"
    project_number = module.prj.number
    pool_id        = google_iam_workload_identity_pool.pool.workload_identity_pool_id
    provider_id    = google_iam_workload_identity_pool_provider.provider.workload_identity_pool_provider_id
    sa             = module.sa.email
  })
  filename        = "${path.module}/get_credential.sh"
  file_permission = "0777"
}

resource "local_file" "get_access_token_file" {
  content = templatefile("${path.module}/templates/get_access_token.sh.tpl", {
    app_id_uri     = "api://${local.app_name}"
    project_number = module.prj.number
    pool_id        = google_iam_workload_identity_pool.pool.workload_identity_pool_id
    provider_id    = google_iam_workload_identity_pool_provider.provider.workload_identity_pool_provider_id
    sa             = module.sa.email
  })
  filename        = "${path.module}/get_access_token.sh"
  file_permission = "0777"
}

resource "local_sensitive_file" "ssh_key" {
  count           = var.vm_test ? 1 : 0
  content         = tls_private_key.private_key[0].private_key_pem
  filename        = "${path.module}/id_rsa"
  file_permission = "0600"
}
