#!/usr/bin/env perl

use warnings;
use strict;
use List::Util qw(min max);
use Data::Dumper;

my @region_states;

while (my $line = <>) {
    chomp $line;
    $line =~ /^(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)$/ or die "invalid input on line $.\n";
    my ($state_str, $x1, $x2, $y1, $y2, $z1, $z2) = ($1, $2, $3, $4, $5, $6, $7);

    my $state = $state_str eq "on" ? 1 : 0;
    die unless $x1 <= $x2;
    die unless $y1 <= $y2;
    die unless $z1 <= $z2;
    my $region = {x1=>$x1, x2=>$x2, y1=>$y1, y2=>$y2, z1=>$z1, z2=>$z2};
    my @new_region_states;
    for my $existing_region_state (@region_states) {
        if ($existing_region_state->{state} == 1) {
            my $anti_region = region_intersection($region, $existing_region_state->{region});
            push(@new_region_states, {state=>0, region=>$anti_region}) if defined $anti_region;
        }
        else {
            my $anti_anti_region = region_intersection($region, $existing_region_state->{region});
            push(@new_region_states, {state=>1, region=>$anti_anti_region}) if defined $anti_anti_region;
        }
    }
    if ($state == 1) {
        push(@new_region_states, {state=>1,region=>$region});
    }

    push(@region_states, @new_region_states);
}

my $total_volume = 0;
for my $rs (@region_states) {
    my $s = $rs->{state};
    my $volume = region_volume($rs->{region});
    $total_volume += ($rs->{state} ? 1 : -1) * $volume;
    #print "$s, " . region_to_str($rs->{region}) . " (volume $volume) (total on $total_volume)\n";
}

print "total on volume: $total_volume\n";

sub region_volume {
    my ($region) = @_;
    my $dx = 1 + $region->{x2} - $region->{x1};
    my $dy = 1 + $region->{y2} - $region->{y1};
    my $dz = 1 + $region->{z2} - $region->{z1};
    return $dx * $dy * $dz;
}

sub region_to_str {
    my ($region) = @_;
    my $x1 = $region->{x1};
    my $x2 = $region->{x2};
    my $y1 = $region->{y1};
    my $y2 = $region->{y2};
    my $z1 = $region->{z1};
    my $z2 = $region->{z2};

    return "x=$x1..$x2,y=$y1..$y2,z=$z1..$z2";
}

sub region_intersection {
    my ($a, $b) = @_;

    return undef if $a->{x2} < $b->{x1};
    return undef if $a->{x1} > $b->{x2};

    return undef if $a->{y2} < $b->{y1};
    return undef if $a->{y1} > $b->{y2};

    return undef if $a->{z2} < $b->{z1};
    return undef if $a->{z1} > $b->{z2};

    my $x1 = max($a->{x1}, $b->{x1});
    my $x2 = min($a->{x2}, $b->{x2});

    my $y1 = max($a->{y1}, $b->{y1});
    my $y2 = min($a->{y2}, $b->{y2});

    my $z1 = max($a->{z1}, $b->{z1});
    my $z2 = min($a->{z2}, $b->{z2});

    return {x1=>$x1,x2=>$x2,y1=>$y1,y2=>$y2,z1=>$z1,z2=>$z2};
}
