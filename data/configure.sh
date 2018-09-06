#!/bin/bash
	
#Wait till the rundeck server is up
until [ -f index.html ]
do
    wget http://localhost:4440/
    echo "waiting for rundeck server to be available..."
    sleep 5
done
sleep 10
projectOption=""
if [ -f "$RSA_KEY_DIR/id_rsa" ]; then
	if [ ! -f "$SHARED_STORAGE/storage/content/keys/${RD_PROJECT}/id_rsa" ]; then
		$rd_cli_home/rd keys create -f ${RSA_KEY_DIR}/id_rsa --path keys/${RD_PROJECT}/id_rsa --type privateKey
	fi
	projectOption=" -- --project.ssh-keypath=${RSA_KEY_DIR}/id_rsa --project.ssh-key-storage-path=keys/${RD_PROJECT}/id_rsa"
fi
if [ ! -d "$SHARED_STORAGE/projects/${RD_PROJECT}" ]; then
    echo "Creating default project"
    cd $SHARED_STORAGE/projects
    $rd_cli_home/rd projects create -p ${RD_PROJECT} $projectOption
    
    #wait for projects to be created
    found="false"
    while [ $found = "false" ]
    do
        if [ -d "$SHARED_STORAGE/projects/${RD_PROJECT}/etc" ]; then
            cp $RUNDECK_INSTALL_DIR/resources.xml $SHARED_STORAGE/projects/$RD_PROJECT/etc/
            cp $RUNDECK_INSTALL_DIR/project.properties $SHARED_STORAGE/projects/$RD_PROJECT/etc/
            found="true"
        fi
    done
    
    echo "Default project created"
    /bin/bash
else
    echo "Default project already created."
fi
