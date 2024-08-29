# requires ids.txt file that contains gene IDs
# cat ids.txt
#G8077
#G8546
#G11423
#G4113

# requires a multi-fasta file (translate_agat.fa) that contains all the protein sequences for the entire transcriptome
# this mutli-fasta protein file can be created using agat perl script that needs genome.fa and genome.gff3 files, see command below
# agat_sp_extract_sequences.pl -g Crassostrea_gigas.cgigas_uk_roslin_v1.58.chr.gff3 -f Crassostrea_gigas_uk_roslin_v1.dna_sm.primary_assembly.fa -p -o translate_agat.fa


# min_len is set to 100, idea is to filter out smaller isoforms to save time

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
