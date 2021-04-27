locals {
  vlan_pool_from_yaml = yamldecode(file("${local.cfg_dir}/vlan_pools.yaml"))
  vlan_pool = {
    for k, v in local.vlan_pool_from_yaml : k => merge(v, { name = k })
  }
}


#=============================
#  VLAN POOLs
#=============================

module "vlan_pools" {
  source = "../../terraform-aci-access/modules/pools_vlan"
  vlan_pool = local.vlan_pool
}

output "vlan_pools" {
  value = { for v in sort(keys(module.vlan_pools)) : v => module.vlan_pools[v] }
}