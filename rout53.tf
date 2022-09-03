resource "aws_route53_record" "redis-record" {
    # I'd need the zone details, which we have given in the vpc module, so we need to fetch the zone id from there. We are can read remote state from their outputs
  zone_id = data.terraform_remote_state.vpc.outputs.HOSTEDZONE_PRIVATE_ID
  name    = "redis-${var.ENV}.${data.terraform_remote_state.vpc.outputs.HOSTEDZONE_PRIVATE_ZONE}"
  type    = "CNAME"
  ttl     = 660
  records = [aws_elasticache_cluster.redis.cache_nodes[0].address]  # as the output gives in the list format
  depends_on = [aws_elasticache_cluster.redis]

}

output "redis" {
    value = aws_elasticache_cluster.redis
}







### Output structure of redis endpoint 
# [0mredis = {
#   "apply_immediately" = tobool(null)
#   "arn" = "arn:aws:elasticache:us-east-1:834725375088:cluster:roboshop-dev"
#   "auto_minor_version_upgrade" = "true"
#   "availability_zone" = "us-east-1a"
#   "az_mode" = "single-az"
#   "cache_nodes" = tolist([
#     {
#       "address" = "roboshop-dev.ij0ide.0001.use1.cache.amazonaws.com"
#       "availability_zone" = "us-east-1a"
#       "id" = "0001"
#       "port" = 6379
#     },
#   ])