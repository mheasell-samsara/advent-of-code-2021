#!/usr/bin/env perl

use warnings;
use strict;
use List::Util qw(sum);
use Data::Dumper;

my $lookup_str = <>;
chomp $lookup_str;

my @lookup = map { $_ eq "#" ? 1 : 0 } split(//, $lookup_str);

<>;

my $global_img = { width => undef, img => [], background => 0 };
while (my $line = <>) {
    chomp $line;
    $global_img->{width} = length $line if not defined $global_img->{width};
    push(@{$global_img->{img}}, map { $_ eq "#" ? 1 : 0 } split(//, $line));
}

img_print($global_img);
print "\n";

for my $i (1..50) {
    $global_img = enhance_image($global_img);
}

img_print($global_img);
print "\n";

my $count = img_count_lit($global_img);

print "\n";
print "lit pixels: $count\n";

#print Dumper($global_img);

sub img_count_lit {
    my ($img) = @_;
    if ($img->{background}) {
        die "infinite pixels lit\n";
    }
    my $sum = 0;
    for my $i (@{$img->{img}}) {
        $sum += $i ? 1 : 0;
    }
    return $sum;
}

sub enhance_image {
    my ($img) = @_;

    my ($width, $height) = img_get_size($img);

    my $out_width = $width+2;
    my $out_height = $height+2;
    my $new_background = $img->{background} ? $lookup[511] : $lookup[0];
    my $out_img = img_create($out_width, $out_height, $new_background);

    for my $y (0..$out_height-1) {
        for my $x (0..$out_width-1) {
            my $val = img_read_3x3($img, $x-1, $y-1);
            my $new_val = $lookup[$val];
            img_set($out_img, $x, $y, $new_val);
        }
    }

    return $out_img;
}

sub img_read_3x3 {
    my ($img, $x, $y) = @_;
    my $num = 0;
    for my $dy ($y-1..$y+1) {
        for my $dx ($x-1..$x+1) {
            $num = ($num << 1) | img_get($img, $dx, $dy);
        }
    }
    return $num;
}

sub img_get {
    my ($img, $x, $y) = @_;
    my ($width, $height) = img_get_size($img);
    return $img->{background} if $x < 0 or $x >= $width;
    return $img->{background} if $y < 0 or $y >= $height;
    my $idx = ($y * $width) + $x;
    return $img->{img}[$idx];
}

sub img_set {
    my ($img, $x, $y, $val) = @_;
    my ($width, $height) = img_get_size($img);
    die "out of range" if $x < 0 or $x >= $width;
    die "out of range" if $y < 0 or $y >= $height;
    my $idx = ($y * $width) + $x;
    $img->{img}[$idx] = $val;
}

sub img_create {
    my ($width, $height, $background) = @_;
    return { img => [(0)x($width*$height)], width => $width, background => $background };
}

sub img_get_size {
    my ($img) = @_;
    my $width = $img->{width};
    my $height = (scalar @{$img->{img}}) / $img->{width};
    return ($width, $height);
}

sub img_print {
    my ($img) = @_;
    my ($width, $height) = img_get_size($img);
    my $bg = $img->{background};
    print "width $width, height $height, background: $bg\n";
    for my $y (0..$height-1) {
        for my $x (0..$width-1) {
            print img_get($img, $x, $y) ? "#" : ".";
        }
        print "\n";
    }
}
