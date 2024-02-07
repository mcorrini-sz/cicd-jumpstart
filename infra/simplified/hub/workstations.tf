# Copyright 2023-2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_workstations_workstation_cluster" "cicd_jumpstart" {
  provider               = google-beta
  project                = var.project_id
  workstation_cluster_id = var.ws_cluster_name
  network                = module.vpc.id
  subnetwork             = module.vpc.subnets["${var.region}/hub"].id
  location               = var.region
}

resource "google_workstations_workstation_config" "cicd_jumpstart" {
  provider               = google-beta
  project                = var.project_id
  workstation_config_id  = var.ws_config_name
  workstation_cluster_id = google_workstations_workstation_cluster.cicd_jumpstart.workstation_cluster_id
  location               = var.region
  idle_timeout           = "${var.ws_idle_time}s"
  host {
    gce_instance {
      machine_type                = var.ws_config_machine_type
      boot_disk_size_gb           = var.ws_config_boot_disk_size_gb
      disable_public_ip_addresses = var.ws_config_disable_public_ip
      pool_size                   = var.ws_pool_size
    }
  }
  persistent_directories {
    mount_path = "/home"
    gce_pd {
      size_gb        = 200
      fs_type        = "ext4"
      disk_type      = "pd-standard"
      reclaim_policy = "DELETE"
    }
  }
}
