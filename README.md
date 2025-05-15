# PostgreSQL Audit-Enabled Docker Image

A security-enhanced PostgreSQL 17 image with integrated audit logging capabilities using pgAudit and pgAuditLogToFile extensions.

## Description

This Docker image extends the official PostgreSQL 17 image with advanced audit logging capabilities to meet compliance requirements and enhance security monitoring. It incorporates:

- **pgAudit extension**: Provides detailed session and object audit logging functionality
- **pgAuditLogToFile extension**: Enables writing audit logs to dedicated files instead of standard PostgreSQL logs

## Tags

- `latest`: PostgreSQL 17 with pgAudit and pgAuditLogToFile extensions

## Quick Start

```bash
docker run -d \
  --name postgres-audit \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  talismar/postgres-audit:latest
```

docker-compose.yml

```yml
services:
  posgresql:
    build: .
    environment:
      POSTGRES_PASSWORD: admin123
    ports:
      - 5433:5432
```

## Environment Variables

This image accepts all the environment variables from the [official PostgreSQL image](https://hub.docker.com/_/postgres):

- `POSTGRES_PASSWORD`: Required password for the PostgreSQL superuser
- `POSTGRES_USER`: Optional username for the PostgreSQL superuser (default: postgres)
- `POSTGRES_DB`: Optional name for the default database (default: same as POSTGRES_USER)
- `POSTGRES_INITDB_ARGS`: Optional arguments to send to postgres initdb
- `POSTGRES_INITDB_WALDIR`: Optional directory for the transaction log
- `POSTGRES_HOST_AUTH_METHOD`: Authentication method for local connections (use with caution)
- `PGDATA`: Optional data directory path (default: /var/lib/postgresql/data)

## Audit Logging Features

### pgAudit

The pgAudit extension provides detailed logging of database activities:

- Session logging: Records all statements executed
- Object logging: Tracks usage of specific objects
- Role-based filtering: Configure auditing by database role

### pgAuditLogToFile

This extension allows:

- Separate audit logs from regular PostgreSQL logs
- Dedicated log file for audit events
- Custom log file location and rotation settings

## Configuration

The image includes a custom `postgresql.conf` file with pre-configured audit settings. You can override these settings by:

1. Mounting your own configuration file:
   ```bash
   docker run -d \
     --name postgres-audit \
     -e POSTGRES_PASSWORD=mysecretpassword \
     -v /path/to/your/postgresql.conf:/etc/postgresql/postgresql.conf \
     talismar/postgres-audit:latest
   ```

2. Setting parameters at runtime:
   ```bash
   docker run -d \
     --name postgres-audit \
     -e POSTGRES_PASSWORD=mysecretpassword \
     talismar/postgres-audit:latest \
     postgres -c "pgaudit.log=write" -c "config_file=/etc/postgresql/postgresql.conf"
   ```

### Key Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `pgaudit.log` | Sets which statement classes to log | `write, ddl` |
| `pgaudit.log_catalog` | Enable/disable logging of catalog objects | `on` |
| `pgaudit.log_parameter` | Includes statement parameters in logs | `on` |
| `pgaudit.log_relation` | Controls logging of relations in `READ/WRITE` statements | `off` |
| `pgaudit.log_statement_once` | Logs statement just once rather than for each row | `off` |
| `pgaudit.role` | Specifies the role for object-level audit logging | None |
| `pgaudit.filename` | Audit log destination file | `audit_%Y-%m-%d_%H%M%S.log` |
| `pgaudit.log_directory` | Directory to store audit logs | `log` |
| `pgaudit.max_files` | Maximum number of retained log files | `100` |
| `pgaudit.max_file_size_mb` | Maximum size of each log file | `10` |

## Security Considerations

- This image provides comprehensive audit logging capabilities useful in regulatory compliance scenarios (SOX, HIPAA, PCI DSS, etc.)
- Audit logs should be preserved securely, possibly by configuring volume mounts to persist logs outside the container
- Consider restricting access to the audit logs using appropriate file permissions
- The default configuration enables moderate audit detail - adjust based on your security requirements

## Volumes

Mount volumes to persist your data and logs:

```bash
docker run -d \
  --name postgres-audit \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -v postgres_data:/var/lib/postgresql/data \
  -v postgres_audit_logs:/var/lib/postgresql/log \
  talismar/postgres-audit:latest
```

## Custom Initializations

The image includes an initialization script in `/docker-entrypoint-initdb.d/` that:
1. Enables the pgAudit and pgAuditLogToFile extensions
2. Sets up basic audit policies

You can add additional initialization scripts by mounting them to the `/docker-entrypoint-initdb.d/` directory.

> ⚠️ **IMPORTANT**: Do not create a file named `create_extensions.sql` in your initialization scripts directory as the image already includes this file. Creating a file with this name will overwrite the built-in initialization script and may prevent the audit extensions from being properly configured. If you need to customize the extensions setup, consider using a different filename for your script.

## Build Details

This image is built in two stages:
1. Builder stage compiles pgAudit and pgAuditLogToFile extensions
2. Final stage copies compiled extensions and configurations

## License

This image includes:
- PostgreSQL (PostgreSQL License)
- pgAudit (PostgreSQL License)
- pgAuditLogToFile (PostgreSQL License)

## Support and Issues

For issues or support requests, please file an issue on the GitHub repository.
