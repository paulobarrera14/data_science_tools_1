#!/bin/bash
# Bash script to calculates the MAX, MIN, MEDIAN and MEAN of the word frequencies in the
# file the  https://www.gutenberg.org/files/58785/58785-0.txt

if [ $# -ne 1 ]
   then
       echo "Please provide a txt file url"
       echo "usage ./calculate_basic_stats.sh  url"
       #exit with error
       exit 1
fi   

#this downloads the file from the URL being argument $1 and saves it as tempfile.txt
curl -o tempfile.txt $1

echo  "############### Statistics for file  ############### "

# Q1(.5 point) write  positional parameter after echo to print its value. It is the file url used by curl command.

echo "URL used by curl command: $1"

# sort based on multiple columns

#Q2(2= 1+1 for right sorting of each columns). Write last sort command options so that first column(frequencies) is
#sorted via numerical values and
#second column is sorted by reverse alphabetical order

#-k option specifies sort key, -k1,n1 sorts first field numerically then -k2,2r sorts second field in reverse order
sorted_words=`curl -s $1 | tr [A-Z] [a-z] | grep -oE "\w+" | sort | uniq -c | sort -k1,1n -k2,2r`

total_uniq_words=`echo "$sorted_words" | wc -l`
echo "Total number of words = $total_uniq_words"

#Q3(1=.5+.5 points ) Complete the code in the following echo statements to calculate the  Min and Max frequency with respective word
#Hint:  Use sorted_words variable, head, tail and command susbtitution

#now there is a subshell to echo the freq and word from sorted_words so that there is no broken pipe
echo "Min frequency and word: $(head -n 1 <<< "$sorted_words")"
#the command below causes a broken pipe, why? and why does it not break for tail. Which is right way (question for prof)
#echo "Mix frequency and word: $(echo "$sorted_words" | head -n 1)"
echo "Max frequency and word: $(echo "$sorted_words" | tail -n 1)"


#Median calculation

#Q4(2=1(taking care of even number of frequencies)+1 points(right value of median)). Using sorted_words,
#write code for median frequency value calculation. Print the value of the median with an echo statement, stating
# it is a median value.
#Code must check even or odd  number of unique words. For even case median is the mean of middle two values,
#for the odd case, it is middle value in sorted items.

if (($total_uniq_words % 2 == 0));
   then
	middle_even="$((($total_uniq_words + 1) / 2))"
	echo "There is an even number of unique words, the median is $middle_even and median value is $(echo "$sorted_words" | awk -v line="${middle_even}" 'NR == line')"
else
	middle_odd="$(($total_uniq_words) / 2)"
	echo "There is an odd number of unique words, the median is $middle_odd and median value is $(echo "$sorted_words" | awk -v "${middle_odd}" 'NR == line')"
fi

# Mean value calculation
#Q5(1 point) Using for loop, write code to update count variable: total number of unique words
#Q6(1 point) Using for loop, write code to update total_freq variable : sum of frequencies
total_freq=0
count=0

#loops through lines of sorted_words variable, frequency and word are the two different variables
while read -r frequency word; 
   do
	#adds +1 for each unique word
	count=$((count + 1))
#each line from the $sorted_words string is fed into the while loop as a new line of input
done <<< "$sorted_words"

echo "Total unique words = $count"

#loops through lines of sorted_words variable again
while read -r frequency word;
   do
	#adds frequency to total_freq
	total_freq=$((total_freq + frequency))
done <<< "$sorted_words"

echo "Sum of frequencies = $total_freq"

#Q7(1 point) Write code to calculate mean frequency value based on total_freq and count

#makes sure that count is not 0 so no divide by 0 error
if [ $count -ne 0 ];
   then
	mean=$(echo "$total_freq / $count" | bc)

	echo "Mean frequency using integer arithmetics = $mean"

fi

#Q8(1 point) Using bc -l command, calculate mean value.
# Write your code after = 
echo "Mean frequency using floating point arithemetics =  $(echo "scale=2; $total_freq / $count" | bc -l)"

# Q9 (1 point) Complete lazy_commit bash function(look for how to write bash functions) to add, commit and push to the remote master.
# In the command prompt, this function is used as
#
# lazygit file_1 file_2 ... file_n commit_message
#
# This bash function must take files name and commit message as positional parameters
# and perform followling git function
#
# git add file_1 file_2 .. file_n
# git commit -m commit_message
# git push origin master

lazycommit() {
#checks to make sure there is atleast 1 file
   if [ "$#" -lt 1 ];
   then
	echo "Usage: lazycommit <file1> <file2> ... <commit message>"
	return 1
   fi
# ${@:1:$#-1} applies to all arguments but the last one
   for arg in "${@:1:$#-1}";
   do
	git add "$arg"
   done
# applies to the last argument
   git commit -m "${!#}"

}

rm tempfile.txt 
