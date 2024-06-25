# ------------------------------------------------------------------------------
# SSH Key Pair
# ------------------------------------------------------------------------------

resource "aws_key_pair" "ec2_keypair" {
  key_name   = "end_to_end_pilot"
  public_key = local.ec2_data["public-key"]
}
