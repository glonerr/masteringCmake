set_default(){
    for opt; do
        eval : \${$opt:=\$${opt}_default}
    done
}

arch=aarch64
arch_default=x86_64
cc_default=gcc
cc=clang

set_default arch

echo "arch:$arch"
echo "cc:$cc"