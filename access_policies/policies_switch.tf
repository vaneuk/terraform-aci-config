locals {
  policies_switch_from_yaml = yamldecode(file("${local.cfg_dir}/policies_switch.yaml"))
  policies_switch = {
    for k, v in local.policies_switch_from_yaml : k => {
      for policy_name, policy_value in v : policy_name => merge(policy_value, { name = policy_name })
    }
  }
}

#=============================
#  Switch Policies
#=============================

module "switch_policies" {
  source = "../../terraform-aci-access/modules/policies_switch"

  # fast_link_failover = contains(keys(local.policies_switch), "fast_link_failover") ? local.policies_switch.fast_link_failover : null
  # forwarding_scale_profile = contains(keys(local.policies_switch), "forwarding_scale_profile") ? local.policies_switch.forwarding_scale_profile : {}

  # Comment any value that is not defined in YAML file
  fast_link_failover       = local.policies_switch.fast_link_failover
  forwarding_scale_profile = local.policies_switch.forwarding_scale_profile
}

output "switch_policies" {
  value = { for v in sort(keys(module.switch_policies)) : v => module.switch_policies[v] }
}
