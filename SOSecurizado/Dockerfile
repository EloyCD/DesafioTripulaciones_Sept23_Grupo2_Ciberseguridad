FROM alpine

# Generación de fallos comunes para facilitar el debugeo del código con una tubería como prevención 
SHELL ["/bin/sh", "-o", "pipefail", "-c"]

#  Empleamos repositorios HTTPS para apk
RUN echo "https://alpine.global.ssl.fastly.net/alpine/v$(cut -d . -f 1,2 < /etc/alpine-release)/main" > /etc/apk/repositories \
        && echo "https://alpine.global.ssl.fastly.net/alpine/v$(cut -d . -f 1,2 < /etc/alpine-release)/community" >> /etc/apk/repositories

# Creamos un usuario por defecto
ENV APP_USER=app
# Creamos su directorio principal
ENV APP_DIR="/$APP_USER"
# Donde se almacenarán los datos
ENV DATA_DIR "$APP_DIR/data"
# Donde se almacenará la configuración
ENV CONF_DIR "$APP_DIR/conf"

# Añadimos los certificados HTTPS que empleará para establecer las conexiones seguras
RUN apk add --no-cache ca-certificates

# Realizamos una actualización y añadimos el paquete npm
RUN apk update && apk upgrade
RUN apk add npm

# Creamos el usuario por defecto y su directorio
RUN adduser -s /bin/true -u 1000 -D -h $APP_DIR $APP_USER \
  && mkdir "$DATA_DIR" "$CONF_DIR" \
  && chown -R "$APP_USER" "$APP_DIR" "$CONF_DIR" \
  && chmod 700 "$APP_DIR" "$DATA_DIR" "$CONF_DIR"

# Si existen crontabs los eliminamos
RUN rm -fr /var/spool/cron \
        && rm -fr /etc/crontabs \
        && rm -fr /etc/periodic

# Eliminamos varios comandos de admin
RUN find /sbin /usr/sbin \
  ! -type d -a ! -name apk -a ! -name ln \
  -delete

# Suprimimos los permisos de lectura-excritura excepto /tmp/
RUN find / -xdev -type d -perm +0002 -exec chmod o-w {} + \
        && find / -xdev -type f -perm +0002 -exec chmod o-w {} + \
        && chmod 777 /tmp/ \
  && chown $APP_USER:root /tmp/

# Nos deshacemos todas las cuentas innecesarias menos app y root
RUN sed -i -r "/^($APP_USER|root|nobody)/!d" /etc/group \
  && sed -i -r "/^($APP_USER|root|nobody)/!d" /etc/passwd

# Quitamos la shell interactiva para todos
RUN sed -i -r 's#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd

# Borramos temp shadow, passwd, group
RUN find /bin /etc /lib /sbin /usr -xdev -type f -regex '.*-$' -exec rm -f {} +

# Nos aseguramos que los directorios del sistema son de root y no tiene permiso de escritura ninguno más
RUN find /bin /etc /lib /sbin /usr -xdev -type d \
  -exec chown root:root {} \; \
  -exec chmod 0755 {} \;

# Eliminamos los archivos suid y sgid
RUN find /bin /etc /lib /sbin /usr -xdev -type f -a \( -perm +4000 -o -perm +2000 \) -delete

# Quitamos comandos que podrían ser peligrosos
RUN find /bin /etc /lib /sbin /usr -xdev \( \
  -iname hexdump -o \
  -iname chgrp -o \
  -iname ln -o \
  -iname od -o \
  -iname strings -o \
  -iname su -o \
  -iname sudo \
  \) -delete

# Borramos los scripts de inicio
RUN rm -fr /etc/init.d /lib/rc /etc/conf.d /etc/inittab /etc/runlevels /etc/rc.conf /etc/logrotate.d

# Eliminamos configuraciones relacionadas con el kernel para aportar mayor seguridad
RUN rm -fr /etc/sysctl* /etc/modprobe.d /etc/modules /etc/mdev.conf /etc/acpi

# Suprimimos el directorio de root
RUN rm -fr /root

# Quitamos fstab
RUN rm -f /etc/fstab

# Eliminamos enlaces simbólicos previos
RUN find /bin /etc /lib /sbin /usr -xdev -type l -exec test ! -e {} \; -delete

# Damos permisos al scrip de post instalación
COPY post-install.sh $APP_DIR/
RUN chmod 500 $APP_DIR/post-install.sh

# Especificamos que el directorio por defecto sea /app
WORKDIR $APP_DIR
