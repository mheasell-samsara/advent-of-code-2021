#!/usr/bin/perl


my $depth = 0;
my $horiz = 0;
my $aim = 0;

for my $line (<>) {
	chomp $line;
	$line =~ /^(forward|down|up) (\d+)$/ or die "invalid line $.: $line\n";
	my ($op, $amount) = ($1, $2);

	if ($op eq "down") {
		$aim += $amount;
	}
	elsif ($op eq "up") {
		$aim -= $amount;
	}
	elsif ($op eq "forward") {
		$horiz += $amount;
		$depth += $aim * $amount;
	}
	else {
		die "invalid op on line $.: $op\n";
	}
}

my $result = $horiz * $depth;

print "horiz: $horiz, depth: $depth, answer: $result\n";
