use std::hash::sha256;

// Convert u64 to little-endian byte array
fn u64_to_le_bytes(x: u64) -> [u8; 8] {
    let mut out: [u8; 8] = [0; 8];
    for i in 0..8 {
        let shift = (i as u64) * 8;
        let byte = ((x >> shift) & 0xff) as u8;
        out[i] = byte;
    }
    out
}

// Convert u32 to little-endian byte array
fn u32_to_le_bytes(x: u32) -> [u8; 4] {
    let mut out: [u8; 4] = [0; 4];
    for i in 0..4 {
        let shift = (i as u32) * 8;
        let byte = ((x >> shift) & 0xff) as u8;
        out[i] = byte;
    }
    out
}

// XOR-pad a 32-byte key to 64-byte block with given pad constant
fn xor_pad64(key32: [u8; 32], pad: u8) -> [u8; 64] {
    let mut out: [u8; 64] = [0; 64];
    for i in 0..32 {
        out[i] = key32[i] ^ pad;
    }
    for i in 32..64 {
        out[i] = 0 ^ pad;
    }
    out
}

// Concatenate 64 + 20 bytes into 84 bytes
fn concat64_20(a: [u8; 64], b: [u8; 20]) -> [u8; 84] {
    let mut out: [u8; 84] = [0; 84];
    for i in 0..64 {
        out[i] = a[i];
    }
    for i in 0..20 {
        out[64 + i] = b[i];
    }
    out
}

// Concatenate 64 + 32 bytes into 96 bytes
fn concat64_32(a: [u8; 64], b: [u8; 32]) -> [u8; 96] {
    let mut out: [u8; 96] = [0; 96];
    for i in 0..64 {
        out[i] = a[i];
    }
    for i in 0..32 {
        out[64 + i] = b[i];
    }
    out
}

// HMAC-SHA256 using 32-byte key and fixed 20-byte message
// HMAC(k, m) = sha256( (k^opad) || sha256( (k^ipad) || m ) )
fn hmac_sha256_32_20(key32: [u8; 32], msg20: [u8; 20]) -> [u8; 32] {
    let ipad: u8 = 0x36;
    let opad: u8 = 0x5c;

    let k_ipad: [u8; 64] = xor_pad64(key32, ipad);
    let k_opad: [u8; 64] = xor_pad64(key32, opad);

    let inner_input: [u8; 84] = concat64_20(k_ipad, msg20);
    let inner_hash: [u8; 32] = sha256(inner_input);

    let outer_input: [u8; 96] = concat64_32(k_opad, inner_hash);
    let mac: [u8; 32] = sha256(outer_input);
    mac
}

// Compare two 32-byte arrays for equality (constrain each element)
fn bytes32_equal(a: [u8; 32], b: [u8; 32]) {
    for i in 0..32 {
        assert(a[i] == b[i]);
    }
}

// Poseidon-like hash is not necessary here; we commit account_id via sha256 for simplicity.
fn sha256_equal(a: [u8; 32], b: [u8; 32]) {
    bytes32_equal(a, b);
}