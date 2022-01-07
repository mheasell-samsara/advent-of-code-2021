#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

my %adjacency_map;

while (my $line = <>) {
    chomp $line;
    my ($a, $b) = split(/-/, $line, 2);

    push(@{$adjacency_map{$a}}, $b);
    push(@{$adjacency_map{$b}}, $a);
}


my @queue = ({v => "start", visited => {}});

my $path_count = 0;

while (scalar @queue) {
    #print Dumper(\@queue);
    my $vertex = shift @queue;
    my $val = $vertex->{v};
    my %visited = %{$vertex->{visited}};

    if ($val eq "end") {
        $path_count += 1;
        next;
    }

    # mark small cave as visited
    if ($val =~ /^[a-z]+$/) {
        $visited{$val} = 1;
    }

    # explore neighbours
    for my $v (@{$adjacency_map{$val}}) {
        next if $visited{$v};
        push(@queue, {v => $v, visited => \%visited});
    }

}

print Dumper(\%adjacency_map);

print "path count: $path_count\n";
