# 1. Descarga todos los archivos especificados en data/filenames.
# 1.1. Crea el directorio data/filenames si no existe.

mkdir -p "data/filenames"

# 1.2. Descarga los archivos url en el directorio data/filenames:
# Diseño inicial:
# for url in $(cat data/urls); do
### bash scripts/download.sh "$url" data/filenames
# done
# BONUS: reemplaza el loop inicial para descarga de los archivos (samples) con una linea de codigo con wget.
# BONUS: Chequea si el output ya existe (que el directorio filenames no está vacio) antes de ejecutar el comando.
# Si existe (no está vacio), manda un mensaje, descarta este paso y continua.

if [ -z "$(ls -A data/filenames/)" ]; then
	wget -i data/urls -P data/filenames
	echo "Los archivos de las muestras han sido descargados."
else
	echo "El directorio filenames ya contiene archivos. Se descarta nueva descarga "
fi

# 2. Descarga el archivo contaminants.fasta, descomprimelo y filtra todos los small nuclera RNAs.
# BONUS: Chequea si el output ya existe (los archivos contaminants.fasta y _filtered.fasta) antes de ejecutar el comando.
# Si existe, manda un mensaje, descarta este paso y continua.

if [ ! -e "res/contaminants.fasta" ] || [ ! -e "res/contaminants_filtered.fasta" ]; then
	echo "Descarga y descompresion de archivos del genoma de referencia."
	bash scripts/download.sh "https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz" res yes
	echo "Descarga y descompresion de archivos del genoma de referencia realizados."
else
        echo "Archivos contaminants.fasta y contaminants_filtered.fasta ya están disponibles en el directorio res. Se descarta nueva descarga del genoma y filtrado".
fi

# 3. Indexa el archivo contaminants.fasta
# 3.1. Crea el directorio contaminants_idx si no existe.

mkdir -p "res/contaminants_idx"

# 3.2. Ejecuta el indexado:
# BONUS: Chequea si el output ya existe (que el directorio contaminants_idx no está vacio) antes de ejecutar el comando.
# Si existe (no está vacio), manda un mensaje, descarta este paso y continua.

if [ -z "$(ls -A res/contaminants_idx/)" ]; then
	echo "Se procede a realizar indexacion del genoma de referencia."
	bash scripts/index.sh res/contaminants.fasta res/contaminants_idx
	echo "Indexacion del genoma de referencia completada."
else
	echo "El directorio contaminants_idx ya contiene archivos, se descarta realizar la indexacion del genoma".
fi

# 4. Fusiona (merge) las muestras en un archivo unico.
# 4.1. Crea el directorio out/merged si no existe.

mkdir -p "out/merged"

# 4.2. Ejecuta el bucle for para fusionar los archivos (merge).
# BONUS: Chequea si el output ya existe (que el directorio merged no está vacio) antes de ejecutar el comando.
# Si existe (no está vacio), manda un mensaje, descarta este paso y continua.
# Corto el nombre del sample ID en la barra "-" siguiendo el ejemplo del ejercicio. 

if [ -z "$(ls -A out/merged/ )" ]; then
	for sid in $(ls data/filenames | grep 'fastq' | cut -d"-" -f1 | sort | uniq); do
		echo "Procediendo a realizar fusion de archivos."
		bash scripts/merge_fastqs.sh data/filenames out/merged "$sid"
		echo "Fusión de archivos completada."
	done
else
	echo "El directorio merged ya contiene archivos, se descarta el paso de fusion de archivos".
fi

# 5. Ejecuta cutadapt en los archivos fusionados (merged files).
# 5.1. Crea los directorios trimmed y cutadapt si no existen.

mkdir -p "out/trimmed"
mkdir -p "log/cutadapt"

# 5.2. Ejecuta cutadapt en los archivos fusionados en el directorio merged para eliminar los adaptadores.
# BONUS: Chequea si el output ya existe (los directorios trimmed y cutadapt no están vacios) antes de ejecutar el comando.
# Si existe (no están vacios), manda un mensaje, descarta este paso y continua.

if [ -z "$(ls -A out/trimmed/)" ] || [ -z "$(ls -A log/cutadapt/)" ]; then
	for file in $(ls out/merged | cut -d"." -f1 | sort | uniq); do
		echo "Ejecutando cutadapt. Elimando adaptadores."
        	cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
        	-o out/trimmed/"$file".trimmed.fastq.gz out/merged/"$file".merged.fastq.gz \
		> log/cutadapt/"$file".log
		echo "Cutadapt terminado. Adaptadores eliminados."
	done
else
	echo "Los directorios trimmed y cutadapt ya contienen archivos. Se descarta ejecucion de cutadapt."
fi

# 6. Ejecuta STAR en todos el trimmed files (ya sin adaptadores) obtenidos en el paso anterior.
# 6.1. Crea el directorio out/star si no existe.

mkdir -p "out/star"

# 6.2. Ejecuta STAR para alinear las lecturas ya libres de adaptadores (trimmed) con el contaminants genoma
# y guardar las lecturas no alineadas en formato fastq.
# Crea directorio para los samples IDs si no existe.
# BONUS: Chequea si el output ya existe (el directorio star no está vacio) antes de ejecutar el comando.
# Si existe (no están vacio), manda un mensaje, descarta este paso y continua.

if [ -z "$(ls -A out/star/)" ]; then
	for fname in out/trimmed/*.fastq.gz; do
        	sampleid=$(basename "$fname" .trimmed.fastq.gz)
	        mkdir -p "out/star/$sampleid"
		echo "Ejecutando STAR. Alineacion con genoma de referencia."
	        # Ejecuta STAR:
        	STAR --runThreadN 4 --genomeDir res/contaminants_idx \
        	--outReadsUnmapped Fastx --readFilesIn "$fname" \
        	--readFilesCommand gunzip -c --outFileNamePrefix out/star/"$sampleid/"
		echo "Ejecución de STAR completada. Alineamiento realizado."
	done

else
	echo "El directorio star ya contiene archivos. Alineamiento ya realizado. Se descarta ejecucion de STAR."
fi


# 7. Crea un archivo.log con la informacion de los resultados del cutadapt y star logs.
# Debe ser en un archivo unico, con informacion *appended* en cada run
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in

for sid in $(ls out/merged | cut -d"." -f1 | sort | uniq); do
    {
        echo "Sample ID: $sid"
        echo "Cutadapt: "
        grep -hi -e "Reads with adapters: " -e "total basepairs: " log/cutadapt/"$sid".log
        echo "STAR: "
        grep -hi -e "Uniquely mapped reads %" -e "% of reads mapped to multiple loci" -e "% of reads mapped to too many loci" out/star/"$sid"/Log.final.out
        echo " "
    } 

done >> log/pipeline.log

echo "Pipeline completado."

