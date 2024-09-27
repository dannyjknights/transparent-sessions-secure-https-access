output "boundary_ingress_worker_public_ip" {
  value = aws_instance.boundary_ingress_worker.public_ip
}