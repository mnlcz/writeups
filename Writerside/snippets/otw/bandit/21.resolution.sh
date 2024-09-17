ls /etc/cron.d/

chmod 644 /SOME/PATH
cat /etc/bandit_pass/bandit22 > /SOME/PATH

cat /usr/bin/cronjob_bandit22.sh | grep '>' | awk -F'>' '{ print $NF }' | xargs cat