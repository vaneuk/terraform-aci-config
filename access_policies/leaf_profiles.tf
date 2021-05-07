locals {
  # Leaf Profile to Leaf Policy Group
  leaf_profile_to_pg_map = {
    for entry in local.vpc_ids : "SwProf_Node${entry.id1}-${entry.id2}" => {
      leaf_profile_name  = "SwProf_Node${entry.id1}-${entry.id2}"
      leaf_selector_name = "SwSel_Node${entry.id1}-${entry.id2}"
      leaf_policy_group  = module.leaf_policy_group.leaf_policy_group[entry.policy_group]
    }
  }

  # Used for Leaf Profiles
  access_leaf_profile_map = {
    for entry in local.leaf_ids : "SwProf_Node${entry.id}" => {
      name                   = "SwProf_Node${entry.id}"
      leaf_interface_profile = module.leaf_interface_profile.leaf_interface_profile["IntProf_Node${entry.id}"]
      leaf_selector_name     = "SwSel_Node${entry.id}"
      # switch_association_type = "range" # is already the default
      node_block_name = "bl${entry.id}${entry.id}" # internal value, should be moved to module, example "name": "bl110110",
      node_block_from = entry.id
      node_block_to   = entry.id
    }
  }
  vpc_leaf_profile_map = {
    for entry in local.vpc_ids : "SwProf_Node${entry.id1}-${entry.id2}" => {
      name                   = "SwProf_Node${entry.id1}-${entry.id2}"
      leaf_interface_profile = module.leaf_interface_profile.leaf_interface_profile["IntProf_Node${entry.id1}-${entry.id2}"]
      leaf_selector_name     = "SwSel_Node${entry.id1}-${entry.id2}"
      # switch_association_type = "range" # is already the default
      node_block_name = "bl${entry.id1}${entry.id2}" # internal value, should be moved to module, example "name": "bl110110",
      node_block_from = entry.id1
      node_block_to   = entry.id2
    }
  }
  access_and_vpc_leaf_profile_map = merge(local.access_leaf_profile_map, local.vpc_leaf_profile_map)
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
