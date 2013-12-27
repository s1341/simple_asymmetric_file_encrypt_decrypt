simple_asymmetric_file_encrypt_decrypt
======================================

A set of simple bash functions  for asymmetrically encrypting and decrypting
files.

The functions use RSA to encrypt/decrypt a 256bit symmetric key, which is then
used to encrypt/decrypt the files using AES 256bit in CBC mode.

The files specified are compressed and tared into a single file.

encrypting
----------
The `encrypt` function takes the following arguments:
 - pubkey: The path to an RSA public key in openssl PEM format.
 - keyfile: The name of the file which will contain the encrypted symmetric key.
 - encfilename: The name of the 'encrypted file store' - the encrypted tar ball.
 - file(s): A list of files to encrypt.

### Example
````
encrypt id_rsa.pub.pem keyfile.enc secretfiles.enc *.secret
```

### ProTip
You probably already have an asymmetric RSA keypair: your SSH key!

You can use this same key to encrypt/decrypt files using this script, you just
need to export your ssh public key to the PEM format required by openssl. It's
not necessary to export your private key, as openssl and openssh use the same
private key format.

To export your public ssh key, use the following:
```
ssh-keygen -f ~/.ssh/id_rsa.pub -e -m PKCS8 > id_rsa.pub.pem
```


decrypting
----------
The `decrypt` function takes the following arguments:
 - privkey: The path to an RSA public key file.
 - enckeyfile: The name of the file containing the encrypted symmetric key.
 - encfilename: The name of the 'encrypted file store' - the encrypted tar ball.
 - file(s): A list of files to extract from the tar ball. If undefined, all 
            files will be extracted.

 ### Example
 ```
 decrypt ~/.ssh/id_rsa keyfile.enc secretfiles.enc
 ```
