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


my @queue = ({v => "start", visited => {}, second_small => 0});

my $path_count = 0;

while (scalar @queue) {
    #print Dumper(\@queue);
    my $vertex = shift @queue;
    my $val = $vertex->{v};
    my %visited = %{$vertex->{visited}};
    my $second_small = $vertex->{second_small};

    if ($val eq "end") {
        $path_count += 1;
        next;
    }

    # mark small cave as visited
    elsif ($val =~ /^[a-z]+$/) {
        if ($visited{$val}) {
            $second_small = 1;
        }
        else {
            $visited{$val} = 1;
        }
    }

    # explore neighbours
    for my $v (@{$adjacency_map{$val}}) {
        next if $v eq "start";
        next if $visited{$v} && $second_small == 1;
        push(@queue, {v => $v, visited => \%visited, second_small => $second_small});
    }

}

print Dumper(\%adjacency_map);

print "path count: $path_count\n";
