#!/bin/bash

function createBarcelona() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/barcelona.universidades.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/barcelona.universidades.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-barcelona --tls.certfiles "${PWD}/organizations/fabric-ca/barcelona/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-barcelona.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-barcelona.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-barcelona.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-barcelona.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-barcelona --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/barcelona/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-barcelona --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/barcelona/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-barcelona --id.name barcelonaadmin --id.secret barcelonaadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/barcelona/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-barcelona -M "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/msp" --csr.hosts peer0.barcelona.universidades.com --tls.certfiles "${PWD}/organizations/fabric-ca/barcelona/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-barcelona -M "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/tls" --enrollment.profile tls --csr.hosts peer0.barcelona.universidades.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/barcelona/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/tlsca/tlsca.barcelona.universidades.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/ca"
  cp "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/peers/peer0.barcelona.universidades.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/ca/ca.barcelona.universidades.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-barcelona -M "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/users/User1@barcelona.universidades.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/barcelona/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/users/User1@barcelona.universidades.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://barcelonaadmin:barcelonaadminpw@localhost:7054 --caname ca-barcelona -M "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/users/Admin@barcelona.universidades.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/barcelona/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/barcelona.universidades.com/users/Admin@barcelona.universidades.com/msp/config.yaml"
}

function createMexico() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/mexico.universidades.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/mexico.universidades.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-mexico --tls.certfiles "${PWD}/organizations/fabric-ca/mexico/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-mexico.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-mexico.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-mexico.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-mexico.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/mexico.universidades.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-mexico --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/mexico/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-mexico --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/mexico/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-mexico --id.name mexicoadmin --id.secret mexicoadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/mexico/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-mexico -M "${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/msp" --csr.hosts peer0.mexico.universidades.com --tls.certfiles "${PWD}/organizations/fabric-ca/mexico/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/mexico.universidades.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-mexico -M "${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/tls" --enrollment.profile tls --csr.hosts peer0.mexico.universidades.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/mexico/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/mexico.universidades.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/mexico.universidades.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/mexico.universidades.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/mexico.universidades.com/tlsca/tlsca.mexico.universidades.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/mexico.universidades.com/ca"
  cp "${PWD}/organizations/peerOrganizations/mexico.universidades.com/peers/peer0.mexico.universidades.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/mexico.universidades.com/ca/ca.mexico.universidades.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-mexico -M "${PWD}/organizations/peerOrganizations/mexico.universidades.com/users/User1@mexico.universidades.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/mexico/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/mexico.universidades.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/mexico.universidades.com/users/User1@mexico.universidades.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://mexicoadmin:mexicoadminpw@localhost:8054 --caname ca-mexico -M "${PWD}/organizations/peerOrganizations/mexico.universidades.com/users/Admin@mexico.universidades.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/mexico/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/mexico.universidades.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/mexico.universidades.com/users/Admin@mexico.universidades.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/universidades.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/universidades.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/universidades.com/msp/config.yaml"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp" --csr.hosts orderer.universidades.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/universidades.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls" --enrollment.profile tls --csr.hosts orderer.universidades.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/server.key"

  mkdir -p "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem"

  mkdir -p "${PWD}/organizations/ordererOrganizations/universidades.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/universidades.com/orderers/orderer.universidades.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/universidades.com/msp/tlscacerts/tlsca.universidades.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/universidades.com/users/Admin@universidades.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/universidades.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/universidades.com/users/Admin@universidades.com/msp/config.yaml"
}
