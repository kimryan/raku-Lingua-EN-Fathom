
NAME

Lingua::EN::Fathom - Measure readability of English text

SYNOPSIS


    use Lingua::EN::Fathom;
    
    my $sample =
    q{Determine the readability of the given text file or block. Words
    need to contain letters, and optionally numbers (such as Gr8). There
    is no understanding of context.
    
    Numbers like 1.234 are valid, but strings like #### are ignored.};
    
    my $f = Fathom.new();
    $f.analyse_block($sample,0);
    say $f.report;

Output is:
Number of characters       : 227
Number of words            : 37
Percent of complex words   : 13.51
Average syllables per word : 1.5676
Number of sentences        : 4
Average words per sentence : 9.2500
Number of text lines       : 4
Number of blank lines      : 1
Number of paragraphs       : 2


READABILITY INDICES

Fog                        : 9.1054s
Flesch                     : 64.8300
Flesch-Kincaid             : 6.5148

# Access individual statistics
say $f.percent_complex_words;  # 13.51

# Analyse file contents, accumualting statisitics over succesive calls
my $accumulate = 1;
$f.analyse_file('sample.txt',$accumulate);


REQUIRES

Lingua::EN::Syllable, Lingua::EN::Sentence

DESCRIPTION

This module analyses English text in either a string or file. Totals are
then calculated for the number of characters, words, sentences, blank
and non blank (text) lines and paragraphs.

Three common readability statistics are also derived, the Fog, Flesch and
Kincaid indices.

All of these properties can be accessed through method attributes, or by
generating a text report.


LIMITATIONS

The syllable count provided in Lingua::EN::Syllable is about 90% accurate
The fog index should exclude proper names

AUTHOR

Lingua::EN::Fathom was written by Kim Ryan <kimryan at cpan dot org>.

COPYRIGHT AND LICENSE

Copyright (c) 2023 Kim Ryan. All rights reserved.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.



