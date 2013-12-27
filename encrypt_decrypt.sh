function generate_keyfile () {
    args=( $@ )
    pubkey="${args[0]}"
    keyfile="${args[1]}"
    enckeyfile="${args[2]}"

    openssl rand 256 > ${keyfile}
    openssl rsautl -encrypt -pubin -inkey ${pubkey} -in ${keyfile} -out ${enckeyfile}
}

function decrypt_keyfile () {
    args=( $@ )
    privatekey="${args[0]}"
    enckeyfile="${args[1]}"
    keyfile="${args[2]}"

    openssl rsautl -decrypt -inkey ${privatekey} -in ${enckeyfile} -out ${keyfile}
}

function aesencrypt () {
    args=( $@ )
    keyfile="${args[0]}"
    encfilename="${args[1]}"
    files="${args[@]:2}"

    if [[ ! -e ${keyfile} ]];
    then
        echo "[encrypt] missing keyfile (${keyfile}). make sure to call generate_keyfile() first"
        return 1
    fi
    # compress and aes encrypt file with keyfile
    tar cz ${files[@]} | openssl enc -aes-256-cbc -salt -out ${encfilename} -pass file:${keyfile}
}

function encrypt () {
    args=( $@ )
    pubkey="${args[0]}"
    enckeyfile="${args[1]}"
    keyfile="/tmp/keyfile.bin"
    encfilename="${args[2]}"
    files="${args[@]:3}"

    generate_keyfile ${pubkey} ${keyfile} ${enckeyfile}
    hd ${keyfile} | head -n 2
    aesencrypt ${keyfile} ${encfilename} "${files[@]}"
    # clean up the keyfile
    rm ${keyfile}
}

function aesdecrypt () {
    args=( $@ )
    keyfile="${args[0]}"
    encfilename="${args[1]}"
    files="${args[@]:2}"

    if [[ ! -e ${keyfile} ]];
    then
        echo "[decrypt] missing keyfile (${keyfile}). make sure to call decrypt_keyfile() first"
        return 1
    fi

    # decrypt and decompress file with keyfiles
    openssl enc -d -aes-256-cbc -in ${encfilename} -pass file:${keyfile} | tar xz "${files[@]}"
}

function decrypt () {
    args=( $@ )
    privkey="${args[0]}"
    enckeyfile="${args[1]}"
    keyfile="/tmp/keyfile.bin"
    encfilename="${args[2]}"
    files="${args[@]:3}"

    decrypt_keyfile ${privkey} ${enckeyfile} ${keyfile}
    aesdecrypt ${keyfile} ${encfilename} "${files[@]}"
    # clean up the keyfile
    rm ${keyfile}
 }
