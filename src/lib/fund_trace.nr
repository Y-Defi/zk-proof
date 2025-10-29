// Simplified scaffold for Proof of Fund Traceability.
// Goal (MVP): prove exchange_balance equals total_deposits - total_withdrawals + total_yield - fees, all derived from private lists,
// with public commitments (Merkle-like or sha256 vector hashes) anchoring each list.

use std::hash::sha256;

// Sum a fixed-size array of u64
fn sum_u64(arr: [u64; 8]) -> u64 {
    let mut s: u64 = 0;
    for i in 0..8 {
        s = s + arr[i];
    }
    s
}

// Commit a fixed-size array by hashing concatenated LE bytes
fn commit_u64_8(arr: [u64; 8]) -> [u8; 32] {
    let mut bytes: [u8; 8 * 8] = [0; 64];
    let mut offset: u64 = 0;
    for i in 0..8 {
        let b = super::utils::u64_to_le_bytes(arr[i]);
        for j in 0..8 {
            bytes[(offset + (j as u64)) as usize] = b[j];
        }
        offset = offset + 8;
    }
    sha256(bytes)
}

// Main constraint: exchange_balance equals deposits - withdrawals + yield - fees
fn prove_fund_trace(
    // Public inputs
    exchange_balance_now: pub u64,
    deposits_commit: pub [u8; 32],
    withdrawals_commit: pub [u8; 32],
    yield_commit: pub [u8; 32],
    fees_commit: pub [u8; 32],

    // Private lists (fixed-size MVP; can switch to merkle proofs for scalable version)
    deposits: [u64; 8],
    withdrawals: [u64; 8],
    yield_items: [u64; 8],
    fees_items: [u64; 8]
) {
    let total_deposits = sum_u64(deposits);
    let total_withdrawals = sum_u64(withdrawals);
    let total_yield = sum_u64(yield_items);
    let total_fees = sum_u64(fees_items);

    // Enforce commitments match
    let dc = commit_u64_8(deposits);
    let wc = commit_u64_8(withdrawals);
    let yc = commit_u64_8(yield_items);
    let fc = commit_u64_8(fees_items);
    super::utils::bytes32_equal(dc, deposits_commit);
    super::utils::bytes32_equal(wc, withdrawals_commit);
    super::utils::bytes32_equal(yc, yield_commit);
    super::utils::bytes32_equal(fc, fees_commit);

    // Traceability equation
    assert(exchange_balance_now == (total_deposits - total_withdrawals + total_yield - total_fees));
}