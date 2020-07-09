if [ ! -f /usr/local/bin/goss ] ; then
  # Install latest goss from https://github.com/aelsabbahy/goss
  /usr/bin/curl -L https://github.com/aelsabbahy/goss/releases/latest/download/goss-linux-amd64 -o /usr/local/bin/goss
  /usr/bin/chmod +rx /usr/local/bin/goss
fi
/usr/bin/echo "goss is installed..."
goss -v
