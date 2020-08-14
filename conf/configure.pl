#!/usr/bin/perl
use strict;
use warnings;
use File::Slurp;
use File::Spec::Functions;

my $path = '/home/www/conf/wge';
opendir my $dir, $path or die "Cannot open conf directory: $!";
my @templates = grep { /[.]tpl$/ } readdir $dir;
closedir $dir;
my @vars = qw/WGE_SERVER_EMAIL WGE_APACHE_PORT WGE_FCGI_PORT
WGE_DB_DSN WGE_DB_USER WGE_DB_PASS WGE_API_TRANSPORT WGE_OAUTH/;

foreach my $template ( @templates ) {
    my $contents = read_file(catfile($path, $template));
    foreach my $var ( @vars ) {
        die "Environment variable $var not set" if not exists $ENV{$var};
        $contents =~ s/#$var/$ENV{$var}/g;
    }
    my $conf = $template =~ s/[.]tpl$//gr;
    write_file(catfile($path, $conf), $contents);
    unlink catfile($path, $template);
}

