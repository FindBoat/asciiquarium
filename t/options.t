use strict;
use warnings;

use FindBin;
use IPC::Open3;
use Symbol qw(gensym);
use Test::More;

my $script = "$FindBin::Bin/../asciiquarium";

sub run_asciiquarium {
	my (@args) = @_;
	my $stderr = gensym;
	my $pid = open3(my $stdin, my $stdout, $stderr, $^X, $script, @args);
	close($stdin);

	my $output = do { local $/; <$stdout> // '' };
	my $error = do { local $/; <$stderr> // '' };
	waitpid($pid, 0);
	return ($? >> 8, $output, $error);
}

my ($status, $output, $error) = run_asciiquarium('--help');
is($status, 0, 'help exits successfully');
like($output, qr/--background COLOR/, 'help documents the background option');
like($output, qr/default\/transparent/, 'help documents terminal-default backgrounds');
is($error, '', 'help does not write to stderr');

($status, $output, $error) = run_asciiquarium('--background', 'blue');
is($status, 2, 'invalid background exits with a usage error');
is($output, '', 'invalid background does not write to stdout');
like($error, qr/Invalid background 'blue'/, 'invalid background identifies the value');

($status, $output, $error) = run_asciiquarium('unexpected');
is($status, 2, 'unexpected argument exits with a usage error');
like($error, qr/Unexpected argument 'unexpected'/, 'unexpected argument is identified');

done_testing();
