#!/usr/bin/perl -w

#
# Simple script for adding new user
# Requires 2 parameters: <username> <password>
#

BEGIN {
    push @INC, "/usr/share/YaST2/modules";
}

use YaPI::USERS;

# take user name and password from the command line
my $uid    = shift;
my $passwd = shift;

my $config	= {};
my $data	= {
    "uid"		=> $uid		|| "",
    "userpassword"	=> $passwd	|| ""
};
my $error     = YaPI::USERS->UserAdd ($config, $data);

# the return value is empty string on success
print "add user error: '$error'\n";
