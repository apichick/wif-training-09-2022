/**
 * Copyright 2022 Google LLC
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

 output "credential" {
  description = "Credential configuration file contents."
  value = templatefile("${path.module}/credential.json", {
    project_number        = module.prj.number
    pool_id               = google_iam_workload_identity_pool.pool.workload_identity_pool_id
    provider_id           = google_iam_workload_identity_pool_provider.provider.workload_identity_pool_provider_id
    service_account_email = module.sa.email
  })
}

output "vm_public_ip" {
    value = aws_instance.vm.public_ip
}