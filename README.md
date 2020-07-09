# This code needs to be found in a subdirectory called "lockdown"
--------
# The three goals for this module.
## AUDIT a RHEL or Centos o/s and report on CIS compliance
## LOCKDOWN selected CIS *level 1* items. It can address level 2 fixes, however this is disabled by default
## TEST for cis-level1 compliance ongoing, and alert on config drift as desired. Can be plugged into monitoring, or run on demand.

# Compatibility: Red Hat Enterprise Linux 7.X (tested 7.1 - 7.7) and CentOS 7.4 (tested 7.4 - 7.7, note CentOS version below 7.4 may have issues with SSH).
# Note latest centos7 is v7.8. There's a manual update below to make this work.

# LAUNCH a container for CIS testing / lockdown, attaching ./lockdown in the currnt directory as a mountable volume inside the container
docker run --detach --privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro --volume=`pwd`/lockdown:/mnt:ro centos7-ansible:latest

stephenwallace@StephenBP2016i7 lockdown % docker ps
  CONTAINER ID          IMAGE                    COMMAND                  CREATED             STATUS              PORTS               NAMES
**d75b85d99415**        centos7-ansible:latest   "/usr/lib/systemd/sy…"   6 days ago          Up 2 hours                              boring_greider

# AUDIT the RHEL/Centos 7.2->7.8 container
docker exec -it <CONtAINER-ID> /mnt/scripts/Centos.sh

# LOCKDOWN the operating system
docker exec -it <CONtAINER-ID> yum -y install git wget
docker exec -it <CONtAINER-ID> /mnt/scripts/centos-cis-hardening.sh

# OPTIONALLY run just section 1 of the CIS level 1 controls
docker exec -it <CONtAINER-ID> ansible-playbook /root/cis/cis-centos-playbook.yml -t section-1

# TEST for CIS compliance
## Install goss
docker exec -it <CONtAINER-ID> /usr/bin/curl -L https://github.com/aelsabbahy/goss/releases/latest/download/goss-linux-amd64 -o /usr/local/bin/goss
docker exec -it <CONtAINER-ID> chmod +x /usr/local/bin/goss  
## Validate that the server is compliant
docker exec -it <CONtAINER-ID> /usr/local/bin/goss -g /mnt/tests/cis-level1.yml validate
