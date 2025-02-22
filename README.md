# **OpenSSL with PQC Hybrid KEMs in Docker**

## **📌 Overview**
This **Dockerfile** builds an OpenSSL container with **Post-Quantum Cryptography (PQC) support**, integrating **the Open Quantum Safe (OQS) provider**. It enables **hybrid key exchange mechanisms (KEMs)** for TLS 1.3 connections, allowing **quantum-resistant cryptographic operations**.

---

## **🔧 Features**
- ✅ **Builds OpenSSL 3.2+ from source** with full OQS provider support.
- ✅ **Includes hybrid PQC KEMs**, such as:
  - `X25519MLKEM768` (Hybrid: X25519 + ML-KEM-768)
  - `SecP256r1MLKEM768` (Hybrid: SecP256r1 + ML-KEM-768)
  - `FrodoKEM`, `BIKE`, `HQC`, and more.
- ✅ **Configures OpenSSL to load OQS provider by default**.
- ✅ **Supports TLS 1.3 connections using PQC hybrid key exchange**.

---

## **🚀 How to Build and Run the Container**
### **Step 1: Build the Docker Image**
Clone the repository and build the image:
```sh
docker build -t openssl-oqs .
```

### **Step 2: Create an Alias for Easy Execution**
To run OpenSSL inside the container:
```sh
alias f5pqc-tester='docker run --rm openssl-oqs'
```

### **Step 3: Verify OpenSSL Version**
Ensure OpenSSL 3.2+ is installed in the container:
```sh
f5pqc-tester version -a
```

### **Step 4: List Supported PQC Hybrid KEMs**
Check which PQC hybrid key exchange mechanisms are available:
```sh
f5pqc-tester list --public-key-algorithms -provider oqsprovider
```

### **Step 5: Test a TLS Connection Using PQC**
To connect to a **PQC-enabled** TLS server (e.g., Cloudflare’s PQC test server):
```sh
f5pqc-tester s_client -connect pq.cloudflareresearch.com:443 -curves X25519MLKEM768
```
✅ This negotiates **X25519 + ML-KEM-768** as the key exchange mechanism.

---

## **🔑 Understanding PQC Hybrid KEMs in OpenSSL**
Unlike traditional cipher suites, **TLS 1.3 separates key exchange from encryption**:
- **Cipher suites define encryption & authentication** (e.g., `TLS_AES_256_GCM_SHA384`).
- **Key exchange (KEMs) is negotiated separately** using `-curves`.

### **Example: Listing TLS Cipher Suites**
```sh
f5pqc-tester ciphers -v
```
✅ Output:
```
TLS_AES_256_GCM_SHA384  TLSv1.3  Kx=any   Au=any   Enc=AESGCM(256)  Mac=AEAD
TLS_CHACHA20_POLY1305_SHA256  TLSv1.3  Kx=any   Au=any   Enc=ChaCha20-Poly1305  Mac=AEAD
```
*These do not specify PQC directly—PQC is negotiated separately via `-curves`.*

---

## **🛠 Customizing the Build**
### **Enable Kyber Hybrid KEMs**
To enable **Kyber768**, modify the **Dockerfile**:
```dockerfile
RUN git clone --depth 1 https://github.com/open-quantum-safe/oqs-provider.git && \
    cd oqs-provider && \
    mkdir build && cd build && \
    cmake -GNinja -DCMAKE_PREFIX_PATH=${OPENSSL_PREFIX} \
          -DOQS_ENABLE_KEM_HYBRID=ON \
          -DOQS_KEM_DEFAULT=kyber768 \
          -DOQS_ENABLE_KEM_KYBER=ON \
          -DOQS_ENABLE_SIG=ON .. && \
    ninja && \
    ninja install && \
    ldconfig
```
Then **rebuild**:
```sh
docker build -t openssl-oqs .
```

---

## **📌 Summary**
| Feature                | Description |
|------------------------|-------------|
| **Base Image**         | Ubuntu 22.04 |
| **OpenSSL Version**    | 3.2+ |
| **PQC Provider**       | OQS-Provider |
| **Supported KEMs**     | ML-KEM, BIKE, FrodoKEM, HQC (Kyber optional) |
| **TLS Version**        | 1.3 |
| **Key Exchange**       | `-curves X25519MLKEM768` |

This **Dockerized OpenSSL environment** provides a secure, **PQC-ready** implementation for testing hybrid post-quantum key exchange mechanisms.

---

## **🔗 Additional Resources**
- [Open Quantum Safe (OQS) Project](https://openquantumsafe.org)
- [Cloudflare PQC TLS Test](https://pq.cloudflareresearch.com)
- [OpenSSL Documentation](https://www.openssl.org/docs/)


Note that this was written with the help of ChatGPT and other GenAI tools