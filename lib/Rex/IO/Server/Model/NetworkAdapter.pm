#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   
package Rex::IO::Server::Model::NetworkAdapter;

use strict;
use warnings;

use base qw(DBIx::ORMapper::DM::DataSource::Table);

__PACKAGE__->attr(id => "Integer");
__PACKAGE__->attr(hardware_id => "Integer");
__PACKAGE__->attr(dev => "String");
__PACKAGE__->attr(proto => "String");
__PACKAGE__->attr(ip => "Integer");
__PACKAGE__->attr(netmask => "Integer");
__PACKAGE__->attr(broadcast => "Integer");
__PACKAGE__->attr(network => "Integer");
__PACKAGE__->attr(gateway => "Integer");

__PACKAGE__->table("network_adapter");
__PACKAGE__->primary_key("id");

__PACKAGE__->belongs_to("hardware", "Rex::IO::Server::Model::Hardware", "hardware_id");

1;