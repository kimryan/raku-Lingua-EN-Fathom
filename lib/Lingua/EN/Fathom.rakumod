use v6;
unit module Lingua::EN::Fathom:ver<0.0.3>:auth<zef:kimryan> ;
use Lingua::EN::Syllable;
use Lingua::EN::Sentence;

class Fathom is export
{
    my $.num_words;
    my $.num_sents;
    my $.num_text_lines;
    my $.num_blank_lines;
    my $.num_paragraphs;    
    my $.num_chars;
    my $.num_syllables;
    my $.num_complex_words;
    my $.words_per_sentence;
    my $.syllables_per_word ;
    my $.percent_complex_words;    
    my %.words;    
    
    my $.fog;
    my $.flesch;
    my $.kincaid;
    
    # Private attributes
    has $!in_paragraph;

    method !reset
    {
        $.num_words = 0;
        $.num_sents = 0;
        $.num_text_lines = 0;
        $.num_blank_lines = 0;
        $.num_paragraphs = 0;    
        $.num_chars = 0;
        $.num_syllables = 0;
        $.num_complex_words = 0.0;
        $.words_per_sentence = 0.0;
        $.syllables_per_word = 0.0;
        $.percent_complex_words = 0.0;
        
        $.fog = 0.0;
        $.flesch = 0.0;
        $.kincaid = 0.0;
    }
    
    method new
    {
        self!reset;
        self.bless;
    }
         
    # Analyse a block of text, stored as a string. The string may contain lineterminators.
    method analyse_block($block,$accumulate)
    {   
         unless ( $accumulate )
         {
            self!reset;         
         }
         
         unless ( $block )
         {
            return;
         }
         
         $!in_paragraph = 0;      
         my @all_lines = $block.split(/\n/);
               
         for  @all_lines -> $one_line
         {         
             self!analyse_line($one_line);
         }
         # Use external module Lingua::EN::Sentence:
         $.num_sents += $block.sentences.elems;
             
         self!calculate_readability;     
   }
    
   #------------------------------------------------------------------------------
   # Analyse text stored in a file, reading from the file one line at a time
   
   method analyse_file($file_name,$accumulate)
   {   
        unless ( $accumulate )
        {
            self!reset;             
        }
         
        # Only analyse non-empty files 
        unless (  $file_name.IO.e or  $file_name.IO.z )
        {
           say "File $file_name is missing or empty";
           
        }
        my $text = $file_name.IO.slurp; # may not work for very large files
        $.analyse_block($text,$accumulate);
   }  
    
   method report
   {      
   
      my $report = '';
   
      # $text->{file_name} and
      # $report .= sprintf("File name                  : %s\n",$text->{file_name} );
   
      $report ~=  sprintf("Number of characters       : %d\n",  $.num_chars);
      $report ~=  sprintf("Number of words            : %d\n",  $.num_words);
      $report ~=  sprintf("Percent of complex words   : %.2f\n",$.percent_complex_words);
      $report ~=  sprintf("Average syllables per word : %.4f\n",$.syllables_per_word);
      $report ~=  sprintf("Number of sentences        : %d\n",  $.num_sents);
      $report ~=  sprintf("Average words per sentence : %.4f\n",$.words_per_sentence);
      $report ~=  sprintf("Number of text lines       : %d\n",  $.num_text_lines);
      $report ~=  sprintf("Number of blank lines      : %d\n",  $.num_blank_lines);
      $report ~=  sprintf("Number of paragraphs       : %d\n",  $.num_paragraphs);
   
      $report ~=  "\n\nREADABILITY INDICES\n\n";
      $report ~=  sprintf("Fog                        : %.4f\n",$.fog);
      $report ~=  sprintf("Flesch                     : %.4f\n",$.flesch);
      $report ~=  sprintf("Flesch-Kincaid             : %.4f\n",$.kincaid);
   
      return($report);
   }

    
   #------------------------------------------------------------------------------
   # Private methods
   #------------------------------------------------------------------------------
   
   # Increment number of text lines, blank lines and paragraphs
   
   method !analyse_line($one_line)
   {      
      if ( $one_line ~~ /\w/ )
      {
         chomp($one_line);
         
         self!analyse_words($one_line);
         $.num_text_lines++;
      
         unless ( $!in_paragraph )
         {
            $.num_paragraphs++;
            $!in_paragraph = 1;
         }
      }
      else # empty or blank line
      {
         $.num_blank_lines++;
         $!in_paragraph = 0;
      }      
   }

   #------------------------------------------------------------------------------
   # Detect real words in line. Increment character, syllable, word, and complex word counters.
   
   method !analyse_words($one_line)
   {
       $.num_chars += $one_line.chars;
              
       my $fixed_line = $one_line;
       # Words may include hyphens and apostrophes
       my @words =  $fixed_line.comb(/[\w|\-|\'|\.]+/);       
       
       for @words -> $word
       {
            # Identify words, including acronyms and numbers
            # Ignore strings such as like  , #### ____ &,...
            # No detection of valid words so ABCD, Gr8 etc are acceptable
            
            next if ($word !~~ /\w/); # Allow for slang like Gr8
            next if ($word ~~ /_+/);  # All underlines, underscore is part of \w char set
            
            my $fixed_word = $word.lc;
            $fixed_word ~~ s/\.$//; # remove end of sentence markers
            
            # retain occurenc of each unique word
            %.words{$fixed_word}++;
            
            $.num_words++;
            # Use subroutine from Lingua::EN::Syllable
            my $current_num_syllables = syllable($fixed_word);            
 
            # Required for Fog index, count non hyphenated words of 3 or more
            # syllables. Should add check for proper names in here as well
            if ( $current_num_syllables > 2 and $fixed_word !~~ /\-/ )
            {
               $.num_complex_words++;              
            }
            $.num_syllables = $.num_syllables + $current_num_syllables;
       }       
   }
   
   # Calculate all the stats needed to cfreate readability indices
   method !calculate_readability
   {      
      if ($.num_sents && $.num_words )
      {
   
        $.words_per_sentence = $.num_words / $.num_sents;
        $.syllables_per_word = $.num_syllables / $.num_words;
        $.percent_complex_words =
            ($.num_complex_words / $.num_words ) * 100;
   
        $.fog = ($.words_per_sentence + $.percent_complex_words ) * 0.4;
   
        $.flesch =  206.835 - (1.015 * $.words_per_sentence) -
            (84.6 * $.syllables_per_word);
   
        $.kincaid =  (11.8 * $.syllables_per_word) +
            (0.39 * $.words_per_sentence) - 15.59;
      }    
   }
#------------------------------------------------------------------------------
# end of methods
}   
    

