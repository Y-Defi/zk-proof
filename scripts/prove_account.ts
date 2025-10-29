import { Noir } from "@noir-lang/noir_js";
import { BarretenbergBackend } from "@noir-lang/barretenberg";
import fs from "node:fs";

function u64ToLeBytes(x: bigint): Uint8Array {
  const out = new Uint8Array(8);
  let v = x;
  for (let i = 0; i < 8; i++) {
    out[i] = Number(v & 0xffn);
    v >>= 8n;
  }
  return out;
}

function u32ToLeBytes(x: number): Uint8Array {
  const out = new Uint8Array(4);
  let v = BigInt(x);
  for (let i = 0; i < 4; i++) {
    out[i] = Number(v & 0xffn);
    v >>= 8n;
  }
  return out;
}

function concatBytes(a: Uint8Array, b: Uint8Array): Uint8Array {
  const out = new Uint8Array(a.length + b.length);
  out.set(a, 0);
  out.set(b, a.length);
  return out;
}

// HMAC-SHA256 using Node crypto to produce signature (off-circuit)
import crypto from "node:crypto";
function hmacSHA256(key: Uint8Array, msg: Uint8Array): Uint8Array {
  const mac = crypto.createHmac("sha256", key).update(msg).digest();
  return new Uint8Array(mac);
}

async function main() {
  const circuit = JSON.parse(fs.readFileSync("./target/account_control.json", "utf-8"));
  const backend = new BarretenbergBackend(circuit);
  const noir = new Noir(circuit, backend);

  // Example values
  const timestamp = 1730200000n;
  const exchange_id = 1;
  const api_key = crypto.randomBytes(32); // Replace with real API secret if desired
  const balance = 12345n; // private, only constrained > 0
  const account_id = crypto.randomBytes(32);

  const msg = concatBytes(
    concatBytes(u64ToLeBytes(timestamp), u32ToLeBytes(exchange_id)),
    u64ToLeBytes(balance)
  );

  const signature = hmacSHA256(api_key, msg);
  const account_id_hash = new Uint8Array(
    crypto.createHash("sha256").update(account_id).digest()
  );

  const inputs = {
    timestamp: timestamp.toString(),
    exchange_id,
    signature: Array.from(signature),
    account_id_hash: Array.from(account_id_hash),
    api_key: Array.from(api_key),
    balance: balance.toString(),
    account_id: Array.from(account_id),
  };

  const proof = await noir.generateProof(inputs);
  fs.writeFileSync("./proof_account.json", JSON.stringify(proof, null, 2));
  const verified = await noir.verifyProof(proof);
  console.log("Verified:", verified);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});