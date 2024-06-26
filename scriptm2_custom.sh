#!/bin/bash

# Definir el directorio HOME del usuario original
USER_HOME=$(eval echo ~$SUDO_USER)

# Función para verificar si un archivo existe y es accesible
check_file() {
  if [ ! -f "$1" ]; then
    echo "Error: El archivo $1 no existe o no es accesible."
    exit 1
  fi
}

echo "Actualizando el sistema operativo..."
# ACTUALIZAR SISTEMA OPERATIVO
sudo apt update --assume-yes
sudo apt upgrade -y

echo "Comprobando si está instalado Git..."
# COMPROBAR SI ESTÁ INSTALADO GIT
git --version

echo "Comprobando si está instalado Curl..."
# COMPROBAR SI ESTÁ INSTALADO CURL
curl --version

echo "Instalando Docker..."
# INSTALAR DOCKER
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

echo "Agregando el grupo Docker..."
sudo groupadd docker
sudo usermod -aG docker $USER

#echo "Deteniendo y eliminando todos los contenedores Docker..."
#sudo docker stop $(docker ps -a -q) -f
#sudo docker rm $(docker ps -a -q) -f
#sudo docker volume prune -f
#sudo docker network prune -f

echo "Instalando Go..."
# INSTALAR GO
sudo apt install golang-go --assume-yes
go version

echo "Instalando npm..."
# INSTALAR NPM
sudo apt install npm --assume-yes

echo "Instalando Docker Compose..."
# INSTALAR DOCKER COMPOSE
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

cd "$USER_HOME"

echo "Clonando el repositorio soluciones-blockchain..."
#git clone https://gitlab.com/STorres17/soluciones-blockchain.git
git clone https://github.com/jesusrosasdm/soluciones-blockchain.git

cd "$USER_HOME/soluciones-blockchain/universidades"

echo "Instalando jq..."
sudo apt install jq --assume-yes

echo "Borrando instalaciones anteriores para empezar desde cero..."
# Borrar instalaciones anteriores para empezar desde cero
rm -rf organizations/peerOrganizations
rm -rf organizations/ordererOrganizations
rm -rf channel-artifacts/
mkdir channel-artifacts

echo "Exportando carpetas de binarios y de la red inicial configurada..."
# Exportación de las carpetas de binarios y de la red inicial configurada
export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/../config

echo "Creando certificados para la Universidad de Barcelona, Mexico y el Orderer..."
# Creación de los certificados de la Universidad de Barcelona, Bogotá y el Orderer
cryptogen generate --config=./organizations/cryptogen/crypto-config-barcelona.yaml --output="organizations"
cryptogen generate --config=./organizations/cryptogen/crypto-config-mexico.yaml --output="organizations"
cryptogen generate --config=./organizations/cryptogen/crypto-config-orderer.yaml --output="organizations"

sleep 5

echo "Levantando los contenedores (la red)..."
# Levantar los contenedores (la red)
sudo docker-compose -f docker/docker-compose-universidades.yaml up -d

sleep 5

echo "Exportando la carpeta donde se encuentra la configuración de los canales y del MSP de cada empresa..."
# Exportar la carpeta donde se encuentra la configuración de los canales y del MSP de cada empresa
export FABRIC_CFG_PATH=${PWD}/configtx

echo "Creando el bloque génesis del canal..."
# Crear el bloque génesis del canal
configtxgen -profile UniversidadesGenesis -outputBlock ./channel-artifacts/universidadeschannel.block -channelID universidadeschannel

sleep 5

echo "Cambiando el FABRIC_CFG_PATH..."
# Cambiar el FABRIC_CFG_PATH
export FABRIC_CFG_PATH=${PWD}/../config

echo "Verificando la existencia de los archivos de certificados y claves..."
# Verificar la existencia de los archivos de certificados y claves
check_file "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem"
check_file "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/server.crt"
check_file "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/server.key"

echo "Exportando las carpetas que nos ponen con el gorrito de administrador del Orderer..."
# Exportar las carpetas que nos ponen con el gorrito de administrador del Orderer
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/server.key

echo "Verificando la cadena de confianza del certificado..."
# Verificar la cadena de confianza del certificado
openssl verify -CAfile "$ORDERER_CA" "$ORDERER_ADMIN_TLS_SIGN_CERT"
if [ $? -ne 0 ]; then
  echo "Error: La verificación del certificado falló."
  exit 1
fi

echo "Configurando el Orderer con el bloque génesis..."
# Verificar si el canal ya existe
CHANNEL_EXISTS=$(osnadmin channel list -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY" | grep universidadeschannel)

if [ -n "$CHANNEL_EXISTS" ]; then
  echo "El canal universidadeschannel ya existe. Eliminando archivos relacionados..."
  # Eliminar archivos relacionados con el canal
  rm -rf ./channel-artifacts/universidadeschannel.block
else
  echo "Configurando el Orderer con el bloque génesis..."
  # Configurar el Orderer con el bloque génesis
  osnadmin channel join --channelID universidadeschannel --config-block ./channel-artifacts/universidadeschannel.block -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"
fi

sleep 5

echo "Verificando que el canal fue creado..."
# Verificar que el canal fue creado
osnadmin channel list -o localhost:7053 --ca-file "$ORDERER_CA" --client-cert "$ORDERER_ADMIN_TLS_SIGN_CERT" --client-key "$ORDERER_ADMIN_TLS_PRIVATE_KEY"

echo "Añadiendo el nodo de la Universidad de Barcelona..."
# Añadir el nodo de la Universidad de Barcelona
export CORE_PEER_TLS_ENABLED=true
export PEER0_BARCELONA_CA=${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="BarcelonaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BARCELONA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/barcelona.universidades.com/users/Admin@barcelona.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer channel join -b ./channel-artifacts/universidadeschannel.block

sleep 5

echo "Añadiendo el nodo de la Universidad de Bogotá..."
# Añadir el nodo de la Universidad de Bogotá
export PEER0_MEXICO_CA=${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="MexicoMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MEXICO_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/mexico.universidades.com/users/Admin@mexico.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:9051

peer channel join -b ./channel-artifacts/universidadeschannel.block

sleep 5

echo "Verificando contenedores Docker..."
# Verificación
sudo docker ps -a
#docker logs -f peer0.mexico.universidades.com
#docker logs -f peer0.barcelona.universidades.com

echo "Añadiendo una organización a la red universitaria..."
# Adición de una organización a la red universitaria
# Exportar la carpeta de los binarios
export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/../config

echo "Generando certificados de la Universidad de Vancouver..."
# Generación de los certificados de la Universidad de Vancouver
cryptogen generate --config=./organizations/cryptogen/crypto-config-vancouver.yaml --output="organizations"

sleep 5

echo "Creando configuración a partir del archivo YAML..."
# Creación de configuración a partir del archivo YAML
cd vancouver/
export FABRIC_CFG_PATH=$PWD
../../bin/configtxgen -printOrg VancouverMSP > ../organizations/peerOrganizations/vancouver.universidades.com/vancouver.json

sleep 5

echo "Arrancando el nodo de Vancouver..."
# Arrancar el nodo
cd ..
sudo docker-compose -f docker/docker-compose-vancouver.yaml up -d

sleep 5

echo "Editando la configuración del canal..."
# Editar la configuración del canal
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=${PWD}/../config
export CORE_PEER_TLS_ENABLED=true
export PEER0_BARCELONA_CA=${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="BarcelonaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_BARCELONA_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/barcelona.universidades.com/users/Admin@barcelona.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:7051

echo "Fetching the latest configuration block..."
# Fetch the latest configuration block
peer channel fetch config channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com -c universidadeschannel --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem

sleep 5

echo "Decoding the binary configuration block..."
# Decode the binary configuration block
cd channel-artifacts
configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json

sleep 5

echo "Modifying the configuration to add the Vancouver node..."
# Modify the configuration to add the Vancouver node
jq .data.data[0].payload.data.config config_block.json > config.json
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"VancouverMSP":.[1]}}}}}' config.json ../organizations/peerOrganizations/vancouver.universidades.com/vancouver.json > modified_config.json

sleep 5

echo "Encoding and computing the update..."
# Encode and compute the update
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id universidadeschannel --original config.pb --updated modified_config.pb --output vancouver_update.pb
configtxlator proto_decode --input vancouver_update.pb --type common.ConfigUpdate --output vancouver_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"universidadeschannel", "type":2}},"data":{"config_update":'$(cat vancouver_update.json)'}}}' | jq . > vancouver_update_in_envelope.json
configtxlator proto_encode --input vancouver_update_in_envelope.json --type common.Envelope --output vancouver_update_in_envelope.pb

sleep 5

echo "Signing the transaction..."
# Sign the transaction
cd ..
peer channel signconfigtx -f channel-artifacts/vancouver_update_in_envelope.pb

sleep 5

echo "Confirming the transaction as Mexico..."
# Confirm the transaction as Mexico
export PEER0_MEXICO_CA=${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="MexicoMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MEXICO_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/mexico.universidades.com/users/Admin@mexico.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:9051
peer channel update -f channel-artifacts/vancouver_update_in_envelope.pb -c universidadeschannel -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem

sleep 5

echo "Adding Vancouver node..."
# Add Vancouver node
export PEER0_VANCOUVER_CA=${PWD}/organizations/peerOrganizations/vancouver.universidades.com/peers/peer0.vancouver.universidades.com/tls/ca.crt
export CORE_PEER_LOCALMSPID="VancouverMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_VANCOUVER_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/vancouver.universidades.com/users/Admin@vancouver.universidades.com/msp
export CORE_PEER_ADDRESS=localhost:2051
peer channel fetch 0 channel-artifacts/universidadeschannel.block -o localhost:7050 --ordererTLSHostnameOverride orderer.universidades.com -c universidadeschannel --tls --cafile ${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem
peer channel join -b channel-artifacts/universidadeschannel.block

sleep 5

echo "Proceso completado. Puedes acceder a CouchDB en las siguientes URLs:"
# COUCHDB URLs
# http://192.168.1.83:5984/_utils/#login   # Barcelona
# http://192.168.1.83:7984/_utils/#login   # Mexico
# http://192.168.1.83:9984/_utils/#login   # Vancouver
