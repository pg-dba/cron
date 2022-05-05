#!/bin/bash

FileReport='/cronwork/pgbadger_report.html'
FileTmp='/cronwork/pgbadger-incremental.last'

echo "[pgbadger]  Generate Weekly Report Started"

DS=$(date +"%Y-%m-%d 00:00:00.0+03" -d "7 day ago");
DF=$(date +"%Y-%m-%d 00:00:00.0+03");
#echo "DS=${DS} DF=${DF}"; 
pgbadger --no-progressbar --timezone +3 --jobs 1 --format csv --outfile ${FileReport} --begin "${DS}" --end "${DF}" --last-parsed ${FileTmp} \
  $(find /pglog/*.csv -type f -newermt "${DS}" ! -newermt "${DF}") 2>&1 | ts '[pgbadger] ';
#chown 999:999 ${FileReport};

echo "[pgbadger]  Generate Weekly Report Finished"

if [[ -v MAILSMTP ]]; then

# MAILSMTP='smtp.inbox.ru:25'
echo "<html>PostgreSQL on ${HOST} pgbadger Weekly Report<BR><BR>See Attachment</html>" | mutt -e 'set content_type = text/html' -e 'set from="${MAILLOGIN}"' \
  -e 'set realname="${MAILFROM}"' -e 'set smtp_authenticators="login"' -e 'set smtp_url=smtp://"${MAILLOGIN}"@"${MAILSMTP}"' -e 'set smtp_pass="${MAILPWD}"' \
  -e 'set ssl_starttls=yes' -e 'set ssl_verify_dates=no' -e 'set ssl_verify_host=no' -s 'PostgreSQL pgbadger Weekly Report' -a ${FileReport} -- "${MAILTO}"

fi

if [[ -v MAILSMTPURL ]]; then

# MAILSMTPURL='smtp://10.42.161.197:25'
echo "<html>PostgreSQL on ${HOST} pgbadger Weekly Report<BR><BR>See Attachment</html>" | mutt -e 'set ssl_starttls=no' -e 'set ssl_force_tls=no' \
  -e 'set content_type = text/html' -e 'set from="${MAILLOGIN}"' -e 'set realname="${MAILFROM}"' -e 'set smtp_url="${MAILSMTPURL}"' \
  -s 'PostgreSQL pgbadger Weekly Report' -a ${FileReport} -- '"${MAILTO}"'"

fi

echo "[pgbadger]  PostgreSQL pgbadger Weekly Report Mail Sended"