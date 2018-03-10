#!/bin/bash
# script para seleção de pacotes de instalação automatizada

#Definições de Variáveis

CONFIG_FILES="conf"

larguraPequena=10;
larguraMedia=50;
larguraGrande=100;

alturaPequena=5;
alturaMedia=10;
alturaGrande=20;

AUTO=0;
completo=-1;

# variaveis do dialog

BACKTITLE="Assitente de personalização de ambiente";


function get_distro()
{
	cat /etc/*release* | grep  -i "PRETTY" | grep -ioE "UBUNTU|DEBIAN|CENTOS|FEDORA" | tr "a-z" "A-Z" | sort | uniq
}

function extract_config()
{
	FILE="$1"
	FIELD="$2"
	SEPARATOR="$3"
	
	cat "$FILE" | grep "$FIELD" | awk -F "$SEPARATOR" '{print $2}'
}

function get_config_for_files()
{
	DATA=""
	for F in $(ls ${CONFIG_FILES}/*.sh);do
		
		ACTIVE=$(extract_config "$F" "ACTIVE" "=")
		RESP=$(echo "$ACTIVE" | grep -ioE "Y|YES|S|SIM|1|on")

		if [ -z "$RESP" ];then
			# O script de configuração não está ativo
			continue
		fi

		DISTRO=$(extract_config "$F" "DISTRO" "=")
		# echo "DISTRO: $DISTRO"
		# echo "MYDISTRO: $MYDISTRO"

		RESP=$(echo "$DISTRO" | grep -io "$MYDISTRO")

		if [ "$RESP" !=  "$MYDISTRO" ];then
			# O script de configuração não é compativel com a distro atual
			continue
		fi

		TITLE=$(extract_config "$F" "TITLE" "=")
		#ID=$(extract_config "$F" "ID" "=")
		ID="${F}"
		VERSION=$(extract_config "$F" "VERSION" "=")
		
		STATE=$(extract_config "$F" "STATE" "=")
		COMMENT=$(extract_config "$F" "COMMENT" "=")

		DATA="${DATA} ${ID} ${TITLE} ${STATE}"
	done
	echo "${DATA}" 

}

function execute_selection()
{
	LIST="$1"
	for F in $LIST; do
		source "$F"
		fn_start
	done

}
###################
# FUNÇÔES DO DIALOG

function dialog_question()
{
	# sinstaxe questao txtTitulo txtMsg
	dialog --stdout --backtitle "${BACKTITLE}" --title "$1" --yesno "$2" 0 0
	
	return $?
}

function dialog_msgbox()
{
	# sinstaxe questao txtTitulo txtMsg
	dialog --stdout --backtitle "${BACKTITLE}" --title "$1" --msgbox "$2" 0 0
	
	return $?
}


function dialog_menu_select()
{
	# Função que gera o menu de opções
	LIST=$(get_config_for_files) 
	if [ -z "$LIST" ];then
		#echo "[INFO] Não existem itens para configurar"
		exit 1
	fi
	MSG="Selecione os itens de personalização desejados:"

	# Montando os comandos para geração do dialog corretamente
	CMD=$(echo "dialog --backtitle \"${BACKTITLE}\" --stdout --checklist  \"${MSG}\" ${AUTO} ${AUTO} ${AUTO} ${LIST}")
	eval ${CMD}
}

### INICIO DO SCRIPT
export MYDISTRO="$(get_distro)"

SELECTED=$(dialog_menu_select)

if [ -n "$SELECTED" ];then
	dialog_question "Confirmação de operação" "deseja realizar a configuração dos intens selecionados?"
	RETURN="$?"
	case "$RETURN" in
		0)
			export ADV_OPT="INSTALL"
			execute_selection "$SELECTED"
		;;
		1)
			dialog_msgbox "Cancelamento" "Operação cancelada pelo usuário."
		;;

	esac
fi

