#Purpose = git push to repo and pull to server

echo -n "Enter the details of your deployment (i.e. 4-FEB-2014 Updating this script.) > "
read comment
echo "You entered $comment"

#zero out php_errors.log
> php_errors.log

#Push to AWS
echo "Committing to git..."
git add .
git commit -m "$comment"
echo "Pushing to github..."
set -v verbose #echo on
git push 

#
# curl url to pull latest on backend
#
#curl http://YOUR_IP_DNS_HERE/?action=gitpull
#curl http://YOUR_IP_DNS_HERE/?action=clearlog
