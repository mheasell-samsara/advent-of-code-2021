#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

my %autocomplete_score_table = (
    ")" => 1,
    "]" => 2,
    "}" => 3,
    ">" => 4,
);

my @scores;

while (my $line = <>) {
    chomp $line;
    my $result = parse_line($line);
    if ($result->{status} eq "incomplete") {
        my $score = score_stack($result->{stack});
        print "score: $score\n";
        push(@scores, $score);
    }
}


@scores = sort { $a <=> $b } @scores;

# there will always be an odd number of scores
# so we can hackily compute middle index.
my $middle_idx = ((scalar @scores) - 1) / 2;
my $middle_score = $scores[$middle_idx];

print "middle scores: $middle_score\n";



sub score_stack {
    my ($stack) = @_;

    my $score = 0;
    for (my $i = $#$stack; $i >= 0; --$i) {
        my $c = $stack->[$i];
        $score *= 5;
        my $table_lookup = $autocomplete_score_table{get_closing($c)};
        $score += $table_lookup;
    }

    return $score;

}

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
        return { status => "incomplete", stack => \@stack };
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
