#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;


my %score_table = (
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137,
);

my $total_score = 0;

while (my $line = <>) {
    chomp $line;
    my $result = parse_line($line);
    if ($result->{status} eq "corrupt") {
        my $score = $score_table{$result->{bad_char}};
        $total_score += $score;
    }
}

print "total score: $total_score\n";

sub parse_line {
    my ($line) = @_;

    my @stack;
    for my $c (split(//, $line)) {
        if ($c eq "[" || $c eq "(" || $c eq "{" || $c eq "<") {
            push(@stack, $c);
        }
        elsif ($c eq "]" || $c eq ")" || $c eq "}" || $c eq ">") {
            my $stack_item = pop(@stack);
            if (!is_matching($stack_item, $c)) {
                return { status => "corrupt", bad_char => $c };
            }
        }
        else {
            die "invalid char $c";
        }
    }

    if (scalar @stack > 0) {
        return { status => "incomplete" };
    }
    
    return { status => "valid" };
}

sub get_closing {
    my ($c) = @_;

    return ")" if $c eq "(";
    return "]" if $c eq "[";
    return ">" if $c eq "<";
    return "}" if $c eq "{";

    die "invalid input $c";
}

sub is_matching {
    my ($opening, $closing) = @_;

    my $expected_closing = get_closing($opening);
    return $closing eq $expected_closing;
}
