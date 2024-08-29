awk -v ids_file="ids.txt" -v min_len=100 '
BEGIN {
    # Read IDs into an array, appending space to each
    while ((getline line < ids_file) > 0) {
        ids[line " "] = 1
    }
    close(ids_file)
}

# Process each header
/^>/ {
    # If we have a previous sequence and it matches the ID pattern
    if (seq && length(seq) > min_len && header ~ id_pattern) {
        print header
        print seq
    }
    header = $0
    seq = ""
    id_pattern = ""
    # Build the pattern for matching
    for (id in ids) {
        id_pattern = id_pattern (id_pattern ? "|" : "") id
    }
    next
}

# Accumulate sequence lines
{
    seq = seq $0
}

# At the end of the file, print the last sequence if it matches
END {
    if (seq && length(seq) > min_len && header ~ id_pattern) {
        print header
        print seq
    }
}
' translate_agat.fa > output.fasta
