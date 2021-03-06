########################################################################
# AwsVpcDhcpOptionsAssociation is the +aws_vpc_dhcp_options_association+ terrform resource,
#
# {https://www.terraform.io/docs/providers/aws/r/vpc_dhcp_options_association.html Terraform Docs}
########################################################################
class GeoEngineer::Resources::AwsVpcDhcpOptionsAssociation < GeoEngineer::Resource
  validate -> { validate_required_attributes([:dhcp_options_id, :vpc_id]) }

  after :initialize, -> {
    _terraform_id -> { "#{dhcp_options_id}-#{vpc_id}" }
  }

  def to_terraform_state
    tfstate = super
    tfstate[:primary][:attributes] = {
      'vpc_id' => vpc_id,
      'dhcp_options_id' => dhcp_options_id
    }
    tfstate
  end

  def support_tags?
    false
  end

  def self._fetch_remote_resources(provider)
    AwsClients
      .ec2(provider)
      .describe_vpcs['vpcs']
      .map(&:to_h)
      .select { |vpc| vpc[:dhcp_options_id] }
      .map do |vpc|
        {
          vpc_id: vpc[:vpc_id],
          dhcp_options_id: vpc[:dhcp_options_id],
          _terraform_id: "#{vpc[:dhcp_options_id]}-#{vpc[:vpc_id]}"
        }
      end
  end
end
