locals {
  # vpc_ids2  = yamldecode(file("${path.module}/yaml/leaf_vpc_ids2.yaml"))
  # "vpc_ids" was already defined at leaf_intprof.tf
  vpc_domains = {
    for entry in local.vpc_ids : "vPC_${entry.id1}-${entry.id2}" => {
      name          = "vPC_${entry.id1}-${entry.id2}"
      node1_id      = entry.id1
      node2_id      = entry.id2
      vpc_domain_id = entry.id1
    }
  }
}

#------------------------------------------
#  Create Explicit VPC Protection Group(s)
#------------------------------------------

module "vpc_domains" {
  source      = "../../terraform-aci-access/modules/vpc_domains"
  vpc_domains = local.vpc_domains
}
