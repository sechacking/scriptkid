#!/bin/bash

#设置路径
export PATH=$PATH:/bin:/usr/bin:/sbin:/usr/sbin/

unset HISTORY HISTFILE HISTSAVE HISTZONE HISTORY HISTLOG; export HISTFILE=/dev/null; export HISTSIZE=0; export HISTFILESIZE=0


PYTHON_VERSION=2.7.9
PYTHON_SRC_PKG_NAME=Python-${PYTHON_VERSION}.tgz
PYTHON_SRC_PKG_URL="http://www.python.org/ftp/python"/${PYTHON_VERSION}/${PYTHON_SRC_PKG_NAME}
FILE_NOT_EXISTS=505
PYTHON_SRC_DIR=Python-${PYTHON_VERSION}
WORKSPACE=${PWD}


function check_os_type() {
	local line

	line=`cat /etc/redhat-release |sed 's/\ release\|(Final)//g'`
	if echo $line|grep "[Cc]ent[Oo][Ss] 5" >/dev/null; then
		os_type=1
	elif echo $line|grep "[Cc]ent[Oo][Ss] 6" >/dev/null; then
		os_type=2
	elif echo $line|grep "[Rr]ed.Hat.Enterprise" >/dev/null; then
		os_type=3
	elif echo $line|grep "[Uu]buntu" >/dev/null; then
		os_type=4
	elif echo $line|grep "[Dd]ebian" >/dev/null; then
		os_type=5
	elif echo $line|grep "[Ff]edora" >/dev/null; then
		os_type=6
	else
		exit 0
	fi

	return $os_type
}

function install_deps() {

	check_os_type
	os_flag=$?
	if [ $os_flag -eq 1 ]; then
		echo "centos 5 found"
		if [ -f ./rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm ]; then
			echo "ok,go on"
		else
			wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm
		fi
		sudo rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
		sudo rpm -K rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm
		sudo rpm -i rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm
		
	elif [ $os_flag -eq 2 ]; then
		
		echo "centos 6 found"
		
		if [ -f ./rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm ]; then
		
		echo "ok,go on"
		
		else
			wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
		fi	
		sudo rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
		sudo rpm -K rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
		sudo rpm -i rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm
	fi


   if [ -f /usr/bin/yum ]; then
       yum -y groupinstall "Development tools"
       INST_CMD="yum -y install \
           openssl-devel bzip2-devel \
           expat-devel gdbm-devel \
		   python-devel mysql-devel \
		   subversion-devel readline-devel \
		   sqlite-devel wget curl gcc gcc*"
   elif [ -f /usr/bin/apt-get ]; then
       INST_CMD="apt-get -y install \
           build-essential libncursesw5-dev \
           libreadline6-dev libssl-dev \
           libgdbm-dev libc6-dev \
           libsqlite3-dev tk-dev bzip2 libbz2-dev"
   fi
   sudo ${INST_CMD}
   
	if [ -f ./nmap-6.47-1.x86_64.rpm ]; then
		echo "ok,go on"
	else
		wget https://nmap.org/dist/nmap-6.47-1.x86_64.rpm --no-check-certificate
	fi
	
	sudo rpm -vhU nmap-6.47-1.x86_64.rpm
	sudo yum -y install git
}



function checkPython() {
    #mini V2.7.1
    V1=2
    V2=7
    V3=1
	
    #not V3.0.0
    V5=3

    U_V1=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $1}'`
    U_V2=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $2}'`
    U_V3=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $3}'`

    echo your python version is : $U_V1.$U_V2.$U_V3

    if [ $U_V1 -ge $V5 ];then
        echo 'Your python version is not OK!'
        return 1
    elif [ $U_V1 -lt $V1 ];then
        echo 'Your python version is not OK!'
        return 1
    elif [ $U_V1 -eq $V1 ];then
        if [ $U_V2 -lt $V2 ];then
            echo 'Your python version is not OK!'
            return 1
        elif [ $U_V2 -eq $V2 ];then
            if [ $U_V3 -lt $V3 ];then
                echo 'Your python version is not OK!'
                return 1
            fi
        fi
    fi
    echo Your python version is OK!
    return 0
}


function get_python_src() {
	checkPython
	check_flag=$?
	if [ $check_flag -eq 1 ];then
			echo "Start to download python source now..."
			wget ${PYTHON_SRC_PKG_URL}
		else
			exit
		fi
}

function build_python() {
   if [ -f ${PYTHON_SRC_PKG_NAME} ]; then
      tar xvf ${PYTHON_SRC_PKG_NAME}
   else
      exit ${FILE_NOT_EXISTS}
   fi
   cd ${PYTHON_SRC_DIR}
   ./configure
   sudo make
   sudo make install
}

function clean_build_artifacts() {
   cd ${WORKSPACE}
   sudo rm -f *.rpm
   sudo rm -f *.tar
   sudo rm -f *.gz
   sudo rm -f *.py
}

# Install pip using get-pip

 function setup_pip() {
    local GET_PIP_URL=https://bootstrap.pypa.io/get-pip.py
    local ret=1

    if [ -f ./get-pip.py ]; then
        ret=0
    elif type curl >/dev/null 2>&1; then
        curl -O ${GET_PIP_URL}
        ret=$?
    elif type wget >/dev/null 2>&1; then
        wget ${GET_PIP_URL} --no-check-certificate
        ret=$?
    fi

    if [ $ret -ne 0 ]; then
        echo "Failed to get get-pip.py"
        echo "ok,go on"
    fi
    # install pip
    sudo ${PYTHON_BIN} get-pip.py
	if [ -f /usr/bin/pip ]; then
		mv /usr/bin/pip /usr/bin/pip.bak
		cp -f /usr/local/bin/pip /usr/bin
	else
		cp -f /usr/local/bin/pip /usr/bin
	fi
}

function main() {

	sed -i '$anameserver 114.114.114.114' /etc/resolv.conf
	install_deps
	
	checkPython
	check_flag=$?
	if [ $check_flag -eq 1 ];then
		echo "ok,python version is wrong,go on"
		if [ $? -eq 0 ]; then
			get_python_src
			build_python
			if [ -f ${PYTHON_BIN_PATH} ]; then
				#sudo mv /usr/bin/python /usr/bin/python${U_V1}.${U_V2}
				sudo mv /usr/bin/python /usr/bin/python.bak
				sudo ln -s /usr/local/bin/python${V1}.${V2} /usr/bin/python
				sed -i -e "s/\/usr\/bin\/python.*/\/usr\/bin\/python${U_V1}.${U_V2}/g" /usr/bin/yum
			else
				echo "ok,go on"
			fi
		else
			echo "ok,go on"
		fi
	else
		echo "ok,go on"
	fi
	
	PYTHON_BIN=`which python`
	NEW_PYTHON_VERSION=`${PYTHON_BIN} -V 2>&1|head -n 1|awk -F " " '{print $2}'`
	setup_pip
	if [ "${PYTHON_VERSION}" == "${NEW_PYTHON_VERSION}" ]; then
		PIP_BIN=`which pip`
		sudo ${PIP_BIN} install setuptools sqlalchemy
		sudo ${PIP_BIN} install MySQL-python SQLAlchemy
		sudo ${PIP_BIN} install -U celery[redis]
		sudo ${PIP_BIN} install supervisor
	fi
	if [ -f /usr/bin/supervisord ]; then
		ret=0
	else
		cp /usr/local/bin/supervisord /usr/bin
	fi
	if [ -f /usr/bin/celery ]; then
		ret=0
	else
		cp /usr/local/bin/celery /usr/bin
	fi
	SUPERVISORD_BIN=`which supervisord`
	
	mkdir -p /srv/app
	cd /srv/app
	git clone https://github.com/ring04h/thorns.git
	HOSTNAME=`hostname -s`
	sed -i "s/\[program:scanclient\]/[program:scanclient_${HOSTNAME}]/g" /srv/app/thorns/src/supervisord_client.conf
	${SUPERVISORD_BIN} -c /srv/app/thorns/src/supervisord_client.conf
	cd /srv
	git clone https://gitlab.com/sechacking/brootkit.git
	chmod a+x -R /srv/brootkit
	cd /srv/brootkit
	./install.sh
 }
 
#install all soft
main
clean_build_artifacts
