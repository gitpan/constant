package constant;

$VERSION = '0.01';

=head1 NAME

constant - Perl pragma to declare constants

=head1 SYNOPSIS

    use constant BUFFER_SIZE	=> 4096;
    use constant ONE_YEAR	=> 365.2425 * 24 * 60 * 60;
    use constant PI		=> 4 * atan2 1, 1;
    use constant DEBUGGING	=> 0;
    use constant ORACLE		=> 'oracle@cs.indiana.edu';
    use constant USERNAME	=> scalar getpwuid($<);
    use constant USERINFO	=> getpwuid($<);

    sub deg2rad { PI * $_[0] / 180 }

    print "This line does nothing"		unless DEBUGGING;

=head1 DESCRIPTION

This will declare a symbol to be a constant with the given scalar
or list value.

When you declare a constant such as C<PI> using the method shown
above, each machine your script runs upon can have as many digits
of accuracy as it can use. Also, your program will be easier to
read, more likely to be maintained (and maintained correctly), and
far less likely to send a space probe to the wrong planet because
nobody noticed the one equation in which you wrote C<3.14195>.

=head1 NOTES

The value or values are evaluated in a list context. You may override
this with C<scalar> as shown above.

These constants do not directly interpolate into double-quotish
strings, although you may use references to do so. See L<perlref>
for details about how this works.

    print "The value of PI is ${\( PI )}.\n";		# scalar
    print "Your USERINFO is @{[ USERINFO ]}.\n";	# list

Multiple values are returned as lists, not as arrays.

    $homedir = USERINFO[7];		# WRONG
    $homedir = (USERINFO)[7];		# Right
    @homedir = USERINFO;		# Get the whole list

The use of all caps for constant names is merely a convention,
although it is recommended in order to make constants stand out
and to help avoid collisions with other barewords, keywords, and
subroutine names. Constant names must begin with a letter.

Symbols are package scoped. That is, you can refer to a constant
in package Other as C<Other::CONST>.

Omitting the value for a symbol gives it the value of C<undef> in
a scalar context or the empty list, C<()>, in a list context. This
isn't so nice as it may sound, though, because in this case you
must either quote the symbol name, or use a big arrow, (C<=E<gt>>),
with nothing to point to. It is probably best to declare these
explicitly.

    use constant UNICORNS	=> ();
    use constant LOGFILE	=> undef;

The result from evaluating a list constant in a scalar context is
not documented, and is B<not> guaranteed to be any particular value
in the future. In particular, you should not rely upon it being
the number of elements in the list, especially since it is not that
value in the current implementation.

=head1 TECHNICAL NOTE

In the current implementation, scalar constants are actually
inlinable subroutines. As of version 5.004 of Perl, the appropriate
scalar constant is inserted directly in place of some subroutine
calls, thereby saving the overhead of a subroutine call. See
L<perlsub/"Constant Functions"> for details about how and when this
happens.

=head1 BUGS

In general, it's too much trouble to use this module if it's not
bundled with Perl.

In the current version of Perl, list constants are not inlined,
some symbols may be redefined without generating a warning, and
C<defined> works reliably only upon scalar constants.

In the current implementation, scalar constants and elements of
list constants must be either C<undef>, numbers, or strings.
References are stringified, so they aren't especially useful.
Magical values (such as C<$!>) are also stringified, so they lose
their magic.

It is not possible to have a subroutine or keyword with the same
name as a constant. This is probably a Good Thing.

Unlike constants in some other languages, these cannot be overridden
on the command line or via environment variables.

=head1 AUTHOR

Tom Phoenix, E<lt>F<rootbeer@teleport.com>E<gt>

=head1 COPYRIGHT

Copyright (C) 1997, Tom Phoenix

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

=cut

use strict;
use Carp;
use vars qw($VERSION $VERBOSE);
$VERBOSE = 0 unless defined $VERBOSE;

#=======================================================================

# Some of this stuff didn't work in version 5.003, alas.
require 5.003_20;

#=======================================================================
# import() - import symbols into user's namespace
#
# What we actually do is define a function in the caller's namespace
# which returns the value. The function we create will normally
# be inlined as a constant, thereby avoiding further sub calling 
# overhead.
#=======================================================================
sub import {
    my $class = shift;
    return unless defined(my $name = shift);	# Ignore 'use constant;'
    croak "Bad name ('$name') for constant"
	unless $name =~ /^[^\W_0-9]\w*$/;

    local $^W;				# Suspend warnings
    my $values = join ", ", map
	{
	    if ($_ eq (0+$_)) {		# no change when numified?
		$_
	    } elsif (defined) {		# looks stringy
		s#(['\\])#\\$1#g;	# Protect existing \ and '
		"'$_'"
	    } else {
		"undef"
	    }
	} eval { @_ };			# modifiable copies of args
    
    my $pkg = caller;

    my $code = "sub ${pkg}::$name () { $values } # $class";
    warn "# $code\n" if $VERBOSE;
    eval $code;
    croak $@ if $@;
}

1;
