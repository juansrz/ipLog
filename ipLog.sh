#!/bin/bash

# Mostrar información del usuario y fecha
echo "Usuario: $(whoami)"
echo "Fecha: $(date)"
echo "Versión de bash: $BASH_VERSION"
echo "Autor: Juan Antonio Suárez Suárez"

if [ "$1" == "--help" ]; then
    echo "Uso: ipLog.sh [ruta] [IP]"
    echo "   Sin argumentos: Muestra las últimas 100 líneas de /var/log/auth.log"
    echo "   Un argumento (IP): Busca la IP en /var/log/auth.log"
    echo "   Un argumento (ruta): Busca la última IP en el directorio especificado"
    echo "   Dos argumentos (ruta, IP): Busca la IP en los logs del directorio"
    exit 0
fi

# Función para manejar errores
error_exit() {
  echo "Error: $1" >&2
  exit 1
}

# Función que reconoce IP con formato XXX.XXX.XXX o XXX-XXX-XXX
validate_ip() {
  # Verificar formato estándar
  if [[ $1 =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then
    for octet in $(echo "$1" | tr '.' ' '); do
      if (( octet < 0 || octet > 255 )); then
        return 1
      fi
    done
    return 0
  # Verificar formato alternativo
  elif [[ $1 =~ ^[0-9]{1,3}(-[0-9]{1,3}){3}$ ]]; then
    for octet in $(echo "$1" | tr '-' ' '); do
      if (( octet < 0 || octet > 255 )); then
        return 1
      fi
    done
    return 0
  else
    return 1
  fi
}

# Script Argumentos
if [ $# -eq 0 ]; then

  # Sin argumentos: mostrar las últimas 100 líneas de /var/log/auth.log

  if [ ! -f /var/log/auth.log ]; then
    error_exit "/var/log/auth.log no existe"
  fi
  echo "Mostrando las últimas 100 líneas de /var/log/auth.log:"
  tail -n 100 /var/log/auth.log || error_exit "Error al leer /var/log/auth.log"

elif [ $# -eq 1 ]; then

  # Un solo argumento: puede ser una IP o un directorio

  if validate_ip "$1"; then

    # IF IP, buscarla en /var/log/auth.log

    if [ ! -f /var/log/auth.log ]; then
      error_exit "/var/log/auth.log no existe"
    fi
    echo "Buscando $1 en /var/log/auth.log:"
    line_count=$(grep -c "$1" /var/log/auth.log)
    if [ "$line_count" -eq 0 ]; then
	error_exit "No se encuentra "$1" en /var/log/auth.log"
    else
	echo "$line_count $1"
    fi

  elif [ -d "$1" ]; then
    # IF directorio, buscar la última IP registrada en /var/log/auth.log y luego buscarla en el directorio

    if [ ! -f /var/log/auth.log ]; then
      error_exit "/var/log/auth.log no existe"
    fi
    last_ip=$(grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' /var/log/auth.log | tail -n 1)
    if [ -z "$last_ip" ]; then
      error_exit "No se encontró ninguna IP en /var/log/auth.log"
    fi
    echo "Última IP encontrada en /var/log/auth.log: $last_ip"
    echo "Buscando en los archivos de logs en el directorio $1"
    find "$1" -type f \( -name "*.log" -o -name "*.log.gz" \) -exec zgrep -H --color=auto "$last_ip" {} + || error_exit "No se encontró la IP en los logs de $1"
  else
    error_exit "Argumento no válido. Debe ser una IP o un directorio."
  fi

elif [ $# -eq 2 ]; then

  # Dos argumentos: un path y una IP
  if [ ! -d "$1" ]; then
    error_exit "El directorio $1 no existe"
  fi
  if ! validate_ip "$2"; then
    error_exit "$2 no es una IP válida"
  fi
  echo "Buscando IP $2 en los archivos de logs en el directorio $1"
  find "$1" -type f \( -name "*.log" -o -name "*.log.gz" \) -exec zgrep -H --color=auto "$2" {} + || error_exit "No se encontró la IP $2 en los logs de $1"
else
  error_exit "Número de argumentos no válido"
fi

#Añadido

LOG_FILE="/var/log/ipLog.log"
echo "Se ejecuto el script el $(date)" >> "$LOG_FILE"
echo "Usuario: $(whoami)" >> "$LOG_FILE"
echo "Parametros: $@" >> "$LOG_FILE"
