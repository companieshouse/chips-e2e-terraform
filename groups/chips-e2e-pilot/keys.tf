# ------------------------------------------------------------------------------
# SSH Key Pair
# ------------------------------------------------------------------------------

resource "aws_key_pair" "ec2_keypair" {
  key_name   = "chips_e2e_pilot"
  public_key = local.ec2_data["public-key"]
}
