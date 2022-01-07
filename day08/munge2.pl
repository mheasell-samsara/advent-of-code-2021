#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

my $sum = 0;
while (my $line = <>) {
    chomp $line;
    my ($signals, $outputs) = split(/ *\| */, $line, 2);
    my %digits_map = process_signals(map { make_mapping($_) } split(" ", $signals));

    my @norm_outputs = map { norm_string($_) } split(" ", $outputs);

    my $decoded_output = join("", map { $digits_map{$_} } @norm_outputs);
    print "Decoded: $decoded_output\n";

    $sum += $decoded_output;
}

print "sum: $sum\n";

sub make_mapping {
    my ($str) = @_;
    my %m = map { $_ => 1 } split(//, $str);
    return \%m;
}

sub make_string {
    my ($m) = @_;
    my $str = "";
    my @keys = sort { $a cmp $b } keys %$m;
    return join("", @keys);
}

sub norm_string {
    my ($str) = @_;
    my @letters = split(//, $str);
    @letters = sort { $a cmp $b } @letters;
    return join("", @letters);
}

sub process_signals {
    my (@signals_hashes) = @_;

    my $signal_digit_one;
    my $signal_digit_four;
    my $signal_digit_seven;
    my $signal_digit_eight;

    for my $signal (@signals_hashes) {
        my $len = scalar keys %$signal;
        if ($len == 2) {
            $signal_digit_one = $signal;
        }
        elsif ($len == 3) {
            $signal_digit_seven = $signal;
        }
        elsif ($len == 4) {
            $signal_digit_four = $signal;
        }
        elsif ($len == 7) {
            $signal_digit_eight = $signal;
        }
    }

    my %mappings;

    my $letter_for_a = (keys %{diff($signal_digit_seven, $signal_digit_one)})[0];
    $mappings{$letter_for_a} = "a";

    my ($letter_for_c, $letter_for_f) = (keys %$signal_digit_one);
    my $count = scalar (grep { $_->{$letter_for_c} } @signals_hashes);
    if ($count == 8) {
        # do nothing, already in correct order
    } elsif ($count == 9) {
        # swap them
        ($letter_for_c, $letter_for_f) = ($letter_for_f, $letter_for_c);
    }
    else {
        die "bad logic";
    }

    $mappings{$letter_for_c} = "c";
    $mappings{$letter_for_f} = "f";

    my $signal_digit_two = (grep { not $_->{$letter_for_f} } @signals_hashes)[0];

    my $signal_digit_six = (grep { (scalar keys %$_) == 6 && !$_->{$letter_for_c} } @signals_hashes)[0];

    my $signal_digit_three = (grep { (scalar keys %$_) == 5 && $_->{$letter_for_c} && $_->{$letter_for_f} } @signals_hashes)[0];

    my $letter_for_e = make_string(diff($signal_digit_two, $signal_digit_three));
    $mappings{$letter_for_e} = "e";

    my $signal_digit_five = diff($signal_digit_six, make_mapping($letter_for_e));

    my $signal_digit_zero = (grep {
            (scalar keys %$_) == 6
            && $_->{$letter_for_e}
            && !set_eq($_, $signal_digit_six)
        } @signals_hashes)[0];

    my $signal_digit_nine = diff($signal_digit_eight, make_mapping($letter_for_e));

    #print Dumper(\%mappings);
    #print "zero  @{[make_string($signal_digit_zero)]}\n";
    #print "one   @{[make_string($signal_digit_one)]}\n";
    #print "two   @{[make_string($signal_digit_two)]}\n";
    #print "three @{[make_string($signal_digit_three)]}\n";
    #print "four  @{[make_string($signal_digit_four)]}\n";
    #print "five: @{[make_string($signal_digit_five)]}\n";
    #print "six   @{[make_string($signal_digit_six)]}\n";
    #print "seven @{[make_string($signal_digit_seven)]}\n";
    #print "eight @{[make_string($signal_digit_eight)]}\n";
    #print "nine  @{[make_string($signal_digit_nine)]}\n";

    return (
        make_string($signal_digit_zero) => 0,
        make_string($signal_digit_one) => 1,
        make_string($signal_digit_two) => 2,
        make_string($signal_digit_three) => 3,
        make_string($signal_digit_four) => 4,
        make_string($signal_digit_five) => 5,
        make_string($signal_digit_six) => 6,
        make_string($signal_digit_seven) => 7,
        make_string($signal_digit_eight) => 8,
        make_string($signal_digit_nine) => 9,
    );

}

sub intersect {
    my ($a, $b) = @_;
    my %r;
    for my $k (keys %$a) {
        next if not $b->{$k};
        $r{$k} = 1;
    }
    return \%r;
}

sub union {
    my ($a, $b) = @_;
    my %r;
    for my $k (keys %$a) {
        $r{$k} = 1;
    }
    for my $k (keys %$b) {
        $r{$k} = 1;
    }
    return \%r;
}

sub diff {
    my ($a, $b) = @_;
    my %r;
    for my $k (keys %$a) {
        next if $b->{$k};
        $r{$k} = 1;
    }
    return \%r;
}

sub set_eq {
    my ($a, $b) = @_;
    return make_string($a) eq make_string($b);
}
