#!/usr/bin/perl
use strict;
use List::Util qw(reduce);

sub fail{
    print "I reject your reality and substitute my own!\n";
    exit 1;
}

$ARGV[0] =~ /
    (\/[A-Za-z]+\s+)? #we match the roll itself
    (r(?<rtimes>\d+)\s+)? #repetition
    (?<n>\d+)d(?<x>\d+) #ndx
    (!(?<xabv>\d+))? #explode at n or greater
    (k(?<knum>\d+))? #keep x
    (\+(?<plnum>\d+)|-(?<minum>\d+))? #plus or minus
    ((>=(?<osucc>\d+))|(<=(?<usucc>\d+)))? #success gte or lte
    \s*(\#(?<comment>.*))? #comment
/x or fail();

for my $i (1..($+{rtimes} or 1)){
    my @dice=map {int(rand($+{x})+1)} (1..$+{n});
    if($+{xabv}){@dice=map {$_>=$+{xabv}?($_,int(rand($+{x}+1))):$_} @dice}
    if($+{knum}){@dice=(reverse(sort {$a<=>$b} @dice))[0..$+{knum}-1]}
    printf "(%s)", join(", ", @dice);
    my $res=reduce {$a + $b} @dice;
    if($+{plnum}){printf "+%d", $+{plnum}}
    if($+{minum}){printf "-%d", $+{minum}}
    $res=$res+$+{plnum}-$+{minum};
    $res<=0?$res=1:0;
    printf "=%d", $res;
    if($+{osucc}){print (($res>=$+{osucc})?"(success)":"(failure)")}
    elsif($+{usucc}){print (($res<=$+{usucc})?"(success)":"(failure)")}
    print ". ";
}
if($+{comment}){printf "# %s", $+{comment}}
