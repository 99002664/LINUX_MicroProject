#! bin/bash
while IFS=, read -r name email repo; do
    
[[ "$name" != "Name" ]] && echo "$name"
[[ "$email" != "Email ID" ]] && echo "$email"
if [[ "$repo" != "Repo link" ]]; then
    git clone "$repo"
    if [ "$?" == 0 ]; then
    GIT_STATUS="Clone Successful"
    else
    GIT_STATUS="Clone Failed"
    fi
    REPO_NAME=`echo "$repo" | cut -d'/' -f5`
    BUILD=`find $REPO_NAME -name Makefile -exec dirname {} \;`
    make -C "$BUILD"
    if [ "$?" == 0 ]; then
    BUILD_STATUS="Build Successful"
    else
    BUILD_STATUS="Build Failed"
    fi
    err=`cppcheck $REPO_NAME | grep "error" | wc -l`
    echo "$err"
    make test -C $BUILD
    FINAL_VAL=`find "$BUILD" -name "Test*.out"`
    echo "dir = $FINAL_VAL"
    valgrind "./$FINAL_VAL" 2> valgrinrd.csv
    VALGRI=`grep "ERROR SUMMARY" valgrinrd.csv`
    echo "ERROR = ${VALGRI:23:2}"
    echo "$name ,$email ,$repo ,$GIT_STATUS ,$BUILD_STATUS ,$err , ${VALGRI:23:2}" >> Report.csv
fi
done < Input.csv
