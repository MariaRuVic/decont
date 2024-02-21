# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
# The directory containing the samples is indicated by the first argument ($1).

# Directorio de entrada (donde están los samples ids):
input_directory="$1"
# Directorio de salida (donde guardar los archivos fusionados):
output_directory="$2"
# Identificador de la muestra (sample id) 
sample_id="$3"

# Comprobar si hay archivos para fusionar, lanza un mensaje si se ha podido realizar la fusion o no.
cat "$input_directory/$sample_id"-12.5dpp.1.1*.fastq.gz "$input_directory/$sample_id"-12.5dpp.1.2*.fastq.gz > "$output_directory/$sample_id".merged.fastq.gz
