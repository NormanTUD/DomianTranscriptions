#!/usr/bin/perl

use strict;
use warnings;

main();

sub main {
	my $res = 'result';
	mkdir $res unless -d $res;

	while (my $filename = <*.txt>) {
		my $id = $filename;
		$id =~ s#\.txt$##g;
		my $contents = read_and_parse_file($filename, $id);

		write_file("$res/$id.txt", $contents);
	}
}

sub read_and_parse_file {
	my $file = shift;
	my $id = shift;

	my $contents = '';

	open my $fh, '<', $file or die $!;
	while (my $line = <$fh>) {
		if($line =~ m#^\[(\d+):(\d+)\]$#) {
			my ($hour, $minute) = ($1, $2);
			my $ytlink = create_ytlink($id, $hour, $minute);
			$line = "[$1:$2 -> $ytlink] ";
		#if($line =~ m#^(\[\d+:\d+ ->.*\])(.*)#) {
		#	$line = "\n$1 $2";
		}
		$contents .= $line;
	}
	close $fh;

	return $contents;
}

sub create_ytlink {
	my ($id, $hour, $minute) = @_;

	my $time = ($hour * 3600) + ($minute * 60);
	my $ytlink = 'https://www.youtube.com/watch?v='.$id.'&t='.$time;
	return $ytlink;
}

sub write_file {
	my $file = shift;
	my $contents = shift;

	open my $fh, '>', $file or die $!;
	print $fh $contents;
	close $fh or die $!;
}
