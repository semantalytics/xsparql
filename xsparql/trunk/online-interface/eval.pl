#!/usr/bin/perl
use strict;
use warnings;
use Switch;
use CGI;
use Sys::Hostname;
require Encode;

sub trim
{
    my $string = shift;
    for ($string)
    {
        s/^\s+//;
        s/\s+$//;
    }
    return $string;
}

my $plugindir = '';
my $error = '';
my $resultlimit = 60000;

$ENV{'PATH'} = '/usr/local/bin:/usr/bin:/bin:/opt/SDK/jdk/bin/:/home/axepol/public_html/xsparql:/home/axepol/public_html/xsparqltmp';

my $cgi = new CGI;

my $query = $cgi->param('query');

my $solver = $cgi->param('solver');

my $solverexec = '';

my @result = ();

switch ($solver)
{
case 'evaluate'
    { $solverexec = './xquery '; }
case 'rewrite'
    { $solverexec = './xsparqlrewrite '; }
else
    { $error = 'error: no solver specified!'; }
}

my $filename = '';

if ($error eq '')
{
    my $salt=join '', (0..9, 'A'..'Z', 'a'..'z')[rand 64, rand 64];
    $filename = "/home/axepol/public_html/xsparqltmp/tempfiles/query$$".time.$salt.".tmp";

    open(FH, "> $filename") ||  print "Cannot open file";
    print FH $query;
    print FH "\n";
    close(FH);

    my $finished = 1;
    my $totalsize = 0;

    my $pid = open(SOLVER, "$solverexec $filename 2>&1 |");
    while (<SOLVER>)
    {
        push(@result, $_);
        $totalsize = $totalsize + length($_);

        if ($totalsize > $resultlimit)
        {
            push(@result, '<br/>Output too long, cut here!'); 
            $finished = 0;
            last;
        }
    }
    if ($finished == 1)
        { close(SOLVER); }
    else
        { kill 9, $pid; }

    #@result = `echo '$query' | $solverexec -- 2>&1`;

    #unlink $filename;
}


#
# output starts
#

print $cgi->header(-'Cache-Control'=>'no-cache, must-revalidate, max-age=0',
                   -expires=>'Mon, 26 Jul 1997 05:00:00 GMT',
                   -charset=>'utf-8');


#print '<p>call: ' . $solverexec . '</p>';
#print @result;
if ($error ne '') { print $error; exit 0; }

print '<h3 style="margin-top: 0px;">Rewritten query:</h3> ' . $query. '</p>'; 
print '<p>call: ' . $solverexec . '</p>'; 
print '<p>file: ' . $filename. '</p>'; 

print '<h3 style="margin-top: 0px;">Result:</h3>';


#print '<pre>';
foreach my $line (@result)
{
   $line =~ s/\>/&gt;/g;
   $line =~ s/\</&lt;/g;
   print $line.'<br/>';
}
#print '</pre>';