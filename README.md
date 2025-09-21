# Wakapi Helm Chart

Un chart de Helm para desplegar [Wakapi](https://github.com/muety/wakapi), un servidor de métricas de tiempo de codificación compatible con WakaTime.

## 🚀 Instalación Rápida

### Usando Helm Repository

```bash
# Agregar el repositorio
helm repo add wakapi https://start-codex.github.io/wakapi-helm-chart/
helm repo update

# Instalar con configuración por defecto
helm install my-wakapi wakapi/wakapi

# Instalar con configuración personalizada
helm install my-wakapi wakapi/wakapi -f values.yaml
```

### Desde Código Fuente

```bash
git clone https://github.com/start-codex/wakapi-helm-chart
cd wakapi-helm-chart
helm install my-wakapi ./charts/wakapi -f values.yaml
```

## ⚙️ Configuración

### Configuración Mínima Requerida

El chart requiere configurar la sección `wakapi_secrets` para funcionar correctamente:

```yaml
wakapi_secrets:
  db:
    password: "tu-password-de-bd"
  security:
    password_salt: "salt-aleatorio-minimo-32-caracteres"
  mail:
    smtp:
      password: "tu-password-smtp"
```

### Ejemplo de Configuración Básica

```yaml
# values.yaml
wakapi_config:
  env: production
  server:
    port: 3000
    public_url: "https://wakapi.tudominio.com"

  db:
    dialect: postgres
    host: "postgres-service"
    port: 5432
    user: "wakapi"
    name: "wakapi"

  security:
    allow_signup: false
    insecure_cookies: false

  mail:
    enabled: true
    sender: "noreply@tudominio.com"
    smtp:
      host: "smtp.tudominio.com"
      port: 587
      username: "wakapi@tudominio.com"
      tls: true

wakapi_secrets:
  db:
    password: "password-super-seguro"
  security:
    password_salt: "salt-aleatorio-de-64-caracteres"
  mail:
    smtp:
      password: "password-smtp"

persistence:
  enabled: true
  size: 5Gi

service:
  type: LoadBalancer
```

### Bases de Datos Soportadas

#### PostgreSQL (Recomendado)
```yaml
wakapi_config:
  db:
    dialect: postgres
    host: "postgres-host"
    port: 5432
    user: "wakapi"
    name: "wakapi"
```

#### MySQL
```yaml
wakapi_config:
  db:
    dialect: mysql
    host: "mysql-host"
    port: 3306
    user: "wakapi"
    name: "wakapi"
    charset: "utf8mb4"
```

#### SQLite (Para desarrollo)
```yaml
wakapi_config:
  db:
    dialect: sqlite3
    name: "/data/wakapi.db"
```

## 🔐 Configuración de Seguridad

### Generación de Password Salt

```bash
# Generar salt seguro de 64 caracteres
openssl rand -hex 32

# O usando Python
python3 -c "import secrets; print(secrets.token_hex(32))"
```

### Configuración HTTPS con Ingress

```yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: wakapi.tudominio.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: wakapi-tls
      hosts:
        - wakapi.tudominio.com

wakapi_config:
  server:
    public_url: "https://wakapi.tudominio.com"
  security:
    insecure_cookies: false  # Importante para HTTPS
```

## 📊 Monitoreo y Observabilidad

### Sentry (OBLIGATORIO - Configuración Requerida)

⚠️ **IMPORTANTE**: La sección `sentry` es **OBLIGATORIA** en el archivo de configuración. El template del chart siempre busca estos campos, incluso si no usas Sentry.

#### Si NO usas Sentry (Configuración por defecto)
```yaml
wakapi_config:
  sentry:
    dsn: ""                           # OBLIGATORIO: Vacío = Sentry deshabilitado
    environment: "production"         # OBLIGATORIO
    enable_tracing: false             # OBLIGATORIO
    sample_rate: "1.0"                # OBLIGATORIO
    sample_rate_heartbeats: "0.1"     # OBLIGATORIO
```

#### Si SÍ usas Sentry
```yaml
wakapi_config:
  sentry:
    dsn: "https://tu-dsn@sentry.io/proyecto"  # Tu DSN real de Sentry
    environment: "production"
    enable_tracing: true
    sample_rate: "1.0"
    sample_rate_heartbeats: "0.1"
```

### Métricas de Prometheus
```yaml
wakapi_config:
  security:
    expose_metrics: true
```

## 🔧 Parámetros de Configuración Principales

| Parámetro | Descripción | Valor por Defecto |
|-----------|-------------|-------------------|
| `image.repository` | Repositorio de la imagen | `ghcr.io/muety/wakapi` |
| `replicaCount` | Número de réplicas | `1` |
| `service.type` | Tipo de servicio | `ClusterIP` |
| `persistence.enabled` | Habilitar almacenamiento persistente | `true` |
| `persistence.size` | Tamaño del volumen | `2Gi` |
| `wakapi_config.env` | Entorno de la aplicación | `development` |
| `wakapi_config.server.port` | Puerto interno | `3000` |
| `wakapi_config.security.allow_signup` | Permitir registro | `true` |

## 🚨 Solución de Problemas

### Error: `nil pointer evaluating interface {}.password`

Este error indica que falta la configuración de `wakapi_secrets`. Asegúrate de incluir:

```yaml
wakapi_secrets:
  db:
    password: "tu-password"
  security:
    password_salt: "tu-salt-secreto"
  mail:
    smtp:
      password: "tu-password-smtp"
```

### Error: `nil pointer evaluating interface {}.dsn`

Este error indica que **falta la sección `sentry` completa**. La configuración de Sentry es **OBLIGATORIA** en el archivo values, incluso si no usas Sentry.

**Solución**: Incluye SIEMPRE la sección completa de Sentry:

```yaml
wakapi_config:
  sentry:
    dsn: ""                           # OBLIGATORIO: Vacío si no usas Sentry
    environment: "production"         # OBLIGATORIO
    enable_tracing: false             # OBLIGATORIO
    sample_rate: "1.0"                # OBLIGATORIO
    sample_rate_heartbeats: "0.1"     # OBLIGATORIO
```

💡 **Importante**: El template del chart **siempre** busca estos campos. No puedes omitir la sección `sentry`, pero puedes deshabilitarla con `dsn: ""`.

## 📝 Ejemplos Completos

### Desarrollo Local
```yaml
wakapi_config:
  env: development
  server:
    public_url: "http://localhost:3000"
  db:
    dialect: sqlite3
    name: "/data/wakapi.db"
  security:
    allow_signup: true
    insecure_cookies: true

wakapi_secrets:
  db:
    password: ""
  security:
    password_salt: "development-salt-change-in-production"
  mail:
    smtp:
      password: ""
```

### Producción con PostgreSQL
```yaml
wakapi_config:
  env: prod
  server:
    public_url: "https://wakapi.empresa.com"
  db:
    dialect: postgres
    host: "postgres.database.svc.cluster.local"
    port: 5432
    user: "wakapi"
    name: "wakapi_prod"
  security:
    allow_signup: false
    insecure_cookies: false
  mail:
    enabled: true
    sender: "wakapi@empresa.com"
    smtp:
      host: "smtp.empresa.com"
      port: 587
      tls: true

wakapi_secrets:
  db:
    password: "password-muy-seguro"
  security:
    password_salt: "salt-aleatorio-de-produccion"
  mail:
    smtp:
      password: "password-smtp-seguro"

persistence:
  size: 10Gi
  storageClass: "fast-ssd"

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
```

## 📚 Recursos Adicionales

- [Documentación de Wakapi](https://github.com/muety/wakapi)
- [Configuración de Wakapi](https://github.com/muety/wakapi#-configuration-options)
- [Repositorio del Chart](https://github.com/start-codex/wakapi-helm-chart)

## 🤝 Contribuir

Las contribuciones son bienvenidas! Por favor:

1. Fork el repositorio
2. Crea una rama para tu feature
3. Haz commit de tus cambios
4. Abre un Pull Request

## 📄 Licencia

Este chart está bajo la misma licencia que [Wakapi](https://github.com/muety/wakapi).  