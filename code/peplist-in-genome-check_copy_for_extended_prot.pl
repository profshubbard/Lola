#!/usr/bin/perl
#  perl scripts/peplist-in-genome-check.pl uniq-pep-seqs.list Drosophila_melanogaster.fasta
#  files in ~/Unix/PRIDE-clusters
#

use warnings;

$pepfile = shift;
$genomefile = shift;  # reformatted ensembl with seqs all on one line

open($fh, "<", $genomefile) or die "cant open genomefile $genomefile\n";
while ( <$fh> ) {

	if ( /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s/ ) { #\S matches any NON-whitespace character whilst \s matches any whitespace character. + means match 1 or more times. 
		$prot = $1; #picks up what is in the first set of brackets, which would be the FBpp... in this case
		$gene = $2; #picks up what is in the second set of brackets, in this case the FBgn
		$tx = $3;
		$seq = $4;
		$protein{$tx}->{TX} = $tx;
		$protein{$tx}->{NAME} = $prot;
		$protein{$tx}->{GENE} = $gene;
		$protein{$tx}->{SEQ} = $seq;
		$prots{$prot}++;
		$genes{$gene}++;
	} else {
		chomp;
		$protein{$tx}->{SEQ} .= $_;

	}
}
close($fh);

$ntxs = keys %protein;
$nprots = keys %prots;
$ngenes = keys %genes;

print "read in $nprots proteins, $ntxs transcripts and $ngenes genes\n"; #prints the number of proteins and genes in the reference genome file

open($fh, "<", $pepfile) or die "cant open pepfile $pepfile\n";

#
# lets do it the hard way and cycle through every protein for each peptide
#

while ( <$fh> ) { #here we read in the uniq peptide file and thus this is just a list of peptide sequences found by the search
	chomp;
	$pepseq = $_;
#	$peptide{$pepseq} = ();
	%fprots = (); #make empty hash
	%fgenes = (); #make empty hash
	%ftxs = (); #make empty hash
	$counts = 0; #set count to 0
	foreach my $tx ( keys %protein ) {
		if ( $protein{$tx}->{SEQ} =~ /$pepseq/ ) {
			$counts++;
			$ftxs{$tx}++;
			$fprots{$protein{$tx}->{NAME}}++;
			$fgenes{$protein{$tx}->{GENE}}++;
#			$protein{$prot}->$peps{$pepseq}++;
		}
	}
	$ntxs = keys %ftxs;
	$nprots = keys %fprots;
	$ngenes = keys %fgenes;
	$txlist = join(':', keys %ftxs);
	$genelist = join(':', keys %fgenes);
	$protlist = join(':', keys %fprots);
	print "pep\t$ntxs\t$nprots\t$ngenes\t$pepseq\t$txlist\t$genelist\t$protlist\n";
}
exit
