locals {
  policies_interface_from_yaml = yamldecode(file("${local.cfg_dir}/policies_interface.yaml"))
  policies_interface = {
    for k, v in local.policies_interface_from_yaml : k => {
      for policy_name, policy_value in v : policy_name => merge(policy_value, { name = policy_name })
    }
  }
}

#=============================
#  Interface Policies
#=============================

module "intf_policies" {
  source = "../../terraform-aci-access/modules/policies_interface"

  cdp          = contains(keys(local.policies_interface), "cdp") ? local.policies_interface.cdp : null
  lldp         = contains(keys(local.policies_interface), "lldp") ? local.policies_interface.lldp : null
  l2_interface = contains(keys(local.policies_interface), "l2_interface") ? local.policies_interface.l2_interface : null
  lacp         = contains(keys(local.policies_interface), "lacp") ? local.policies_interface.lacp : null
  link_level   = contains(keys(local.policies_interface), "link_level") ? local.policies_interface.link_level : null
  mcp          = contains(keys(local.policies_interface), "mcp") ? local.policies_interface.mcp : null
  stp          = contains(keys(local.policies_interface), "stp") ? local.policies_interface.stp : null
  fc_interface = contains(keys(local.policies_interface), "fc_interface") ? local.policies_interface.fc_interface : null
  storm_control = contains(keys(local.policies_interface), "storm_control") ? local.policies_interface.storm_control : null
}

output "intf_policies" {
  value = { for v in sort(keys(module.intf_policies)) : v => module.intf_policies[v] }
}
