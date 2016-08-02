#!/usr/bin/perl
#  perl scripts/peplist-in-genome-check.pl uniq-pep-seqs.list Drosophila_melanogaster.fasta
#  files in ~/Unix/PRIDE-clusters
#

use warnings;

$pepfile = shift;
$genomefile = shift;  # reformatted ensembl with seqs all on one line

open($fh, "<", $genomefile) or die "cant open genomefile $genomefile\n";
while ( <$fh> ) {

	if ( /^(\S+)\s+(\S+)\s+\S+\s+(\S+)\s/ ) { #\S matches any NON-whitespace character whilst \s matches any whitespace character. + means match 1 or more times. 
		$prot = $1; #picks up what is in the first set of brackets, which would be the FBpp... in this case
		$gene = $2; #picks up what is in the second set of brackets, in this case the FBgn
		$seq = $3;
		$protein{$prot}->{NAME} = $prot;
		$protein{$prot}->{GENE} = $gene;
		$protein{$prot}->{SEQ} = $seq;
		$genes{$gene}++;
	} else {
		chomp;
		$protein{$prot}->{SEQ} .= $_;

	}
}
close($fh);

$nprots = keys %protein;
$ngenes = keys %genes;

print "read in $nprots proteins and $ngenes genes\n"; #prints the number of proteins and genes in the reference genome file

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
	$counts = 0; #set count to 0
	foreach my $prot ( keys %protein ) {
		if ( $protein{$prot}->{SEQ} =~ /$pepseq/ ) {
			$counts++;
			$fprots{$prot}++;
			$fgenes{$protein{$prot}->{GENE}}++;
#			$protein{$prot}->$peps{$pepseq}++;
		}
	}
	$nprots = keys %fprots;
	$ngenes = keys %fgenes;
	$genelist = join(':', keys %fgenes);
	$protlist = join(':', keys %fprots);
	print "pep\t$nprots\t$ngenes\t$pepseq\t$genelist\t$protlist\n";
}
exit
