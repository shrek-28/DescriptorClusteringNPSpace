from rdkit import Chem
import csv

input_sdf = r"C:/Users/admin/Documents/Major_Project/DATA/complete_coconut_SDF.sdf"

output_csv = "molecules.csv"

IDENTIFIER_FIELD = "identifier"  

# Open CSV for writing
with open(output_csv, mode="w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["canonical_smiles", "identifier"])

    suppl = Chem.SDMolSupplier(input_sdf, sanitize=False, removeHs=False)

    total = 0
    written = 0
    failed = 0

    for mol in suppl:
        total += 1
        if mol is None:
            failed += 1
            continue

        try:
            Chem.RemoveStereochemistry(mol)
            Chem.SanitizeMol(mol)
            smi = Chem.MolToSmiles(mol, canonical=True)
            identifier = mol.GetProp(IDENTIFIER_FIELD) if mol.HasProp(IDENTIFIER_FIELD) else ""
            writer.writerow([identifier, smi])
            written += 1

        except Exception as e:
            failed += 1

print(f"Processed: {total}")
print(f"Written: {written}")
print(f"Failed: {failed}")
print(f"CSV saved to: {output_csv}")
