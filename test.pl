use strict;
use Test;
BEGIN{plan test => 1 };
use String::lcse qw(lcsQ lcsST lcsT);
ok(1);

my @A = ('The Dog Ate The Cat', 'Bob Dog Ate The Pizza', 'Ralph Dog Ate The Bomb', 'Zed Dog Ate The Bowling Ball');
my $lcss = lcsQ(\@A, 100);
print("\nTesting lcsQ...  $lcss\n");
ok($lcss, 'Dog Ate The');

my @A = ('The Dog Ate The Cat', 'e Dog Ate The C', 'Me Dog Ate The Can', 'See Dog Ate The Car');
$lcss = lcsST(\@A, 75);
print("\nTesting lcsST...  $lcss\n");
ok($lcss, 'e Dog Ate The Ca');

$lcss = lcsT(\@A, 75);
print("\nTesting lcsT...  $lcss\n");
ok($lcss, 'e Dog Ate The Ca');
