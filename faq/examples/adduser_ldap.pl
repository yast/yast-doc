#!/usr/bin/perl -w

#
# Simple script for adding LDAP user
# Requires 2 parameters: <username> <password>
#

BEGIN {
    push @INC, "/usr/share/YaST2/modules";
}

use YaPI::USERS;

# take user name and password from the command line
my $uid    = shift;
my $passwd = shift;

my $config	= {
    "type"		=> "ldap",
    "bind_pw"	      	=> "q"	# password for LDAP administrator
};

my $data	= {
    "sn"		=> $uid		|| "",
    "uid"		=> $uid		|| "",
    "userpassword"	=> $passwd	|| "",
    "description"       => [ "first", "second" ] # additional LDAP attribute
};

my $error     = YaPI::USERS->UserAdd ($config, $data);

# the return value is empty string on success
if ($error) {
    print "add user error: '$error'\n";
}
