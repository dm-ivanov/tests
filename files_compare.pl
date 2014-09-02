#!/usr/bin/perl -w

use strict;
use warnings;
use Time::HiRes;

# Наполнение тестовых файлов,
sub fill_files {
	my $file1 = 'file1.txt';
	my $file2 = 'file2.txt';

	open(my $file1_fh, ">", $file1) or die "Can't open file $file1: $!";
	open(my $file2_fh, ">", $file2) or die "Can't open file $file2: $!";

	foreach my $num (1..20_000) {
		for my $s ('A'..'Z','a'..'z') {
			my $str = $num . "_" . $s x (int(rand 100)+1);
			my $mod = int rand 2 == 1 ? "_MOD" : ""; # отличия в строках у файлов

			print $file1_fh $str . "\n";
			print $file2_fh $str . "$mod\n";
		}
	}
	 
	close $file1_fh or die "Can't close file $file1: $!";
	close $file2_fh or die "Can't close file $file2: $!";
}

#fill_files();

my $start_time = Time::HiRes::time();

my $file1 = 'file1.txt';
my $file2 = 'file2.txt';
my $file_tmp = 'file_tmp.txt';
my $file_tmp2 = 'file_tmp2.txt';

open(my $file1_fh, "<$file1") or die "Can't open file $file1: $!";
open(my $file2_fh, "<$file2") or die "Can't open file $file2: $!";
open(my $file_tmp_fh,  ">$file_tmp")  or die "Can't open file $file_tmp: $!";
open(my $file_tmp2_fh, ">$file_tmp2") or die "Can't open file $file_tmp2: $!";

my $block_size = 1_000_000; # строк

my $read_from_tmp_file = 0;
my $read_file_fh  = $file1_fh;
my $write_file_fh = $file_tmp_fh;

while (1) {
	my $string_count = 0;
	my %block;
#	my %block_small;

	while (<$file2_fh>) {
		my $str = $_;
		$block{$str}++;
#		$block_small{substr($str, 0, 4)}++;
		last if $string_count++ > $block_size;
	}

	last unless $string_count;

	while (<$read_file_fh>) {
		my $str = $_;
		print $write_file_fh $str unless exists $block{$str};
#		print $write_file_fh $str unless exists $block_small{substr($str, 0, 4)} && exists $block{$str};
	}

	close $file_tmp_fh  or die "Can't close file $file_tmp: $!";
	close $file_tmp2_fh or die "Can't close file $file_tmp2: $!";

	if ($read_from_tmp_file) {
		$read_from_tmp_file = 0;

		open($file_tmp_fh,  ">$file_tmp")  or die "Can't open file $file_tmp: $!";
		open($file_tmp2_fh, "<$file_tmp2") or die "Can't open file $file_tmp2: $!";

		$read_file_fh  = $file_tmp2_fh;
		$write_file_fh = $file_tmp_fh;
	}
	else {
		$read_from_tmp_file = 1;

		open($file_tmp_fh,  "<$file_tmp")  or die "Can't open file $file_tmp: $!";
		open($file_tmp2_fh, ">$file_tmp2") or die "Can't open file $file_tmp2: $!";

		$read_file_fh  = $file_tmp_fh;
		$write_file_fh = $file_tmp2_fh;
	}
}

close $file1_fh or die "Can't close file $file1: $!";
close $file2_fh or die "Can't close file $file2: $!";
close $file_tmp_fh or die "Can't close file $file_tmp: $!";
close $file_tmp2_fh or die "Can't close file $file_tmp2: $!";

printf "time: %f\n", Time::HiRes::time() - $start_time;

