#!/bin/bash
echo Foram digitados $# parâmetros. São eles: $*
echo O nome do arquivo é: $1
echo O nome do script é: $0 

diretorio=$( echo $1 | awk -F. '{ print $1 }')


if [ ! -d files_$diretorio ] 
then
    mkdir files_$diretorio
fi


array=("$@")
lista=${array[@]:1:$#}
lista_de_entrada=()


for chaves1 in ${array[@]:1:$#}
do
   for chaves2 in ${array[@]:1:$#}
    do
        if [ "$chaves1" != "$chaves2" ]
        then
            #--- copia arquivos renomeando para as duplas de chaves possiveis
            cp $1 files_$diretorio/$1"."$chaves1"."$chaves2 2>erro_copias.txt
            if [ $? -eq 0 ] 
            then
                #-- primeira encriptacao 
                gpg -er $chaves1 files_$diretorio/$1"."$chaves1"."$chaves2 2>erro_primeira_Encriptacao.txt
                if [ $? -eq 0 ] 
                then
                    rm files_$diretorio/$1"."$chaves1"."$chaves2
                    echo "Criado o arquivo "files_$diretorio/$1"."$chaves1"."$chaves2".gpg"
                    gpg -er $chaves2 files_$diretorio/$1"."$chaves1"."$chaves2".gpg" 2>erro_segunda_Encriptacao.txt
                    
                    if [ $? -eq 0 ] 
                    then
                        rm files_$diretorio/$1"."$chaves1"."$chaves2".gpg"
                        echo "Criado o arquivo "files_$diretorio/$1"."$chaves1"."$chaves2".gpg.gpg"
                        
                    else
                        echo "Houve uma falha na Encriptacao"
                    fi

                else
                    echo "Houve uma falha na Encriptacao"
                fi
            else
                echo "Houve uma falha na copia"
            fi 
        fi

    done
done


if [ $? -eq 0 ] 
then
     if [ -e "$1" ]
    then
        rm $1
        echo "Arquivo "$1" removido por segurança!"
    fi  
else
     echo "Houve uma falha no processo, verifique os arquivos de erro"
fi

