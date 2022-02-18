#!/bin/bash -ve

SECRET_KEY="27550b062382487d075e958a2200f3b6a6a7c4f1d9edd07e4de2d640eb4e60bf"
PUBLIC_KEY="0xbA16e909F572aD210fd5Ef8752dBbac1Cf4A7D76"
RPC_URL="http://localhost:7545/"
export RUST_BACKTRACE=1

forge build

ADDRESS_SPACESHIP=`forge create Resource --rpc-url ${RPC_URL} --legacy --private-key ${SECRET_KEY} --constructor-args "Spaceship" --constructor-args "SHIP" | grep "Deployed to:" | awk '{ print $3; }'`
ADDRESS_URANIUM=`forge create Resource --rpc-url ${RPC_URL} --legacy --private-key ${SECRET_KEY} --constructor-args "Uranium" --constructor-args "URAN" | grep "Deployed to:" | awk '{ print $3; }'`
ADDRESS_GALAXY=`forge create Galaxy --rpc-url ${RPC_URL} --legacy --private-key ${SECRET_KEY} --constructor-args ${ADDRESS_URANIUM} --constructor-args ${ADDRESS_SPACESHIP} | grep "Deployed to:" | awk '{ print $3; }'`

echo "const CONTRACT_ADDRESS_URANIUM = \"${ADDRESS_URANIUM}\";";
echo "const CONTRACT_ADDRESS_SPACESHIP = \"${ADDRESS_SPACESHIP}\";";
echo "const CONTRACT_ADDRESS_GALAXY = \"${ADDRESS_GALAXY}\";";

cast call --rpc-url ${RPC_URL} --private-key ${SECRET_KEY} --from ${PUBLIC_KEY} ${ADDRESS_SPACESHIP} "setupGalaxy(address)" ${ADDRESS_GALAXY}
cast call --rpc-url ${RPC_URL} --private-key ${SECRET_KEY} --from ${PUBLIC_KEY} ${ADDRESS_URANIUM} "setupGalaxy(address)" ${ADDRESS_GALAXY}

