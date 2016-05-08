
if [ -z "`curl http://ovdata.applinzi.com/index.php/User/checklogin.html?api\\&username=$username\\&password=$password | grep ^1`" ] ;then
exit 1
fi
exit 0
