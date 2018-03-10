TITLE="EXEMPLO 1"
ACTIVE="yes"
ID="01_TESTE"
VERSION="1.0"
DISTRO="DEBIAN|UBUNTU"
STATE=on
COMMENT="Configure personalizações do ambiente"

function verify()
{
	# Verifica se o pacote ja está instalado
	return 0
}

function fn_install()
{
	# Realiza a operação
	echo "[INFO] Install $TITLE - $COMMENT" 
}

function fn_start()
{
	case ${ADV_OPT} in
	INSTALL)
		verify
		if [ "$?" -eq 0 ];then
			fn_install
		else
			echo "Solution $TITLE already installed/Configured"	
		fi
		;;
	FORCE)	
		fn_install
		;;
	*)
		echo "Exit, option not found!"
		;;
	esac	
}



