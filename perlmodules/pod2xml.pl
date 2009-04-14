#!/usr/bin/perl -w

# Tool for converting Perl modules into the XML
#
# It uses:
#   * `/usr/bin/perldoc` and `/usr/bin/xsltproc` programs
#   * yast2_pm.xslt xslt stylesheet
#   * and 'conversion_output.xml' temporary file
#
# Prints XML document to the STDOUT
# Warnings to the STDERR

use Data::Dumper;

my $DOCUMENT = "";

my $convert_command = '/usr/bin/perldoc -o xml -T %file_name% > conversion_output.xml';
my $xslt_conversion = '/usr/bin/xsltproc --xinclude yast2_pm.xslt conversion_output.xml';

(scalar(@ARGV)) || do {
    warn
	"\nTool for converting Perl modules into the XML\n".
	"Usage: ./pod2xml.pl input_file [input_file [input_file]]\n\n";
    exit 1;
};

exit 2 if (! CheckBehavior());

my $XML_CONTENT = '';
foreach my $file (@ARGV) {
    if (CheckFile ($file)) {
	warn "Parsing file ".$file."\n";
	ParseFile ($file);
    } else {
	warn "Cannot use file: ".$file."\n";
    }
}

$DOCUMENT =
    "<?xml version=\"1.0\"?>\n".
    "<article>\n".
    "<title>YaST Perl Modules</title>\n".
    $DOCUMENT.
    "</article>";
    
print $DOCUMENT;

# ---------------------------------------------------------------------------- #

sub CheckBehavior {
    # doesn't seem to be needed anymore...
    #my @packages_needed = ('perl-XML-Generator', 'perl-Pod-Escapes');
    my @packages_needed = ();
    foreach my $package_needed (@packages_needed) {
	my $check_lib = `rpm -q $package_needed`;
	chop ($check_lib);
	if ($check_lib =~ /^$package_needed/) {
	    warn "Needed package $package_needed installed...\n";
	    return 1;
	} else {
	    warn "Needed package $package_needed is not installed, exiting...\n\n";
	    return 0;
	}
    }

    return 1;
}

sub CheckFile {
    my $file = shift || do {
	warn "File not defined\n";
	return 0;
    };
    ### File-existency
    if (! -e $file) {
	warn "File $file does not exist\n";
	return 0;
    }
    ### File-type
    if (! -f $file) {
	warn "File $file is not a 'file'\n";
	return 0;
    }
    ### File-readability
    if (! -r $file) {
	warn "File $file cannot be read\n";
    }
    
    return 1;
}

sub ParseFile {
    my $file = shift || do {
	warn "File not defined";
	return 0;
    };

    my $command = $convert_command;
    $command =~ s/%file_name%/$file/;
    warn 'Running command: `'.$command.'`'."\n";
    my $output = `$command`;

    if (! -s 'conversion_output.xml') {
	warn "Zero size output for file '$file'";
	return 0;
    } else {
	warn "File conversion_output.xml has ".(-s 'conversion_output.xml')." bytes\n";
    }

    my $module_doc = `$xslt_conversion`;
    $module_doc =~ s/^<\?xml[^>]+>\n//;

    $DOCUMENT .= $module_doc;
}
