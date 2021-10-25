provider "aws" {
    region = "us-east-2"
}

module "webmodule" {
  source = "./web"
}

module "dbmodule" {
  source = "./db"
}

output "PrivateIP" {
  value = module.dbmodule.PrivateIP
  }

output "PublicIP" {
  value = module.webmodule.pub_ip
}