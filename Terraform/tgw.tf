# resource "aws_ec2_transit_gateway" "seoul_tgw" {
#   description = "Seoul region Transit Gateway"
#   amazon_side_asn = 65000
# }

# resource "aws_ec2_transit_gateway_vpc_attachment" "seoul_vpc_attachment" {
#   transit_gateway_id = aws_ec2_transit_gateway.seoul_tgw.id
#   vpc_id             = aws_vpc.vpc.id
#   subnet_ids         = [aws_subnet.subnet["rds1"].id, aws_subnet.subnet["rds2"].id]
#   transit_gateway_default_route_table_association = false
# }

# resource "aws_ec2_transit_gateway" "singapore_tgw" {
#   provider = aws.singapore
#   description = "Singapore Region Transit Gateway"
#   amazon_side_asn = 65000
# }

# resource "aws_ec2_transit_gateway_vpc_attachment" "singapore_vpc_attachment" {
#   provider = aws.singapore
#   transit_gateway_id = aws_ec2_transit_gateway.singapore_tgw.id
#   vpc_id             = aws_vpc.sin_vpc.id
#   subnet_ids         = [aws_subnet.sin_subnet["api1"].id]
#   transit_gateway_default_route_table_association = false
# }

# resource "aws_ec2_transit_gateway_peering_attachment" "seoul_to_singapore" {
#   transit_gateway_id        = aws_ec2_transit_gateway.seoul_tgw.id
#   peer_transit_gateway_id   = aws_ec2_transit_gateway.singapore_tgw.id
#   peer_region               = "ap-southeast-1"
#   peer_account_id           = data.aws_caller_identity.current.id
# }

# resource "aws_ec2_transit_gateway_peering_attachment_accepter" "accept_seoul_to_singapore" {
#   provider                     = aws.singapore
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.seoul_to_singapore.id
# }

# resource "aws_ec2_transit_gateway_route_table" "seoul_tgw_rt" {
#   transit_gateway_id = aws_ec2_transit_gateway.seoul_tgw.id
# }

# resource "aws_ec2_transit_gateway_route_table" "singapore_tgw_rt" {
#   provider = aws.singapore
#   transit_gateway_id = aws_ec2_transit_gateway.singapore_tgw.id
# }

# resource "aws_ec2_transit_gateway_route" "seoul_to_singapore_route" {
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.seoul_tgw_rt.id
#   destination_cidr_block         = "10.1.0.0/16"
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.seoul_to_singapore.id

#   depends_on = [
#     aws_ec2_transit_gateway_peering_attachment_accepter.accept_seoul_to_singapore
#   ]
# }

# resource "aws_ec2_transit_gateway_route" "singapore_to_seoul_route" {
#   provider = aws.singapore
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.singapore_tgw_rt.id
#   destination_cidr_block         = "10.0.0.0/16"
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.seoul_to_singapore.id

#   depends_on = [
#     aws_ec2_transit_gateway_peering_attachment_accepter.accept_seoul_to_singapore
#   ]
# }

# resource "aws_ec2_transit_gateway_route_table_association" "seoul_vpc_attach_to_rt" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.seoul_vpc_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.seoul_tgw_rt.id
# }

# resource "aws_ec2_transit_gateway_route_table_association" "singapore_vpc_attach_to_rt" {
#   provider = aws.singapore
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.singapore_vpc_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.singapore_tgw_rt.id
# }
