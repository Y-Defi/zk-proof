// Simplified scaffold for Proof of Actual Return Rate.
// MVP: linearized annualization: R = ((V1 - V0) / V0) * (365 / T)
// Use fixed-point i64 scaled by S (e.g., S=1e6)

fn prove_return_rate(
    // Public inputs (fixed-point scaled by S)
    S: pub i64,                 // scale (e.g., 1_000_000)
    T_days: pub i64,            // period length in days
    R_benchmark: pub i64,       // promised benchmark rate scaled by S

    // Private inputs (fixed-point)
    V0: i64,                    // starting net assets
    V1: i64                     // ending net assets
) {
    // Prevent divide-by-zero and ensure positive scale
    assert(V0 > 0);
    assert(S > 0);
    assert(T_days > 0);

    // ((V1 - V0) / V0) * (365 / T_days)
    // In fixed-point: num = (V1 - V0) * S / V0  => simple return
    let num = ((V1 - V0) * S) / V0;
    let R = (num * 365) / T_days;

    // Prove actual return meets or exceeds benchmark
    assert(R >= R_benchmark);
}