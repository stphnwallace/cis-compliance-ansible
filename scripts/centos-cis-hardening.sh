#!/bin/bash
echo Script name: $0
echo $# arguments 
if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters. Try something like this ->     ./centos-cis-hardening.sh <branchname>"
fi

if  [ ! -d /etc/ansible/roles ] ; then
  echo "Creating the ansible ROLES directory"
  mkdir -p /etc/ansible/roles/Ansible-RHEL7-CIS-Benchmarks
fi

if  [ ! -d /root/cis ] ; then
  echo "Creating the CIS directory and creating git repo"
  mkdir /root/cis
  git init
fi

cd /root/cis

# Download the CentOS CIS audit script
if [ ! -f ./CentOS.sh ]; then
  wget https://github.com/securelayer7/CENTOS-Audit-Script-CIS/blob/master/CentOS.sh -O /root/cis/CentOS.sh
  chmod 0700 /root/cis/CentOS.sh
  echo "Downloaded the CentOS CIS audit script from the interwebs to /root/cis dir"
fi

echo "CIS audit script already installed"

echo "Running the CIS checker before locking down"
#cd /root/cis && ./CentOS.sh > cis-audit-before.out 2>&1


# Pre-reqs requirements.yml + playbook.yml
if ! command -v ansible &> /dev/null
then
    echo "ansible could not be found, installing now"
    sudo yum -y install ansible
fi
echo "Ansible already installed"

if [ ! -d /etc/ansible/roles/Ansible-RHEL7-CIS-Benchmarks ]; then
  echo "Download the Ansible role for the CIS controls"
  #wget https://apro.telstra-somewhere.com.au/generic/scripts/cis/Ansible-RHEL7-CIS-Benchmarks.tar.gz -O /etc/ansible/roles/Ansible-RHEL7-CIS-Benchmarks.tar.gz
  #cd /etc/ansible/roles && tar xvfz ./Ansible-RHEL7-CIS-Benchmarks.tar.gz
  git clone https://github.com/HarryHarcourt/Ansible-RHEL7-CIS-Benchmarks.git /etc/ansible/roles/Ansible-RHEL7-CIS-Benchmarks/
fi

echo "Checking to see if we're running Centos 7.*8*....update the supported o/s file in Ansible if so!"
if /usr/bin/grep "7.8" /etc/ansible/roles/Ansible-RHEL7-CIS-Benchmarks/vars/main.yml
then
  echo "Centos 7.8 support is included"
else
  echo "Centos 7.8 support needs to be ADDED"
  echo "vi /etc/ansible/roles/Ansible-RHEL7-CIS-Benchmarks/vars/main.yml"
  exit 1
fi

if [ ! -f ./cis-centos-playbook.yml ]; then
  echo "Downloading the Ansible playbook"
  cp /mnt/cis-centos-playbook.yml /root/cis/
#  wget https://apro.telstra-somewhere.com.au/generic/scripts/cis/cis-centos-playbook.yml -O /root/cis/cis-centos-playbook.yml
fi
cp /mnt/cis-centos-playbook.yml /root/cis/
echo "cis-centos-playbook.yml in place"

echo "Disabling level-2 CIS checks"
mv /etc/ansible/roles//Ansible-RHEL7-CIS-Benchmarks/tasks/level-2.yml /etc/ansible/roles//Ansible-RHEL7-CIS-Benchmarks/tasks/level-2.yml.old
touch /etc/ansible/roles/Ansible-RHEL7-CIS-Benchmarks/tasks/level-2.yml

echo "Now running the CentOS CIS *level-1* lock down..."

echo "Section-1 lockdown...around 4mins..."
time ansible-playbook /root/cis/cis-centos-playbook.yml -t section-1
echo "Section-1 lockdown complete"

echo "NOT running Section-2 lockdown...breaks symlinks."
#time ansible-playbook /root/cis/cis-centos-playbook.yml -t section-2
#echo "Section-2 lockdown complete"

echo "NOT running Section-3 lockdown...breaks stuff."
#time ansible-playbook /root/cis/cis-centos-playbook.yml -t section-3
#echo "Section-1 lockdown complete"

echo "Section-4 lockdown...around ?mins..."
time ansible-playbook /root/cis/cis-centos-playbook.yml -t section-4
echo "Section-4 lockdown complete"

echo "Section-5 lockdown...around ?mins..."
time ansible-playbook /root/cis/cis-centos-playbook.yml -t section-5
echo "Section-5 lockdown complete"

echo "Section-6 lockdown...around ?mins..."
time ansible-playbook /root/cis/cis-centos-playbook.yml -t section-6
echo "Section-6 lockdown complete"

echo "CIS level-1 lockdown complete"

echo "STARTED running the CIS checker script post lockdown"
#cd /root/cis && ./CentOS.sh > cis-audit-after.out 2>&1
echo "FINISHED running the CIS checker script post lockdown"

cd /root/cis
git add cis-audit-before.out cis-audit-before.out
git diff cis-audit-before.out cis-audit-before.out
#diff  cis-audit-before.out cis-audit-after.out > cis-audit-diff.out 2>&1
