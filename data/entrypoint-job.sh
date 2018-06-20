#!/bin/bash

if [ ! -z "$GID" ] && [ ! -z "$UID" ] ; then
	addgroup --gid $GID $RD_USER
	useradd -ms /bin/bash --uid $UID --gid $GID $RD_USER
	adduser $RD_USER sudo
	chown $RD_USER:$RD_USER $RUNDECK_INSTALL_DIR
	su -m $RD_USER -c /data/bootstrap-job.sh
else
	/data/bootstrap-job.sh
fi
