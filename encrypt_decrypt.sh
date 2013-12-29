function rsa_encrypt () {
    args=( $@ )
    pubkey="${args[0]}"
    plaintext_file="${args[1]}"
    ciphertext_file="${args[2]}"

    openssl rsautl -encrypt -pubin -inkey ${pubkey} -in ${plaintext_file} -out ${ciphertext_file}
}

function rsa_decrypt () {
    args=( $@ )
    privkey="${args[0]}"
    ciphertext_file="${args[1]}"
    plaintext_file="${args[2]}"

    openssl rsautl -decrypt -inkey ${privkey} -in ${ciphertext_file} -out ${plaintext_file}
}

function aes_encrypt () {
    args=( $@ )
    keyfile="${args[0]}"
    ciphertext_file="${args[1]}"
    plaintext_files="${args[@]:2}"

    if [[ ! -e ${keyfile} ]];
    then
        echo "[encrypt] missing keyfile (${keyfile}). make sure to call generate_keyfile() first"
        return 1
    fi
    # compress and aes encrypt file with keyfile
    tar cz ${plaintext_files[@]} | openssl enc -aes-256-cbc -salt -out ${ciphertext_file} -pass file:${keyfile}
}

function aes_decrypt () {
    args=( $@ )
    keyfile="${args[0]}"
    ciphertext_file="${args[1]}"
    plaintext_files="${args[@]:2}"

    if [[ ! -e ${keyfile} ]];
    then
        echo "[decrypt] missing keyfile (${keyfile}). make sure to call decrypt_keyfile() first"
        return 1
    fi

    # decrypt and decompress file with keyfiles
    openssl enc -d -aes-256-cbc -in ${ciphertext_file} -pass file:${keyfile} | tar xz "${plaintext_files[@]}"
}



function generate_keyfile () {
    args=( $@ )
    pubkey="${args[0]}"
    keyfile="${args[1]}"
    enckeyfile="${args[2]}"

    openssl rand 256 > ${keyfile}
    rsa_encrypt ${pubkey} ${keyfile} ${enckeyfile}
}

function decrypt_keyfile () {
    args=( $@ )
    privatekey="${args[0]}"
    enckeyfile="${args[1]}"
    keyfile="${args[2]}"

    rsa_decrypt ${privatekey} ${enckeyfile} ${keyfile}
}

function encrypt () {
    args=( $@ )
    pubkey="${args[0]}"
    enckeyfile="${args[1]}"
    keyfile="/tmp/keyfile.bin"
    encfilename="${args[2]}"
    files="${args[@]:3}"

    generate_keyfile ${pubkey} ${keyfile} ${enckeyfile}
    aes_encrypt ${keyfile} ${encfilename} "${files[@]}"
    # clean up the keyfile
    rm ${keyfile}
}


function decrypt () {
    args=( $@ )
    privkey="${args[0]}"
    enckeyfile="${args[1]}"
    keyfile="/tmp/keyfile.bin"
    encfilename="${args[2]}"
    files="${args[@]:3}"

    decrypt_keyfile ${privkey} ${enckeyfile} ${keyfile}
    aes_decrypt ${keyfile} ${encfilename} "${files[@]}"
    # clean up the keyfile
    rm ${keyfile}
 }
