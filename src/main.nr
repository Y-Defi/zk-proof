use std::hash::sha256;
mod utils;

fn main(
    // Public inputs
    timestamp: pub u64,              // Attested time for the account snapshot
    exchange_id: pub u32,            // Specific CEX code (e.g., 1=Binance, 2=OKX)
    signature: pub [u8; 32],         // HMAC-SHA256 over the snapshot message
    account_id_hash: pub [u8; 32],   // Commitment to hidden account ID (sha256(account_id))

    // Private inputs
    api_key: [u8; 32],               // API secret (NOT revealed)
    balance: u64,                    // Balance value (NOT revealed, only constrained > 0)
    account_id: [u8; 32]             // Account ID (NOT revealed)
) {
    // Encode snapshot message as bytes: LE(timestamp[8]) || LE(exchange_id[4]) || LE(balance[8])
    let ts_bytes: [u8; 8] = utils::u64_to_le_bytes(timestamp);
    let ex_bytes: [u8; 4] = utils::u32_to_le_bytes(exchange_id);
    let bal_bytes: [u8; 8] = utils::u64_to_le_bytes(balance);

    // Build fixed 20-byte message
    let mut msg: [u8; 20] = [0; 20];
    // Copy ts (8), ex (4), bal (8)
    for i in 0..8 {
        msg[i] = ts_bytes[i];
    }
    for i in 0..4 {
        msg[8 + i] = ex_bytes[i];
    }
    for i in 0..8 {
        msg[12 + i] = bal_bytes[i];
    }

    // Compute HMAC-SHA256 with api_key (private), compare to public signature
    let expected_sig: [u8; 32] = utils::hmac_sha256_32_20(api_key, msg);
    utils::bytes32_equal(expected_sig, signature);

    // Assert non-zero balance without revealing balance value
    assert(balance != 0);

    // Bind the hidden account_id to a public commitment; proves we have a real account ID but don't disclose it
    let account_id_digest: [u8; 32] = sha256(account_id);
    utils::sha256_equal(account_id_digest, account_id_hash);

    // Optional: constrain specific exchange id if needed (e.g., only Binance valid)
    // assert(exchange_id == 1);
}