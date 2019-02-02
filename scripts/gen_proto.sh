#!/bin/bash -e

if ! [ -x "$(command -v protoc)" ]; then
  echo 'Error: protoc is not installed.' >&2
  exit 1
fi

app_dir=$(cd $(dirname $0); cd ../; pwd)
echo "app_dir:" $app_dir

proto_dir="$app_dir/shogi-board-protobufs/protos"
proto_file="v1.proto"

server_out="$app_dir/shogi-board-server/app/proto"
front_out="$app_dir/shogi-board/src/proto"

echo "creating directory..."
mkdir -p $server_out $front_out

echo "generates protobuf"
protoc \
  --js_out=import_style=commonjs:$front_out \
  --grpc-web_out=import_style=typescript,mode=grpcwebtext:$front_out \
  --go_out=plugins=grpc:$server_out \
  --proto_path=$proto_dir \
  $proto_file

echo "done ✨"
