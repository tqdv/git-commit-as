#!/usr/bin/perl

use v5.26;

# Return codes:
# * 1: Missing or invalid argument or data
# * 2: External tool error

my $USAGE = <<~END;
	Usage: git commitas <as-user> <arguments>
	       git commitas -h | --help
	       git commitas --man | --manual
	END

my $MAN = <<~END;
	$USAGE
	This script overrides the GIT_AUTHOR_* and GIT_COMMITTER_* environment variables
	with git config values users.<as-user>.name and users.<as-user>.email.

	For a user named John, you would add this to your git config:
	```
	[users "John"]
		name = "John Doe"
		email = "john.doe\@example.com"
	```
	And call it as so: git commitas John <arguments>

	Note that <as-user> is case-sensitive and can not start with a hyphen.

	Dependencies: perl, sh, env, git

	Licensed by Tilwa Qendov under The Artistic 2.0 license
	END

# Check arguments
my $useras = shift @ARGV;
unless ($useras) {
	say STDERR "Error: missing as-user";
	print STDERR $USAGE;
	exit 1;
}

# Handle help, manual and unknown flags
if ($useras eq '--help' || $useras eq '-h') {
	print $USAGE;
	exit 0;
} elsif ($useras eq '--man' || $useras eq '--manual') {
	print $MAN;
	exit 0;
} elsif ($useras =~ /^-/) {
	say STDERR "Error: unknown flag '$useras'";
	print STDERR $USAGE;
	exit 1;
}

# Filter invalid characters
# NB: command line can't contain the null byte anyways
my $invalid = $useras =~ s/[\n\0]//g;
if ($invalid) {
	say STDERR "Error: invalid as-user '$useras'. Newlines and null characters aren't allowed.";
	exit 1;
}

# Quote for shell
my $useras_e = $useras =~ s/'/'\\''/gr;
$useras_e = qq('$useras');

# Query git config
my ($ret, $namemissing, $emailmissing);

my $name  = qx[ git config --get users.$useras_e.name ];
chomp $name;
$ret = $? >> 8;
$namemissing = ($ret == 1);
if ($ret > 1) { say STDERR "git errored with return code $ret while querying config."; exit 2 }

my $email = qx[ git config --get users.$useras_e.email ];
chomp $email;
$ret = $? >> 8;
$emailmissing = ($ret == 1);
if ($ret > 1) { say STDERR "git errored with return code $ret while querying config."; exit 2 }

# Handle errors in a more user-friendly way
if ($namemissing && $emailmissing) {
	say STDERR qq(Missing section [users "$useras"] in git config. Did you forget to add it?);
} elsif ($namemissing) {
	say STDERR qq(Missing 'name' field under section [users "$useras"] in git config. Did you forget to add it?);
} elsif ($emailmissing) {
	say STDERR qq(Missing 'email' field under section [users "$useras"] in git config. Did you forget to add it?);
}
if($namemissing || $emailmissing) {
	exit 2;
}

say qq(Committing as "$name" <$email>.);

my @command = @ARGV;

# Add our command
unshift @command, "git", "commit";

# Add our environment variables
unshift @command, "GIT_AUTHOR_NAME=$name";
unshift @command, "GIT_AUTHOR_EMAIL=$email";
unshift @command, "GIT_COMMITTER_NAME=$name";
unshift @command, "GIT_COMMITTER_EMAIL=$email";

unshift @command, "env";

exec { $command[0] } @command;
