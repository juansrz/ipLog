# ipLog.sh
Analizador de logs de autenticación en Linux. Trabaja principalmente con /var/log/auth.log y busca direcciones IP en ficheros *.log y *.log.gz dentro de un directorio.

## Características
- Solo analiza ficheros *.log y *.log.gz (ignora otros tipos cuando busca en directorios).
- Admite rutas absolutas y relativas para los directorios.
- Validación robusta de IPs en formatos XXX.XXX.XXX.XXX y XXX-XXX-XXX-XXX, comprobando que cada octeto esté en [0, 255].
- Gestión de errores mediante mensajes claros y código de salida distinto de 0 en caso de fallo.
- No modifica los archivos de log analizados; solo opcionalmente registra la ejecución en /var/log/ipLog.log.

## Modos de uso

bash
chmod +x ./ipLog.sh

# 0 argumentos:
# Muestra las últimas 100 líneas de /var/log/auth.log
./ipLog.sh

# 1 argumento (IP):
# Busca la IP en /var/log/auth.log
./ipLog.sh 192.168.1.10

# 1 argumento (directorio):
# Obtiene la última IP que aparece en /var/log/auth.log
# y la busca en todos los *.log y *.log.gz de ese directorio (recursivamente)
./ipLog.sh /var/log/

# 2 argumentos (directorio, IP):
# Busca la IP en todos los *.log y *.log.gz del directorio (recursivamente)
./ipLog.sh /var/log/ 192.168.1.10

# Mostrar ayuda integrada
./ipLog.sh --help
