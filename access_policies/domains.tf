locals {
  domain_from_yaml = yamldecode(file("${local.cfg_dir}/domains.yaml"))
  domain = {
    for k, v in local.domain_from_yaml : k => {
      for domain_name, domain_value in v : domain_name => merge(domain_value,
        {
          name      = domain_name
          vlan_pool = module.vlan_pools.vlan_pool[domain_value.vlan_pool]
      })
    }
  }
}

#---------------------------------
#  Create Layer3/Physical Domains
#---------------------------------

module "domains" {
  depends_on      = [module.vlan_pools]
  source          = "../../terraform-aci-access/modules/domains"
  layer3_domain   = local.domain.layer3
  physical_domain = local.domain.physical
}

output "domains" {
  value = { for v in sort(keys(module.domains)) : v => module.domains[v] }
}
