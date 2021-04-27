locals {
  # Leaf Profile to Leaf Policy Group
  leaf_profile_to_pg_map = {
    for entry in local.leaf_ids : "SwProf_Node${entry.id}" => {
      leaf_profile_name  = "SwProf_Node${entry.id}"
      leaf_selector_name = "SwSel_Node${entry.id}"
      leaf_policy_group  = module.leaf_policy_group.leaf_policy_group["PG_Leaf"]
    }
  }
}
module "leaf_profile" {
  source       = "../../terraform-aci-access/modules/leaf_profile_single"
  depends_on   = [module.leaf_interface_profile]
  leaf_profile = local.access_and_vpc_leaf_profile_map
}

module "leaf_profile_to_pg" {
  source                    = "../../terraform-aci-access/modules/leaf_profile_to_pg"
  depends_on                = [module.leaf_profile, module.leaf_policy_group]
  leaf_profile_policy_group = local.leaf_profile_to_pg_map
}

# module "leaf_policy_group" {
#   source     = "../modules/leaf_profile_to_pg"
#   depends_on = [module.leaf_interface_profile, module.leaf_policy_group]
#   leaf_profile_policy_group = {
#     "policy_group" = {
#       leaf_profile_name  = "dc1-leaf201"
#       leaf_policy_group  = module.leaf_policy_group.leaf_policy_group["default"]
#       leaf_selector_name = "dc1-leaf201"
#       # switch_association_type = "range" # is already the default
#     }
#   }
# }