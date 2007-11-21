#! /usr/bin/perl -w

# Example of using YaPI/PerlAPI in Perl

use strict;
use Data::Dumper;

use ycp;
use YaST::YCP qw(sformat);
YaST::YCP::Import ("SambaServer");

y2milestone("Export_A: ".Dumper(SambaServer->Export()));
SambaServer->addShare("NEW1_SHARE", { "public" => "yes" });
y2milestone("Export_B: ".Dumper(SambaServer->Export()));
SambaServer->addShare("NEW2_SHARE", { "public" => "no" });
y2milestone("Export_C: ".Dumper(SambaServer->Export()));