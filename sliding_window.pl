use Bio::SeqIO;
use Bio::AlignIO;
use PostScript::Simple;
require "subfuncs.pl";

# Bring in the file and format, or die with a nice
# usage statement if one or both arguments are missing.
my $usage  = "sliding_window.pl fasta_file window_size\n";
my $fa_file = shift or die $usage;
my $window_size = shift or die $usage;

my $start_pos = 1;
my $stop_pos = $window_size;
my $len;
my $flag = 1;
my $curr_aln;
my $gb_fh;

$curr_aln = make_aln_from_fasta_file($fa_file);

my $sub_aln = $curr_aln->slice($start_pos, $stop_pos);

my $result = convert_aln_to_nexus ($sub_aln);
#print "$result\n";

my $string;
open($stringfh, ">", \$string) or die "Could not open string for writing: $!";   # Use this for Perl AFTER 5.8.0 (inclusive)
my $gb_seq = Bio::SeqIO->new(-format => "genbank", -fh => $stringfh);
#my $seq_frag = Bio::Seq->new(-seq => $curr_aln->consensus_iupac(), -id => "consensus");
my $seq_frag = Bio::Seq->new(-seq => $curr_aln->get_seq_by_pos(1)->seq(), -id => "chloroplast", -is_circular => 1);

while ($flag) {
	my $gene_name = "$start_pos";
	my $seq_feat = Bio::SeqFeature::Generic->new(-start => $start_pos, -end => $stop_pos, -strand => 1, -primary_tag => "gene");
	$seq_feat->add_tag_value("gene", $gene_name);
	$seq_frag->add_SeqFeature($seq_feat);
	$flag = perc_diff_partition ($curr_aln, $start_pos, $stop_pos);
	if ($flag > 0) {
		my $val = (100-$flag) * 1000;
		print "$start_pos\t$val\n";
	}
	$start_pos += $window_size;
	$stop_pos += $window_size;
}
	$gb_seq->write_seq($seq_frag);

	open $gb_fh, ">$fa_file.gb";
	print $gb_fh $string;
