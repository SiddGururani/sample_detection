--------------------------------------------------------------------------------------------------
Copyright and terms of use (DO NOT REMOVE):

The code is made freely available for non-commercial uses only, provided that the copyright 
header in each file not be removed, and suitable citation(s) (see below) be made for papers 
published based on the code.

The code is not optimized for speed, and we are not responsible for any errors that might
occur in the code.

The copyright of the code is retained by the authors.  By downloading/using the code you
agree to all the terms stated above.

   Lin, J., Keogh, E., Lonardi, S. & Chiu, B. 
   "A Symbolic Representation of Time Series, with Implications for Streaming Algorithms." 
   In proceedings of the 8th ACM SIGMOD Workshop on Research Issues in Data Mining and 
   Knowledge Discovery. San Diego, CA. June 13, 2003. 


   Lin, J., Keogh, E., Patel, P. & Lonardi, S. 
   "Finding Motifs in Time Series". In proceedings of the 2nd Workshop on Temporal Data Mining, 
   at the 8th ACM SIGKDD International Conference on Knowledge Discovery and Data Mining. 
   Edmonton, Alberta, Canada. July 23-26, 2002

Copyright (c) 2003, Eamonn Keogh, Jessica Lin, Stefano Lonardi, Pranav Patel. All rights reserved.


Please direct all questions or comments to jessica@cs.ucr.edu and eamonn@cs.ucr.edu
--------------------------------------------------------------------------------------------------



--------------------
timeseries2symbol.m:
--------------------
 
This function takes in a time series and convert it to string(s).
 There are two options:
   1. Convert the entire time series to ONE string
   2. Use sliding windows, extract the subsequences and convert these subsequences to strings

 For the first option, simply enter the length of the time series as "N"
   ex. We have a time series of length 32 and we want to convert it to a 8-symbol string,
       with alphabet size 3:
       timeseries2symbol(data, 32, 8, 3)
 For the second option, enter the desired sliding window length as "N"
   ex. We have a time series of length 32 and we want to extract subsequences of length 16 using
       sliding windows, and convert the subsequences to 8-symbol strings, with alphabet size 3:
       timeseries2symbol(data, 16, 8, 3)
 

 Input:
   data              is the raw time series. 
   N                 is the length of sliding window (use the length of the raw time series
                     instead if you don't want to have sliding windows)
   n                 is the number of symbols in the low dimensional approximation of the sub sequence.
   alphabet_size     is the number of discrete symbols. 2 <= alphabet_size <= 10, although alphabet_size = 2 is a 
		     special "useless" case.

 Output:
   symbolic_data:    matrix of symbolic data (no-repetition).  If consecutive subsequences
                     have the same string, then only the first occurrence is recorded, with
                     a pointer to its location stored in "pointers"
   pointers:         location of the first occurrences of the strings

 N/n must be an integer, otherwise the program will give a warning, and abort.

 The variable "win_size" is assigned to N/n, this is the number of data points on the raw 
 time series that will be mapped to a single symbol, and can be imagined as the 
 "compression rate".

 The symbolic data is returned in "symbolic_data", with pointers to the subsequences  

----------
min_dist.m
----------

 This function computes the minimum (lower-bounding) distance between two strings.  The strings
 should have equal length.
   Input:
       str1: first string
       str2: second string
       alphabet_size: alphabet size used to construct the strings
       compression_ratio: original_data_len / symbolic_len
   Output:
       dist: lower-bounding distance

   usage: dist = min_dist(str1, str2, alphabet_size, compression_ratio)

 This distance measure is not the best measure to use for comparing strings,
 if you are NOT going to follow up with access to the original data. This is
 because it cannot discriminate between two strings that differ only in the
 ith place, by consecutive symbols.  For example the min_dist between 'abba'
 and  'abbb' is zero.
 However, in practice, the min_dist function works very well for
 classification and clustering, even when you do not follow up with access to
 the original data. See [1].


---------
sax_demo:
---------

This code demonstrates the first case described in timeseries2symbol.m (for the
second case, see the example below). It provides a step-by-step demo of SAX 
(Symbolic Aggregate approXimation).  Press enter for the next step.

   usage: [str] = sax_demo
          [str] = sax_demo(data)


--------------
mindist_demo.m
--------------

  This function demonstrates that min_dist lower-bounds the true Euclidean distance.
Suppose there are two time series A and B.  The demo shows the euclidean distance
and the mindist.


>> mindist_demo

sax_version_of_A =

     3     4     2     1     1     3     4     2


sax_version_of_B =

     1     1     3     4     3     1     1     4


euclidean_distance_A_and_B =

   10.9094


ans =

    5.3600				---> This is the mindist



-----------------
symbolic_visual.m
-----------------

This demo presents a visual comparison between SAX and PAA and shows how SAX can represent
data in finer granularity while using the same, if not less, amount of space as PAA.
 
The input parameter [data] is optional.  The default # of PAA segments is 16, and the alphabet
size is 4.




--------
Examples:
--------

You can type this up in your matlab:

Recall that there are two options for timeseries2symbol.  The first option is demonstrated in
sax_demo.m


Now here is an example of the latter. We are going to convert time series of
length 50, with a sliding window of 32, into 8 symbols, with and alphabet
size of 3.

>> [symbolic_data, pointers] = timeseries2symbol(long_time_series,32,8,alphabet_size)
symbolic_data =
     1     1     3     3     3     3     1     1
     1     2     3     3     3     2     1     1
     1     3     3     3     3     1     1     1
     2     3     3     3     2     1     1     1
     3     3     3     3     1     1     1     1
     3     3     3     2     1     1     1     2
     3     3     3     1     1     1     1     3
     3     3     2     1     1     1     2     3
     3     3     1     1     1     1     3     3
     3     2     1     1     1     2     3     3
pointers =
     1
     2
     5
     6
     9
    10
    13
    14
    17
    18

Note that each row corresponds to a subsequence (with overlap)

The SAX word at 3 and 4 were omitted, since they where the same as the word
at 2, same for 7 and 8, which were the same as 6 etc (look at the pointers)

It might be helpful to view the data this way

>> [pointers symbolic_data ]
ans =
     1     1     1     3     3     3     3     1     1
     2     1     2     3     3     3     2     1     1
     5     1     3     3     3     3     1     1     1
     6     2     3     3     3     2     1     1     1
     9     3     3     3     3     1     1     1     1
    10     3     3     3     2     1     1     1     2
    13     3     3     3     1     1     1     1     3
    14     3     3     2     1     1     1     2     3
    17     3     3     1     1     1     1     3     3
    18     3     2     1     1     1     2     3     3


So the first word is (1     1     3     3     3     3     1     1) , 
   the 9th word is (3     3     3     3     1     1     1     1)  , 
   the 14 word is (3 	3     2     1     1     1     2     3)





--------------

[1] Lin, J., Keogh, E., Lonardi, S. & Chiu, B. 
   "A Symbolic Representation of Time Series, with Implications for Streaming Algorithms." 
   In proceedings of the 8th ACM SIGMOD Workshop on Research Issues in Data Mining and 
   Knowledge Discovery. San Diego, CA. June 13, 2003. 

[2] Lin, J., Keogh, E., Patel, P. & Lonardi, S. 
   "Finding Motifs in Time Series". In proceedings of the 2nd Workshop on Temporal Data Mining, 
   at the 8th ACM SIGKDD International Conference on Knowledge Discovery and Data Mining. 
   Edmonton, Alberta, Canada. July 23-26, 2002