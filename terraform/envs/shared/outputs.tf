output "shared_vpc_id" {
  value = module.vpc.network_id
}

output "shared_service_account_email" {
  value = module.iam_shared_vm.service_account_email
}