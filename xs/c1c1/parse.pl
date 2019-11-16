#!env perl

# Usage: this command parses parton_systematics.log and returns central-lowerunc-upperunc numbers.
# One may want to use this command as
# for i in **/parton_systematics.log
# do
#    echo $i | sed -e 's/\/Events\//\t/' -e 's/\/parton_systematics.log/\t/' | read stem mass
#    echo $stem
#    (echo -n $mass\\t; ./parse.pl $i) | tee -a result_${stem}.txt
# done


use strict;
use warnings;

my $float_regexp = '\d+(?:\.\d+)?(?:e[+-]\d+)?%?';

my @lines = <>;

my @central_lines = grep {/original cross-section:/} @lines;
if(@central_lines != 1){ die "central value parse failed."; }
$central_lines[0] =~ /original cross-section:\s*($float_regexp)/i or die "invalid central";
my $central = $1 * 1;

my (@lower_var, @higher_var);

sub add_variation{
    my $regex = shift;
    my @variation_line = grep {/$regex\s*(\+\s*$float_regexp)\s+(-\s*$float_regexp)\s*$/} @lines;
    if(@variation_line != 1) { die "parse failed: $regex"; }
    $variation_line[0] =~ /$regex\s*\+\s*($float_regexp)\s+-\s*($float_regexp)\s*$/ or die;
    my ($low, $high) = ($1, $2);
    push(@lower_var, $low =~ /^(.*)%$/ ? $central * $1 * 0.01 : $low*1);
    push(@higher_var, $high =~ /^(.*)%$/ ? $central * $1 * 0.01 : $high*1);
}

add_variation("scale variation:");
add_variation("central scheme variation:");
add_variation("PDF variation:");

sub total{
    my $sum_squared = 0;
    foreach(@_){
        $sum_squared += $_ * $_;
    }
    return sqrt($sum_squared);
}

my $low_sum = total(@lower_var) * -1;
my $high_sum = total(@higher_var);

print "$central\t$low_sum\t$high_sum\n";

