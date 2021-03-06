#!/bin/bash
# c_send_report.sh

FILEREPORT='/cronwork/pg_profile_daily.html'

echo '<html><head><meta charset="utf-8"></head><body><p style="font-family:Monospace;font-size:10px"><a href="https://postgrespro.ru/docs/postgrespro/13/pgpro-pwr#PGPRO-PWR-SECTIONS-OF-A-REPORT">Описание разделов отчёта</a></p></body></html>' > ${FILEREPORT}
PGPASSWORD=${PASSWORD} psql -h ${HOST} -p ${PORT} -U ${USERNAME} -d ${DBNAME} -P pager=off -qtc "SELECT profile.report_daily();" >> ${FILEREPORT}
RC=$?
echo "[pg_profile]  Generate Daily Report. RC=${RC}"

sed -i 's/<H2>Report sections<\/H2>/<H2><a NAME=report_sec>Report sections<\/H2>/' ${FILEREPORT}
sed -i 's/<\/a><\/H3>/<\/a> <a HREF=#report_sec><button>up to contents<\/button><\/a><\/H3>/g' ${FILEREPORT}

PGPASSWORD=${PASSWORD} psql -h ${HOST} -p ${PORT} -U ${USERNAME} -d ${DBNAME} -xtA -c "SELECT pg_stat_statements_reset();" 2>&1 | sed -n '1p' | ts '[pg_profile]   '
RC=$?
echo "[pg_profile]  Reset Stats. RC=${RC}"

if [[ -v MAILSMTP ]]; then

# MAILSMTP='smtp.inbox.ru:465'
cmdsend=$(echo "mutt -e \"set content_type=text/html\" -e \"set send_charset=utf-8\" -e \"set allow_8bit=yes\" -e \"set use_ipv6=no\" \
  -e \"set move=no\" -e \"set copy=no\" \
  -e \"set from=\\\"${MAILLOGIN}\\\"\" -e \"set realname=\\\"${MAILFROM}\\\"\" \
  -e \"set smtp_authenticators=\\\"login\\\"\" -e \"set smtp_url=smtps://\\\"${MAILLOGIN}\\\"@\\\"${MAILSMTP}\\\"\" -e \"set smtp_pass=\\\"${MAILPWD}\\\"\" \
  -e \"set ssl_starttls=yes\" -e \"set ssl_force_tls=yes\" -e \"set ssl_verify_dates=no\" -e \"set ssl_verify_host=no\" \
  -s \"PostgreSQL Daily Report\" ${MAILTO}")
#echo ${cmdsend}

rm -f /root/.muttdebug0

cat ${FILEREPORT} | mutt -d3 -e "set content_type=text/html" -e "set send_charset=utf-8" -e "set allow_8bit=yes" -e "set use_ipv6=no" \
  -e "set move=no" -e "set copy=no" \
  -e "set from=\"${MAILLOGIN}\"" -e "set realname=\"${MAILFROM}\"" \
  -e "set smtp_authenticators=\"login\"" -e "set smtp_url=smtps://\"${MAILLOGIN}\"@\"${MAILSMTP}\"" -e "set smtp_pass=\"${MAILPWD}\"" \
  -e "set ssl_starttls=yes" -e "set ssl_force_tls=yes" -e "set ssl_verify_dates=no" -e "set ssl_verify_host=no" \
  -s "PostgreSQL Daily Report" ${MAILTO} 2>&1 | ts '[pg_profile]   '
RC=$?
echo "[pg_profile]  Send Daily Report. RC=${RC}"

fi

if [[ -v MAILSMTPURL ]]; then

# MAILSMTPURL='smtp://10.42.161.197:25'
cmdsend=$(echo "mutt -e \"set ssl_starttls=no\" -e \"set ssl_force_tls=no\" -e \"set content_type=text/html\" -e \"set send_charset=utf-8\" \
  -e \"set allow_8bit=yes\" -e \"set use_ipv6=no\" -e \"set move=no\" -e \"set copy=no\" \
  -e \"set from=\\\"${MAILLOGIN}\\\"\" -e \"set realname=\\\"${MAILFROM}\\\"\" -e \"set smtp_url=\\\"${MAILSMTPURL}\\\"\" \
  -s \"PostgreSQL Daily Report\" ${MAILTO}")
#echo ${cmdsend}

rm -f /root/.muttdebug0

cat ${FILEREPORT} | mutt -d3 -e "set ssl_starttls=no" -e "set ssl_force_tls=no" -e "set content_type=text/html" -e "set send_charset=utf-8" \
  -e "set allow_8bit=yes" -e "set use_ipv6=no" -e "set move=no" -e "set copy=no" \
  -e "set from=\"${MAILLOGIN}\"" -e "set realname=\"${MAILFROM}\"" -e "set smtp_url=\"${MAILSMTPURL}\"" \
  -s "PostgreSQL Daily Report" ${MAILTO} 2>&1 | ts '[pg_profile]   '
RC=$?
echo "[pg_profile]  Send Daily Report. RC=${RC}"

fi
