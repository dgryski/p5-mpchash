
use Test::Simple tests => 6000;
use File::Slurp qw/read_file/;
use Algorithm::ConsistentHash::MultiProbe;

my $buckets = [ map { "shard-$_" } 1..6000 ];

my $mpc = Algorithm::ConsistentHash::MultiProbe->new($buckets, [1, 2], 21);

chomp(my @compat = read_file('t/testdata/compat.out'));

for (my $i=0; $i < @compat; $i++) {
    my $b = $buckets->[$i];
    my $got = $mpc->hash($b);
    my $want = $compat[$i];
    ok ($got eq $want);
}
