#!/bin/bash

start=`date +%s`
echo "THIS MIGHT TAKE MORE TIME THAN BUILDING A KERNEL"
echo "................................................"

HOME_DIR=$PWD
BASE_DIR=(git/kernels/staging)
FILE="todo.txt"

cd $BASE_DIR
git checkout staging-testing
git pull
cd $HOME_DIR

arr=($(find $BASE_DIR/drivers/staging -name TODO))
if [ -f $FILE ];then
	rm $FILE
	echo "Existing todo file deleted"
fi

echo "Creating new todo file named" $FILE
echo "redirecting stdout to" $FILE
touch $FILE

for element in "${arr[@]}" 
do
	end=${#element}
	start=$(($end-4))
	a=${element:0:$start}
	echo $a
	test=($(find $a -name '*.c' -o -name '*.h' 2> /dev/null))
	for i in "${test[@]}" 
	do
    		$(perl $BASE_DIR/scripts/checkpatch.pl -f $i 1>> $FILE 2> /dev/null)
	done
done

end=`date +%s`
runtime=$((((end-start))/60*60))
echo "script finished in" $runtime "hrs"
