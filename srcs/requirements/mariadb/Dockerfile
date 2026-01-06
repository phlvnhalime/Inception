FROM alpine:3.19

RUN apk update && apk upgrade && apk add --no-cache mariadb mariadb-client

RUN mkdir -p /var/lib/mariadb /run/mysql && \
    chown -R mysql:mysql /var/lib/mariadb /run/mysql

# stream editor to modify the configuration file
# sed -i 's|pattern|replacement|g' file 
# i to save permenantly the changes
# s substitute the pattern with the replacement
# g to replace all occurrences of the pattern
RUN sed -i 's|skip-networking|#skip-networking|g' /etc/my.cnf.d/mariadb-server.cnf
    sed -i 's|.*bind-address\s*=.*|bind-address=0.0.0.0|g' /etc/my.cnf.d/mariadb-server.cnf

COPY conf/mariadb.cnf /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb.cnf

EXPOSE 3306

CMD ["mariadbd"]