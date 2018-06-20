#!/bin/bash

generate_token(){
    cat $SHARED_STORAGE/token/tokens.properties | grep $RD_USER
    if [ $? -ne 0 ] ; then
        echo "Token will be generated"
        java -cp $RUNDECK_INSTALL_DIR/server/lib/jetty-all-9.0.7.v20131107.jar org.eclipse.jetty.util.security.Password $RD_USER $RD_PASSWORD >> $SHARED_STORAGE/token/output.txt 2>&1
        rd_token=$(cat $SHARED_STORAGE/token/output.txt | grep MD5| cut -d ':' -f 2)
        echo "Generated token $rd_token"
        echo "$RD_USER: $rd_token" > $SHARED_STORAGE/token/tokens.properties && truncate -s -1 $SHARED_STORAGE/token/tokens.properties
        rm -f $SHARED_STORAGE/token/output.txt
    fi
}

create_base_dir(){
    if [ ! -d "$SHARED_STORAGE/token/" ]; then
        mkdir $SHARED_STORAGE/token/
        chmod 777 $SHARED_STORAGE/token/
    fi
    if [ ! -d "$SHARED_STORAGE/projects/" ]; then
        mkdir $SHARED_STORAGE/projects/
        chmod 777 $SHARED_STORAGE/projects/
    fi
    if [ ! -d "$SHARED_STORAGE/logs/" ]; then
        mkdir $SHARED_STORAGE/logs/
        chmod 777 $SHARED_STORAGE/logs/
    fi

}

install_rundeck() {
    echo "installing Rundeck"
    #Run rundeck in daemon  mode so that the default directories and configs are created
	(nohup java $JAVA_OPTIONS -jar $RUNDECK_INSTALL_DIR/rundeck-launcher-2.11.4.jar >/dev/null 2>&1) &
	
    PID=$!
    echo $PID
    #wait till etc directory is created
    until [ -d "$RUNDECK_INSTALL_DIR/etc/" ]
    do
        sleep 5
    done
    #Directory is created so kill the daemon process
    kill $PID
}

start_rundeck(){
    echo "Starting Rundeck..."
    
    cp $RUNDECK_INSTALL_DIR/rundeck-config.properties $RUNDECK_INSTALL_DIR/server/config/
    cp $RUNDECK_INSTALL_DIR/realm.properties $RUNDECK_INSTALL_DIR/server/config/
    cp $RUNDECK_INSTALL_DIR/framework.properties $RUNDECK_INSTALL_DIR/etc/framework.properties
    cp $RUNDECK_INSTALL_DIR/project.properties $RUNDECK_INSTALL_DIR/etc/project.properties
    java $JAVA_OPTIONS -jar $RUNDECK_INSTALL_DIR/rundeck-launcher-2.11.4.jar
}

create_base_dir
install_rundeck
generate_token
start_rundeck
