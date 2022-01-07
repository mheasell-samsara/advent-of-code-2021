#!/usr/bin/env perl

use warnings;
use strict;

my $count = 0;

while (my $line = <>) {
    chomp $line;
    my ($signals, $outputs) = split(/ *\| */, $line, 2);

    for my $output (split(" ", $outputs)) {
        my $len = length $output;
        if ($len == 2 || $len == 3 || $len == 4 || $len == 7) {
            $count += 1;
        }
    }
}

print "count: $count\n";

