#!/usr/bin/bash
#########################################
# Criado por Kum Traceroute             #
# Contato: +33 (06) 41-39-77-79         #
#########################################
# Não me responsabilizo pelos seus atos #
# Esse programa foi criado somente para #
#  fins educacionais                    #
#########################################

cor_vermelha="\e[31m"
cor_verde="\e[32m"
cor_amarela="\e[33;1m"
cor_azul="\e[34m"
cor_normal="\e[0m"

function print_error() {
  echo -e " ${cor_vermelha}-${cor_normal} $*" ; exit
}

function stalking_version() {
  echo "[*] Stalking 1.0.0"
}

# Verificar se algum arquivo ($1) existe
# Se existir um segundo argumento ($2), então significa que devemos retornar
#  0 se ele existe ou 1 se ele não existe
function stalking_verificar_dep() {

  dep=`echo "$1" | awk {'print $1'}`

  # Se não existir no /usr/bin ou não tiver alias
  if [ ! -e "/usr/bin/$dep" ] && [ ! `alias | grep -q "$dep"` ] ; then

    # Se não tiver um segundo argumento
    if [ ! "$2" ] ; then
      print_error "\"$dep\" não foi encontrado" ; exit
    else
      return 1
    fi

  else
    return 0
  fi

}

function stalking_mostrar_caminho() {
  echo "Veja $CAMINHO_STKG para mais informações" ; exit
}

function stalking_help() {
  echo "[*] Uso: stalking <opção>"
  echo " :: help         :: mostra essa página de ajuda"
  echo " :: list         :: lista os diretórios existentes"
  echo " :: search       :: procura por algo/alguém"
  echo " :: view         :: vê as imagens de um diretório"
  echo " :: delete       :: apaga algum diretório"
  echo " :: encrypt      :: criptografa algum diretório"
  echo " :: decrypt      :: descriptografa algum diretório"
  stalking_mostrar_caminho
}

# Função para retornar o nome do alvo ou do diretório ($1)
# Se não foi especificado ($2), pedir para que o usuário especifique
function stalking_get_dir() {

  # Se o usuário não especificou
  if [ ! "$2" ] ; then
    read -p " `printf ${cor_azul}`*`printf ${cor_normal}` ${1}: "  alvo

  # Se o usuário já especificou
  else
    alvo="$2"
  fi

  echo "$alvo"

}

# Verifica se o diretório ($1) existe
function stalking_verificar_dir() {
  if [ ! -d "$CAMINHO_STKG_DB/$1" ] ; then
    print_error "Diretório \"$1\" não existe"
  fi
}

# Função para tratar de erros, recebe $? como argumento
# A mensagem de erro é passado via o segundo argumenro ($2)
function stalking_verificar_erro() {

  # Se não aconteceu nenhum erro
  if [ $1 -eq 0 ] ; then

    echo -e " [${cor_verde}ok${cor_normal}]"

  else
    
    echo -e " [${cor_vermelha}error${cor_normal}]"
    print_error "$2"
    exit
 
  fi

}

# Listar os diretórios existentes
function stalking_list() {

  stalking_verificar_dep "tree"

  lista_dir=`tree -d --noreport -L 1 "$CAMINHO_STKG_DB" | \
    sed -e "s,$CAMINHO_STKG_DB,new-line,g" | sed -e "/new-line/d"`

  # Se não foi encontrado nenhum diretório
  if [ ! "$lista_dir" ] ; then
    print_error "Nenhum diretório foi encontrado"
  fi

  printf " + Procurando pelo diretório"
  # Se o usuário quiser listar somente um diretório
  if [ "$1" ] ; then

    diretorio=`echo "$lista_dir" | grep -i "$1"`
    stalking_verificar_erro "$?" "Diretório \"$diretorio\" não encontrado"

    lista_dir="$diretorio"

  # Se o usuário não especificou, então tudo foi encontrado, logicamente
  # E não é necessário trocar a variável lista_dir
  else
    stalking_verificar_erro "0"
  fi

  echo "$lista_dir"

}

# Função para deletar/remover um diretório
function stalking_delete() {

  dir_alvo=`stalking_get_dir "Diretório" "$1"`

  # Se não existir  a var especificando o programa, então o stalking utilizará 
  #  o rm
  : ${STKG_DEL:="rm -rf"}

  # Verifica se o programa realmente existe
  stalking_verificar_dep "$STKG_DEL"

  # Remove/Deleta o diretório
  printf " + Removendo o diretório"
  $STKG_DEL "$CAMINHO_STKG_DB/$dir_alvo"

  # Se foi removido com sucesso
  stalking_verificar_erro "$?" "Não foi possivel remover o diretório \"$dir_alvo\""

}

# Função para ver as imagens de um diretório
# Recebe o diretório como argumento ($1)
function stalking_view() {

  # Se não existir, stalking utiliza o viewnior como padrão
  : ${STKG_VIEWER:="viewnior"}

  # Verifica se o programa especificado nas variáveis existe
  stalking_verificar_dep "$STKG_VIEWER"

  dir_alvo=`stalking_get_dir "Diretório" "$1"`

  stalking_verificar_dir "$dir_alvo"

  $STKG_VIEWER "$CAMINHO_STKG_DB/$dir_alvo/instagram/FT-01.png"

}

# Função para criptografar/descriptografar um diretório
# Recebe a opção (encrypt/decrypt) como primeiro argumento ($1) e o diretório alvo
#  como segundo argumento ($2)
function stalking_crypt() {

  if [ "${1,,}" == "encrypt" ] ; then
    
    # Se não existir, stalking utiliza o ccrypt como padrão
    : ${STKG_ENCRYPT:="ccrypt -r -e --key"}
    : ${STKG_CRYPT:="$STKG_ENCRYPT"}
    : ${STKG_CRYPT_ALG:="Rijndael-256"}
    frase="Criptografando"

  else

    : ${STKG_DECRYPT:="ccrypt -r -d --key"}
    : ${STKG_CRYPT:="$STKG_DECRYPT"}
    : ${STKG_CRYPT_ALG:="Rijndael-256"}
    frase="Descriptografando"

  fi

  # Verificar se o programa especificado nas variáveis existe
  stalking_verificar_dep "`echo \"$STKG_CRYPT\" | awk {'print $1'}`"

  dir_alvo=`stalking_get_dir "Diretório" "$2"`

  stalking_verificar_dir "$dir_alvo"

  # Chave, para evitar duplicar code, vou utilizar uma func já existente que faz
  #  a mesma coisa
  senha=`stalking_get_dir "Senha"`

  # Criptografar/Descriptografar o diretório alvo
  printf " [$STKG_CRYPT_ALG] $frase \"$dir_alvo\""
  $STKG_CRYPT "$senha" "$CAMINHO_STKG_DB/$dir_alvo" 1>/dev/null 2>&1

  stalking_verificar_erro "$?" "Senha incorreta"

}

# Função para o Instagram
function stalking_instagram() {

  # Dessa maneira somente um curl será executado
  conteudo_site=`curl -L -s "$1"`

  # Verificar se a conta é privada
  conta_privada=`echo "$conteudo_site" | grep -o "is_private......."`
  if [ "${conta_privada:12}" == "true," ] ; then
    printf "[${cor_vermelha}privado${cor_normal}]"
  else
    printf "\n"
  fi

  # Outra pequena gambiarra para conseguir a lista de fotos
  lista_fotos=`echo "$conteudo_site" | grep ".jpg" | \
    sed -e "s/https:/\nhttps:/g" | sed -e "s/.jpg/.jpg\n/g" | grep ".jpg" | \
    grep "https:"`

  # Qauantidade de fotos
  qnt_fotos=`echo "$lista_fotos" | grep "s320x320" | wc -l`
  qnt_fotos=$[qnt_fotos+1]

  printf " :: Baixando fotos [${cor_amarela}${qnt_fotos}${cor_normal}]"

  # Para cada foto
  for (( i=1 ; i<=$qnt_fotos ; ++i )) ; do

    if [ $i -eq 1 ] ; then
      link_baixar=`echo "$lista_fotos" | head -1`
    else
      ii=$[i-1]
      link_baixar=`echo "$lista_fotos" | grep "s320x320" | head -$ii | tail -1`
    fi

    # Hora de baixar os materiais de pesquisa
    # Brincadeiras a parte, vai baixar a foto
    wget -q "$link_baixar" -O "$CAMINHO_STKG_DB/$2/FT-$i.jpg"
    num_erro=$?

    # Se for a ultima foto
    if [ $i -eq $qnt_fotos ] ; then
      stalking_verificar_erro "$?" "Não foi possivel baixar a ultima foto"

    else
      # Só irá mostrar se tiver algum erro
      if [ $num_erro -ne 0 ] ; then
        stalking_verificar_erro "$?" "Não foi possivel baixar a $i° foto"
      fi
    fi
	
  done

}

# Ainda em desenvolvimento
function stalking_twitter() {
  printf "\n :: Ainda em desenvolvimento\n"
}

# Função para pesquisar por alguém
# Instagram: vai baixar as fotos
# Twitter: vai baixar os tweets
function stalking_search() {

  # github.com/jarun/googler
  stalking_verificar_dep "googler"

  alvo=`stalking_get_dir "Nome do alvo" "$1"`

  # Verificando se existe um diretório para esse alguém
  # Criar se não tiver
  if [ ! -d "$CAMINHO_STKG_DB/$alvo" ] ; then
    mkdir "$CAMINHO_STKG_DB/$alvo"
  fi

  site[0]="Instagram"
  site[1]="Twitter"

  # Para cada site
  var=0 ; while [ "${site[$var]}" ] ; do

    # Resultado da pesquisa no Google
    output_googler=`googler -C --np -n 2 "$alvo ${site[$var]}" | \
      sed -e "s/?hl=\w*//g"`

    # Gambiarra para ter somente o nome do usuário
    # Estou aceitando pull requests ou sugestões de como fazer isso de uma forma
    #  mais "bonita"
    username=`echo "$output_googler" | sed -e 's/ /\n/g' | grep "@" | \
      head -1 | sed -e 's/(//g' | sed -e 's/)//g' | sed -e 's/@//g'`

    # Considera o primeiro resultado como o correto
    link=`echo "$output_googler" | head -2 | tail -1`

    printf "[*] ${cor_amarela}${site[$var]}${cor_normal}: $username "

    # Chamar a função responsável por aquele determinado site
    stalking_chamar_func=`echo "stalking_${site[$var],,}"`
    $stalking_chamar_func "$link" "$alvo"

    var=$[var+1]

  done

}



stalking_version

CAMINHO_STKG="`pwd`/`dirname $0`/stalking.sh"

# Caminho até aonde ficarão os arquivos
# Se não existir, criar o diretório
: ${CAMINHO_STKG_DB:="$HOME/.config/stalking"}
if [ ! -d "$CAMINHO_STKG_DB" ] ; then
  mkdir "$CAMINHO_STKG_DB"
fi

if [ "${1,,}" == "list" ] ; then
  stalking_list "$2"

elif [ "${1,,}" == "view" ] ; then
  stalking_view "$2"

elif [ "${1,,}" == "delete" ] || [ "${1,,}" == "remove" ] ; then
  stalking_delete "$2"

elif [ "${1,,}" == "encrypt" ] || [ "${1,,}" == "decrypt" ] ; then
  stalking_crypt "${1,,}" "$2"

elif [ "${1,,}" == "search" ] ; then
  stalking_search "$2"

else
  stalking_help
fi

