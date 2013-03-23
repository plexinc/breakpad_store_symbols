#!/bin/sh 

die()
{
    echo $1
    exit 1
}

if [ $# -ne 2 ]; then
  die "Need to supply two arguments, symbol file and store path"
fi

SYMBOL_FILE=$1
STORE_PATH=$2

if [ ! -e "$SYMBOL_FILE" ];
then
  die "Can't find that symbol file..."
fi

EXT="${SYMBOL_FILE##*.}"

if [[ $EXT == xz ]]; then
  echo "Uncompressing symbols...(xz)"
  xz -d "$SYMBOL_FILE"
  SYMBOL_FILE="${SYMBOL_FILE%.*}"
elif [[ $EXT == bz2 ]]; then
  echo "Uncompressing symbols...(bzip2)"
  bunzip2 "$SYMBOL_FILE"
  SYMBOL_FILE="${SYMBOL_FILE%.*}"
fi

if [ ! -d $STORE_PATH ]; then
  mkdir -p "$STORE_PATH" || die "Couldn't create $STORE_PATH"
fi

HASH=$(head -n1 $SYMBOL_FILE | cut -d" " -f4)
PRODUCT=$(head -n1 $SYMBOL_FILE | cut -d" " -f5-)

echo $PRODUCT/$HASH
if [ ! -d "$STORE_PATH/$PRODUCT" ]; then
  mkdir -p "$STORE_PATH/$PRODUCT"
fi
echo "$SYMBOL_FILE -> $STORE_PATH/$PRODUCT/$HASH"
mv "$SYMBOL_FILE" "$STORE_PATH/$PRODUCT/$HASH" || die "Couldn't move file..."

