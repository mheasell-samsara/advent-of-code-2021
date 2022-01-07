#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;

my $numbers_string = <>;
my @numbers = split(",", $numbers_string);

my @boards;

# read in the boards
while (!eof) {
    # skip blank line
    <>;
    my @board;
    for my $i (0..4) {
        my $line = <>;
        chomp $line;
        $line =~ s/^ +//;
        my @numbers = split(/ +/, $line);
        die "wrong row length" unless (scalar @numbers == 5);
        push(@board, @numbers);
    }
    push(@boards, \@board);
}

@boards = map { { board => $_, index => make_board_index($_) } } @boards;

#print Dumper(\@numbers, \@boards);


for my $number (@numbers) {
    print "number $number!\n";
    for my $i (0..$#boards) {
        my $board = $boards[$i];
        my $idx = $board->{index}{$number};
        next if not defined($idx);
        $board->{seen}{$idx} = 1;
        print "board $i, index $idx\n";

        if (is_winner($board, $idx)) {
            my $sum = sum_of_unmarked($board);
            my $score = $number * $sum;
            print "last number: $number, board $i, sum of unmarked: $sum, score: $score\n";
            exit;
        }
    }
}

print "no winning board found\n";


sub make_board_index {
    my ($board) = @_;

    my %index;
    for my $i (0..$#$board) {
        $index{$board->[$i]} = $i;
    }

    return \%index;
}

sub is_winner {
    my ($board, $idx) = @_;

    my $row = int($idx / 5);
    my $col = $idx % 5;

    return is_winning_row($board, $row) || is_winning_col($board, $col);
}

sub is_winning_row {
    my ($board, $row) = @_;
    my $start_idx = $row * 5;
    for my $i (0..4) {
        return 0 if not defined($board->{seen}{$start_idx + $i});
    }

    return 1;
}

sub is_winning_col {
    my ($board, $col) = @_;
    for my $i (0..4) {
        my $row_idx = $i * 5;
        return 0 if not defined($board->{seen}{$row_idx + $col});
    }

    return 1;
}


sub compute_score {
    my ($board, $number) = @_;
    return sum_of_unmarked($board) * $number;
}

sub sum_of_unmarked {
    my ($board) = @_;
    my $sum = 0;
    for my $i (0..24) {
        next if $board->{seen}{$i};
        $sum += $board->{board}[$i];
    }
    return $sum;
}
