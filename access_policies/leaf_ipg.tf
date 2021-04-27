locals {
  ipgs_access = yamldecode(file("${local.cfg_dir}/ipgs_access.yaml"))
  ipgs_bundle = yamldecode(file("${local.cfg_dir}/ipgs_bundle.yaml"))
  ipgs_access_with_defaults = {
    for k, v in local.ipgs_access : k => {
      name                = k
      description         = contains(keys(v), "description") ? v.description : null
      relation_aaep       = contains(keys(v), "aaep") ? module.global_policies.aaep[v.aaep] : null
      relation_cdp        = contains(keys(v), "cdp") ? module.intf_policies.cdp[v.cdp] : null
      relation_l2_intf    = contains(keys(v), "l2_interface") ? module.intf_policies.l2_interface[v.l2_interface] : null
      relation_link_level = contains(keys(v), "link_level") ? module.intf_policies.link_level[v.link_level] : null
      relation_lldp       = contains(keys(v), "lldp") ? module.intf_policies.lldp[v.lldp] : null
      relation_mcp        = contains(keys(v), "mcp") ? module.intf_policies.mcp[v.mcp] : null
      relation_stp        = contains(keys(v), "stp") ? module.intf_policies.stp[v.stp] : null
      relation_storm_ctrl = contains(keys(v), "storm_control") ? module.intf_policies.storm_control[v.storm_control] : null
    }
  }
  ipgs_bundle_with_defaults = {
    for k, v in local.ipgs_bundle : k => {
      name                = k
      description         = contains(keys(v), "description") ? v.description : null
      relation_aaep       = contains(keys(v), "aaep") ? module.global_policies.aaep[v.aaep] : null
      relation_cdp        = contains(keys(v), "cdp") ? module.intf_policies.cdp[v.cdp] : null
      relation_l2_intf    = contains(keys(v), "l2_interface") ? module.intf_policies.l2_interface[v.l2_interface] : null
      relation_link_level = contains(keys(v), "link_level") ? module.intf_policies.link_level[v.link_level] : null
      relation_lldp       = contains(keys(v), "lldp") ? module.intf_policies.lldp[v.lldp] : null
      relation_mcp        = contains(keys(v), "mcp") ? module.intf_policies.mcp[v.mcp] : null
      relation_stp        = contains(keys(v), "stp") ? module.intf_policies.stp[v.stp] : null
      relation_storm_ctrl = contains(keys(v), "storm_control") ?  module.intf_policies.storm_control[v.storm_control] : null
      relation_lacp       = contains(keys(v), "lacp") ? module.intf_policies.lacp[v.lacp] : null
    }
  }
}


#---------------------------------------
#  Interface Policy Groups
#---------------------------------------

module "leaf_interface_policy_groups" {
  source     = "../../terraform-aci-access/modules/leaf_interface_policy_groups"
  depends_on = [module.intf_policies]

  access = local.ipgs_access_with_defaults

  breakout = {
    # "10g-4x" = {} # Everything is already default for this policy.
    # "25g-4x" = {
    #   breakout_map = "25g-4x"
    #   description  = "New default 4x25G Breakout Policy."
    #   name         = "25g-4x"
    # }
    # "50g-8x" = {
    #   breakout_map = "50g-8x"
    #   description  = "default 8x50G Breakout Policy."
    #   name         = "50g-8x"
    # }
    # "100g-2x" = {
    #   breakout_map = "100g-2x"
    #   description  = "default 2x100G Breakout Policy."
    #   name         = "100g-2x"
    # }
    # "100g-4x" = {
    #   breakout_map = "100g-4x"
    #   description  = "default 4x100G Breakout Policy."
    #   name         = "100g-4x"
    # }
  }

  bundle = local.ipgs_bundle_with_defaults
}

output "leaf_interface_policy_groups" {
  value = { for v in sort(keys(module.leaf_interface_policy_groups)) : v => module.leaf_interface_policy_groups[v] }
}
