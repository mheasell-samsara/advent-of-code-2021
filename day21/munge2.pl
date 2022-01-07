#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;
use List::Util qw(max);

my %die_freq_table;
for my $i (1..3) {
    for my $j (1..3) {
        for my $k (1..3) {
            $die_freq_table{$i+$j+$k} += 1;
        }
    }
}

#print Dumper(\%die_freq_table);

my $score_needed_to_win = 21;

my %win_universes_cache;

my $player1_str = <>;
chomp $player1_str;
my $player2_str = <>;
chomp $player2_str;

my $player1_pos = parse_start_pos($player1_str);
my $player2_pos = parse_start_pos($player2_str);

my $initial_state = {
    player1_pos => $player1_pos,
    player1_score => 0,

    player2_pos => $player2_pos,
    player2_score => 0,

    current_player => 1,
};

print "initial state: $player1_pos, $player2_pos\n";

my ($player1_wins, $player2_wins) = count_winning_universes($initial_state);

print "$player1_wins, $player2_wins\n";
my $result = max($player1_wins, $player2_wins);
print "result: $result\n";

sub count_winning_universes {
    my ($state) = @_;
    my $cache_key = state_to_str($state);
    my $cache_result = $win_universes_cache{$cache_key};
    if (defined $cache_result) {
        return @$cache_result;
    }

    my $won_player = player_has_won($state);
    if ($won_player == 1) {
        $win_universes_cache{$cache_key} = [1, 0];
        return (1, 0);
    }
    if ($won_player == 2) {
        $win_universes_cache{$cache_key} = [0, 1];
        return (0, 1);
    }

    my $total_player1_wins = 0;
    my $total_player2_wins = 0;

    my @next_states = compute_all_next_states($state);
    for my $next (@next_states) {
        my ($next_state, $freq) = @$next;
        my ($player1_wins, $player2_wins) = count_winning_universes($next_state);
        $total_player1_wins += $player1_wins * $freq;
        $total_player2_wins += $player2_wins * $freq;
    }

    $win_universes_cache{$cache_key} = [$total_player1_wins, $total_player2_wins];
    return ($total_player1_wins, $total_player2_wins);
}

sub player_has_won {
    my ($state) = @_;
    if ($state->{player1_score} >= $score_needed_to_win) {
        return 1;
    }

    if ($state->{player2_score} >= $score_needed_to_win) {
        return 2;
    }

    return 0;
}

sub compute_all_next_states {
    my ($state) = @_;
    my @next_states;
    for my $i (3..9) {
        push(@next_states, [compute_next_state($state, $i), $die_freq_table{$i}]);
    }
    return @next_states;
}

sub compute_next_state {
    my ($state, $dice_result) = @_;

    my %new_state = %$state;
    if ($state->{current_player} == 1) {
        $new_state{player1_pos} = add_to_pos($state->{player1_pos}, $dice_result);
        $new_state{player1_score} = $state->{player1_score} + $new_state{player1_pos};
        $new_state{current_player} = 2;
    } elsif ($state->{current_player} == 2) {
        $new_state{player2_pos} = add_to_pos($state->{player2_pos}, $dice_result);
        $new_state{player2_score} = $state->{player2_score} + $new_state{player2_pos};
        $new_state{current_player} = 1;
    } else {
        die "invalid player";
    }

    return \%new_state;
}

sub state_to_str {
    my ($state) = @_;
    my $player1_pos = $state->{player1_pos};
    my $player1_score = $state->{player1_score};

    my $player2_pos = $state->{player2_pos};
    my $player2_score = $state->{player2_score};

    my $current_player = $state->{current_player};

    return "$player1_pos,$player1_score,$player2_pos,$player2_score,$current_player";
}

sub add_to_pos {
    my ($pos, $val) = @_;

    my $new_pos = $pos + $val;
    $new_pos -= 10 while $new_pos > 10;
    return $new_pos;
}

sub parse_start_pos {
    my ($str) = @_;
    $str =~ /^Player \d starting position: (\d+)$/ or die "invalid input";
    return $1;
}
