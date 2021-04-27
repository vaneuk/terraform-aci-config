locals {
  leaf_pg_from_yaml = yamldecode(file("${local.cfg_dir}/leaf_pg.yaml"))
  leaf_pg = {
    for k, v in local.leaf_pg_from_yaml : k => merge(v, { name = k })
  }
}

#=============================
#  Leaf Policy Groups
#=============================

module "leaf_policy_group" {
  source = "../../terraform-aci-access/modules/leaf_policy_groupv4"
  leaf_policy_group = local.leaf_pg
  # leaf_policy_group = {
  #   # "default" = {
  #   #   # bfd_ipv4_plcy       = "default" # is already the default
  #   #   # bfd_ipv6_plcy       = "default" # is already the default
  #   #   # bfd_mhop_ipv4_plcy  = "default" # is already the default
  #   #   # bfd_mhop_ipv6_plcy  = "default" # is already the default
  #   #   cdp_policy = "cdp_enabled" # Policy Created in the policies.tf example
  #   #   # copp_leaf_plcy      = "default" # is already the default
  #   #   # copp_pre_filter     = "default" # is already the default
  #   #   description = "Default Leaf Policy Group"
  #   #   # fc_node_policy      = "default" # is already the default
  #   #   # fc_san_policy       = "default" # is already the default
  #   #   # fast_link_plcy      = "default" # is already the default
  #   #   # flash_config        = "default" # is already the default
  #   #   # fwd_scale_plcy      = "default" # is already the default
  #   #   lldp_policy = "lldp_both_enabled" # Policy Created in the policies.tf example
  #   #   # monitor_policy      = "default" # is already the default
  #   #   # name                = "default" # is already the default
  #   #   # netflow_node_plcy   = "default" # is already the default
  #   #   # node_8021x_plcy     = "default" # is already the default
  #   #   # poe_policy          = "default" # is already the default
  #   #   # stp_policy          = "default" # is already the default
  #   # }
  #   "PG_Leaf" = {
  #     description    = "Leaf Fabric Access Policy Group"
  #     fast_link_plcy = "flfEnabled"
  #     fwd_scale_plcy = "fspIPv4Scale"
  #     name           = "PG_Leaf"
  #   }
  # }
}

output "leaf_policy_group" {
  value = { for v in sort(keys(module.leaf_policy_group)) : v => module.leaf_policy_group[v] }
}
