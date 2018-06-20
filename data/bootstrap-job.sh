#!/bin/bash

create_project(){
	
    #Wait till the rundeck server is up
	until [ -f index.html ]
    do
		wget http://rundeck:4440/
		echo "waiting for rundeck server to be available..."
        sleep 10
    done

    if [ ! -d "$SHARED_STORAGE/projects/${RD_PROJECT}" ]; then
        echo "Creating default project"
        $rd_cli_home/rd projects create -p ${RD_PROJECT}
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

}

create_project
