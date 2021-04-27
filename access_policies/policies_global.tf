locals {
  aaep_from_yaml = yamldecode(file("${local.cfg_dir}/policies_global_aaep.yaml"))
  aaep_map = {
    for k, v in local.aaep_from_yaml : k => merge(v, { name = k })
  }
  # aaep_map = {
  #   for map_item in local.aaep_from_yaml : map_item.name => map_item
  # }
  #  aaep_map        = {
  #      AEP_INFRADC    = {
  #          domain_layer3   = [
  #              "L3D_INFRADC",
  #           ]
  #          domain_physical = [
  #              "PhysD_INFRADC",
  #           ]
  #          name            = "AEP_INFRADC"
  #       }
  #      AEP_NO_DOMAINS = {
  #          name = "AEP_NO_DOMAINS"
  #       }
  #      AEP_Shared     = {
  #          domain_layer3   = [
  #              "L3D_INFRADC",
  #              "L3D_KB",
  #           ]
  #          domain_physical = [
  #              "PhysD_EDGE",
  #           ]
  #          name            = "AEP_Shared"
  #       }
  #   }
  domain_helper = {
    for k, v in local.aaep_map : k => {
      domain = flatten([
        (contains(keys(v), "domain_physical") ? [for domain_name in v.domain_physical : module.domains.physical[domain_name]] : []),
        (contains(keys(v), "domain_layer3") ? [for domain_name in v.domain_layer3 : module.domains.layer3[domain_name]] : [])
      ])
    }
  }
  #  domain_helper   = {
  #      AEP_INFRADC    = {
  #          domain = [
  #              "uni/phys-PhysD_INFRADC",
  #              "uni/l3dom-L3D_INFRADC",
  #           ]
  #       }
  #      AEP_NO_DOMAINS = {
  #          domain = []
  #       }
  #      AEP_Shared     = {
  #          domain = [
  #              "uni/phys-PhysD_EDGE",
  #              "uni/l3dom-L3D_INFRADC",
  #              "uni/l3dom-L3D_KB",
  #           ]
  #       }
  #   }
  aaep = {
    for k, v in local.aaep_map : k => merge(local.aaep_map[k], local.domain_helper[k])
  }
  #  aaep            = {
  #      AEP_INFRADC    = {
  #          domain          = [
  #              "uni/phys-PhysD_INFRADC",
  #              "uni/l3dom-L3D_INFRADC",
  #           ]
  #          domain_layer3   = [
  #              "L3D_INFRADC",
  #           ]
  #          domain_physical = [
  #              "PhysD_INFRADC",
  #           ]
  #          name            = "AEP_INFRADC"
  #       }
  #      AEP_NO_DOMAINS = {
  #          domain = []
  #          name   = "AEP_NO_DOMAINS"
  #       }
  #      AEP_Shared     = {
  #          domain          = [
  #              "uni/phys-PhysD_EDGE",
  #              "uni/l3dom-L3D_INFRADC",
  #              "uni/l3dom-L3D_KB",
  #           ]
  #          domain_layer3   = [
  #              "L3D_INFRADC",
  #              "L3D_KB",
  #           ]
  #          domain_physical = [
  #              "PhysD_EDGE",
  #           ]
  #          name            = "AEP_Shared"
  #       }
  #   }
}


#=============================
#  Global Policies
#=============================

module "global_policies" {
  depends_on = [module.domains]
  source     = "../../terraform-aci-access/modules/policies_global"
  aaep       = local.aaep
}

output "global_policies" {
  value = { for v in sort(keys(module.global_policies)) : v => module.global_policies[v] }
}
