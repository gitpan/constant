# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

BEGIN {$^W |= 1}		# Insist upon warnings
BEGIN {				# And make 'em fatal
    $SIG{'__WARN__'} = sub { die "not ok\n", @_ }
}

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..33\n"; }
END {print "not ok 1\n" unless $loaded;}
use constant;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

use strict;

sub test ($$;$) {
    my($num, $bool, $diag) = @_;
    if ($bool) {
	print "ok $num\n";
	return;
    }
    print "not ok $num\n";
    return unless defined $diag;
    $diag =~ s/\Z\n?/\n/;			# unchomp
    print map "# $num : $_", split m/^/m, $diag;
}

use constant PI		=> 4 * atan2 1, 1;

test 2, substr(PI, 0, 7) eq '3.14159';
test 3, defined PI;

sub deg2rad { PI * $_[0] / 180 }

my $ninety = deg2rad 90;

test 4, $ninety > 1.5707;
test 5, $ninety < 1.5708;

use constant UNDEF1	=> undef;	# the right way
use constant UNDEF2	=>	;	# the weird way
use constant 'UNDEF3'		;	# the 'short' way
use constant EMPTY	=> ( )  ;	# the right way for lists

test 6, not defined UNDEF1;
test 7, not defined UNDEF2;
test 8, not defined UNDEF3;
my @undef = UNDEF1;
test 9, @undef == 1;
test 10, not defined $undef[0];
@undef = UNDEF2;
test 11, @undef == 0;
@undef = UNDEF3;
test 12, @undef == 0;
@undef = EMPTY;
test 13, @undef == 0;

use constant COUNTDOWN	=> scalar reverse 1, 2, 3, 4, 5;
use constant COUNTLIST	=> reverse 1, 2, 3, 4, 5;
use constant COUNTLAST	=> (COUNTLIST)[-1];

test 14, COUNTDOWN eq '54321';
my @cl = COUNTLIST;
test 15, @cl == 5;
test 16, COUNTDOWN eq join '', @cl;
test 17, COUNTLAST == 1;
test 18, (COUNTLIST)[1] == 4;

use constant ABC	=> 'ABC';
test 19, "abc${\( ABC )}abc" eq "abcABCabc";

use constant DEF	=> 'D', "\x45", chr 70;
test 20, "d e f @{[ DEF ]} d e f" eq "d e f D E F d e f";

use constant SINGLE	=> "'";
use constant DOUBLE	=> '"';
use constant BACK	=> '\\';
my $tt = BACK . SINGLE . DOUBLE ;
test 21, $tt eq q(\\'");

use constant MESS	=> q('"'\\"'"\\);
test 22, MESS eq q('"'\\"'"\\);
test 23, length(MESS) == 8;

use constant TRAILING	=> '12 cats';
{
    my $save_warn;
    BEGIN { $save_warn = $^W; $^W = 0 }
    test 24, TRAILING == 12;
    BEGIN { $^W = $save_warn }
}
test 25, TRAILING eq '12 cats';

use constant LEADING	=> " \t\n1234";
test 26, LEADING == 1234;
test 27, LEADING eq " \t\n1234";

use constant ZERO1	=> 0;
use constant ZERO2	=> 0.0;
use constant ZERO3	=> '0.0';
test 28, ZERO1 eq '0';
test 29, ZERO2 eq '0';
test 30, ZERO3 eq '0.0';

{
    package Other;
    use constant PI	=> 3.141;
}

test 31, PI > 3.1415 and PI < 3.1416;
test 32, Other::PI == 3.141;

test 33, $^W & 1, "Where did the warnings go?";
