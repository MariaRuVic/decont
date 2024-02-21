# Donde están las URLs
urls="$1"
# Path donde queremos descargar los archivos de las urls
urls_destination="$2"
# Para descomprimir archivos
unzip_files="$3"
# Path para el archivo contaminants.fasta y para guardar los small nuclear contaminants.
contaminant_file="res/contaminants.fasta"
# Palabras claves (contaminante) a excluir:
small_nuclear="$4" 
snRNA="$5"

# Download the file specified in the first argument ($1) and place it in the directory specified in the second argument ($2),
wget "$urls" -P "$urls_destination"

# Optionally uncompress the downloaded file with gunzip if the third argument ($3) contains the word "yes"
if [ "$unzip_files" == "yes" ]; then

	# Localizar archivo descargado de las urls
	file=$(basename "$urls")

	# Revisar si el archivo está comprimido y si lo está descomprime y lanza un mensaje
	if [ "$¨{file##*.}" = "gz" ]; then
		echo "Archivos comprimidos detectados. Descomprimiendo..."
	       	gunzip -k "$urls_destination/$file"
		echo "Archivos descomprimidos"
	else
		# Avisa si no hay archivos comprimidos
                echo "No hay archivos comprimidos en la carpeta de destino"
	fi

	# Remove all sequences corresponding to small nuclear RNAs from the contaminants list before using it. 
	# Make sure you don't mix "small nuclear" and "small nucleolar"
	# Filter the sequences based on a word contained in their header lines. Sequences containing the specified word in their header should be **excluded**
	#   If $4 == "another" only the **first two sequence** should be output
	if  [ -e "$contaminant_file" ]; then
		seqkit grep -v -n -r -p "small nuclear" "$contaminant_file" | seqkit grep -v -n -r -p "snRNA" > res/contaminants_filtered.fasta
		echo "Nuevo archivo filtrado sin las secuencias que contienen las palabras 'small nuclear' o 'snRNA' ha sido creado."
	else
        	echo "El archivo contaminants.fasta no contiene secuencias con las palabras 'small nuclear' o 'snRNA'. No hay cambios realizados."

	fi

fi

