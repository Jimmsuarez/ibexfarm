package IbexFarm::Controller::Experiment;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use File::Spec::Functions qw( catfile );

sub manage :Absolute {
    my ($self, $c, $experiment) = (shift, shift, shift);
    return $c->res->redirect($c->uri_for('/login')) unless $c->user_exists;
    return $c->res->redirect($c->uri_for('/myaccount')) unless $experiment;
    $c->detach('Root', 'default') if scalar(@_);

    # Open USER file to get saved values for git repo/branch.
    open my $uf, catfile(IbexFarm->config->{deployment_dir}, $c->user->username, IbexFarm->config->{USER_FILE_NAME}) or
        die "Unable to open '", IbexFarm->config->{USER_FILE_NAME}, "' file for reading: $!";
    local $/;
    my $contents = <$uf>;
    defined $contents or die "Error reading '", IbexFarm->config->{USER_FILE_NAME}, "' file: $!";
    close $uf or die "Error closing '", IbexFarm->config->{USER_FILE_NAME}, "' file: $!";
    my $json = JSON::XS::decode_json($contents) or die "Error decoding JSON";

    # So that other pages can point back to this one.
    $c->flash->{back_uri} = $c->uri_for('/manage/' . $experiment);
    $c->flash->{experiment_name} = $experiment;

    $c->stash->{experiment_base_url} = IbexFarm->config->{experiment_base_url};
    $c->stash->{experiment} = $experiment;
    $c->stash->{git_repo_url} = $json->{git_repo_url};
    $c->stash->{git_repo_branch} = $json->{git_repo_branch};
    $c->stash->{template} = "manage.tt";
}

1;
