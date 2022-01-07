#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
use List::Util qw(max min);

my $template_str = <>;
chomp $template_str;
my @template = split(//, $template_str);

<>;

my %rules;
while (my $line = <>) {
    chomp $line;
    $line =~ /^([A-Z][A-Z]) -> ([A-Z])$/ or die "invalid input on line $.\n";
    $rules{$1} = $2;
}

print Dumper(\%rules);

print "Initial state: ";
dd(\@template);

for my $s (1..10) {
    my @output;
    push(@output, $template[0]);
    for my $i (1..$#template) {
        my $prev = $template[$i-1];
        my $curr = $template[$i];
        my $insert = $rules{"$prev$curr"};
        if (defined $insert) {
            push(@output, $insert);
        }
        push(@output, $curr);
    }

    @template = @output;

    #print "After step $s: ";
    #dd(\@template);
}

my %freqs;
for my $c (@template) {
    $freqs{$c} += 1;
}

my $max_quant;
my $min_quant;

for my $c (keys %freqs) {
    my $val = $freqs{$c};
    $max_quant = defined($max_quant) ? max($val, $max_quant) : $val;
    $min_quant = defined($min_quant) ? min($val, $min_quant) : $val;
}

my $result = $max_quant - $min_quant;
print "result: $result\n";

sub dd {
    my ($a) = @_;
    print join("", @$a);
    print "\n";
}
