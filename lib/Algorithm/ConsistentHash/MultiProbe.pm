package Algorithm::ConsistentHash::MultiProbe;

use warnings;
use strict;

use Digest::SipHash qw/siphash64/;
use List::BinarySearch qw/binsearch_pos/;

sub new {
    my $class = shift;
    my ($buckets, $seeds) = @_;

    my $self = bless {
        buckets => $buckets,
        seeds => [ map { pack "C16", $_ } @$seeds ],
        bmap => {},
        bhashes => [],
    }, $class;

    for my $bucket (@{$self->{buckets}}) {
        my $h = siphash64($bucket, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0");
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

    for my $seed (@{$self->{seeds}}) {
        my $h = siphash64($key, $seed);
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
