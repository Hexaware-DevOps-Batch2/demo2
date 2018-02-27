#!/bin/bash
DIRECTORY="~/my-projects/demo2"
PROPERTIESFILE="properties.txt"
SERVER="ec2-user@ec2-18-220-236-227.us-east-2.compute.amazonaws.com"
KEY="trainingkeypair.pem"
APPFILE="application.yml"
CREATED=true
TRANSFERED=true
UPDATED=false

function createDirectory(){
    ssh -i $KEY $SERVER "mkdir -p $DIRECTORY"
	if [ "$?" -eq "0" ];
		then
			echo "Directory created"
		else
			CREATED=false
	fi
}
function transferFileA(){
	if ssh -i $KEY $SERVER '[ -e $DIRECTORY/$APPFILE ]'
	then
		UPDATED=true
	fi
	
    scp -i $KEY application.yml $SERVER:$DIRECTORY
	if [ "$?" -eq "0" ];
		then
			echo "File transfered"
		else
			TRANSFERED=false
	fi
}
function transferFileB(){
	if ssh -i $KEY $SERVER '[ -e $DIRECTORY/$APPFILE ]'
	then
		UPDATED=true
	fi
	
    scp -i $KEY script.sh $SERVER:$DIRECTORY
	if [ "$?" -eq "0" ];
		then
			echo "File transfered"
		else
			TRANSFERED=false
	fi
}
function transferFileC(){
	if ssh -i $KEY $SERVER '[ -e $DIRECTORY/$APPFILE ]'
	then
		UPDATED=true
	fi
	
    scp -i $KEY trainingAmazonLinux.pem $SERVER:$DIRECTORY
	if [ "$?" -eq "0" ];
		then
			echo "File transfered"
		else
			TRANSFERED=false
	fi
}
function transferFileD(){
	if ssh -i $KEY $SERVER '[ -e $DIRECTORY/$APPFILE ]'
	then
		UPDATED=true
	fi
	
    scp -i $KEY trainingkeypair.pem $SERVER:$DIRECTORY
	if [ "$?" -eq "0" ];
		then
			echo "File transfered"
		else
			TRANSFERED=false
	fi
}
function transferFileE(){
	if ssh -i $KEY $SERVER '[ -e $DIRECTORY/$APPFILE ]'
	then
		UPDATED=true
	fi
	
    scp -i $KEY trainingubuntukeypair.pem $SERVER:$DIRECTORY
	if [ "$?" -eq "0" ];
		then
			echo "File transfered"
		else
			TRANSFERED=false
	fi
}

createDirectory
transferFileA
transferFileB
transferFileC
transferFileD
transferFileE
