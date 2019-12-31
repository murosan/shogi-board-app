#!/bin/bash -e

if ! [ -x "$(command -v protoc)" ]; then
  echo 'Error: protoc is not installed.'
  exit 1
fi

if ! [ -x "$(command -v protoc-gen-grpc-web)" ]; then
  echo 'Error: protoc-gen-grpc-web is not installed.'
  echo 'https://github.com/grpc/grpc-web/releases'
  exit 1
fi

app_dir=$(cd $(dirname $0); cd ../; pwd)
echo "app_dir:" $app_dir

proto_dir="$app_dir/shogi-board-protobufs/protos"
proto_file="v1.proto"
js_out_proto_file="v1_pb.js"

server_out="$app_dir/shogi-board-server/app/proto"
front_out="$app_dir/shogi-board/src/proto"

echo "creating directory..."
mkdir -p $server_out $front_out
ls -d $front_out/* | grep -v factory.ts | xargs rm

echo "generates protobuf"

protoc \
  --js_out=import_style=commonjs:$front_out \
  --grpc-web_out=import_style=commonjs+dts,mode=grpcwebtext:$front_out \
  --go_out=plugins=grpc:$server_out \
  --proto_path=$proto_dir \
  $proto_file

# create react app では、eslint に引っかかるとコンパイルに失敗するので
# 生成された js ファイルに eslint-disable を入れる
# .eslintignore は意味なかった
js_target="$front_out/$js_out_proto_file"
echo "adding eslint-disable to $js_target"
sed -i '' '1s!^!/* eslint-disable */!' $js_target

echo "done ✨"
