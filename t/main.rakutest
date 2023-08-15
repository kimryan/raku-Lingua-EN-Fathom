use v6.*;
use Lingua::EN::Fathom;
use Test;

plan 6;


my $sample = q{
Returns the number of words in the analysed text file or block. A word must
consist of letters a-z with at least one vowel sound, and optionally an
apostrophe or hyphen. Items such as "&, K108, NSW" are not counted as words.
Common abbreviations such a U.S. or numbers like 1.23 will not denote the end of
a sentence.


};

my $f = Fathom.new();
$f.analyse_block($sample);

is $f.num_chars, 313, 'sub num_chars';
is $f.num_words, 54,  'sub num_words';
is $f.num_sentences,  4,'sub num_sentences' );
is $f.num_text_lines, 5,'sub num_text_lines' );
is $f.num_blank_lines,4,'sub num_blank_lines' );
is $f.num_paragraphs, 1,'sub num_paragraphs' );