#!/usr/bin/env perl


use warnings;
use strict;
use Data::Dumper;

my $input_counter = 0;

my $use_real_input = 1;
#my @input=split(//, 98989898989898);

my $w = {type=>"constant", value=>0};
my $x = {type=>"constant", value=>0};
my $y = {type=>"constant", value=>0};
my $z = {type=>"constant", value=>0};

my @instructions;

while (my $line = <>) {
    chomp $line;
    push(@instructions, $line);
}


my @serial = split(//, 89959794919939);
if (is_valid_serial(\@serial)) {
    print "valid!!!\n";
}
else {
    print "invalid...\n";
}

my @serial2 = split(//, 17115131916112);
if (is_valid_serial(\@serial2)) {
    print "valid!!!\n";
}
else {
    print "invalid...\n";
}

#
#
#my $start_serial = [split(//, 9x14)];
#my $loop_count = 0;
#while (1) {
#    my $in = $start_serial;
#    my $in_num = join("", @$in);
#    print "trying $in_num\n" if $loop_count % 1000 == 0;
#    if (is_valid_serial($in)) {
#        print "valid: $in_num\n";
#        exit 0;
#    }
#    $start_serial = decrement_serial($start_serial);
#    ++$loop_count;
#}

sub has_0 {
    my ($arr) = @_;
    for my $d (@$arr) {
        return 1 if $d == 0;
    }
    return 0;
}

sub decrement_serial {
    my ($s) = @_;

    while(1) {
        my $num = join("", @$s);
        if ($num <= 1x14) { die "too low!" };
        $num -= 1;
        my @arr = split(//, $num);
        $s = \@arr;
        next if has_0($s);
        return $s;
    }
}

sub is_valid_serial {
    my ($input) = @_;
    my @input_copy = @$input;
    my ($res_w, $res_x, $res_y, $res_z) = run_code(\@instructions, \@input_copy);
    my $z_val = get_const($res_z);
    die unless defined($z_val);
    return $z_val == 0;
}

sub gen_digit {
    my $r = int(rand(9)) + 1;
    return $r;
}

sub gen_input {
    my @in;
    for (1..14) {
        push(@in, gen_digit());
    }
    return \@in;
}

sub run_code {
    my ($instructions, $input) = @_;

    $w = cnst(0);
    $x = cnst(0);
    $y = cnst(0);
    $z = cnst(0);

    my $input_count = 0;
    my $in_digit;

    for my $i (0..$#$instructions) {
        my $line = @$instructions[$i];
        my @parts = split(/ /, $line);
        my $op = $parts[0];
        if ($op eq "inp") {

            print "state after digit $input_count ($in_digit)\n";
            print Data::Dumper->Dump([to_str($w), to_str($x), to_str($y), to_str($z)], [qw(w x y z)]);
            print "\n";
            ++$input_count;

            $in_digit = $input->[0];
            op_input($input, $parts[1]);
        } elsif ($op eq "add") {
            op_add($parts[1], $parts[2]);
        } elsif ($op eq "mul") {
            op_mul($parts[1], $parts[2]);
        } elsif ($op eq "div") {
            op_div($parts[1], $parts[2]);
        } elsif ($op eq "mod") {
            op_mod($parts[1], $parts[2]);
        } elsif ($op eq "eql") {
            op_eql($parts[1], $parts[2]);
        } else {
            die "invalid op $op on line $i\n";
        }

        #print "line $i: $line\n";
        #print Data::Dumper->Dump([to_str($w), to_str($x), to_str($y), to_str($z)], [qw(w x y z)]);
        #print "\n";
    }

    return ($w, $x, $y, $z);
}


sub cnst {
    my ($num) = @_;
    return {type=>"constant",value=>$num};
}

sub var {
    my ($name) = @_;
    return {type=>"var", value=>$name};
}

sub expr {
    my ($a, $b, $op) = @_;
    return {type=>"expr",op=>$op,a=>$a,b=>$b};
}

sub inp {
    my ($input_buffer) = @_;
    if (!$use_real_input) {
        return {type=>"inp", value=>$input_counter++};
    }

    my $val = shift @$input_buffer;
    return cnst(0+$val);
}

sub op_input {
    my ($input_buffer, $var) = @_;
    my $in = inp($input_buffer);
    set($var, $in);
}

sub decode_operand {
    my ($var) = @_;
    if ($var =~ /^-?[0-9]+$/) {
        return cnst($var);
    }
    if ($var =~ /^[wxyz]$/) {
        return get($var);
    }

    die "failed to decode operand $var";
}

sub get {
    my ($name) = @_;
    if ($name eq "w") {
        return $w;
    } elsif ($name eq "x") {
        return $x;
    } elsif ($name eq "y") {
        return $y;
    } elsif ($name eq "z") {
        return $z;
    }
}

sub set {
    my ($name, $val) = @_;
    if ($name eq "w") {
        $w = $val;
    } elsif ($name eq "x") {
        $x = $val;
    } elsif ($name eq "y") {
        $y = $val;
    } elsif ($name eq "z") {
        $z = $val;
    }
}

sub is_const {
    my ($expr, $val) = @_;
    return 0 unless $expr->{type} eq "constant";
    return 0 unless $expr->{value} == $val;
    return 1;
}

sub is_inp {
    my ($expr) = @_;
    return $expr->{type} eq "inp" ? 1 : 0;
}

sub get_const {
    my ($expr) = @_;
    return undef unless $expr->{type} eq "constant";
    return $expr->{value};
}

sub to_str {
    my ($expr) = @_;
    return $expr->{value} if $expr->{type} eq "constant";
    return "inp".$expr->{value} if $expr->{type} eq "inp";
    if ($expr->{type} eq "expr") {
        my $a = to_str($expr->{a});
        if ($expr->{a}{type} eq "expr") {
            $a = "($a)";
        }
        my $b = to_str($expr->{b});
        if ($expr->{b}{type} eq "expr") {
            $b = "($b)";
        }
        my $op = $expr->{op};
        return "$a $op $b";
    }

    die "invalid expr type " . $expr->{type};
}

sub op_add {
    my ($a, $b) = @_;
    set($a, add(decode_operand($a), decode_operand($b)));
}

sub add {
    my ($a, $b) = @_;

    return $a if is_const($b, 0);
    return $b if is_const($a, 0);

    my $a_const = get_const($a);
    my $b_const = get_const($b);
    if (defined($a_const) && defined($b_const)) {
        return cnst($a_const + $b_const);
    }

    return expr($a, $b, "+");
}

sub op_mul {
    my ($a, $b) = @_;
    set($a, mul(decode_operand($a), decode_operand($b)));
}

sub mul {
    my ($a, $b) = @_;
    return cnst(0) if is_const($a, 0);
    return cnst(0) if is_const($b, 0);

    return $a if is_const($b, 1);
    return $b if is_const($a, 1);

    my $a_const = get_const($a);
    my $b_const = get_const($b);
    if (defined($a_const) && defined($b_const)) {
        return cnst($a_const * $b_const);
    }

    return expr($a, $b, "*");
}

sub op_div {
    my ($a, $b) = @_;
    set($a, div(decode_operand($a), decode_operand($b)));
}

sub div {
    my ($a, $b) = @_;
    return $a if is_const($b, 1);

    my $a_const = get_const($a);
    my $b_const = get_const($b);
    if (defined($a_const) && defined($b_const)) {
        return cnst(int($a_const / $b_const));
    }

    return expr($a, $b, "/");
}

sub op_mod {
    my ($a, $b) = @_;
    set($a, mod(decode_operand($a), decode_operand($b)));
}

sub mod {
    my ($a, $b) = @_;
    if (is_inp($a)) {
        my $b_const = get_const($b);
        if (defined($b_const) && $b_const > 9) {
            return $a;
        }
    }

    my $a_const = get_const($a);
    my $b_const = get_const($b);
    if (defined($a_const) && defined($b_const)) {
        return cnst($a_const % $b_const);
    }

    return expr($a, $b, "%");
}

sub op_eql {
    my ($a, $b) = @_;
    set($a, eql(decode_operand($a), decode_operand($b)));
}

sub eql {
    my ($a, $b) = @_;
    if (is_inp($a)) {
        my $b_const = get_const($b);
        if (defined($b_const) && ($b_const < 1 || $b_const > 9)) {
            return cnst(0);
        }
    }

    if (is_inp($b)) {
        my $a_const = get_const($a);
        if (defined($a_const) && ($a_const < 1 || $a_const > 9)) {
            return cnst(0);
        }
    }

    if ($a->{type} eq "expr" && $a->{op} eq "==" && is_const($b, 0)) {
        return expr($a->{a}, $a->{b}, "!=");
    }
    if ($b->{type} eq "expr" && $b->{op} eq "==" && is_const($a, 0)) {
        return expr($b->{a}, $b->{b}, "!=");
    }
    if ($a->{type} eq "expr" && $a->{op} eq "==" && is_const($b, 1)) {
        return $a;
    }
    if ($b->{type} eq "expr" && $b->{op} eq "==" && is_const($a, 1)) {
        return $b;
    }

    my $a_const = get_const($a);
    my $b_const = get_const($b);
    if (defined($a_const) && defined($b_const)) {
        return cnst($a_const == $b_const ? 1 : 0);
    }

    return expr($a, $b, "==");
}
