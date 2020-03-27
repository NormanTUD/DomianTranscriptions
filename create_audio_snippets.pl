#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

main();

sub main {
	my $folder = 'snippets';
	my $downloads = 'downloads';
	unless (-d $folder) {
		mkdir $folder or die $!;
	}

	unless (-d $downloads) {
		mkdir $downloads or die $!;
	}

	my @files = ();

	while (my $file = <result/*.txt>) {
		push @files, $file;
	}

	foreach my $file (sort { rand() <=> rand() } @files) {
		my ($id, $contents) = read_file($file);

		my $fn = download_video_to_mp3($id, $downloads);
		cut_snippets($id, $fn, $contents, $folder);
	}
}

sub cut_snippets {
	my ($id, $fn, $contents, $folder) = @_;

	# ffmpeg -i file.mkv -ss 20 -to 40 -c copy file-2.mkv
	
	
	my %timestamps = ();

	while ($contents =~ m#\[\d\d:\d\d -> https://www\.youtube\.com/watch\?v=.*?&t=(\d+)\] (.*)#g) {
		my $result_file = "./$folder/$id-$1.mp3";
		my $result_file_text = "./$folder/$id-$1.txt";
		my $from = $1;
		my $text = $2;
		if(!-e $result_file) {
			my $command = qq#ffmpeg -ss $from -t 60 -i "$fn" -c:a libmp3lame "$result_file"#;
			print "$command\n";
			system($command);
		} else {
			print "Snippet $result_file already exists. Skipping...\n";
		}

		if(!-e $result_file_text) {
			open my $fh, '>', $result_file_text;
			print $fh $text;
			close $fh;
		} else {
			print "Snippet text $result_file already exists. Skipping...\n";
		}
	}

	#die Dumper \%timestamps;
	#die $contents;
}

sub read_file {
	my $file = shift;

	my $id = undef;

	if($file =~ m#result/(.*)\.txt$#) {
		$id = $1;
	}

	my $contents = '';

	open my $fh, '<', $file or die $!;
	while (my $line = <$fh>) {
		$contents .= $line;
	}

	return ($id, $contents);
}

sub download_video_to_mp3 {
	my $id = shift;
	my $folder = shift;
	my $filename = "$folder/$id.mp3";
	
	if(-e $filename) {
		print "$filename already exists. Skipping...\n";
	} else {
		my $command = qq#youtube-dl -x --audio-format mp3 --audio-quality 0 -o "$filename" -- "$id"#;
		print "$command\n";
		system($command);
	}

	return $filename;
}
