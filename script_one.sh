#!/bin/bash

# Defina as variáveis
url="http:*******/shp/file.zip"
downloadFolder="/home/admtest/script/shp"
databaseUser="postgres"
databaseName="*******"
databasePassword="****"

# Configura a senha para o psql
export PGPASSWORD="$databasePassword"

# Exclua o arquivo anterior, se existir
rm -f "$downloadFolder/file.zip"
rm -f "$downloadFolder/file.1"

# Baixe o arquivo
echo "Baixando arquivo..."
wget "$url" -P "$downloadFolder"

# Verifique se o download foi bem-sucedido
if [ $? -ne 0 ]; then
    echo "Falha ao baixar o arquivo."
    exit 1
fi

echo "Arquivo baixado com sucesso."

# Descompacte o arquivo zip
unzip "$downloadFolder/file.zip" -d "$downloadFolder"

# Importe os dados shapefile para o PostgreSQL usando shp2pgsql e psql
echo "Importando dados shapefile para o PostgreSQL..."

shp2pgsql -d -D -I -s 4674 -W LATIN1 "$downloadFolder/shp/file.shp" auxiliar.adm_auto_infracao_p | psql -h 000.000.0.000 -p 5432 -U "$databaseUser" -d "$databaseName"

# Verifique se a importação foi bem-sucedida
if [ $? -ne 0 ]; then
    echo "Falha ao importar o shapefile adm_auto_infracao para o PostgreSQL."
    exit 1
fi

echo "Dados importados com sucesso."

# Exclua os arquivos baixados e descompactados após as operações
rm -rf "$downloadFolder/file.zip"
rm -f "$downloadFolder/file.zip.1"
rm -f "$downloadFolder/shp/file.shp"
rm -f "$downloadFolder/shp/file.dbf"
rm -f "$downloadFolder/shp/file.prj"
rm -f "$downloadFolder/shp/file.shx"

echo "Arquivos removidos."

#----------------

# Data e hora atual
DATE_TIME=$(date +"%Y-%m-%d %H:%M:%S")
TABLE_NAME="exemplo_de_nome_de_tabela"
echo "Enviando data e hora para o banco"

# Executar comando SQL usando o cliente psql
SQL_COMMAND="CREATE TABLE IF NOT EXISTS auxiliar.logs_adm_infracao (id SERIAL PRIMARY KEY, tabela_nome varchar(20) , datetime TIMESTAMP); INSERT INTO logs_exemplo_de_nome_de_tabela (tabela_nome,datetime) VALUES ('$TABLE_NAME',now());"
echo "Enviando data e hora para o banco..."

# Executar comando SQL e verificar o código de saída
if echo "$SQL_COMMAND" | psql -h 000.000.0.000 -U "$databaseUser" -d "$databaseName"; then
        echo "Tabela log_adm_infracao criada com sucesso"
else
        echo "Error! Tabela log_adm_infracao não foi criada com sucesso"
fi

exit 0