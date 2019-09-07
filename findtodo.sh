#!/bin/bash

start=`date +%s`
echo "THIS MIGHT TAKE MORE TIME THAN BUILDING A KERNEL"
echo "................................................"

HOME_DIR=$PWD
BASE_DIR=(git/kernels/staging)
FILE="todo.txt"
STAGING="staging-testing"

cd $BASE_DIR

if [[ -s $(git status -uno | head -n 2 | tail -n 1 |
           sed 's/.*by //' | awk '{print $1;}' |
           awk '$0 ~/[^0-9]/ {  }') ]] ; then
    CURR_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ $CURR_BRANCH != $STAGING ] ; then
        git checkout $STAGING
    fi
    git pull
    git checkout $CURR_BRANCH
fi
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
	TEMP_DIR=${element:0:$start}
	echo $TEMP_DIR
	test=($(find $TEMP_DIR -name '*.c' -o -name '*.h' 2> /dev/null))
	for i in "${test[@]}"
	do
    		$(perl $BASE_DIR/scripts/checkpatch.pl -f $i 1>> $FILE 2> /dev/null)
	done
done

end=`date +%s`
runtime=$((((end-start))/60*60))
echo "script finished in" $runtime "hrs"
