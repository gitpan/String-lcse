#!/usr/local/bin/perl
package String::lcse;
###################################################################
#  Chad Granum                                                    #
#                                                                 #
#  http://sourceforge.net/users/exodist/                          #
#                                                                 #
# Contact Info:                                                   #
#  exodist@yifan.net                                              #
#  (530) 583-2746                                                 #
#  ICQ: 14536019                                                  #
#  AIM, MSN, Yahoo: Exodist7                                      #
#  Jabber: Exodist@Jabber.com                                     #
###################################################################

#This package contains meathods for finding the largest common string.
#Will ignore ' '(Space) while finding matches (for instance "bye bye" would match "byebye"
#Will return the lognest form of the largest common string (if both "byebye" and "bye bye" are found, "bye bye" will be returned)
#    ^Ammendmant to above: Space between segmants is ignored, for instance of the string was divided into 2 segmants, "Bye Bye" and "Hello There" the space in the midle of the segmant will be counted, only space between segmants is optional.
#Will return Longest string found in the required percentage of strings (if the string "many" is found in twice as many strings as "even more", "even more" will be returned because it is longer)
#If 2 or more common sub-strings are the same length it will return the one found the most (if "ExampleA" is found 5 times, "ExampleB" 2 times, and "ExampleC" 20 times, "ExampleC" will be returned)
#If no sub-strings of the required length are found in the required percentage of strings than 0 will be returned.
#Will only match a sub-string once per string, for instance of a string was "Hello Hello" and the match was "Hello", it would only count 1 match
$VERSION = '0.1';
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(lcsQ lcsST lcsT lcs);

#-----Declare Functions----
sub lcsQ($$);
sub lcsST($$);
sub lcsT($$);
sub Strip($);
sub GetChars($);
sub lcs($$$$);
sub Sort($$$);
sub SafeExp($);
#-----Logic-----

#Replace underscores and dashes with spaces unless dash acts as a word joining (bye-bye), also removes duplicate spaces
#Param 0 is a reference to an array of strings.
sub Strip($)
{
    my ($In) = @_;
    foreach my $I (@$In)
    {
        $I =~ s/{|}|\[|\]|\(|\)|_+| -|- |  +/ /g; #We do nto care about brackets or parentheses, also removes double spaces, replaces underscores and dashes with spaces, buton replaces the dashes if there is a space on one side.
    }
}

#Quickly find the largest common string based on words (space seperated segmants of alphanumerics)
#Param 0 reference to an array of strings
#Param 1 Percentage of strings that need to contain the sub-string for it to be considered for return.
sub lcsQ($$)
{
    my ($In, $Percent) = @_; #Get Parameters
    Strip($In); #Strip the strings
    my @Segmants = ();
    my @Temp = ();
    my $Average = 0;
    foreach (@$In)
    {
        @Temp = ();
        @Temp = split;
        $Average += @Temp; #Add the number of words for this phrase to the average
        push(@Segmants,[@Temp]); #Add this array of segmants to the @Segmants array (Thats a mouth full)
    }
    $Average /= @Segmants; #Calculate the average number of words.
    return lcs( $In,\@Segmants,$Percent,($Average  * 15)/100); #Call the lcs function and let it work it's heart out, we use 15% of the Average as the minimum length of the string.
}

#Find the largest common string checking every character first running each string through Strip();
#Param 0 reference to an array of strings
#Param 1 Percentage of strings that need to contain the sub-string for it to be considered for return.
sub lcsST($$)
{
    my ($In, $Percent) = @_; #Get Parameters
    Strip($In); #Strip the strings
    return lcsT($In, $Percent); #Call lcsT now that the strings have been stripped
}

#Find the largest common string checking every character.
#Param 0 reference to an array of strings
#Param 1 Percentage of strings that need to contain the sub-string for it to be considered for return.
sub lcsT($$)
{
    my ($In, $Percent) = @_;  #Get Parameters
    #--Declare variables--
    my @Characters = ();
    my @Temp;
    my $Expr;
    my %String = {};
    my $Average = 0;
    foreach my $I (@$In) #For each of the strings...
    {
        @Temp = GetChars($I); #Get an array of all the characters for the string with space removed
        $Average += @Temp;
        push (@Characters, [@Temp]); #Push the array of characters onto the @Characters array
    }
    $Average /= @Characters;
    return lcs($In,\@Characters,$Percent,($Average  * 15)/100); #Call the lcs function and let it work it's heart out, we use 15% of the Average as the minimum length of the string.
}

#Generate an array of characters from a string, removing whitespace
sub GetChars($)
{
    $_ = shift; #Get the string parameter
    my @Characters = (); #Create an array to store the characters in
    while (/./) #While a character remains in the string (We want them all!)
    {        
        push(@Characters, $&) if ($& ne ' '); #Push the character onto the array, but do not put whitespace into the array of characters
        $_ = $'; #Place the remaining portion of the string into $_
    }
    # I know @Array = split(//,$String) followed by logic to remove the ' '(Space) would also work, but I am sure split being made to use a token to splot with would essentually waste operations, the logic I wrote is simple enough
    return @Characters;
}

#Find the longest common sub-string (This is where the real work is done ;-))
#param 0 reference to an array of strings to be matched
#param 1 reference to an array of arrays in which the strings in param 0 are split into segmants to iterate through
#param 2 is percentage of strings that need to contain the largest common string, if the number is below that mark 0 will be returned
#param 3 is minimum segmants for a match
#Algorith pattern will look like this:
#a b c d e
#a b c d
#a b c
#a b
#a
#  b c d e
#  b c d
#  b c
#  b
#    c d e
#    c d
#    c
#      d e
#      d

#a,b,c & d represent the divisions of a string.
sub lcs($$$$)
{
    my ($Strings, $SplitForm, $Percent, $Segmants) = @_; #Get Parameters
    $Segmants = 1 if ($Segmants < 1); #1 digit minimum match, though this is also rediculously low if you are trying to accomplish anything unless you are dividing by words at which point a 1 word match is exceptable.
    if ($#$Strings != $#$SplitForm) #If the Splitform array does not have the same ammount of elements as the array of strings
    {
        print("\nDid not get split form for each string, or too many split forms.\n"); #Call the user an idiot
        exit(1); #Laugh in his face.
    }
    my @Temp = ();
    my %Tracker = {}; #Use a hash to store how many matches an expression gets
    #Using a hash will make it slower at the end when you need to cycle through 
    #each element to find the largest common match and then the most found match
    #as apposed to just replacing each with the next longest as we go, however
    #using the hash will speed things up if we have a lot of similar strings
    #It will keep track of expressions already checked so we do nto check them again
    #Considering the operations involved in checking I have opted to use the hash. it will
    #be faster when it counts.
    my $Expr; #Used to hold the expression we are checking for a match with
    for (my $CS = 0; $CS < @{$Strings}; $CS++) #For each string, CS is current string index
    {
        for (my $LS = 0; $LS < (@{$SplitForm->[$CS]} - $Segmants); $LS++) #for each Split from left to right, LS is current index on the left side
        {
            for (my $RSCount = 0; (($RSCount < @{$SplitForm->[$CS]}) && ((@{$SplitForm->[$CS]} - $RSCount) - $LS >= $Segmants)); $RSCount++) #Keep track of digits away fromt he right side to stop at.
            {
                $Expr = ""; #Reset the expression string
                for (my $RS = $LS; $RS < (@{$SplitForm->[$CS]} - $RSCount); $RS++) #Start at the leftmost division we are checking and move right
                {
                    $Expr = $Expr . " *" if ($LS != $RS); #If we are on any iteration but the first (if rs and ls are still equal) then append " *" before appending the next division
                    $Expr = $Expr . $SplitForm->[$CS]->[$RS]; #Append the next segmant
                }
                $Expr = SafeExp($Expr); #The characters used in regular expressions need to be backslashed except '*'
                #---Match---
                if (!$Tracker{$Expr}) #If the $Expr key of the tracker hash has not yet been initilised (we have nto checked this expression yet)
                {
                    @Temp = (0, ""); #Clear the temp array
                    foreach my $X (@$Strings) #check each string
                    {
                        if ($X =~ m/$Expr/) #If the expression is found
                        {
                            $Temp[0]++; #Incriment the find record
                            $Temp[1] = $& if(length($&) > length($Temp[1])); #Put the longer fo the two strings into the identifier
                        }
                    }
                    $Tracker{$Expr} = [@Temp] if ($Temp[0] > 1);#Put the ID info into the tracker so long as there were more than 1 match
                }
            }
        }
    }
    return Sort(\%Tracker,$Percent,$#$Strings + 1);
}

#Runs through the tracker hash and pulls out the longest common string that meets the requirements.
#Param 0 = The tracker hash
#Param 1 = percent of strings that need to match
#Param 2 = Total strings
sub Sort($$$)
{
    my ($Tracker, $MinPercent, $Total) = @_; #Get parameters
    my $Current = 0; #Set current to 0, if no matches are found 0 will be returned
    my $Count = 0; #Count of current
    my $Error = 0; #If a potential problem is noticed this will be set, if it is resolved it will be unset
    foreach (%$Tracker) #For each element in the Tracker
    {        
        if (!(/ARRAY/)) #If the elemnt is not a reference to an array
        {
            next; #Next iteration
        }
        if ( (length($_->[1]) >= length($Current)) && (($_->[0] / $Total) * 100 >= $MinPercent) ) #if this match's length is greator or equal to the old and it fits the percentage of matching
        {
            if (length($_->[1]) == length($Current)) #if the 2 strings are of equal length (potential problem)
            {
                if ($Count > $_->[0]) #If the current has more matches there is no problem
                {
                    next; #Next iteration
                }
                elsif ($Count == $_->[0]) #If the count is also equal we have a problem unless a larger string is found
                {
                    warn("\nThe sub-strings: \"$Current\" and \"$_->[1]\" Both test the same! unless a larger match is found result may be innacurate!\n"); #Warn but do nto exit
                    $Error = 1; #Set error
                }
            }
            elsif ($Error) #If there is no potential problem and a problem has already been found it has now been resolved
            {
                warn("\nLonger sub-string found, erroneus outcome averted\n"); #Another warn to renounce the previous
                $Error = 0; #Unset error
            }
            $Current = $_->[1]; #Set this new one to current
            $Count = $_->[0]; #Set this ones count
        }
    }
    warn("\nLonger sub-string not found! Using first sub-string that fit, outcome may not be erranious!\n") if ($Error); #If error is set warn about the unresolved error
    return $Current; #Return eather the largest common sub-string, or 0 if none was found.
}

#The following function will make a text recognition expression safe. all metacharacters will be stripped with exception of '*'.
sub SafeExp($)
{
    my $Expr = $_[0];
    foreach my $I ('\.', '\[', '\]', '\{', '\}', '\/', '\(', '\)', '\^', '\$', '\?', '\|', '\+')
    {
        $Expr =~ s/$I//g;
    }
    return $Expr;
}

1; #this is here because it is required for a package that you "use" or so it would seem as it did not work thena  friend told me to put thsi here, now it works.
