
use Algorithm::ConsistentHash::MultiProbe;

my $buckets = [ map { "shard-$_" } 1..6000 ];

my $mpc = Algorithm::ConsistentHash::MultiProbe->new($buckets, [1, 2], 21);

for my $b (@$buckets) {
    print $mpc->hash($b), "\n";
}
