import csv
import hashlib

def hash_address(address):
    return hashlib.sha256(address.encode()).hexdigest()

def compute_merkle_proof(addresses):
    if len(addresses) == 1:
        return [], addresses[0]

    mid = len(addresses) // 2
    left_proof, left_hash = compute_merkle_proof(addresses[:mid])
    right_proof, right_hash = compute_merkle_proof(addresses[mid:])

    combined_hash = hash_address(left_hash + right_hash)
    proof = [right_hash] + left_proof if len(addresses) % 2 == 1 else [left_hash] + right_proof
    return proof, combined_hash

def generate_merkle_proofs(csv_file):
    with open(csv_file, 'r') as f:
        reader = csv.DictReader(f)
        addresses = [row['user'] for row in reader]

    merkle_proofs = {}
    for i in range(len(addresses)):
        proof, _ = compute_merkle_proof(addresses[:i] + addresses[i+1:])
        merkle_proofs[addresses[i]] = proof

    return merkle_proofs

# Generate Merkle proofs for the addresses in the CSV file
merkle_proofs = generate_merkle_proofs('replies_clean.csv')

# Save the Merkle proofs to a file
with open('merkle_proofs.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['address', 'proof'])
    for address, proof in merkle_proofs.items():
        writer.writerow([address, ','.join(proof)])
