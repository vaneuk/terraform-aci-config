# Deploy and manage ACI using Terraform
## Usage:
Uses modules defined in https://github.com/scotttyso/terraform-aci-access/.
Clone both repos to the same directory:
```
git clone https://github.com/scotttyso/terraform-aci-access.git
git clone https://github.com/vaneuk/terraform-aci-config.git
```
So it looks like this
```
$ tree -d -L 1
.
├── terraform-aci-access
└── terraform-aci-config
```

Book the ACI Simulator on Cisco Dcloud: https://dcloud2-lon.cisco.com/content/demo/430447?returnPathTitleKey=content-view

Proceed to the access-policies directory and try the terraform. The fabric_dcloud.tfvars specifies the url, pass and config directory for Dcloud example.
```
terraform init
terraform plan -var-file=fabric_dcloud.tfvars
```