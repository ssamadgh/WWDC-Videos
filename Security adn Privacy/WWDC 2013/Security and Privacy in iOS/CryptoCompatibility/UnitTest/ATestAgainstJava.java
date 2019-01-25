/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Shows how to generate results compatible with our code from Java.
 */

// I ran this test with the following configuration:
//
// $ sw_vers
// ProductName:	Mac OS X
// ProductVersion:	10.11.6
// BuildVersion:	15G31
// 
// $ java -version
// java version "1.8.0_102"
// Java(TM) SE Runtime Environment (build 1.8.0_102-b14)
// Java HotSpot(TM) 64-Bit Server VM (build 25.102-b14, mixed mode)
//
// I downloaded Java from the download site suggested when I ran `java` from 
// Terminal.  
// 
// To run the test:
//
// $ cd UnitTest
// $ javac ATestAgainstJava.java && java -ea Main
// 
// IMPORTANT: Many of the tests will fail unless you have the Java Cryptography Extension (JCE) 
// Unlimited Strength Jurisdiction Policy Files installed (*phew*).  After downing that package 
// you'll find that the read me references a <java-home> path.  With the configuration described 
// above, that path is `/Library/Java/JavaVirtualMachines/jdk1.8.0_102.jdk/Contents/Home/jre/`.
//
// Note that this code isn't intended to be a good example of Java programming; it's merely 
// sufficient to test the things I needed to test.

import java.lang.*;
import java.util.*;
import java.io.*;
import java.security.*;
import java.security.cert.*;
import java.security.spec.*;
import javax.crypto.*;
import javax.crypto.spec.*;
import javax.xml.bind.DatatypeConverter;

class QHex
{
    public static String hexStringFromBytes(byte[] bytes)
    {
        return DatatypeConverter.printHexBinary(bytes).toLowerCase();
    }

    public static byte[] bytesFromHexString(String string)
    {
        return DatatypeConverter.parseHexBinary(string);
    }
}

class QIO
{
    public static byte[] bytesWithContentsOfFile(String fileName) throws IOException, NoSuchAlgorithmException
    {
        RandomAccessFile f = new RandomAccessFile("../TestData/" + fileName, "r");
        byte[] bytes = new byte[(int) f.length()];
        f.readFully(bytes);
        f.close();
        return bytes;
    }

    public static String stringWithContentsOfFile(String fileName) throws IOException, NoSuchAlgorithmException
    {
        return new String(QIO.bytesWithContentsOfFile(fileName), "UTF-8");
    }
    
    public static byte[] bytesWithDecodedContentsOfPEMFile(String fileName, String tag) throws IOException, NoSuchAlgorithmException
    {
        String pemStr = QIO.stringWithContentsOfFile(fileName);
        String beginMarker = "-----BEGIN " + tag + "-----\n";
        String endMarker = "-----END " + tag + "-----";
        pemStr = pemStr.substring(pemStr.indexOf(beginMarker, 0));
        // System.out.format("%s", pemStr);
        pemStr = pemStr.replace(beginMarker, "");
        pemStr = pemStr.replace(endMarker, "");
        return DatatypeConverter.parseBase64Binary(pemStr);
    }
    
    public static FileInputStream fileInputStreamForFile(String fileName) throws FileNotFoundException
    {
        return new FileInputStream("../TestData/" + fileName);
    }
}

class Base64Tests
{
    public static void testBase64Encode() throws IOException, NoSuchAlgorithmException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("test.cer");
        String expectedOutputString = QIO.stringWithContentsOfFile("test.pem");
        expectedOutputString = expectedOutputString.replace("\n", "");      // there's no way to tell printBase64Binary to add line breaks, so we strip them from the expected string
        String outputString = DatatypeConverter.printBase64Binary(inputBytes);
        assert outputString.equals(expectedOutputString);
    }

    public static void testBase64Decode() throws IOException, NoSuchAlgorithmException
    {
        String inputString = QIO.stringWithContentsOfFile("test.pem");
        byte[] expectedOutputBytes = QIO.bytesWithContentsOfFile("test.cer");
        byte[] outputBytes = DatatypeConverter.parseBase64Binary(inputString);
        assert Arrays.equals(outputBytes, expectedOutputBytes);
    }
}

class DigestTests
{
    public static void testSHA() throws IOException, NoSuchAlgorithmException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("test.cer");
        String kDigestAlgorithms[] = { "SHA1", "SHA-224", "SHA-256", "SHA-384", "SHA-512" };
        byte kDigestsOfTestDotCer[][] = {
            QHex.bytesFromHexString("c1ddfe7dd14c9b8dee83b46b87a408970fd2a83f"),
            QHex.bytesFromHexString("d71908c49c7c1563a829882f1ba6115e1616d1bdbb1d1f757265137b"),
            QHex.bytesFromHexString("d69cb53f849c80d7803294ee8fed312e917656986538d14224468185fac56289"),
            QHex.bytesFromHexString("b1cbdc8c517ad3b0b96436839bfc9cdaf75609c4d8f908444eb31675909912ae73252e0df8a6c8599e81f2a0a760f182"),
            QHex.bytesFromHexString("a1b17242359bb8dbb0cda8356991f65131ca1894ef9f797b296e68dacd300e0e179e28823cd69da1cccc8a3a8d7339bf2c1311b018c48a0e53d488e66df22250")
        };
        assert kDigestAlgorithms.length == kDigestsOfTestDotCer.length;
        for (int i = 0; i < kDigestAlgorithms.length; i++) {
            String algorithm = kDigestAlgorithms[i];
            byte[] expectedOutputBytes = kDigestsOfTestDotCer[i];
            byte[] outputBytes = MessageDigest.getInstance(algorithm).digest(inputBytes);
            assert Arrays.equals(outputBytes, expectedOutputBytes);
        }
    }

    public static void testHMACSHA() throws IOException, NoSuchAlgorithmException, InvalidKeyException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("test.cer");
        String kDigestAlgorithms[] = { "HmacSHA1", "HmacSHA224", "HmacSHA256", "HmacSHA384", "HmacSHA512" };
        byte kDigestsOfTestDotCer[][] = {
            QHex.bytesFromHexString("550a1da058c1b5df6ea167870ae6dbc92f0e0281"),
            QHex.bytesFromHexString("aea439459bf3b7732886d9345c7f2651de94c45ebfc320b1b49c3057"),
            QHex.bytesFromHexString("5ad394b17fb3f064079b0a21f25758550f7c8d9065803ae7271cb7bb86dac081"),
            QHex.bytesFromHexString("78b0fd6c8241261010ad92a9a91538aac46a90989eebdda0cb2564b2dea26061f341eb379d71af720d961c295fbbf5cc"),
            QHex.bytesFromHexString("7ab5c9a876bd52ca9a9cf643ba097e6847ac02797e69f5d39fbdb4ce70390098b978faa022889496c22f0c787e41b17fe9456bb648b2c66ceb53c2dc3cc2c16e")
        };
        assert kDigestAlgorithms.length == kDigestsOfTestDotCer.length;
        byte[] keyBytes = QHex.bytesFromHexString("48656c6c6f20437275656c20576f726c6421");
        for (int i = 0; i < kDigestAlgorithms.length; i++) {
            String algorithm = kDigestAlgorithms[i];
            byte[] expectedOutputBytes = kDigestsOfTestDotCer[i];
            SecretKeySpec keySpec = new SecretKeySpec(keyBytes, algorithm);
            Mac mac = Mac.getInstance(algorithm);
            mac.init(keySpec);
            byte[] outputBytes = mac.doFinal(inputBytes);
            assert Arrays.equals(outputBytes, expectedOutputBytes);
        }
    }
}

class KeyDerivationTests
{
    public static void testPBKDF2() throws IOException, NoSuchAlgorithmException, InvalidKeySpecException
    {
        String passwordString = "Hello Cruel World!";
        byte[] saltBytes = "Some salt sir?".getBytes("UTF-8");
        String kAlgorithms[] = { "PBKDF2WithHmacSHA1", "PBKDF2WithHmacSHA224", "PBKDF2WithHmacSHA256", "PBKDF2WithHmacSHA384", "PBKDF2WithHmacSHA512" };
        byte kExpected[][] = {
            QHex.bytesFromHexString("e56c27f5eed251db50a3"), 
            QHex.bytesFromHexString("88597c3d039227ea2723"), 
            QHex.bytesFromHexString("884185449fa0f5ea91bf"), 
            QHex.bytesFromHexString("7c44bd93a3f5d732a667"), 
            QHex.bytesFromHexString("d4537676e0af5274ca01")
        };
        assert kAlgorithms.length == kExpected.length;
        for (int i = 0; i < kAlgorithms.length; i++) {
            String algorithm = kAlgorithms[i];
            byte[] expectedKeyBytes = kExpected[i];
            PBEKeySpec keySpec = new PBEKeySpec(passwordString.toCharArray(), saltBytes, 1000, 10 * 8);      // keyLength is in bits!
            byte[] keyBytes = SecretKeyFactory.getInstance(algorithm).generateSecret(keySpec).getEncoded();
            assert Arrays.equals(keyBytes, expectedKeyBytes);
        }
    }
}

class CryptorTests
{
    // AES-128
    
    public static void testAES128ECBEncryption() throws IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchProviderException, BadPaddingException, NoSuchPaddingException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("plaintext-336.dat");
        byte[] expectedOutputBytes = QIO.bytesWithContentsOfFile("cyphertext-aes-128-ecb-336.dat");
        byte[] keyBytes = QHex.bytesFromHexString("0C1032520302EC8537A4A82C4EF7579D");
		SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        Cipher cipher = Cipher.getInstance("AES/ECB/NoPadding");
        cipher.init(Cipher.ENCRYPT_MODE, keySpec);
        byte[] outputBytes = cipher.doFinal(inputBytes);
        assert Arrays.equals(outputBytes, expectedOutputBytes);
    }

    public static void testAES128ECBDecryption() throws IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchProviderException, BadPaddingException, NoSuchPaddingException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("cyphertext-aes-128-ecb-336.dat");
        byte[] expectedOutputBytes = QIO.bytesWithContentsOfFile("plaintext-336.dat");
        byte[] keyBytes = QHex.bytesFromHexString("0C1032520302EC8537A4A82C4EF7579D");
		SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        Cipher cipher = Cipher.getInstance("AES/ECB/NoPadding");
        cipher.init(Cipher.DECRYPT_MODE, keySpec);
        byte[] outputBytes = cipher.doFinal(inputBytes);
        assert Arrays.equals(outputBytes, expectedOutputBytes);
    } 

    public static void testAES128CBCEncryption() throws IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchProviderException, BadPaddingException, NoSuchPaddingException, InvalidAlgorithmParameterException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("plaintext-336.dat");
        byte[] expectedOutputBytes = QIO.bytesWithContentsOfFile("cyphertext-aes-128-cbc-336.dat");
        byte[] keyBytes = QHex.bytesFromHexString("0C1032520302EC8537A4A82C4EF7579D");
        byte[] ivBytes = QHex.bytesFromHexString("AB5BBEB426015DA7EEDCEE8BEE3DFFB7");
		SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        Cipher cipher = Cipher.getInstance("AES/CBC/NoPadding");
        cipher.init(Cipher.ENCRYPT_MODE, keySpec, new IvParameterSpec(ivBytes));
        byte[] outputBytes = cipher.doFinal(inputBytes);
        assert Arrays.equals(outputBytes, expectedOutputBytes);
    }

    public static void testAES128CBCDecryption() throws IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchProviderException, BadPaddingException, NoSuchPaddingException, InvalidAlgorithmParameterException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("cyphertext-aes-128-cbc-336.dat");
        byte[] expectedOutputBytes = QIO.bytesWithContentsOfFile("plaintext-336.dat");
        byte[] keyBytes = QHex.bytesFromHexString("0C1032520302EC8537A4A82C4EF7579D");
        byte[] ivBytes = QHex.bytesFromHexString("AB5BBEB426015DA7EEDCEE8BEE3DFFB7");
		SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        Cipher cipher = Cipher.getInstance("AES/CBC/NoPadding");
        cipher.init(Cipher.DECRYPT_MODE, keySpec, new IvParameterSpec(ivBytes));
        byte[] outputBytes = cipher.doFinal(inputBytes);
        assert Arrays.equals(outputBytes, expectedOutputBytes);
    } 

    // AES-256
    
    public static void testAES256ECBEncryption() throws IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchProviderException, BadPaddingException, NoSuchPaddingException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("plaintext-336.dat");
        byte[] expectedOutputBytes = QIO.bytesWithContentsOfFile("cyphertext-aes-256-ecb-336.dat");
        byte[] keyBytes = QHex.bytesFromHexString("0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a");
		SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        Cipher cipher = Cipher.getInstance("AES/ECB/NoPadding");
        cipher.init(Cipher.ENCRYPT_MODE, keySpec);
        byte[] outputBytes = cipher.doFinal(inputBytes);
        assert Arrays.equals(outputBytes, expectedOutputBytes);
    }

    public static void testAES256ECBDecryption() throws IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchProviderException, BadPaddingException, NoSuchPaddingException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("cyphertext-aes-256-ecb-336.dat");
        byte[] expectedOutputBytes = QIO.bytesWithContentsOfFile("plaintext-336.dat");
        byte[] keyBytes = QHex.bytesFromHexString("0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a");
		SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        Cipher cipher = Cipher.getInstance("AES/ECB/NoPadding");
        cipher.init(Cipher.DECRYPT_MODE, keySpec);
        byte[] outputBytes = cipher.doFinal(inputBytes);
        assert Arrays.equals(outputBytes, expectedOutputBytes);
    } 

    public static void testAES256CBCEncryption() throws IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchProviderException, BadPaddingException, NoSuchPaddingException, InvalidAlgorithmParameterException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("plaintext-336.dat");
        byte[] expectedOutputBytes = QIO.bytesWithContentsOfFile("cyphertext-aes-256-cbc-336.dat");
        byte[] keyBytes = QHex.bytesFromHexString("0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a");
        byte[] ivBytes = QHex.bytesFromHexString("AB5BBEB426015DA7EEDCEE8BEE3DFFB7");
		SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        Cipher cipher = Cipher.getInstance("AES/CBC/NoPadding");
        cipher.init(Cipher.ENCRYPT_MODE, keySpec, new IvParameterSpec(ivBytes));
        byte[] outputBytes = cipher.doFinal(inputBytes);
        assert Arrays.equals(outputBytes, expectedOutputBytes);
    }

    public static void testAES256CBCDecryption() throws IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchProviderException, BadPaddingException, NoSuchPaddingException, InvalidAlgorithmParameterException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("cyphertext-aes-256-cbc-336.dat");
        byte[] expectedOutputBytes = QIO.bytesWithContentsOfFile("plaintext-336.dat");
        byte[] keyBytes = QHex.bytesFromHexString("0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a");
        byte[] ivBytes = QHex.bytesFromHexString("AB5BBEB426015DA7EEDCEE8BEE3DFFB7");
		SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        Cipher cipher = Cipher.getInstance("AES/CBC/NoPadding");
        cipher.init(Cipher.DECRYPT_MODE, keySpec, new IvParameterSpec(ivBytes));
        byte[] outputBytes = cipher.doFinal(inputBytes);
        assert Arrays.equals(outputBytes, expectedOutputBytes);
    } 

    // AES-128 Pad CBC
    
    public static void testAES128PadCBCEncryption() throws IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchProviderException, BadPaddingException, NoSuchPaddingException, InvalidAlgorithmParameterException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("plaintext-332.dat");
        byte[] expectedOutputBytes = QIO.bytesWithContentsOfFile("cyphertext-aes-128-cbc-332.dat");
        byte[] keyBytes = QHex.bytesFromHexString("0C1032520302EC8537A4A82C4EF7579D");
        byte[] ivBytes = QHex.bytesFromHexString("AB5BBEB426015DA7EEDCEE8BEE3DFFB7");
		SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, keySpec, new IvParameterSpec(ivBytes));
        byte[] outputBytes = cipher.doFinal(inputBytes);
        assert Arrays.equals(outputBytes, expectedOutputBytes);
    }

    public static void testAES128PadCBCDecryption() throws IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchProviderException, BadPaddingException, NoSuchPaddingException, InvalidAlgorithmParameterException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("cyphertext-aes-128-cbc-332.dat");
        byte[] expectedOutputBytes = QIO.bytesWithContentsOfFile("plaintext-332.dat");
        byte[] keyBytes = QHex.bytesFromHexString("0C1032520302EC8537A4A82C4EF7579D");
        byte[] ivBytes = QHex.bytesFromHexString("AB5BBEB426015DA7EEDCEE8BEE3DFFB7");
		SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, keySpec, new IvParameterSpec(ivBytes));
        byte[] outputBytes = cipher.doFinal(inputBytes);
        assert Arrays.equals(outputBytes, expectedOutputBytes);
    } 

    // AES-256 Pad CBC
    
    public static void testAES256PadCBCEncryption() throws IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchProviderException, BadPaddingException, NoSuchPaddingException, InvalidAlgorithmParameterException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("plaintext-332.dat");
        byte[] expectedOutputBytes = QIO.bytesWithContentsOfFile("cyphertext-aes-256-cbc-332.dat");
        byte[] keyBytes = QHex.bytesFromHexString("0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a");
        byte[] ivBytes = QHex.bytesFromHexString("AB5BBEB426015DA7EEDCEE8BEE3DFFB7");
		SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, keySpec, new IvParameterSpec(ivBytes));
        byte[] outputBytes = cipher.doFinal(inputBytes);
        assert Arrays.equals(outputBytes, expectedOutputBytes);
    }

    public static void testAES256PadCBCDecryption() throws IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchProviderException, BadPaddingException, NoSuchPaddingException, InvalidAlgorithmParameterException
    {
        byte[] inputBytes = QIO.bytesWithContentsOfFile("cyphertext-aes-256-cbc-332.dat");
        byte[] expectedOutputBytes = QIO.bytesWithContentsOfFile("plaintext-332.dat");
        byte[] keyBytes = QHex.bytesFromHexString("0C1032520302EC8537A4A82C4EF7579D2b88e4309655eb40707decdb143e328a");
        byte[] ivBytes = QHex.bytesFromHexString("AB5BBEB426015DA7EEDCEE8BEE3DFFB7");
		SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, keySpec, new IvParameterSpec(ivBytes));
        byte[] outputBytes = cipher.doFinal(inputBytes);
        assert Arrays.equals(outputBytes, expectedOutputBytes);
    } 
}

class RSATests
{
    static PrivateKey sPrivateKey;
    static PublicKey  sPublicKey;
    
    public static void setup() throws IOException, KeyStoreException, NoSuchAlgorithmException, CertificateException, UnrecoverableKeyException, InvalidKeySpecException
    {
        // private key
        
        KeyStore keyStore = KeyStore.getInstance("PKCS12");
        keyStore.load(QIO.fileInputStreamForFile("private.p12"), null);
        if (false) {
            for (Enumeration<String> e = keyStore.aliases(); e.hasMoreElements(); ) {
                System.out.format("%s\n", e.nextElement());
            }
        }
        sPrivateKey = (PrivateKey) keyStore.getKey("testprivatekey", "test".toCharArray());

        // public key
        
        byte[] publicKeyBytes = QIO.bytesWithDecodedContentsOfPEMFile("public.pem", "PUBLIC KEY");
        X509EncodedKeySpec spec = new X509EncodedKeySpec(publicKeyBytes);
        sPublicKey = KeyFactory.getInstance("RSA").generatePublic(spec);
    }

    static int verifyCountForFile(String fileName) throws IOException, FileNotFoundException, CertificateException, NoSuchAlgorithmException, InvalidKeyException, SignatureException, InvalidKeySpecException
    {
        int result = 0;
        byte[] fileBytes = QIO.bytesWithContentsOfFile(fileName + ".cer");
        assert sPublicKey != null;          // set up by setup() method
        String kAlgorithms[] = { "SHA1withRSA", "SHA224withRSA", "SHA256withRSA", "SHA384withRSA", "SHA512withRSA" };
        String kSignatures[] = { 
            "test.cer-sha1.sig", 
            "test.cer-sha2-224.sig", 
            "test.cer-sha2-256.sig", 
            "test.cer-sha2-384.sig", 
            "test.cer-sha2-512.sig"
        };
        assert kAlgorithms.length == kSignatures.length;
        for (int i = 0; i < kAlgorithms.length; i++) {
            String algorithm = kAlgorithms[i];
            byte[] signatureBytes = QIO.bytesWithContentsOfFile(kSignatures[i]);

            Signature sig = Signature.getInstance(algorithm);
            sig.initVerify(sPublicKey);
            sig.update(fileBytes);
            if (sig.verify(signatureBytes)) {
                result += 1;
            }
        }
        return result; 
    }
    
    public static void testRSASHAVerify() throws IOException, FileNotFoundException, CertificateException, NoSuchAlgorithmException, InvalidKeyException, SignatureException, InvalidKeySpecException
    {
        assert RSATests.verifyCountForFile("test") == 5;
        assert RSATests.verifyCountForFile("test-corrupted") == 0;
    }
    
    public static void testRSASHASign() throws IOException, NoSuchAlgorithmException, InvalidKeyException, SignatureException, InvalidKeySpecException
    {
        byte[] fileBytes = QIO.bytesWithContentsOfFile("test.cer");
        assert sPrivateKey != null;         // set up by setup() method
        String kAlgorithms[] = { "SHA1withRSA", "SHA224withRSA", "SHA256withRSA", "SHA384withRSA", "SHA512withRSA" };
        String kSignatures[] = { 
            "test.cer-sha1.sig", 
            "test.cer-sha2-224.sig", 
            "test.cer-sha2-256.sig", 
            "test.cer-sha2-384.sig", 
            "test.cer-sha2-512.sig"
        };
        assert kAlgorithms.length == kSignatures.length;
        for (int i = 0; i < kAlgorithms.length; i++) {
            String algorithm = kAlgorithms[i];
            byte[] expectedSignatureBytes = QIO.bytesWithContentsOfFile(kSignatures[i]);
            Signature sig = Signature.getInstance(algorithm);
            sig.initSign(sPrivateKey);
            sig.update(fileBytes);
            byte[] signatureBytes = sig.sign();
        
            assert Arrays.equals(signatureBytes, expectedSignatureBytes);
        }
    }

    // When you encrypt with padding you can't test a fixed encryption because the padding 
    // adds some randomness so that no two encryptions are the same.  Thus, we can only test 
    // the round trip case (`testRSASmallCryptor`) and the decrypt case (`testRSADecryptPKCS1` 
    // and `testRSADecryptOAEP`).

    public static void testRSASmallCryptor() throws InvalidKeySpecException, IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchPaddingException, BadPaddingException
    {
        byte[] fileBytes = QIO.bytesWithContentsOfFile("plaintext-32.dat");
        assert sPublicKey != null;          // set up by setup() method
        assert sPrivateKey != null;         // set up by setup() method
        
        Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
        cipher.init(Cipher.ENCRYPT_MODE, sPublicKey);
        byte[] encryptedBytes = cipher.doFinal(fileBytes);
        
        cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
        cipher.init(Cipher.DECRYPT_MODE, sPrivateKey);
        byte[] decryptedBytes = cipher.doFinal(encryptedBytes);
        
        assert Arrays.equals(decryptedBytes, fileBytes);
    }

    public static void testRSADecryptPKCS1() throws InvalidKeySpecException, IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchPaddingException, BadPaddingException
    {
        byte[] cyphertext32Bytes = QIO.bytesWithContentsOfFile("cyphertext-rsa-pkcs1-32.dat");
        byte[] fileBytes = QIO.bytesWithContentsOfFile("plaintext-32.dat");
        assert sPublicKey != null;          // set up by setup() method
        assert sPrivateKey != null;         // set up by setup() method

        Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
        cipher.init(Cipher.DECRYPT_MODE, sPrivateKey);
        byte[] decryptedBytes = cipher.doFinal(cyphertext32Bytes);
        
        assert Arrays.equals(decryptedBytes, fileBytes);
    }
    
    public static void testRSADecryptOAEP() throws InvalidKeySpecException, IOException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchAlgorithmException, InvalidKeyException, IllegalBlockSizeException, NoSuchPaddingException, BadPaddingException
    {
        byte[] cyphertext32Bytes = QIO.bytesWithContentsOfFile("cyphertext-rsa-oaep-32.dat");
        byte[] fileBytes = QIO.bytesWithContentsOfFile("plaintext-32.dat");
        assert sPublicKey != null;          // set up by setup() method
        assert sPrivateKey != null;         // set up by setup() method

        Cipher cipher = Cipher.getInstance("RSA/ECB/OAEPPadding");
        cipher.init(Cipher.DECRYPT_MODE, sPrivateKey);
        byte[] decryptedBytes = cipher.doFinal(cyphertext32Bytes);
        
        assert Arrays.equals(decryptedBytes, fileBytes);
    }
}

class Main
{
	public static void main (String[] args) throws Exception
	{
        Base64Tests.testBase64Encode();
        Base64Tests.testBase64Decode();
        DigestTests.testSHA();
        DigestTests.testHMACSHA();
        KeyDerivationTests.testPBKDF2();
        CryptorTests.testAES128ECBEncryption();
        CryptorTests.testAES128ECBDecryption();
        CryptorTests.testAES128CBCEncryption();
        CryptorTests.testAES128CBCDecryption();
        CryptorTests.testAES256ECBEncryption();
        CryptorTests.testAES256ECBDecryption();
        CryptorTests.testAES256CBCEncryption();
        CryptorTests.testAES256CBCDecryption();
        CryptorTests.testAES128PadCBCEncryption();
        CryptorTests.testAES128PadCBCDecryption();
        CryptorTests.testAES256PadCBCEncryption();
        CryptorTests.testAES256PadCBCDecryption();
	    RSATests.setup();
        RSATests.testRSASHAVerify();
        RSATests.testRSASHASign();
        RSATests.testRSASmallCryptor();
        RSATests.testRSADecryptPKCS1();
        RSATests.testRSADecryptOAEP();
	    System.out.format("Success.\n");
	}
}
