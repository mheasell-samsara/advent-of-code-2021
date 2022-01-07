#!/usr/bin/env perl

use warnings;
use strict;
use List::Util qw(min);

my $player1_str = <>;
chomp $player1_str;
my $player2_str = <>;
chomp $player2_str;

my $player1_pos = parse_start_pos($player1_str);
my $player2_pos = parse_start_pos($player2_str);

my $next_dice_num = 1;

my $number_of_dice_rolls = 0;

my $player1_score = 0;
my $player2_score = 0;

my $current_player = 1;

print "initial state: $player1_pos, $player2_pos\n";

while ($player1_score < 1000 && $player2_score < 1000) {
    my $sum = 0;
    $sum += roll_die();
    $sum += roll_die();
    $sum += roll_die();

    $number_of_dice_rolls += 3;

    if ($current_player == 1) {
        $player1_pos = add_to_pos($player1_pos, $sum);
        $player1_score += $player1_pos;
        print "Player 1 rolls $sum, moves to $player1_pos, total score $player1_score\n";
        $current_player = 2;
    } elsif ($current_player == 2) {
        $player2_pos = add_to_pos($player2_pos, $sum);
        $player2_score += $player2_pos;
        print "Player 2 rolls $sum, moves to $player2_pos, total score $player2_score\n";
        $current_player = 1;
    } else {
        die "invalid player $current_player";
    }
}

my $losing_player_score = min($player1_score, $player2_score);

my $result = $losing_player_score * $number_of_dice_rolls;

print "result: $result\n";

sub add_to_pos {
    my ($pos, $val) = @_;

    my $new_pos = $pos + $val;
    $new_pos -= 10 while $new_pos > 10;
    return $new_pos;
}

sub roll_die {
    my $val = $next_dice_num;
    $next_dice_num += 1;
    $next_dice_num = 1 if $next_dice_num == 101;
    return $val;
}


sub parse_start_pos {
    my ($str) = @_;
    $str =~ /^Player \d starting position: (\d+)$/ or die "invalid input";
    return $1;
}
