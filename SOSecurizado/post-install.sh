#!/usr/bin/env sh

# Si algún comando falla, la instalación falla
set -e
set -o pipefail

# Eliminamos el administrador de paquetes apk
find / -type f -iname '*apk*' -xdev -delete
find / -type d -iname '*apk*' -print0 -xdev | xargs -0 rm -r --

# Indicamos permisos rx a todos los directorios, excepto a data
find "$APP_DIR" -type d -exec chmod 500 {} +

# Indicamos permiso r a los archivos
find "$APP_DIR" -type f -exec chmod 400 {} +
chmod -R u=rwx "$DATA_DIR/"

# Cambiamos los permisos para app
chown $APP_USER:$APP_USER -R $APP_DIR $DATA_DIR

# Eliminamos los permisos
find / \( -type f -o -type l \) -iname 'chown' -xdev -delete

# Borramos este archivo
rm "$0"
