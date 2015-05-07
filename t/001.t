
use Algorithm::ConsistentHash::MultiProbe;

my $buckets = [ map { "shard-$_" } 1..10 ];

my $seeds = [ 1..21 ];

use Data::Dumper;

my $mpc = Algorithm::ConsistentHash::MultiProbe->new($buckets, $seeds);

for my $b (@$buckets) {
    print $mpc->hash($b), "\n";
}
