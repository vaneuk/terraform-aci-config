#
locals {
  # load ids from yaml
  leaf_ids    = yamldecode(file("${local.cfg_dir}/leaf_ids.yaml"))
  vpc_ids     = yamldecode(file("${local.cfg_dir}/leaf_vpc_ids.yaml"))
  access_ipgs = yamldecode(file("${local.cfg_dir}/leaf_ipg_access_to_leaf_intprof.yaml"))
  vpc_ipgs    = yamldecode(file("${local.cfg_dir}/leaf_ipg_vpc_to_leaf_intprof.yaml"))

  access_interface_profile_map = {
    for entry in local.leaf_ids : "IntProf_Node${entry.id}" => {
      name = "IntProf_Node${entry.id}"
    }
  }
  vpc_interface_profile_map = {
    for entry in local.vpc_ids : "IntProf_Node${entry.id1}-${entry.id2}" => {
      name = "IntProf_Node${entry.id1}-${entry.id2}"
    }
  }
  access_and_vpc_interface_profile_map = merge(local.access_interface_profile_map, local.vpc_interface_profile_map)
  # Example output:
  # = {
  #     + IntProf_Node101     = {
  #         + name = "IntProf_Node101"
  #       }
  #     + IntProf_Node101-102 = {
  #         + name = "IntProf_Node101-102"
  #       }
  #     + IntProf_Node102     = {
  #         + name = "IntProf_Node102"
  #       }
  #     + IntProf_Node103     = {
  #         + name = "IntProf_Node103"
  #       }
  #     + IntProf_Node103-104 = {
  #         + name = "IntProf_Node103-104"
  #       }
  #     + IntProf_Node104     = {
  #         + name = "IntProf_Node104"
  #       }
  #   }


  access_ipgs_flatten = flatten([
    for leaf_id, objs in local.access_ipgs : [
      for obj in objs : merge(obj, { interface_profile_id = leaf_id })
    ]
  ])
  vpc_ipgs_flatten = flatten([
    for vpc_id, objs in local.vpc_ipgs : [
      for obj in objs : merge(obj, { interface_profile_id = vpc_id })
    ]
  ])
  # Example output:
  # = [
  # + {
  #     + interface_profile_id = "101"
  #     + ipg                  = "IPG_AP_INFRADC_1G"
  #     + port_from            = 1
  #   },
  # + {
  #     + interface_profile_id = "101"
  #     + ipg                  = "IPG_AP_INFRADC_1G"
  #     + port_from            = 2
  #     + port_to              = 2
  #   },
  # + {
  #     + description          = "foo"
  #     + interface_profile_id = "102"
  #     + ipg                  = "IPG_AP_INFRADC_1G"
  #     + port_from            = 1
  #     + port_to              = 1
  #   },
  # + {
  #     + interface_profile_id = "102"
  #     + ipg                  = "IPG_AP_INFRADC_1G"
  #     + port_from            = 2
  #     + port_to              = 2
  #   },
  #     + interface_profile_id = "101-102"
  #     + ipg                  = "IPG_VPC_INFRADC_1G"
  #     + port_from            = 4
  #     + port_to              = 4
  #   }
  # ]
  access_interface_selectors_map = {
    for obj in local.access_ipgs_flatten : "IntProf${obj.interface_profile_id}_IntSel_1-${obj.port_from}" => merge(obj,
      {
        name         = "IntSel_1-${obj.port_from}"
        leaf_profile = module.leaf_interface_profile.leaf_interface_profile["IntProf_Node${obj.interface_profile_id}"]
        policy_group = module.leaf_interface_policy_groups.access[obj.ipg]
    })
  }
  vpc_interface_selectors_map = {
    for obj in local.vpc_ipgs_flatten : "IntProf${obj.interface_profile_id}_IntSel_1-${obj.port_from}" => merge(obj,
      {
        name         = "IntSel_1-${obj.port_from}"
        leaf_profile = module.leaf_interface_profile.leaf_interface_profile["IntProf_Node${obj.interface_profile_id}"]
        policy_group = module.leaf_interface_policy_groups.bundle[obj.ipg]
    })
  }
  access_and_vpc_interface_selectors_map = merge(local.access_interface_selectors_map, local.vpc_interface_selectors_map)
  # Example output:
  #  = {
  #   + IntProf101-102_IntSel_1-3 = {
  #       + interface_profile_id = "101-102"
  #       + ipg                  = "IPG_AP_INFRADC_1G"
  #       + leaf_profile         = (known after apply)
  #       + name                 = "IntSel_1-3"
  #       + policy_group         = "uni/infra/funcprof/accportgrp-IPG_AP_INFRADC_1G"
  #       + port_from            = 3
  #       + port_to              = 3
  #     }
  #   + IntProf101-102_IntSel_1-4 = {
  #       + description          = "bar"
  #       + interface_profile_id = "101-102"
  #       + ipg                  = "IPG_AP_INFRADC_1G"
  #       + leaf_profile         = (known after apply)
  #       + name                 = "IntSel_1-4"
  #       + policy_group         = "uni/infra/funcprof/accportgrp-IPG_AP_INFRADC_1G"
  #       + port_from            = 4
  #       + port_to              = 5
  #     }
  #   + IntProf101_IntSel_1-1     = {
  #       + interface_profile_id = "101"
  #       + ipg                  = "IPG_AP_INFRADC_1G"
  #       + leaf_profile         = "uni/infra/accportprof-IntProf_Node101"
  #       + name                 = "IntSel_1-1"
  #       + policy_group         = "uni/infra/funcprof/accportgrp-IPG_AP_INFRADC_1G"
  #       + port_from            = 1
  #     }
  #   + IntProf101_IntSel_1-2     = {
  #       + interface_profile_id = "101"
  #       + ipg                  = "IPG_AP_INFRADC_1G"
  #       + leaf_profile         = "uni/infra/accportprof-IntProf_Node101"
  #       + name                 = "IntSel_1-2"
  #       + policy_group         = "uni/infra/funcprof/accportgrp-IPG_AP_INFRADC_1G"
  #       + port_from            = 2
  #       + port_to              = 2
  #     }
  #   + IntProf102_IntSel_1-1     = {
  #       + description          = "foo"
  #       + interface_profile_id = "102"
  #       + ipg                  = "IPG_AP_INFRADC_1G"
  #       + leaf_profile         = (known after apply)
  #       + name                 = "IntSel_1-1"
  #       + policy_group         = "uni/infra/funcprof/accportgrp-IPG_AP_INFRADC_1G"
  #       + port_from            = 1
  #       + port_to              = 1
  #     }
  #   + IntProf102_IntSel_1-2     = {
  #       + interface_profile_id = "102"
  #       + ipg                  = "IPG_AP_INFRADC_1G"
  #       + leaf_profile         = (known after apply)
  #       + name                 = "IntSel_1-2"
  #       + policy_group         = "uni/infra/funcprof/accportgrp-IPG_AP_INFRADC_1G"
  #       + port_from            = 2
  #       + port_to              = 2
  #     }
  # }
  access_interface_block_selectors_map = {
    for obj in local.access_ipgs_flatten : "IntProf${obj.interface_profile_id}_IntSel_1-${obj.port_from}" => merge(obj,
      {
        # name = "IntSel_1-${obj.port_from}"
        # name               = "block2" # internal value, should be moved to module. static: "name": "block2",
        description        = contains(keys(obj), "interface_description") ? obj.interface_description : null
        interface_selector = module.leaf_interface_selectors.leaf_interface_selectors["IntProf${obj.interface_profile_id}_IntSel_1-${obj.port_from}"]
    })
  }
  vpc_interface_block_selectors_map = {
    for obj in local.vpc_ipgs_flatten : "IntProf${obj.interface_profile_id}_IntSel_1-${obj.port_from}" => merge(obj,
      {
        # name = "IntSel_1-${obj.port_from}"
        # name               = "block2" # internal value, should be moved to module. static: "name": "block2",
        description        = contains(keys(obj), "interface_description") ? obj.interface_description : null
        interface_selector = module.leaf_interface_selectors.leaf_interface_selectors["IntProf${obj.interface_profile_id}_IntSel_1-${obj.port_from}"]
    })
  }
  access_and_vpc_interface_block_selectors_map = merge(local.access_interface_block_selectors_map, local.vpc_interface_block_selectors_map)
}


/*
Leaf Interface Profile

GUI Location:
 - Fabric > Access Policies > Interfaces > Leaf Interfaces > Profiles > {name}
*/

module "leaf_interface_profile" {
  source                 = "../../terraform-aci-access/modules/leaf_interface_profile"
  leaf_interface_profile = local.access_and_vpc_interface_profile_map
}

output "leaf_interface_profile" {
  value = { for v in sort(keys(module.leaf_interface_profile)) : v => module.leaf_interface_profile[v] }
}


/*
Leaf Interface Selector

GUI Location:
- Fabric > Access Policies > Interfaces > Leaf Interfaces > Profiles > {name}:{interface_selector}
*/

module "leaf_interface_selectors" {
  source                   = "../../terraform-aci-access/modules/leaf_interface_selectors"
  depends_on               = [module.leaf_interface_policy_groups, module.leaf_interface_profile]
  leaf_interface_selectors = local.access_and_vpc_interface_selectors_map
}

output "leaf_interface_selectors" {
  value = { for v in sort(keys(module.leaf_interface_selectors)) : v => module.leaf_interface_selectors[v] }
}


/*
Leaf Interface Selector Block

GUI Location:
- Fabric > Access Policies > Interfaces > Leaf Interfaces > Profiles > {name}:{interface_selector} > Port Block
*/

module "interface_blocks" {
  source     = "../../terraform-aci-access/modules/leaf_interface_selectors_block"
  depends_on = [module.leaf_interface_selectors]
  port_block = local.access_and_vpc_interface_block_selectors_map
}
