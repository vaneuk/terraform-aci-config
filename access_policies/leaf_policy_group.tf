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
  source            = "../../terraform-aci-access/modules/leaf_policy_groupv4"
  leaf_policy_group = local.leaf_pg
}

output "leaf_policy_group" {
  value = { for v in sort(keys(module.leaf_policy_group)) : v => module.leaf_policy_group[v] }
}
