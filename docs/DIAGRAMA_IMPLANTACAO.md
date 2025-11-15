# 🚀 Diagrama de Implantação (Deployment)

Este documento apresenta a arquitetura de implantação do sistema.

## Diagrama de Implantação - Produção

```mermaid
graph TB
    subgraph "Cliente"
        BROWSER[Web Browser]
        MOBILE[Mobile Device]
    end
    
    subgraph "Internet"
        CDN[CDN / CloudFlare]
        LB[Load Balancer]
    end
    
    subgraph "Servidor de Aplicação - Docker Container"
        subgraph "Rails Application"
            APP1[Rails App Instance 1]
            APP2[Rails App Instance 2]
            APP3[Rails App Instance N]
        end
        
        subgraph "Background Jobs"
            SIDEKIQ[Sidekiq Workers]
            CRON[Cron Jobs]
        end
    end
    
    subgraph "Camada de Dados"
        DB[(SQLite Database<br/>Primary)]
        DB_BACKUP[(SQLite Database<br/>Backup)]
    end
    
    subgraph "Serviços Externos"
        EMAIL_SRV[SMTP Server<br/>Email Service]
        SMS_SRV[SMS Gateway<br/>Twilio / Vonage]
        WHATS_SRV[WhatsApp Business API]
        PIX_SRV[PIX Gateway<br/>Payment Provider]
    end
    
    subgraph "Monitoramento"
        LOGS[Log Aggregator<br/>Papertrail / ELK]
        METRICS[Metrics<br/>Prometheus]
        APM[APM<br/>New Relic / Scout]
    end
    
    BROWSER -->|HTTPS| CDN
    MOBILE -->|HTTPS| CDN
    
    CDN -->|HTTPS| LB
    
    LB --> APP1
    LB --> APP2
    LB --> APP3
    
    APP1 --> DB
    APP2 --> DB
    APP3 --> DB
    
    APP1 -.->|Background Jobs| SIDEKIQ
    APP2 -.->|Background Jobs| SIDEKIQ
    APP3 -.->|Background Jobs| SIDEKIQ
    
    CRON -.->|Scheduled Tasks| SIDEKIQ
    
    SIDEKIQ -->|Send Notifications| EMAIL_SRV
    SIDEKIQ -->|Send Notifications| SMS_SRV
    SIDEKIQ -->|Send Notifications| WHATS_SRV
    
    APP1 -->|Process Payments| PIX_SRV
    APP2 -->|Process Payments| PIX_SRV
    APP3 -->|Process Payments| PIX_SRV
    
    DB -->|Scheduled Backup| DB_BACKUP
    
    APP1 -.->|Logs| LOGS
    APP2 -.->|Logs| LOGS
    APP3 -.->|Logs| LOGS
    
    APP1 -.->|Metrics| METRICS
    APP2 -.->|Metrics| METRICS
    APP3 -.->|Metrics| METRICS
    
    APP1 -.->|Performance Data| APM
    APP2 -.->|Performance Data| APM
    APP3 -.->|Performance Data| APM
    
    style BROWSER fill:#e1f5ff
    style MOBILE fill:#e1f5ff
    style CDN fill:#fff4e6
    style LB fill:#fff4e6
    style APP1 fill:#e8f5e9
    style APP2 fill:#e8f5e9
    style APP3 fill:#e8f5e9
    style DB fill:#f3e5f5
    style EMAIL_SRV fill:#ffebee
    style SMS_SRV fill:#ffebee
    style WHATS_SRV fill:#ffebee
    style PIX_SRV fill:#ffebee
```

## Arquitetura de Container (Docker)

```mermaid
graph TB
    subgraph "Docker Host"
        subgraph "Container: App"
            RAILS[Rails 8.0<br/>Ruby 3.4]
            PUMA[Puma Web Server]
            FILES[Application Files]
        end
        
        subgraph "Container: Worker"
            SIDEKIQ_C[Sidekiq<br/>Background Worker]
            REDIS[Redis<br/>Job Queue]
        end
        
        subgraph "Volume: Database"
            DB_VOL[(SQLite Database<br/>Persistent Volume)]
        end
        
        subgraph "Volume: Storage"
            STORAGE[Active Storage<br/>Persistent Volume]
        end
    end
    
    RAILS --> PUMA
    PUMA --> FILES
    RAILS --> DB_VOL
    RAILS --> STORAGE
    RAILS -.->|Enqueue Jobs| REDIS
    SIDEKIQ_C -.->|Process Jobs| REDIS
    SIDEKIQ_C --> DB_VOL
    
    style RAILS fill:#e8f5e9
    style PUMA fill:#c8e6c9
    style SIDEKIQ_C fill:#fff9c4
    style DB_VOL fill:#f3e5f5
    style REDIS fill:#ffccbc
```

## Deployment com Kamal

```mermaid
graph LR
    subgraph "Development"
        DEV[Developer Machine]
        GIT[Git Repository<br/>GitHub]
    end
    
    subgraph "CI/CD Pipeline"
        ACTIONS[GitHub Actions]
        BUILD[Build Docker Image]
        TESTS[Run Tests]
        PUSH[Push to Registry]
    end
    
    subgraph "Docker Registry"
        REGISTRY[Docker Registry<br/>GitHub Container Registry]
    end
    
    subgraph "Production Server"
        KAMAL[Kamal Deploy]
        DOCKER[Docker Engine]
        CONTAINERS[Running Containers]
    end
    
    DEV -->|git push| GIT
    GIT -->|trigger| ACTIONS
    ACTIONS --> BUILD
    BUILD --> TESTS
    TESTS --> PUSH
    PUSH --> REGISTRY
    
    REGISTRY -->|kamal deploy| KAMAL
    KAMAL --> DOCKER
    DOCKER --> CONTAINERS
    
    style DEV fill:#e1f5ff
    style ACTIONS fill:#fff4e6
    style REGISTRY fill:#e8f5e9
    style KAMAL fill:#f3e5f5
```

## Infraestrutura de Rede

```mermaid
graph TB
    subgraph "Public Internet"
        USERS[Users]
    end
    
    subgraph "DMZ - Demilitarized Zone"
        FW1[Firewall]
        WAF[Web Application Firewall]
        LB[Load Balancer]
    end
    
    subgraph "Application Zone"
        APP_SERVERS[Application Servers<br/>Rails Containers]
    end
    
    subgraph "Data Zone"
        DB_SERVER[Database Server<br/>SQLite]
        BACKUP_SERVER[Backup Server]
    end
    
    subgraph "Management Zone"
        MONITOR[Monitoring Server]
        ADMIN[Admin Console]
    end
    
    USERS -->|HTTPS:443| FW1
    FW1 --> WAF
    WAF --> LB
    LB -->|HTTP:3000| APP_SERVERS
    APP_SERVERS --> DB_SERVER
    DB_SERVER -.->|Backup| BACKUP_SERVER
    
    APP_SERVERS -.->|Metrics/Logs| MONITOR
    ADMIN -.->|Management| APP_SERVERS
    ADMIN -.->|Management| DB_SERVER
    
    style USERS fill:#e1f5ff
    style FW1 fill:#ffebee
    style WAF fill:#ffebee
    style LB fill:#fff4e6
    style APP_SERVERS fill:#e8f5e9
    style DB_SERVER fill:#f3e5f5
```

## Configuração de Ambiente

### Desenvolvimento

```mermaid
graph LR
    DEV_MACHINE[Developer Machine]
    
    subgraph "Local Development"
        LOCAL_RAILS[Rails Server<br/>localhost:3000]
        LOCAL_DB[(SQLite DB<br/>development.sqlite3)]
        LOCAL_REDIS[Redis<br/>localhost:6379]
    end
    
    DEV_MACHINE --> LOCAL_RAILS
    LOCAL_RAILS --> LOCAL_DB
    LOCAL_RAILS --> LOCAL_REDIS
    
    style DEV_MACHINE fill:#e1f5ff
    style LOCAL_RAILS fill:#e8f5e9
    style LOCAL_DB fill:#f3e5f5
    style LOCAL_REDIS fill:#ffccbc
```

### Homologação / Staging

```mermaid
graph LR
    STAGING_SERVER[Staging Server]
    
    subgraph "Staging Environment"
        STAGE_RAILS[Rails App<br/>staging.example.com]
        STAGE_DB[(SQLite DB<br/>staging.sqlite3)]
        STAGE_REDIS[Redis]
    end
    
    STAGING_SERVER --> STAGE_RAILS
    STAGE_RAILS --> STAGE_DB
    STAGE_RAILS --> STAGE_REDIS
    
    STAGE_RAILS -.->|Test Integrations| EXTERNAL_TEST[Test APIs]
    
    style STAGING_SERVER fill:#fff9c4
    style STAGE_RAILS fill:#fff9c4
    style STAGE_DB fill:#fff9c4
```

### Produção

```mermaid
graph TB
    PROD_LB[Load Balancer]
    
    subgraph "Production Environment"
        PROD_APP1[Rails Instance 1<br/>prod-app-01]
        PROD_APP2[Rails Instance 2<br/>prod-app-02]
        PROD_DB[(SQLite DB<br/>production.sqlite3<br/>+ Replication)]
        PROD_REDIS[Redis Cluster]
        PROD_WORKER[Sidekiq Workers]
    end
    
    PROD_LB --> PROD_APP1
    PROD_LB --> PROD_APP2
    
    PROD_APP1 --> PROD_DB
    PROD_APP2 --> PROD_DB
    
    PROD_APP1 --> PROD_REDIS
    PROD_APP2 --> PROD_REDIS
    PROD_WORKER --> PROD_REDIS
    
    PROD_WORKER --> PROD_DB
    
    style PROD_LB fill:#ffebee
    style PROD_APP1 fill:#e8f5e9
    style PROD_APP2 fill:#e8f5e9
    style PROD_DB fill:#f3e5f5
    style PROD_REDIS fill:#ffccbc
```

## Backup e Disaster Recovery

```mermaid
graph TB
    subgraph "Primary Site"
        PRIMARY_APP[Primary Application]
        PRIMARY_DB[(Primary Database)]
    end
    
    subgraph "Backup Strategy"
        DAILY[Daily Full Backup<br/>00:00 UTC]
        HOURLY[Hourly Incremental<br/>Every hour]
        REALTIME[Real-time WAL Archive]
    end
    
    subgraph "Backup Storage"
        LOCAL_BACKUP[(Local Backup<br/>Last 7 days)]
        CLOUD_BACKUP[(Cloud Storage<br/>S3 / R2<br/>Last 90 days)]
        OFFSITE[(Offsite Backup<br/>Last 365 days)]
    end
    
    PRIMARY_DB -->|Full Backup| DAILY
    PRIMARY_DB -->|Incremental| HOURLY
    PRIMARY_DB -->|WAL| REALTIME
    
    DAILY --> LOCAL_BACKUP
    HOURLY --> LOCAL_BACKUP
    REALTIME --> LOCAL_BACKUP
    
    LOCAL_BACKUP -->|Sync| CLOUD_BACKUP
    CLOUD_BACKUP -->|Archive| OFFSITE
    
    style PRIMARY_DB fill:#f3e5f5
    style LOCAL_BACKUP fill:#e8f5e9
    style CLOUD_BACKUP fill:#fff9c4
    style OFFSITE fill:#ffebee
```

## Segurança e Firewall

```mermaid
graph TB
    INTERNET[Internet]
    
    subgraph "Security Layers"
        direction TB
        
        FW_PUBLIC[Public Firewall<br/>Allow: 80, 443]
        WAF[Web Application Firewall<br/>OWASP Rules]
        FW_APP[Application Firewall<br/>Allow: 3000 from LB only]
        FW_DB[Database Firewall<br/>Allow: App servers only]
    end
    
    subgraph "Application"
        APP[Rails Application]
        DB[(Database)]
    end
    
    INTERNET --> FW_PUBLIC
    FW_PUBLIC --> WAF
    WAF --> FW_APP
    FW_APP --> APP
    APP --> FW_DB
    FW_DB --> DB
    
    style FW_PUBLIC fill:#ffebee
    style WAF fill:#ffebee
    style FW_APP fill:#ffebee
    style FW_DB fill:#ffebee
    style APP fill:#e8f5e9
    style DB fill:#f3e5f5
```

## Escalabilidade

```mermaid
graph TB
    subgraph "Horizontal Scaling"
        LB[Load Balancer<br/>Auto-scaling]
        
        APP1[App Instance 1]
        APP2[App Instance 2]
        APP3[App Instance 3]
        APPN[App Instance N]
        
        LB --> APP1
        LB --> APP2
        LB --> APP3
        LB --> APPN
    end
    
    subgraph "Shared Resources"
        DB[(Database<br/>Shared)]
        REDIS[Redis<br/>Session Store]
        STORAGE[File Storage<br/>Shared Volume]
    end
    
    APP1 --> DB
    APP2 --> DB
    APP3 --> DB
    APPN --> DB
    
    APP1 --> REDIS
    APP2 --> REDIS
    APP3 --> REDIS
    APPN --> REDIS
    
    APP1 --> STORAGE
    APP2 --> STORAGE
    APP3 --> STORAGE
    APPN --> STORAGE
    
    style LB fill:#fff4e6
    style APP1 fill:#e8f5e9
    style APP2 fill:#e8f5e9
    style APP3 fill:#e8f5e9
    style APPN fill:#e8f5e9
    style DB fill:#f3e5f5
```

## Especificações Técnicas

### Servidor de Aplicação

| Componente | Especificação |
|------------|---------------|
| OS | Linux (Ubuntu 22.04 LTS) |
| Runtime | Ruby 3.4.x |
| Framework | Rails 8.0.3 |
| Web Server | Puma (5 workers, 5 threads) |
| Container | Docker |
| Deploy | Kamal |

### Banco de Dados

| Componente | Especificação |
|------------|---------------|
| Database | SQLite3 |
| Storage | SSD (Persistent Volume) |
| Backup | Daily full + Hourly incremental |
| Replication | File-based replication |

### Performance

| Métrica | Valor |
|---------|-------|
| Response Time (p95) | < 200ms |
| Response Time (p99) | < 500ms |
| Throughput | ~1000 req/s |
| Uptime SLA | 99.9% |

### Capacidade

| Recurso | Capacidade |
|---------|------------|
| Concurrent Users | ~5000 |
| Database Size | ~100GB |
| Daily Transactions | ~50k consultas |
| API Rate Limit | 100 req/min per user |

---

**Última atualização:** 15/11/2025
