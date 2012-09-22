#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   
package Rex::IO::Server::MessageBroker;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use Mojo::JSON;
use Mojo::UserAgent;

my $clients = {};

sub broker {
   my ($self) = @_;

   warn "client connected: ". $self->tx->remote_address . "\n";

   push(@{ $clients->{$self->tx->remote_address} }, { tx => $self->tx, tx_id => sprintf("%s", $self->tx) });

   Mojo::IOLoop->stream($self->tx->connection)->timeout(300);

   $self->send("Welcome to the real world.");

   $self->on(finish => sub {
      warn "client disconnected\n";
      my $new_clients = {};

      for (keys %$clients) {
         $new_clients->{$_} = [ grep { $_->{tx_id} ne sprintf("%s", $self->tx) } @{ $clients->{$_} } ];
      }

      $clients = $new_clients;
   });

   $self->on(message => sub {
      my ($tx, $message) = @_;

      my $json = Mojo::JSON->decode($message);

      if($json->{type} eq "broadcast") {
         for (keys %$clients) {
            map { $_->{tx}->send($json->{message}); } @{ $clients->{$_} };
         }
      }

      elsif($json->{type} eq "hello") {
         map { $_->{info} = $json->{info} } @{ $clients->{$self->tx->remote_address} };
      }

   });
}

sub clients {
   my ($self) = @_;
   $self->render_json($clients);
}

sub message_to_server {
   my ($self) = @_;

   my $json = $self->req->json;
   my ($to) = ($self->req->url =~ m/^.*\/(.*?)$/);

   map { $_->{tx}->send(Mojo::JSON->encode($json->{message})) } @{ $clients->{$to} };

   $self->render_json({ok => Mojo::JSON->true});
}

1;
