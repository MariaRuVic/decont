#Add a "cleanup.sh" script that removes created files. It should take zero or more of the following arguments: "data", "resources", "output", "logs". 
# If no arguments are passed then it should remove everything.

# Si se da un argumento como directorio:

cleanup_fx() {
	case "$1" in
		# Comprueba si el argumento del directorio es valido:
		"data" | "res" | "out" | "log")
		# Comprueba si el directorio existe y envia un mensaje anunciando que los archivos van a ser borrados:
			if [ -d "$1" ] ; then
				echo "Eliminando archivos en el directorio $1"
				for file in "$1"/*; do
					# Si urls no es uno de los archivos y se trata de archivos regulares, borralos: 
					if [ "$file" != "$1"/urls ] && [ -f "$file " ]; then
						rm "$file"
					fi
				done
				echo "Los archivos en el directorio $1 han sido eliminados"
			else
				echo "El directorio $1 no existe"
			fi
			;;
		*)
			echo "Argumento no valido. Los direcortorios validos para limpieza son: data, res, out, log." 
			;;
	esac
}

# Si se dan varios argumentos:

if [ "$#" ]; then
	# Para cada argumento, ejecuta la funcion cleanup y borra sus archivos si valido:
	for dir in "$@"; do
		cleanup_fx "$dir"
	done

# Si no se da ningún argumento elimina los archivos de data, res, out y log, excepto urls:

else
	echo "Eliminando todos los archivos dentro de los directorios: data, res, out y log, excepto urls."
	for dir in "data" "res" "out" "log"; do
		cleanup_fx "$dir"
	done
	echo "Los archivos han sido eliminados "
fi
