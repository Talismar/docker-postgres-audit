FROM postgres:17 AS builder

RUN apt-get update \
    && apt-get install -y git make gcc postgresql-server-dev-17 libkrb5-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pgaudit extension
RUN git clone -b REL_17_STABLE https://github.com/pgaudit/pgaudit.git /tmp/pgaudit \
    && cd /tmp/pgaudit \
    && make USE_PGXS=1 \
    && make install USE_PGXS=1

# Install pgauditlogtofile extension
RUN git clone https://github.com/fmbiete/pgauditlogtofile.git /tmp/pgauditlogtofile \
    && cd /tmp/pgauditlogtofile \
    && make USE_PGXS=1 \
    && make install USE_PGXS=1

FROM postgres:17

COPY --from=builder /usr/lib/postgresql/ /usr/lib/postgresql/
COPY --from=builder /usr/share/postgresql/ /usr/share/postgresql/

COPY postgresql.conf /etc/postgresql/postgresql.conf

COPY initdb /docker-entrypoint-initdb.d/
RUN sha256sum /docker-entrypoint-initdb.d/create_extensions.sql > /opt/create_extensions.sha256

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["postgres", "-c", "config_file=/etc/postgresql/postgresql.conf"]
