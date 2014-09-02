#!/usr/bin/perl -w

use strict;
use warnings;

sub text_justify($$) {
	my $text = shift;
	my $paragraph_max_length = shift;

	my $space = ' ';
	my $space_length = 1;
	my $paragraph_start_length = 4;
	my $header_max_length = int($paragraph_max_length / 2);

	my @result_strings;

	foreach my $paragraph_string (split /¶/, $text) {
		$paragraph_string =~ s/^\s+//;
		$paragraph_string =~ s/\s+$//;

		my @paragraph_strings;
		my @paragraph_words = split /\s+/, $paragraph_string;

		my %string = (
			words  => [], # слова
			length => 0,  # длина строки с учетом пробелов между словани
			is_header => 0, # Заголовок или нет (параграф)
		);

		if (length($paragraph_string) > $header_max_length || split(/\n+/, $paragraph_string) > 1) {
			unless (@paragraph_strings) {
				$string{length} = $paragraph_start_length; # для первой строки отступ
			}

			foreach my $word (@paragraph_words) {
				my $word_length = length $word;
				my $string_new_length = $string{length} + $space_length + $word_length;
				my $string_full = 0;

				if (!@{$string{words}}) {
					# Если в строке нет слов, то добавим его, даже если оно длиннее допустимой длины строки,
					# оно будет единственным словом в строке.
					$string{words} = [$word];
					$string{length} += $word_length;
				}
				elsif ($string_new_length > $paragraph_max_length) {
					# Не добавляем ничего, в текущую строку, но добавим в следующую
					push @paragraph_strings, {%string};

					$string{words} = [$word];
					$string{length} = $word_length;
				}
				elsif ($string_new_length <= $paragraph_max_length) {
					# Добавляем слово
					push @{$string{words}}, $word;
					$string{length} += $space_length + $word_length;
				}

				if ($string{length} >= $paragraph_max_length) {
					push @paragraph_strings, {%string};

					$string{words} = [];
					$string{length} = 0;
				}
			}

			push @paragraph_strings, {%string} if @{$string{words}};
		}
		elsif (@paragraph_words) {
			$string{words} = \@paragraph_words;
			$string{is_header} = 1;

			push @paragraph_strings, {%string};
		}

		my $new_paragraph = 1; # флаг "красной" строки

		for (my $i=0; $i<=$#paragraph_strings; $i++) {
			my $string = $paragraph_strings[$i];

			if ($string->{is_header}) {
				$string->{str} = join($space, @{$string->{words}});
			}
			else {
				$string->{str} = '';

				if ($new_paragraph) {
					$string->{str} = $space x $paragraph_start_length;
					$new_paragraph = 0;
				}

				if ($string->{length} == $paragraph_max_length) {
					$string->{str} .= join($space, @{$string->{words}});
				}
				else {
					my $add_spaces_count = $paragraph_max_length - $string->{length};
					$string->{spaces} = $add_spaces_count;
					$string->{spaces_count} = [0]; # перед первым словом пробелы не добавляем

					if (@{$string->{words}} > 1) {
						while ($add_spaces_count) {
							for (my $j=$#{$string->{words}}; $j>0; $j--) {
								$string->{spaces_count}->[$j]++;
								$add_spaces_count--;
								last unless $add_spaces_count;
							}
						}
					}

					for (my $j=0; $j<=$#{$string->{words}}; $j++) {
						my $spaces_count = ($string->{spaces_count}->[$j] || 0);
						$spaces_count++ if $j > 0; # начиная со второго слова, есть хотя бы один пробел перед словом
						$string->{str} .= ($space x $spaces_count) . $string->{words}->[$j];
					}
				}
			}

			push @result_strings, $string->{str};
		}
	}

	return \@result_strings;
}

sub test {
	my $text = <<_TEXT_;
string1Word1 string1Word2 string1Word3 string1Word4 string1Word5 string1Word6. string1Word7 string1Word8. string1Word9 string1Word10, string1Word11 string1Word12.¶
Header if str > 36¶
string2Word1 string2Word2 string2Word3 string2Word4 string2Word5 string2Word6. string2Word7 string2Word8. string2Word9 string2Word10.¶
string3Word1 string3Word2 string3Word3 string3Word4 string3Word5 string3Word6¶

string4Word1 string4Word2
string4Wooooooooooooooooooooooooooooooord3 string4Word4 string4Word5 string4Word6. string4Word7
string4Word8. string4Word9 string4Word10 string4Word11 string4Word12 string4Word13 string4Word14 string4Word15.
string4Word16
string4Word17 string4Word18. string4Word19. 
string4Word20 string4Word21 string4Word22 string4Word23 string4Word24 string4Word25.¶
N o t H e a d e r
N o t H e a d e r¶
_TEXT_

	for (my $paragraph_max_length=20; $paragraph_max_length<=120; $paragraph_max_length+=5) {
		my $control_str = '-' x $paragraph_max_length;
		my $strings = text_justify($text, $paragraph_max_length);

		print $control_str, $paragraph_max_length, "\n", join("\n", @$strings), "\n\n\n";
	}
}


