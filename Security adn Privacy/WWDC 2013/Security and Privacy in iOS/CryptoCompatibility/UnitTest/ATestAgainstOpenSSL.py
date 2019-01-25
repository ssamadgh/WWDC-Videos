#! /usr/bin/python
#
#   Copyright (C) 2016 Apple Inc. All Rights Reserved.
#   See LICENSE.txt for this sample’s licensing information
#   
#   Abstract:
#   #           Tests the command line tool against equivalent OpenSSL commands.
#   #
#

import sys
import os
import subprocess
import tempfile
import time

def pathForResource(relPath):
    return os.path.join(os.path.dirname(sys.argv[0]), "..", "TestData", relPath)

gPathForTool = None

def findPathForTool():
    # We look for the `CryptoCompatibility` tool in the `BUILT_PRODUCTS_DIR`, which 
    # we find by running `xcodebuild`.
    output1 = subprocess.check_output(["xcodebuild", "-showBuildSettings", "-configuration", "Debug"], stderr=open("/dev/null"))
    for l in [l.strip() for l in output1.split("\n")]:
        prefix = "BUILT_PRODUCTS_DIR = "
        if l.startswith(prefix):
            return os.path.join(l[len(prefix):], "CryptoCompatibility")
    return os.path.join(os.path.dirname(sys.argv[0]), "..", "build", "Debug", "CryptoCompatibility")

def setupPathForTool():
    global gPathForTool
    if len(sys.argv) == 1:
        gPathForTool = findPathForTool()
    else:
        gPathForTool = sys.argv[1]
    if not os.path.isfile(gPathForTool):
        print >> sys.stderr, "%s: tool not found: %s" % (os.path.basename(sys.argv[0]), gPathForTool)
        sys.exit(1)
    
def pathForTool():
    return gPathForTool

def checkCommandOutputAgainOtherCommand(command1, command2, command2Filter=None, ignoreRetCode1=False, ignoreRetCode2=False):

    try:
        output1 = subprocess.check_output(command1)
    except subprocess.CalledProcessError, e:
        if ignoreRetCode1:
            output1 = e.output
        else:
            raise e
    
    try:
        output2 = subprocess.check_output(command2)
    except subprocess.CalledProcessError, e:
        if ignoreRetCode2:
            output2 = e.output
        else:
            raise e
    
    if command2Filter != None:
        output2 = command2Filter(output2)

    if output1 != output2:
        print "output1 = %s" % output1.encode("hex")
        print "output2 = %s" % output2.encode("hex")
        assert False

def checkCommandOutputFixed(command, expectedOutput):
    actualOutput = subprocess.check_output(command)
    if actualOutput != expectedOutput:
        print "actualOutput = %s" % actualOutput.encode("hex")
        print "expectedOutput = %s" % expectedOutput.encode("hex")
        assert False

def checkBase64Encode():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "base64-encode", 
            "-l", 
            pathForResource("test.cer")
        ], [
            "openssl", 
            "enc", 
            "-e", 
            "-base64", 
            "-in", 
            pathForResource("test.cer")
        ]
    )
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "base64-encode", 
            "-l", 
            pathForResource("plaintext-0.dat")
        ], [
            "openssl", 
            "enc", 
            "-e", 
            "-base64", 
            "-in", 
            pathForResource("plaintext-0.dat")
        ]
    )

def checkBase64Decode():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "base64-decode", 
            pathForResource("test.pem")
        ], [
            "openssl", 
            "enc", 
            "-d", 
            "-base64", 
            "-in", 
            pathForResource("test.pem")
        ]
    )
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "base64-decode", 
            pathForResource("plaintext-0.dat")
        ], [
            "openssl", 
            "enc", 
            "-d", 
            "-base64", 
            "-in", 
            pathForResource("plaintext-0.dat")
        ]
    )

def checkSHA1Digest():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "digest",
            "-a", "sha1",  
            pathForResource("test.cer")
        ], [
            "openssl", 
            "dgst", 
            "-sha1", 
            pathForResource("test.cer")
        ], 
        lambda s : s[s.index("=")+2:]
    )
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "digest",
            "-a", "sha1",  
            pathForResource("plaintext-0.dat")
        ], [
            "openssl", 
            "dgst", 
            "-sha1", 
            pathForResource("plaintext-0.dat")
        ], 
        lambda s : s[s.index("=")+2:]
    )

def checkSHA2Digest():
    for sizeInBits in [224, 256, 384, 512]:
        checkCommandOutputAgainOtherCommand([
                pathForTool(), 
                "digest",
                "-a", "sha2-%s" % sizeInBits,  
                pathForResource("test.cer")
            ], [
                "openssl", 
                "dgst", 
                "-sha%d" % sizeInBits, 
                pathForResource("test.cer")
            ], 
            lambda s : s[s.index("=")+2:]
        )
        checkCommandOutputAgainOtherCommand([
                pathForTool(), 
                "digest",
                "-a", "sha2-%s" % sizeInBits,  
                pathForResource("plaintext-0.dat")
            ], [
                "openssl", 
                "dgst", 
                "-sha%d" % sizeInBits, 
                pathForResource("plaintext-0.dat")
            ], 
            lambda s : s[s.index("=")+2:]
        )

def checkHMACSHA():
    # AFAICT the version of OpenSSL installed on OS X does not let us 
    # specify the key as hex, so we have to rely or its key derivation 
    # here.  It seems it just uses the bytes of the key string as the 
    # key, and thus we do the same (using UTF-8 because that's what you 
    # get by default from Terminal).
    for ours, theirs in [ ("sha1", "-sha1"), ("sha2-224", "-sha224"), ("sha2-256", "-sha256"), ("sha2-384", "-sha384"), ("sha2-512", "-sha512") ]:
        checkCommandOutputAgainOtherCommand([
                pathForTool(), 
                "hmac",
                "-a", ours, 
                "-k", 
                "48656c6c6f20437275656c20576f726c6421", 
                pathForResource("test.cer")
            ], [
                "openssl", 
                "dgst", 
                theirs, 
                "-hmac", 
                "Hello Cruel World!", 
                pathForResource("test.cer")
            ], 
            lambda s : s[s.index("=")+2:]
        )
        checkCommandOutputAgainOtherCommand([
                pathForTool(), 
                "hmac",
                "-a", ours, 
                "-k", 
                "", 
                pathForResource("test.cer")
            ], [
                "openssl", 
                "dgst", 
                theirs, 
                "-hmac", 
                "", 
                pathForResource("test.cer")
            ], 
            lambda s : s[s.index("=")+2:]
        )

def checkPBKDF2KeyDerivation():
    # AFAICT there's no way to get the OpenSSL command line tool to do PBKDF2 )-:
    pass

def checkAES128ECBEncryption():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-encrypt", 
            "-e", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            pathForResource("plaintext-336.dat")
        ], [
            "openssl", 
            "enc", 
            "-e", 
            "-aes-128-ecb", 
            "-nopad", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-in", 
            pathForResource("plaintext-336.dat")
        ]
    )
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-encrypt", 
            "-e", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            pathForResource("plaintext-0.dat")
        ], [
            "openssl", 
            "enc", 
            "-e", 
            "-aes-128-ecb", 
            "-nopad", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-in", 
            pathForResource("plaintext-0.dat")
        ]
    )

def checkAES128ECBDecryption():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-decrypt", 
            "-e", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            pathForResource("cyphertext-aes-128-ecb-336.dat")
        ], [
            "openssl", 
            "enc", 
            "-d", 
            "-aes-128-ecb", 
            "-nopad", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-in", 
            pathForResource("cyphertext-aes-128-ecb-336.dat")
        ]
    )
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-decrypt", 
            "-e", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            pathForResource("plaintext-0.dat")
        ], [
            "openssl", 
            "enc", 
            "-d", 
            "-aes-128-ecb", 
            "-nopad", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-in", 
            pathForResource("plaintext-0.dat")
        ]
    )

def checkAES128CBCEncryption():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-encrypt", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-i", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            pathForResource("plaintext-336.dat")
        ], [
            "openssl", 
            "enc", 
            "-e", 
            "-aes-128-cbc", 
            "-nopad", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-iv", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            "-in", 
            pathForResource("plaintext-336.dat")
        ]
    )

def checkAES128CBCDecryption():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-decrypt", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-i", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            pathForResource("cyphertext-aes-128-cbc-336.dat")
        ], [
            "openssl", 
            "enc", 
            "-d", 
            "-aes-128-cbc", 
            "-nopad", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-iv", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            "-in", 
            pathForResource("cyphertext-aes-128-cbc-336.dat")
        ]
    )

def checkAES256ECBEncryption():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-encrypt", 
            "-e", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a", 
            pathForResource("plaintext-336.dat")
        ], [
            "openssl", 
            "enc", 
            "-e", 
            "-aes-256-ecb", 
            "-nopad", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a", 
            "-in", 
            pathForResource("plaintext-336.dat")
        ]
    )

def checkAES256ECBDecryption():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-decrypt", 
            "-e", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a", 
            pathForResource("cyphertext-aes-256-ecb-336.dat")
        ], [
            "openssl", 
            "enc", 
            "-d", 
            "-aes-256-ecb", 
            "-nopad", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a", 
            "-in", 
            pathForResource("cyphertext-aes-256-ecb-336.dat")
        ]
    )

def checkAES256CBCEncryption():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-encrypt", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a", 
            "-i", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            pathForResource("plaintext-336.dat")
        ], [
            "openssl", 
            "enc", 
            "-e", 
            "-aes-256-cbc", 
            "-nopad", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a", 
            "-iv", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            "-in", 
            pathForResource("plaintext-336.dat")
        ]
    )

def checkAES256CBCDecryption():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-decrypt", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a", 
            "-i", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            pathForResource("cyphertext-aes-256-cbc-336.dat")
        ], [
            "openssl", 
            "enc", 
            "-d", 
            "-aes-256-cbc", 
            "-nopad", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a", 
            "-iv", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            "-in", 
            pathForResource("cyphertext-aes-256-cbc-336.dat")
        ]
    )

# ---------------------------------------------------------------------------

def checkAES128PadCBCEncryption():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-pad-encrypt", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-i", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            pathForResource("plaintext-332.dat")
        ], [
            "openssl", 
            "enc", 
            "-e", 
            "-aes-128-cbc", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-iv", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            "-in", 
            pathForResource("plaintext-332.dat")
        ]
    )
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-pad-encrypt", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-i", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            pathForResource("plaintext-0.dat")
        ], [
            "openssl", 
            "enc", 
            "-e", 
            "-aes-128-cbc", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-iv", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            "-in", 
            pathForResource("plaintext-0.dat")
        ]
    )

def checkAES128PadCBCDecryption():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-pad-decrypt", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-i", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            pathForResource("cyphertext-aes-128-cbc-332.dat")
        ], [
            "openssl", 
            "enc", 
            "-d", 
            "-aes-128-cbc", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-iv", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            "-in", 
            pathForResource("cyphertext-aes-128-cbc-332.dat")
        ]
    )
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-pad-decrypt", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-i", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            pathForResource("cyphertext-aes-128-cbc-0.dat")
        ], [
            "openssl", 
            "enc", 
            "-d", 
            "-aes-128-cbc", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D", 
            "-iv", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            "-in", 
            pathForResource("cyphertext-aes-128-cbc-0.dat")
        ]
    )

def checkAES128PadBigCBCEncryption():
    ourEncryptedOutput = tempfile.NamedTemporaryFile()
    theirDecryptedOutput = tempfile.NamedTemporaryFile()

    subprocess.check_call([
        pathForTool(), 
        "aes-pad-big-encrypt", 
        "-k", 
        "0C1032520302EC8537A4A82C4EF7579D", 
        "-i", 
        "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
        "/System/Library/Kernels/kernel", 
        ourEncryptedOutput.name
    ])

    subprocess.check_call([
        "openssl", 
        "enc", 
        "-d", 
        "-aes-128-cbc", 
        "-K", 
        "0C1032520302EC8537A4A82C4EF7579D", 
        "-iv", 
        "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
        "-in", 
        ourEncryptedOutput.name, 
        "-out", 
        theirDecryptedOutput.name
    ])

    subprocess.check_call([
        "cmp", 
        "/System/Library/Kernels/kernel", 
        theirDecryptedOutput.name
    ])
    
    ourEncryptedOutput.close();
    theirDecryptedOutput.close();

def checkAES128PadBigCBCDecryption():
    theirEncryptedOutput = tempfile.NamedTemporaryFile()
    ourDecryptedOutput = tempfile.NamedTemporaryFile()

    subprocess.check_call([
        "openssl", 
        "enc", 
        "-e", 
        "-aes-128-cbc", 
        "-K", 
        "0C1032520302EC8537A4A82C4EF7579D", 
        "-iv", 
        "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
        "-in", 
        "/System/Library/Kernels/kernel", 
        "-out", 
        theirEncryptedOutput.name
    ])

    subprocess.check_call([
        pathForTool(), 
        "aes-pad-big-decrypt", 
        "-k", 
        "0C1032520302EC8537A4A82C4EF7579D", 
        "-i", 
        "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
        theirEncryptedOutput.name, 
        ourDecryptedOutput.name
    ])

    subprocess.check_call([
        "cmp", 
        "/System/Library/Kernels/kernel", 
        ourDecryptedOutput.name
    ])

    theirEncryptedOutput.close();
    ourDecryptedOutput.close();

def checkAES256PadCBCEncryption():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-pad-encrypt", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a", 
            "-i", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            pathForResource("plaintext-332.dat")
        ], [
            "openssl", 
            "enc", 
            "-e", 
            "-aes-256-cbc", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a", 
            "-iv", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            "-in", 
            pathForResource("plaintext-332.dat")
        ]
    )

def checkAES256PadCBCDecryption():
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "aes-pad-decrypt", 
            "-k", 
            "0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a", 
            "-i", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            pathForResource("cyphertext-aes-256-cbc-332.dat")
        ], [
            "openssl", 
            "enc", 
            "-d", 
            "-aes-256-cbc", 
            "-K", 
            "0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a", 
            "-iv", 
            "AB5BBEB426015DA7EEDCEE8BEE3DFFB7", 
            "-in", 
            pathForResource("cyphertext-aes-256-cbc-332.dat")
        ]
    )

def checkRSAVerifySHADigest():
    def normaliseVerificationOutput(s):
        if s == "Verified OK\n":
            result = "verified\n"
        elif s == "Verification Failure\n":
            result = "not verified\n"
        else:
            assert False
        return result

    for ours, theirs in [ ("sha1", "-sha1"), ("sha2-224", "-sha224"), ("sha2-256", "-sha256"), ("sha2-384", "-sha384"), ("sha2-512", "-sha512") ]:
        checkCommandOutputAgainOtherCommand([
                pathForTool(), 
                "rsa-verify",
                "-a", ours,  
                pathForResource("public.pem"),
                pathForResource("test.cer-%s.sig" % ours),
                pathForResource("test.cer")
            ], [
                "openssl", 
                "dgst", 
                theirs, 
                "-verify", 
                pathForResource("public.pem"), 
                "-signature", 
                pathForResource("test.cer-%s.sig" % ours), 
                pathForResource("test.cer")
            ], 
            normaliseVerificationOutput, 
            ignoreRetCode2=True
        )
        checkCommandOutputAgainOtherCommand([
                pathForTool(), 
                "rsa-verify",
                "-a", ours,  
                pathForResource("public.pem"),
                pathForResource("test.cer-%s.sig" % ours),
                pathForResource("test-corrupted.cer")
            ], [
                "openssl", 
                "dgst", 
                theirs, 
                "-verify", 
                pathForResource("public.pem"), 
                "-signature", 
                pathForResource("test.cer-%s.sig" % ours), 
                pathForResource("test-corrupted.cer")
            ], 
            normaliseVerificationOutput, 
            ignoreRetCode2=True
        )

    # I don't feel the need to check all the digest schemes in the 0 byte case.
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "rsa-verify",
            "-a", "sha1",  
            pathForResource("public.pem"),
            pathForResource("plaintext-0.dat.sig"),
            pathForResource("plaintext-0.dat")
        ], [
            "openssl", 
            "dgst", 
            "-sha1", 
            "-verify", 
            pathForResource("public.pem"), 
            "-signature", 
            pathForResource("plaintext-0.dat.sig"),
            pathForResource("plaintext-0.dat")
        ], 
        normaliseVerificationOutput, 
        ignoreRetCode2=True
    )

def checkRSASignSHADigest():
    for ours, theirs in [ ("sha1", "-sha1"), ("sha2-224", "-sha224"), ("sha2-256", "-sha256"), ("sha2-384", "-sha384"), ("sha2-512", "-sha512") ]:
        checkCommandOutputAgainOtherCommand([
                pathForTool(), 
                "rsa-sign",
                "-a", ours,  
                pathForResource("private.pem"), 
                pathForResource("test.cer")
            ], [
                "openssl", 
                "dgst", 
                theirs, 
                "-sign", 
                pathForResource("private.pem"), 
                pathForResource("test.cer"), 
            ], 
            lambda s : s.encode("hex") + "\n"
        )

    # I don't feel the need to check all the digest schemes in the 0 byte case.
    checkCommandOutputAgainOtherCommand([
            pathForTool(), 
            "rsa-sign",
            "-a", "sha1",  
            pathForResource("private.pem"), 
            pathForResource("plaintext-0.dat")
        ], [
            "openssl", 
            "dgst", 
            "-sha1", 
            "-sign", 
            pathForResource("private.pem"), 
            pathForResource("plaintext-0.dat"), 
        ], 
        lambda s : s.encode("hex") + "\n"
    )

def checkRSASmallEncrypt():
    # In the PKCS#1 padding case we have OpenSSL decrypt our results.
    cypherText = subprocess.check_output([
            pathForTool(), 
            "rsa-small-encrypt", 
            pathForResource("public.pem"), 
            pathForResource("plaintext-32.dat")
    ])
    assert cypherText[-1] == "\n"
    cypherText = cypherText[:-1]
    cypherTextFile = tempfile.NamedTemporaryFile()
    cypherTextFile.write(cypherText.decode("hex"))
    cypherTextFile.flush()
    decryptedCypherText = subprocess.check_output([
            "openssl", 
            "rsautl",
            "-decrypt",
            "-pkcs",
            "-inkey",
            pathForResource("private.pem"),
            "-in",
            cypherTextFile.name
    ])
    cypherTextFile.close()
    assert decryptedCypherText == open(pathForResource("plaintext-32.dat")).read()

    # In the OAEP padding case we have OpenSSL decrypt our results.
    cypherText = subprocess.check_output([
            pathForTool(), 
            "rsa-small-encrypt", 
            "-p", 
            "oaep", 
            pathForResource("public.pem"), 
            pathForResource("plaintext-32.dat")
    ])
    assert cypherText[-1] == "\n"
    cypherText = cypherText[:-1]
    cypherTextFile = tempfile.NamedTemporaryFile()
    cypherTextFile.write(cypherText.decode("hex"))
    cypherTextFile.flush()
    decryptedCypherText = subprocess.check_output([
            "openssl", 
            "rsautl",
            "-decrypt",
            "-oaep",
            "-inkey",
            pathForResource("private.pem"),
            "-in",
            cypherTextFile.name
    ])
    cypherTextFile.close()
    assert decryptedCypherText == open(pathForResource("plaintext-32.dat")).read()

def checkRSASmallDecrypt():
    # In the PKCS#1 padding case we decrypt OpenSSL's results.
    cypherText = subprocess.check_output([
            "openssl", 
            "rsautl",
            "-encrypt",
            "-pkcs",
            "-pubin",
            "-inkey",
            pathForResource("public.pem"),
            "-in",
            pathForResource("plaintext-32.dat")
    ])
    cypherTextFile = tempfile.NamedTemporaryFile()
    cypherTextFile.write(cypherText)
    cypherTextFile.flush()
    decryptedCypherText = subprocess.check_output([
            pathForTool(), 
            "rsa-small-decrypt", 
            pathForResource("private.pem"), 
            cypherTextFile.name
    ])
    cypherTextFile.close()
    assert decryptedCypherText == (open(pathForResource("plaintext-32.dat")).read().encode("hex") + "\n")

    # In the OAEP padding case we decrypt OpenSSL's results.
    cypherText = subprocess.check_output([
            "openssl", 
            "rsautl",
            "-encrypt",
            "-oaep",
            "-pubin",
            "-inkey",
            pathForResource("public.pem"),
            "-in",
            pathForResource("plaintext-32.dat")
    ])
    cypherTextFile = tempfile.NamedTemporaryFile()
    cypherTextFile.write(cypherText)
    cypherTextFile.flush()
    decryptedCypherText = subprocess.check_output([
            pathForTool(), 
            "rsa-small-decrypt", 
            "-p", 
            "oaep", 
            pathForResource("private.pem"), 
            cypherTextFile.name
    ])
    cypherTextFile.close()
    assert decryptedCypherText == (open(pathForResource("plaintext-32.dat")).read().encode("hex") + "\n")

setupPathForTool();

checkBase64Encode()
checkBase64Decode()

checkSHA1Digest()
checkSHA2Digest()
checkHMACSHA()

checkPBKDF2KeyDerivation()

checkAES128ECBEncryption()
checkAES128ECBDecryption()
checkAES128CBCEncryption()
checkAES128CBCDecryption()

checkAES256ECBEncryption()
checkAES256ECBDecryption()
checkAES256CBCEncryption()
checkAES256CBCDecryption()

# I'm not exercising the Pad + ECB case because ECB is a bad idea and 
# I don't want to encourage it.

checkAES128PadCBCEncryption()
checkAES128PadCBCDecryption()
checkAES128PadBigCBCEncryption()
checkAES128PadBigCBCDecryption()
checkAES256PadCBCEncryption()
checkAES256PadCBCDecryption()

checkRSAVerifySHADigest()
checkRSASignSHADigest()
checkRSASmallEncrypt()
checkRSASmallDecrypt()

print "Success"
