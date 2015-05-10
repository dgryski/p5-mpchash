package Algorithm::ConsistentHash::MultiProbe;

use warnings;
use strict;

use Digest::SipHash qw/siphash64/;
use List::BinarySearch qw/binsearch_pos/;

use constant zero_seed => pack ("C16", 0);

sub new {
    my $class = shift;
    my ($buckets, $seeds, $k) = @_;

    my $self = bless {
        buckets => $buckets,
        seeds => [ map { pack "C16", $_ } @$seeds ],
        k => $k,
        bmap => {},
        bhashes => [],
    }, $class;

    for my $bucket (@{$self->{buckets}}) {
        my $h = siphash64($bucket, zero_seed);
        push @{$self->{bhashes}}, $h;
        $self->{bmap}->{$h} = $bucket;
    }

    @{$self->{bhashes}} = sort {$a <=> $b} @{$self->{bhashes}};

    return $self;
}

sub hash {
    my ($self, $key) = @_;

    my $min_distance = ~0;
    my $midx = 0;

    my $h1 = siphash64($key, $self->{seeds}->[0]);
    my $h2 = siphash64($key, $self->{seeds}->[1]);

    for (my $i=0; $i < $self->{k}; $i++) {
        my $h;
        { use integer; $h = unpack("Q", pack("Q", ($h1 + $i * $h2))); }
        my $idx = binsearch_pos { $a <=> $b } $h, @{$self->{bhashes}};

        if ($idx >= @{$self->{bhashes}}) {
                $idx = 0;
        }

        my $nhash = $self->{bhashes}->[$idx];
        my $d;
        { use integer; $d = $self->{bhashes}->[$idx] - $h; }
        if ($d < $min_distance) {
            $min_distance = $d;
            $midx = $idx;
        }
    }

    return $self->{bmap}->{$self->{bhashes}->[$midx]};
}

1;
