# holden:ignore:HLD_TF_065: wraps one data source but adds real logic (a
# lifecycle postcondition validating the response is a well-formed IPv4
# with a 200 status, plus computing the /32 CIDR) - not a bare pass-through
module "ip" {
  source = "git::https://github.com/JamesWoolfenden/terraform-http-ip.git?ref=e33037668bc4cf5c25f8962c7e8085df4b61623c" #v0.4.0
}
