#!/usr/bin/bash
################################################
##  PostgreSQL JBoss EAP 6 Driver Installer   ##
##  Author: Stephen Walker                    ##
##  Email: swalker@redhat.com                 ##
##  Date: 9/7/13                              ##
################################################

#### Functions
function usage
{
    echo "PostgreSQL JBoss EAP 6 Driver Installer"
    echo
    echo " Syntax: ./install_driver.sh [options] [-s <JBOSS_HOME>|-d <JBOSS_HOME>|-r <JBOSS_HOME>] [-p|-m]"
    echo  
    echo " Required arguments:"
    echo "   -s <JBOSS_HOME> , --standalone <JBOSS_HOME>"
    echo "                             configure standalone mode"
    echo 
    echo "   -d <JBOSS_HOME>, --domain <JBOSS_HOME>"                  
    echo "                             configure domain mode"
    echo 
    echo "   -r <JBOSS_HOME>, --running <JBOSS_HOME>"
    echo "                             specifys that the JBoss instance is running"
    echo         
    echo "   -p, --postgresql          install/configure postgresql"
    echo "   -m, --mysql               install/configure mysql"
    echo " Options: "
    echo "   -h, --help                display this dialog"
    echo
    echo "   -b  <ip-address>, --bind-address <ip-address>"
    echo "                             specify the ip address of the JBoss instance (default:127.0.0.1)"
    echo 
    echo "   -i, --no-configure        don't configure the JBoss instance"
    echo "   -c, --no-install          don't install the driver module"
    echo
    echo "   -f  <file-name>, --config-file <file-name>  "
    echo "                             specify the filename of the configuration xml"
    echo 
    echo "   -t  <dir>, --config-dir <dir>  "
    echo "                             specify the filename of the configuration xml"
    echo 
    echo "   -x, --dry-run             output what would happen when you specify other arguments"

}

function install_driver
{
    mkdir -p $JBOSS_HOME/modules/system/layers/base/$MODULE_PATH/main/
    cp -Rf $DRIVER_DIR/main $JBOSS_HOME/modules/system/layers/base/$MODULE_PATH
}

function configure_server_running
{
    $JBOSS_HOME/bin/jboss-cli.sh -c --controller=$IP_ADDRESS --file=$DRIVER_DIR/runningConfigure.cli
}

function configure_server_stopped
{
    python stoppedConfigure.py $CONFIG_DIR/$CONFIG_FILE $DRIVER
}

function dry_run
{
    echo "DRY RUN (Nothings Happening)"
    if [ $INSTALL == 1 ]; then
        echo "Module being installed..."
        echo
    fi
    if [ $CONFIGURE == 1 ]; then
        if [ $RUN == 1 ]; then
            echo "Configuring server running on $IP_ADDRESS..."
            echo
        fi
        if [ $RUN == 0 ]; then
            if [ "$MODE" == "s"  ]; then
                echo "Configuring standalone server at $JBOSS_HOME/standalone/configuration/$CONFIG_FILE"
                echo
            fi
            if [ "$MODE" == "d"  ]; then
                echo "Configuring domain server at $JBOSS_HOME/domain/configuration/$CONFIG_FILE"
                echo
            fi
        fi
    fi

}

function real_run
{
    if [ $INSTALL == 1 ]; then
        echo "Module being installed..."
        echo
        install_driver
    fi
    if [ $CONFIGURE == 1 ]; then
        if [ $RUN == 1 ]; then
            echo "Configuring server running on $IP_ADDRESS..."
            echo
            configure_server_running
        fi
        if [ $RUN == 0 ]; then
            if [ "$MODE" == "s"  ]; then
                echo "Configuring standalone server at $JBOSS_HOME/standalone/configuration/$CONFIG_FILE"
                echo
                configure_server_stopped
            fi
            if [ "$MODE" == "d"  ]; then
                echo "Configuring domain server at $JBOSS_HOME/domain/configuration/$CONFIG_FILE"
                echo
                configure_server_stopped
            fi
        fi
    fi

}


### Variable Definitions

JBOSS_HOME=
CONFIG_FILE=
CONFIG_DIR=
DRIVER=
DRIVER_CONFIG=
DRIVER_DIR=
RUN=1
MODE="s"
IP_ADDRESS=127.0.0.1
CONFIGURE=1
INSTALL=1
DRY_RUN=0

### Interpret command line arguments
while [ "$1" != "" ]; do
    case $1 in
        -h | --help)            usage
                                exit
                                ;;
        -r | --running)         RUN=1
                                shift
                                JBOSS_HOME=$1
                                ;;
        -d | --domain)          MODE="d"
                                RUN=0
                                shift
                                JBOSS_HOME=$1
                                ;;
        -s | --standalone)      MODE="s"
                                RUN=0
                                shift
                                JBOSS_HOME=$1
                                ;;
        -i | --no-configure)    CONFIGURE=0
                                INSTALL=1
                                ;;
        -c | --no-install)      CONFIGURE=1 
                                INSTALL=0
                                ;;
        -t | --config-dir)      shift
                                CONFIG_DIR=$1
                                ;;
        -f | --config-file)     shift
                                CONFIG_FILE=$1
                                ;;
        -b | --bind-address)    shift
                                IP_ADDRESS=$1
                                ;;
        -a)                     shift
                                ARGS=$1
                                ;;
        -p | --postgresql)      DRIVER=postgresql
                                DRIVER_DIR=./drivers/postgresql
                                MODULE_PATH=org/postgresql
                                ;;
        -m | --mysql)           DRIVER=mysql
                                DRIVER_DIR=./drivers/mysql
                                MODULE_PATH=com/mysql
                                ;;
        -x| --dry-run)          DRY_RUN=1
                                ;;
        * )                     usage
                                exit
    esac
    shift
done 

### Set default CONFIG_FILE

test "$MODE" == "s" && test "$CONFIG_FILE" == "" && CONFIG_FILE=standalone.xml && echo "Using default config file (use -f to specify): $CONFIG_FILE"
test "$MODE" == "d" && test "$CONFIG_FILE" == "" && CONFIG_FILE=domain.xml && echo "Using default config file (use -f to specify): $CONFIG_FILE"
test "$MODE" == "s" && test "$CONFIG_DIR" == "" && CONFIG_DIR=$JBOSS_HOME/standalone/configuration && echo "Using default config directory (use -t to specify): $CONFIG_DIR"
test "$MODE" == "d" && test "$CONFIG_DIR" == "" && CONFIG_DIR=$JBOSS_HOME/domain/configuration && echo "Using default config directory (use -t to specify): $CONFIG_DIR"

test "$JBOSS_HOME" == "" && echo "Must specify a jboss instance." && exit 1
test "$DRIVER" == "" && echo "Must specify the type of driver. Use either -p or --postgresql for postgresql or use -m or --mysql for mysql" && exit 1

### Set it off

if [ $DRY_RUN == 1 ]; then
    dry_run
else
    real_run
fi
