# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).
# The STAR command is provided for you. You should replace the parts surrounded
# by "<>" and uncomment it.
# STAR --runThreadN 4 --runMode genomeGenerate --genomeDir <outdir> \
# --genomeFastaFiles <genomefile> --genomeSAindexNbases 9

# genoma a indexar:
genome_file="$1"
# directorio para guardar el genoma indexado:
output_directory="$2"

# Comando STAR para generar el genoma indexado:
STAR --runThreadN 4 --runMode genomeGenerate --genomeDir "$output_directory" --genomeFastaFiles "$genome_file" --genomeSAindexNbases  9

