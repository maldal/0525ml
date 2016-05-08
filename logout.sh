
_used="`expr $bytes_received + $bytes_sent`"
_used="`expr $_used / 1024`"
curl http://ovdata.applinzi.com/index.php/User/usedata.html?username=$username\&num=$_used
