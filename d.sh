#!/bin/bash


#Prints out help on how to use this script
function  echoHelp () {
cat <<-END
Usage:
------
   -h | --help
     Display this help
   -c | --cookie
     Add the absolute filesystem location to the Netscape format cookie.txt file
   -d | --dir
     Specify the name of the directory this script must create from this level to download 
   -u | --url
     Specify the complete URI to download in the following URI format:  protocol://domain/directory
END
}



#Checks for Parameters
if [ $# -eq 0 ]; then
    echo "No arguments specified. Try -h for help"
    exit;
fi
       


#Processes Parameters
while [ ! $# -eq 0 ]
do
    case $1 in
        -c | --cookie)
            cookie=$2
	    echo "The cookie value is " $cookie
            shift 2 ;;
        -d | --dir)
	    dir=$2
            echo "The directory value is: " $dir
            shift 2 ;;
        -u | --url)
            url=$2
	    echo "The url is: " $url
            shift 2 ;;
        -h | \? | --help)
            echoHelp
            exit
            ;;
    esac
done

#Check Parameters have been successfully set
if ${dir+"false"}; then
   echo "Error: Please Specify the name of the directory this script must create from this level to download";
   exit;
elif ${cookie+"false"}; then
   echo "Error: Please Specify the absolute filesystem location to the Netscape format cookie.txt file"
   exit;
elif ${url+"false"}; then
   echo "Error: Please specify the complete URI to download in the following URI format:  protocol://domain/directory"
   exit;
elif  [ ! -f $cookie ]; then
   echo "Error: Please check the path to the specified Netscape cookie.txt file"
   exit;
fi

domain="https://www.safaribooksonline.com"
domainLength=${#domain}

dir_separator="/"
dirLength=$((${#dir} + ${#dir_separator}))

includePath3=${url:$domainLength}
includePath2=${includePath3%$dir_separator}
includePath=${includePath2},/static

echo "The includePath is: " $includePath

#Construct Container Directory
mkdir $dir
cd $dir

#Main Download in a recursive way
wget -k -r --no-directories -I $includePath --header='Host: www.safaribooksonline.com' --header='User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0' --header='Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header='Accept-Language: en-US,en;q=0.5' --header='Content-Type: application/x-www-form-urlencoded' --load-cookies $cookie $url

#Redownload all CSS
for file in *.css;
do
echo $file
wget -O- --header='Accept-Encoding: gzip,deflate,br' --header='Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header='Accept-Language: en-US,en;q=0.5' --header='Content-Type: application/x-www-form-urlencoded' https://www.safaribooksonline.com/static/CACHE/css/$file | gunzip > $file
done;

#Replace xhtml file extension with html file extension
for xhtmlFile in *.xhtml; 
do 
mv $xhtmlFile ${xhtmlFile: 0: $((${#xhtmlFile} -6))}.html; 
done;

#Replace  all in-file xhtml links with html links
for htmlFile in *.html
do
sed -i s/xhtml/html/g $htmlFile
done;
