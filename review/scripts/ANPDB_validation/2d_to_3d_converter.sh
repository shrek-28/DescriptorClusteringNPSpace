
#!/bin/bash

set -uo pipefail

INPUT_DIR="$1"
OUTPUT_DIR="$2"

mkdir -p "$OUTPUT_DIR"

LOG="$OUTPUT_DIR/conversion.log"
SUCCESS_PUBCHEM=0
SUCCESS_GEN3D=0
FAILED=0
SKIPPED=0
ACTIVE_TEMP=""

cleanup() {
    if [[ -n "$ACTIVE_TEMP" ]]; then
        rm -f "$ACTIVE_TEMP"
    fi
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM
trap 'cleanup; exit 129' HUP

for input_file in "$INPUT_DIR"/*.sdf; do
    [ -f "$input_file" ] || continue

    filename=$(basename "$input_file")
    molecule_id="${filename%.sdf}"
    output_file="$OUTPUT_DIR/$filename"
    temp_file="$OUTPUT_DIR/${molecule_id}.tmp.sdf"

    if [ -s "$output_file" ] && grep -q '^\$\$\$\$$' "$output_file"; then
        ((SKIPPED+=1))
        continue
    fi

    rm -f "$output_file"

    cid=$(awk '
        /<PubChemID>/ {
            getline
            gsub(/[[:space:]\r]/, "")
            print
            exit
        }
    ' "$input_file")

    ACTIVE_TEMP="$temp_file"
    rm -f "$temp_file"

    # Attempt PubChem 3D retrieval
    if [[ "$cid" =~ ^[0-9]+$ ]] && \
       curl -fLsS --retry 2 --retry-delay 2 \
           --connect-timeout 15 --max-time 120 \
           "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${cid}/SDF?record_type=3d" \
           -o "$temp_file" 2>/dev/null && \
       [ -s "$temp_file" ] && \
       grep -q '^\$\$\$\$$' "$temp_file"; then

        mv "$temp_file" "$output_file"
        echo "$molecule_id converted (PubChem CID: $cid)" | tee -a "$LOG"
        ((SUCCESS_PUBCHEM+=1))

    # Fallback: generate 3D from the original 2D SDF
    elif obabel "$input_file" \
        -O "$temp_file" \
        --gen3d \
        --minimize \
        --ff UFF \
        --steps 10000 \
        --crit 1e-6 \
        >/dev/null 2>&1 && \
        [ -s "$temp_file" ] && \
        grep -q '^\$\$\$\$$' "$temp_file"; then

        mv "$temp_file" "$output_file"
        echo "$molecule_id converted (Open Babel fallback; CID: ${cid:-missing})" | tee -a "$LOG"
        ((SUCCESS_GEN3D+=1))

    else
        rm -f "$temp_file"
        echo "$molecule_id failed (CID: ${cid:-missing})" | tee -a "$LOG"
        ((FAILED+=1))
    fi

    ACTIVE_TEMP=""
    sleep 0.2
done

echo "================================"
echo "Conversion completed"
echo "PubChem 3D: $SUCCESS_PUBCHEM"
echo "Open Babel fallback: $SUCCESS_GEN3D"
echo "Failed: $FAILED"
echo "Skipped: $SKIPPED"
echo "Log: $LOG"
echo "================================"
