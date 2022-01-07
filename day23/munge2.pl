#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

my %movement_costs = (
    "A" => 1,
    "B" => 10,
    "C" => 100,
    "D" => 1000,
);

my %edges = (
    left_hallway_2 => [["left_hallway_1", 1]],
    left_hallway_1 => [["room1_1", 2], ["slot1", 2]],
    room1_1 => [["room1_2", 1], ["slot1", 2]],
    room1_2 => [["room1_3", 1]],
    room1_3 => [["room1_4", 1]],
    slot1 => [["room2_1", 2], ["slot2", 2]],
    room2_1 => [["room2_2", 1], ["slot2", 2]],
    room2_2 => [["room2_3", 1]],
    room2_3 => [["room2_4", 1]],
    slot2 => [["room3_1", 2], ["slot3", 2]],
    room3_1 => [["room3_2", 1], ["slot3", 2]],
    room3_2 => [["room3_3", 1]],
    room3_3 => [["room3_4", 1]],
    slot3 => [["room4_1", 2], ["right_hallway_1", 2]],
    room4_1 => [["room4_2", 1], ["right_hallway_1", 2]],
    room4_2 => [["room4_3", 1]],
    room4_3 => [["room4_4", 1]],
    right_hallway_1 => [["right_hallway_2", 1]],
);

my %full_edges;
for my $k (keys %edges) {
    for my $e (@{$edges{$k}}) {
        push(@{$full_edges{$k}}, $e);
        my ($k2, $weight) = @$e;
        push(@{$full_edges{$k2}}, [$k, $weight]);
    }
}
#print Dumper(\%full_edges);

# state list from the example solution.
# Some intermediate states added by me
# because my code doesn't support direct
# room -> room transitions.
my @example_state_path = (
    "__,ADDB,_,DBCC,_,CABB,_,ACAD,__",
    "__,ADDB,_,DBCC,_,CABB,_,ACA_,_D",
    "A_,ADDB,_,DBCC,_,CABB,_,AC__,_D",
    "A_,ADDB,_,DBCC,_,CAB_,_,AC__,BD",
    "A_,ADDB,_,DBCC,_,CA__,B,AC__,BD",
    "AA,ADDB,_,DBCC,_,C___,B,AC__,BD",
    "AA,ADDB,_,DBC_,C,C___,B,AC__,BD", # added by me
    "AA,ADDB,_,DBC_,_,CC__,B,AC__,BD",
    "AA,ADDB,_,DB__,C,CC__,B,AC__,BD", # added by me
    "AA,ADDB,_,DB__,_,CCC_,B,AC__,BD",
    "AA,ADDB,_,D___,B,CCC_,B,AC__,BD",
    "AA,ADDB,D,____,B,CCC_,B,AC__,BD",
    "AA,ADDB,D,B___,_,CCC_,B,AC__,BD",
    "AA,ADDB,D,BB__,_,CCC_,_,AC__,BD",
    "AA,ADDB,D,BBB_,_,CCC_,_,AC__,_D",
    "AA,ADDB,D,BBB_,_,CCC_,C,A___,_D", # added by me
    "AA,ADDB,D,BBB_,_,CCCC,_,A___,_D",
    "AA,ADDB,D,BBB_,_,CCCC,_,____,AD",
    "AA,ADDB,_,BBB_,_,CCCC,_,D___,AD",
    "AA,ADD_,B,BBB_,_,CCCC,_,D___,AD", # added by me
    "AA,ADD_,_,BBBB,_,CCCC,_,D___,AD",
    "AA,AD__,_,BBBB,_,CCCC,D,D___,AD", # added by me
    "AA,AD__,_,BBBB,_,CCCC,_,DD__,AD",
    "AA,A___,D,BBBB,_,CCCC,_,DD__,AD",
    "A_,AA__,D,BBBB,_,CCCC,_,DD__,AD",
    "__,AAA_,D,BBBB,_,CCCC,_,DD__,AD",
    "__,AAA_,_,BBBB,_,CCCC,_,DDD_,AD",
    "__,AAAA,_,BBBB,_,CCCC,_,DDD_,_D",
    "__,AAAA,_,BBBB,_,CCCC,_,DDDD,__",
);

#my $state = "AA,ADDB,D,B___,_,CCC_,B,AC__,BD";
#print "generating neihbours for state $state\n";
#my @neighbours = get_next_positions(state_from_str($state), "slot3");
#print Dumper(\@neighbours);

#test_neighbour_generation();

sub test_neighbour_generation {
    for my $i (0..($#example_state_path-1)) {
        my $state = $example_state_path[$i];
        my $target_next_state = $example_state_path[$i+1];

        print "testing state $i: $state\n";
        print "looking for target $target_next_state\n";

        my @next_state_infos = gen_next_states_str($state);
        my $found = 0;
        for my $next_state_info (@next_state_infos) {
            my ($next_state, $cost) = @$next_state_info;
            if ($next_state eq $target_next_state) {
                print "found next state\n";
                $found = 1;
                last;
            }
        }
        if (!$found) {
            print "didn't find next state!\n";
            print "these were the candidates:\n";
            print Dumper(\@next_state_infos);
        }
    }
}

my $goal_state = {
    left_hallway_1 => undef,
    left_hallway_2 => undef,
    room1_1 => "A",
    room1_2 => "A",
    room1_3 => "A",
    room1_4 => "A",
    slot1 => undef,
    room2_1 => "B",
    room2_2 => "B",
    room2_3 => "B",
    room2_4 => "B",
    slot2 => undef,
    room3_1 => "C",
    room3_2 => "C",
    room3_3 => "C",
    room3_4 => "C",
    slot3 => undef,
    room4_1 => "D",
    room4_2 => "D",
    room4_3 => "D",
    room4_4 => "D",
    right_hallway_1 => undef,
    right_hallway_2 => undef,
};

my $initial_state = parse_state();

print Dumper($initial_state);

my $cost = dijkstra_search($initial_state, $goal_state);

print "min cost: $cost\n";

sub slot_to_str {
    my ($slot) = @_;
    return $slot // "_";
}

sub state_to_str {
    my ($s) = @_;
    my $str =
        ($s->{left_hallway_2} // "_")
        .($s->{left_hallway_1} // "_")
        .","
        .($s->{room1_4} // "_")
        .($s->{room1_3} // "_")
        .($s->{room1_2} // "_")
        .($s->{room1_1} // "_")
        .","
        .($s->{slot1} // "_")
        .","
        .($s->{room2_4} // "_")
        .($s->{room2_3} // "_")
        .($s->{room2_2} // "_")
        .($s->{room2_1} // "_")
        .","
        .($s->{slot2} // "_")
        .","
        .($s->{room3_4} // "_")
        .($s->{room3_3} // "_")
        .($s->{room3_2} // "_")
        .($s->{room3_1} // "_")
        .","
        .($s->{slot3} // "_")
        .","
        .($s->{room4_4} // "_")
        .($s->{room4_3} // "_")
        .($s->{room4_2} // "_")
        .($s->{room4_1} // "_")
        .","
        .($s->{right_hallway_1} // "_")
        .($s->{right_hallway_2} // "_");
    return $str;
}

sub slot_from_str {
    my ($str) = @_;
    return undef if $str eq "_";
    return $str;
}

sub state_from_str {
    my ($str) = @_;
    my @sections = split(/,/, $str);
    my ($lh, $r1, $s1, $r2, $s2, $r3, $s3, $r4, $rh) = @sections;

    my ($lh2, $lh1) = split(//, $lh);
    my ($r1_4, $r1_3, $r1_2, $r1_1) = split(//, $r1);
    my ($r2_4, $r2_3, $r2_2, $r2_1) = split(//, $r2);
    my ($r3_4, $r3_3, $r3_2, $r3_1) = split(//, $r3);
    my ($r4_4, $r4_3, $r4_2, $r4_1) = split(//, $r4);
    my ($rh1, $rh2) = split(//, $rh);
    return {
        left_hallway_1 => slot_from_str($lh1),
        left_hallway_2 => slot_from_str($lh2),
        room1_1 => slot_from_str($r1_1),
        room1_2 => slot_from_str($r1_2),
        room1_3 => slot_from_str($r1_3),
        room1_4 => slot_from_str($r1_4),
        slot1 => slot_from_str($s1),
        room2_1 => slot_from_str($r2_1),
        room2_2 => slot_from_str($r2_2),
        room2_3 => slot_from_str($r2_3),
        room2_4 => slot_from_str($r2_4),
        slot2 => slot_from_str($s2),
        room3_1 => slot_from_str($r3_1),
        room3_2 => slot_from_str($r3_2),
        room3_3 => slot_from_str($r3_3),
        room3_4 => slot_from_str($r3_4),
        slot3 => slot_from_str($s3),
        room4_1 => slot_from_str($r4_1),
        room4_2 => slot_from_str($r4_2),
        room4_3 => slot_from_str($r4_3),
        room4_4 => slot_from_str($r4_4),
        right_hallway_1 => slot_from_str($rh1),
        right_hallway_2 => slot_from_str($rh2),
    };
}

sub cost_to_move {
    my ($letter, $distance) = @_;
    my $cost = $movement_costs{$letter};
    return $cost * $distance;
}

# a square is locked when it is solved
# and doesn't need to move ever.
sub is_locked {
    my ($s, $position) = @_;

    return 0 if not $position =~ /^room(.)_(.)$/;
    my ($room_idx, $room_depth_idx) = ($1, $2);

    for my $i ($room_depth_idx..4) {
        return 0 if not has_correct_letter($s, "room${room_idx}_$i");
    }

    return 1;
}

sub has_correct_letter {
    my ($s, $room) = @_;
    return get_room_letter($room) eq ($s->{$room} // "");
}

sub get_room_letter {
    my ($room) = @_;
    return "A" if $room =~ /^room1/;
    return "B" if $room =~ /^room2/;
    return "C" if $room =~ /^room3/;
    return "D" if $room =~ /^room4/;
    die "invalid room $room";
}

sub is_destination {
    my ($key, $letter) = @_;
    return 1 if $key =~ /^room1/ && $letter eq "A";
    return 1 if $key =~ /^room2/ && $letter eq "B";
    return 1 if $key =~ /^room3/ && $letter eq "C";
    return 1 if $key =~ /^room4/ && $letter eq "D";
    return 0;
}

sub gen_next_states_str {
    my ($s_str) = @_;

    my $s = state_from_str($s_str);

    my @out;

    for my $key (keys %full_edges) {
        my $value = $s->{$key};
        next unless defined($value);

        my @next_pos_infos = get_next_positions($s, $key);

        for my $next_pos_info (@next_pos_infos) {
            my ($next_pos, $distance) = @$next_pos_info;

            my %new_s = %$s;
            $new_s{$key} = undef;
            $new_s{$next_pos} = $value;

            my $cost = cost_to_move($value, $distance);
            push(@out, [state_to_str(\%new_s), $cost]);
        }
    }

    return @out;
}

sub get_next_positions {
    my ($s, $pos) = @_;

    return () if is_locked($s, $pos);

    if ($pos =~ /^room/) {
        return get_next_positions_from_room($s, $pos, $pos);
    }
    else {
        return get_next_positions_from_hallway($s, $s->{$pos}, $pos);
    }
}

sub get_next_positions_from_room {
    my ($s, $start_position, $visited) =  @_;

    my @out;

    my @open_list = ([$start_position, 0]);
    my %open_set = ( $start_position => 1 );
    my %visited;

    while (scalar @open_list > 0) {
        my $item = shift @open_list;
        my ($pos, $distance) =  @$item;
        delete $open_set{$pos};
        $visited{$pos} = 1;

        if ($pos !~ /^room/) {
            push(@out, [$pos, $distance]);
        }

        for my $child_pos_info (@{$full_edges{$pos}}) {
            my ($child_pos, $child_distance) = @$child_pos_info;
            next if $visited{$child_pos};
            next if $open_set{$child_pos};
            next if defined $s->{$child_pos};
            push(@open_list, [$child_pos, $distance + $child_distance]);
            $open_set{$child_pos} = 1;
        }
    }

    return @out;
}

sub get_next_positions_from_hallway {
    my ($s, $letter, $start_position) =  @_;

    my @out;

    my @open_list = ([$start_position, 0]);
    my %open_set = ( $start_position => 1 );
    my %visited;

    while (scalar @open_list > 0) {
        my $item = shift @open_list;
        my ($pos, $distance) =  @$item;
        delete $open_set{$pos};
        $visited{$pos} = 1;

        if ($pos =~ /^room(.)/) {
            my $room_idx = $1;
            next if not is_destination($pos, $letter);
            next if not is_room_available($s, $letter, $room_idx);

            if (room_pos_is_terminal($s, $pos)) {
                push(@out, [$pos, $distance]);
            }
        }

        for my $child_pos_info (@{$full_edges{$pos}}) {
            my ($child_pos, $child_distance) = @$child_pos_info;
            next if $visited{$child_pos};
            next if $open_set{$child_pos};
            next if defined $s->{$child_pos};
            push(@open_list, [$child_pos, $distance + $child_distance]);
            $open_set{$child_pos} = 1;
        }
    }

    return @out;
}

sub is_room_available {
    my ($s, $letter, $room_idx) = @_;
    for my $i (1..4) {
        my $val = $s->{"room${room_idx}_$i"};
        if (defined($val) && $val ne $letter) {
            return 0;
        }
    }
    return 1;
}

sub room_pos_is_terminal {
    my ($s, $pos) = @_;
    $pos =~ /^room(.)_(.)$/ or die "invalid room $pos";
    my ($room_idx, $room_depth_idx) = ($1, $2);
    return 1 if $room_depth_idx == 4;
    my $next_depth_idx = $room_depth_idx + 1;
    return 1 if defined($s->{"room${room_idx}_${next_depth_idx}"});

    return 0;
}

sub heuristic {
    my ($s) = @_;

    my $cost = 0;

    for my $key (keys %full_edges) {
        my $val = $s->{$key};
        next if not defined($val);
        if ($key =~ /^room._(.)/) {
            my $room_depth_idx = $1;
            if (!is_destination($key, $val)) {
                $cost += (3 + $room_depth_idx) * $movement_costs{$val};
            }
        }
        else {
            $cost += 2 * $movement_costs{$val};
        }
    }

    return $cost;
}


sub dijkstra_search {
    my ($initial_state, $goal_state) = @_;

    my @open_list = ([state_to_str($initial_state), 0, 0]);
    my %closed_set;

    my $goal_state_str = state_to_str($goal_state);

    while (scalar @open_list > 0) {
        #print "open list\n";
        #print Dumper(\@open_list);
        #print "closd set\n";
        #print Dumper(\%closed_set);
        my ($state_str, $cost_so_far, $estimated_total_cost) = @{shift @open_list};
        print "exploring ($cost_so_far, $estimated_total_cost): $state_str\n";
        $closed_set{$state_str} = 1;
        return $cost_so_far if $state_str eq $goal_state_str;

        my @neighbours = gen_next_states_str($state_str);
        #print "neighbours\n";
        #print Dumper(\@neighbours);
        for my $n (@neighbours) {
            my ($n_state_str, $n_cost) = @$n;
            next if $closed_set{$n_state_str};
            my $n_cost_so_far = $cost_so_far + $n_cost;
            my $n_estimated_total_cost = $n_cost_so_far + heuristic(state_from_str($n_state_str));
            insert_open_list(\@open_list, $n_state_str, $n_cost_so_far, $n_estimated_total_cost);
        }
    }

    die "goal not found\n";
}

sub insert_open_list {
    my ($open_list, $state_str, $cost_so_far, $estimated_total_cost) = @_;

    # find and delete existing item
    for my $i (0..$#$open_list) {
        my ($s_str, $s_cost_so_far, $s_estimated_total_cost) = @{$open_list->[$i]};
        next unless $s_str eq $state_str;
        return if $s_cost_so_far <= $cost_so_far;

        splice(@$open_list, $i, 1);
        last;
    }

    # insert new item
    for my $i (0..$#$open_list) {
        my ($s_str, $s_cost_so_far, $s_estimated_total_cost) = @{$open_list->[$i]};
        next unless $s_estimated_total_cost > $estimated_total_cost;
        splice(@$open_list, $i, 0, [$state_str, $cost_so_far, $estimated_total_cost]);
        return;
    }

    push(@$open_list, [$state_str, $cost_so_far, $estimated_total_cost]);
}

sub parse_state {
    <>; # top wall
    <>; # middle hallway
    
    my $l1 = <>; # first set of rooms
    $l1 =~ /^###([A-D])#([A-D])#([A-D])#([A-D])###$/ or die "invalid input on line $.\n";
    my ($room1_1, $room2_1, $room3_1, $room4_1) = ($1, $2, $3, $4);

    my ($room1_2, $room2_2, $room3_2, $room4_2) = qw(D C B A);
    my ($room1_3, $room2_3, $room3_3, $room4_3) = qw(D B A C);

    my $l4 = <>; # second set of rooms
    $l4 =~ /^  #([A-D])#([A-D])#([A-D])#([A-D])#$/ or die "invalid input on line $.\n";
    my ($room1_4, $room2_4, $room3_4, $room4_4) = ($1, $2, $3, $4);

    return {
        left_hallway_1 => undef,
        left_hallway_2 => undef,
        room1_1 => $room1_1,
        room1_2 => $room1_2,
        room1_3 => $room1_3,
        room1_4 => $room1_4,
        slot1 => undef,
        room2_1 => $room2_1,
        room2_2 => $room2_2,
        room2_3 => $room2_3,
        room2_4 => $room2_4,
        slot2 => undef,
        room3_1 => $room3_1,
        room3_2 => $room3_2,
        room3_3 => $room3_3,
        room3_4 => $room3_4,
        slot3 => undef,
        room4_1 => $room4_1,
        room4_2 => $room4_2,
        room4_3 => $room4_3,
        room4_4 => $room4_4,
        right_hallway_1 => undef,
        right_hallway_2 => undef,
    };
}
