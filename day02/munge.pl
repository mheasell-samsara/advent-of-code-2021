#!/usr/bin/perl


my $depth = 0;
my $horiz = 0;

for my $line (<>) {
	chomp $line;
	$line =~ /^(forward|down|up) (\d+)$/ or die "invalid line $.: $line\n";
	my ($op, $amount) = ($1, $2);

	$horiz += $amount if $op eq "forward";
	$depth += $amount if $op eq "down";
	$depth -= $amount if $op eq "up";
}

my $result = $horiz * $depth;

print "horiz: $horiz, depth: $depth, answer: $result\n";
