# 📚 TCC - Trabalho de Conclusão de Curso

> **Análise de Desempenho em Java: Threads Tradicionais vs. Threads Virtuais**  
> **Autora:** Stephanye Cristine Antunes De Cunto  
> **Orientadora:** Me. Bianca Portes de Castro  
> **Coorientador:** Dr. José Rui Castro de Sousa  
> **Ano:** 2025

[![Java](https://img.shields.io/badge/Java-21-ED8B00.svg?logo=openjdk&logoColor=white)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-6DB33F.svg?logo=spring&logoColor=white)](https://spring.io/projects/spring-boot)
[![Maven](https://img.shields.io/badge/Maven-3.8+-C71A36.svg?logo=apache-maven&logoColor=white)](https://maven.apache.org/)
[![macOS](https://img.shields.io/badge/macOS-Host-000000.svg?logo=apple&logoColor=white)]()
[![Vegeta](https://img.shields.io/badge/Vegeta-12.8-00A98F.svg?logo=gnu&logoColor=white)](https://github.com/tsenart/vegeta)
[![LaTeX](https://img.shields.io/badge/LaTeX-abntex2-008080.svg?logo=latex&logoColor=white)](https://www.abntex.net.br/)
[![Status](https://img.shields.io/badge/status-Finalizado-green.svg)]()
[![wakatime](https://wakatime.com/badge/user/5a343522-23db-45ae-b20b-54655c392390/project/221c0cf4-099d-4775-8ef9-bb8e514e04b0.svg)](https://wakatime.com/badge/user/5a343522-23db-45ae-b20b-54655c392390/project/221c0cf4-099d-4775-8ef9-bb8e514e04b0)
[![License](https://img.shields.io/badge/license-Academic-blue.svg)](LICENSE)

---

## 📑 Sumário

- [📋 Sobre o Projeto](#-sobre-o-projeto)
- [⚙️ Requisitos](#️-requisitos-mínimos)
- [🛠️ Stack Tecnológica](#️-stack-tecnológica)
- [☁️ Sincronização com Google Drive](#️-sincronização-automática-com-google-drive)
- [🏗️ Arquitetura](#️-arquitetura-do-projeto)
- [📁 Estrutura do Repositório](#-estrutura-do-repositório)
- [🚀 Início Rápido](#-como-começar)
- [📊 API de Benchmark](#-api-de-benchmark)
- [📦 Instalação de Dependências](#-pré-requisitos)
- [📝 Trabalhando com LaTeX](#-compilando-o-documento)
- [📚 Gerenciamento de Referências](#-gerenciando-referências)
- [🛠️ Ferramentas Recomendadas](#️-ferramentas-recomendadas)
- [🧪 Metodologia](#-metodologia-de-testes)
- [🐛 Solução de Problemas](#-problemas-comuns)
- [📚 Recursos e Links Úteis](#-recursos-úteis)
- [📧 Contato](#-contato)
- [📄 Licença](#-licença)
---

## 📋 Sobre o Projeto

Este repositório contém o desenvolvimento do Trabalho de Conclusão de Curso (TCC), que investiga as diferenças de desempenho entre **threads tradicionais** (gerenciadas pelo sistema operacional) e **threads virtuais** (gerenciadas pela JVM, introduzidas no Java 19).

### 🎯 Objetivos

- Comparar o desempenho entre threads tradicionais e virtuais em diferentes cenários
- Analisar o consumo de recursos (CPU, memória, I/O)
- Avaliar a escalabilidade sob diferentes cargas de trabalho
- Medir latência e throughput em aplicações web

## ⚙️ Requisitos Mínimos

| Componente | Versão Mínima | Recomendado |
|------------|---------------|-------------|
| **Java** | 19+ (Virtual Threads) | 21 LTS |
| **Maven** | 3.8+ | 3.9+ |
| **Spring Boot** | 3.0+ | 3.2+ |
| **LaTeX** | TeX Live 2022+ | TeX Live 2024+ |
| **Sistema** | Ubuntu 20.04+ / macOS 12+ | Ubuntu 22.04 / macOS 14+ |
| **RAM** | 4 GB | 8 GB+ |
| **CPU** | 2 cores | 4+ cores |

> **⚠️ Importante:** Java 19+ é obrigatório para Virtual Threads (JEP 444).

---

## 🛠️ Stack Tecnológica

**Backend & Runtime:**  
[![Java](https://img.shields.io/badge/Java-21-ED8B00.svg?logo=openjdk&logoColor=white)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-6DB33F.svg?logo=spring&logoColor=white)](https://spring.io/projects/spring-boot)
[![Maven](https://img.shields.io/badge/Maven-3.8+-C71A36.svg?logo=apache-maven&logoColor=white)](https://maven.apache.org/)

**Infraestrutura:**  
[![macOS](https://img.shields.io/badge/macOS-Host-000000.svg?logo=apple&logoColor=white)]()
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420.svg?logo=ubuntu&logoColor=white)](https://ubuntu.com/)

**Ferramentas de Teste:**  
[![Vegeta](https://img.shields.io/badge/Vegeta-12.8-00A98F.svg?logo=gnu&logoColor=white)](https://github.com/tsenart/vegeta)
[![VisualVM](https://img.shields.io/badge/VisualVM-2.1-FF6600.svg?logo=java&logoColor=white)](https://visualvm.github.io/)

**Documentação:**  
[![LaTeX](https://img.shields.io/badge/LaTeX-abntex2-008080.svg?logo=latex&logoColor=white)](https://www.abntex.net.br/)

**DevOps:**  
[![GitHub](https://img.shields.io/badge/GitHub-Repository-181717.svg?logo=github&logoColor=white)](https://github.com/StephanyeCunto/tcc)
[![Rclone](https://img.shields.io/badge/Rclone-Auto%20Sync-0088CC.svg)](https://rclone.org/)
[![Google Drive](https://img.shields.io/badge/Google%20Drive-Backup-4285F4.svg?logo=googledrive&logoColor=white)](https://drive.google.com/)

**Status:**  
[![Status](https://img.shields.io/badge/status-Finalizado-green.svg)]()
[![wakatime](https://wakatime.com/badge/user/5a343522-23db-45ae-b20b-54655c392390/project/221c0cf4-099d-4775-8ef9-bb8e514e04b0.svg)](https://wakatime.com/badge/user/5a343522-23db-45ae-b20b-54655c392390/project/221c0cf4-099d-4775-8ef9-bb8e514e04b0)
[![Last Commit](https://img.shields.io/github/last-commit/StephanyeCunto/tcc.svg?logo=github)](https://github.com/StephanyeCunto/tcc)
<!-- 
## 📦 Gerenciamento de Arquivos Grandes com Git LFS

Este projeto utiliza **Git Large File Storage (LFS)** para gerenciar arquivos binários grandes, como resultados de benchmarks (`.bin`), dados de teste e arquivos de métricas que excedem os limites práticos do Git convencional.

### 🎯 Por que usar Git LFS?

O Git convencional não é otimizado para arquivos binários grandes porque:
- Cada versão do arquivo é armazenada completamente no histórico
- O repositório cresce rapidamente e clones ficam lentos
- Operações como `git diff` não funcionam bem com binários

O Git LFS resolve isso armazenando apenas **ponteiros** no repositório Git, enquanto os arquivos reais ficam em um servidor LFS separado.

### 📋 Arquivos Rastreados pelo LFS

Os seguintes tipos de arquivo são gerenciados pelo LFS neste projeto:

```
# Resultados de benchmarks
*.bin

# Dados de teste e métricas
*.dat
*.dump

# Arquivos compactados de resultados
results/**/*.tar.gz
results/**/*.zip

# Logs binários grandes
*.hprof
*.jfr
```

### 🔧 Instalação do Git LFS

**Linux (Ubuntu/Debian):**
```bash
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt-get install git-lfs
git lfs install
```

**macOS:**
```bash
brew install git-lfs
git lfs install
```

**Windows:**
```bash
# Chocolatey
choco install git-lfs

# Ou baixe de https://git-lfs.github.com/
git lfs install
```

### 🚀 Usando Git LFS no Projeto

#### 1. Clone Inicial do Repositório

```bash
# Clone normal - LFS faz download automático dos arquivos grandes
git clone https://github.com/StephanyeCunto/tcc
cd tcc
```

#### 2. Verificar Status do LFS

```bash
# Ver quais arquivos são rastreados pelo LFS
git lfs ls-files

# Ver arquivos LFS no último commit
git lfs ls-files -n

# Ver detalhes de rastreamento
git lfs track
```

#### 3. Adicionar Novos Tipos de Arquivo ao LFS

```bash
# Adicionar padrão de arquivo (atualiza .gitattributes)
git lfs track "*.bin"
git lfs track "results/**/*.tar.gz"

# Verificar o que foi adicionado
cat .gitattributes

# Commitar as mudanças
git add .gitattributes
git commit -m "feat: adicionar arquivos .bin ao Git LFS"
```

#### 4. Workflow Normal com Arquivos LFS

```bash
# Adicionar arquivo grande
cp resultado_benchmark.bin Teste/Script/loadConstant/results/
git add Teste/Script/loadConstant/results/resultado_benchmark.bin

# Git LFS processa automaticamente
git commit -m "test: adicionar resultados do benchmark tradicional"
git push origin main
```

#### 5. Comandos Úteis

```bash
# Ver tamanho dos objetos LFS
git lfs ls-files -s

# Buscar apenas ponteiros (clone rápido)
GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/StephanyeCunto/tcc

# Baixar arquivos LFS posteriormente
git lfs pull

# Buscar arquivos LFS de um branch específico
git lfs fetch origin main
git lfs checkout

# Limpar cache local do LFS
git lfs prune
```

### 📊 Estrutura do .gitattributes

O arquivo `.gitattributes` na raiz do projeto define quais arquivos são rastreados pelo LFS:

```gitattributes
# Resultados de benchmarks
*.bin filter=lfs diff=lfs merge=lfs -text
*.dat filter=lfs diff=lfs merge=lfs -text
*.dump filter=lfs diff=lfs merge=lfs -text

# Arquivos compactados grandes
results/**/*.tar.gz filter=lfs diff=lfs merge=lfs -text
results/**/*.zip filter=lfs diff=lfs merge=lfs -text

# Profiling e dumps
*.hprof filter=lfs diff=lfs merge=lfs -text
*.jfr filter=lfs diff=lfs merge=lfs -text

# PDFs de trabalhos relacionados (opcional)
Trabalhos_Relacionados/**/*.pdf filter=lfs diff=lfs merge=lfs -text
```

### 🔍 Verificando se Arquivos Estão no LFS

```bash
# Ver ponteiros LFS em vez do conteúdo real
git lfs pointer --file=resultado.bin

# Comparar tamanho: arquivo local vs ponteiro no Git
ls -lh resultado.bin
git cat-file -p HEAD:resultado.bin | head -n 5
```

**Saída esperada de um ponteiro LFS:**
```
version https://git-lfs.github.com/spec/v1
oid sha256:4d7a214614ab2935c943f9e0ff69d22ebbe7fc6ac0000000000000000000
size 524288000
```

### ⚠️ Limites e Boas Práticas

| Aspecto | Limite/Recomendação |
|---------|---------------------|
| **Tamanho por arquivo** | Até 2 GB por arquivo (GitHub) |
| **Quota mensal** | 1 GB bandwidth + 1 GB storage (gratuito) |
| **Tamanho total do repo** | Manter < 5 GB de arquivos LFS |
| **Arquivos pequenos** | < 100 MB não precisam de LFS |

**Boas práticas:**
- Não rastreie arquivos que mudam frequentemente (ex: logs de desenvolvimento)
- Use `.gitignore` para arquivos temporários antes de `.gitattributes`
- Comprima arquivos grandes quando possível (`.tar.gz` em vez de pasta)

### 🐛 Problemas Comuns

| Problema | Solução |
|----------|---------|
| **Arquivo não está no LFS após commit** | Execute `git lfs migrate import --include="*.bin"` |
| **Clone muito lento** | Use `GIT_LFS_SKIP_SMUDGE=1 git clone` e depois `git lfs pull` |
| **Erro de quota excedida** | Remova arquivos antigos do histórico ou use Git LFS Server próprio |
| **Arquivo grande commitado antes do LFS** | Use `git lfs migrate` para mover para LFS retroativamente |

**Migrar arquivo já commitado:**
```bash
# Migrar arquivo específico para LFS
git lfs migrate import --include="*.bin" --everything

# Verificar histórico
git lfs ls-files

# Force push (cuidado em repos compartilhados!)
git push origin main --force
``` -->

---

## ☁️ Sincronização Automática com Google Drive

Este repositório sincroniza automaticamente com o Google Drive após cada commit usando **Rclone** e **Git Hooks**, mantendo um backup sempre atualizado do projeto.

### Como Funciona

A sincronização ocorre através de um **hook post-commit** que executa o Rclone após cada commit. O processo filtra arquivos temporários (`.aux`, `.log`, `.git/`, etc.) definidos em `filters.txt` e envia apenas os arquivos relevantes para o Drive.


```mermaid
flowchart TB

    subgraph STORAGE["📦 Armazenamento"]
        DRIVE[Google DriveBackup Auto]
        GIT[GitHubControle Versão]
    end
    
    GIT -->|Rclone Hook| DRIVE

    style STORAGE fill:#4285F4
```

### Configuração Rápida

**1. Instalar Rclone:**
```bash
# Linux/macOS
curl https://rclone.org/install.sh | sudo bash

# Windows (Chocolatey)
choco install rclone
```

**2. Configurar Google Drive:**
```bash
rclone config
# n (new) → nome: drive → tipo: drive → autorize no navegador
```

**3. Criar Hook e Filtros:**
```bash
# Criar hook post-commit
cat > .git/hooks/post-commit << 'EOF'
#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_DIR="$(cd "$(git rev-parse --show-toplevel)" && pwd)"
FILTER_FILE="$REPO_DIR/filters.txt"
DRIVE_PATH="drive:/tcc"
LOG_FILE="$REPO_DIR/.rclone-sync.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🔄 Sincronizando com Google Drive    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"

rclone sync "$REPO_DIR" "$DRIVE_PATH" \
  --filter-from "$FILTER_FILE" \
  --delete-excluded \
  --log-file "$LOG_FILE" \
  --log-level INFO \
  --stats 1s \
  --stats-one-line

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Sincronização concluída!${NC}"
    echo "[$TIMESTAMP] ✅ Sync successful" >> "$LOG_FILE"
    BYTES=$(rclone size "$DRIVE_PATH" --json | jq -r '.bytes')
    SIZE=$(awk -v b="$BYTES" 'function human(x){s="B KB MB GB TB";split(s,a);for(i=1;x>=1024&&i<length(a);i++)x/=1024;return sprintf("%.2f %s",x,a[i])}END{print human(b)}')
    echo -e "${YELLOW}📊 Tamanho total no Drive: $SIZE${NC}"
else
    echo -e "${RED}⚠️  Erro na sincronização!${NC}"
    echo "[$TIMESTAMP] ❌ Sync failed" >> "$LOG_FILE"
    exit 1
fi

echo ""

EOF

chmod +x .git/hooks/post-commit

# Criar arquivo de filtros
cat > filters.txt << 'EOF'
# LaTeX Temporários
- *.aux
- *.bbl
- *.blg
- *.log
- *.out
- *.synctex.gz
- *.toc
- *.lof
- *.lot

# Sistema e Build
- .DS_Store
- Thumbs.db
- target/
- */target/
- build/

# Git e IDEs
- .git/
- .github/
- .gitignore
- .idea/
- .vscode/
- *.iml
EOF

# Adicionar ao .gitignore
echo -e "\n.rclone-sync.log\nfilters.txt" >> .gitignore
```

**Teste:** Execute `git commit --allow-empty -m "Teste sync"` para verificar a sincronização.

### Comandos Úteis

```bash
# Listar arquivos no Drive
rclone ls drive:/tcc

# Ver estrutura de pastas
rclone tree drive:/tcc

# Sincronização manual
rclone sync ./ drive:/tcc --filter-from ./filters.txt --progress

# Monitorar logs
tail -f .rclone-sync.log
```

### Solução de Problemas

| Problema | Solução |
|----------|---------|
| Hook não executa | `chmod +x .git/hooks/post-commit` |
| Erro de autenticação | `rclone config reconnect drive:` |
| Sync lento | Adicione `--transfers 8` ao comando rclone |

**⚠️ Importante:** O `rclone sync` é unidirecional (local → Drive). Para sincronização bidirecional, use `rclone bisync`.

---

## 🏗️ Arquitetura do Projeto

### Ambiente de Execução

## Carga constante

```mermaid
sequenceDiagram
    participant L as Linux Vegeta
    participant M as macOS Servidor
    participant S as Scripts start_all / server / metrics
    participant MET as Coletor de Métricas

    %% ======= INICIALIZAÇÃO =======
    L->>M: Executa start_all.sh remotamente
    M->>S: Inicia scripts
    S->>M: Inicia servidor HTTP start_server.sh

    %% ======= WARMUPS (LOOP) =======
    loop 3 vezes
        Note over L: Warmup<br/>300 RPS · 60s
        L->>M: Requisições de warmup
        M->>L: Respostas
    end

    %% ======= CORRIDA DE AQUECIMENTO =======
    Note over L: Corrida de Aquecimento<br/>Cadência real · 2 minutos
    L->>M: RPS variável conforme carga alvo
    M->>L: Respostas

    %% ======= GC =======
    Note over M: Coleta de Lixo GC<br/>Limpeza de buffers e sockets

    %% ======= ESPERA =======
    Note over L,M: Espera 60 segundos<br/>Estabilização da rede e memória

    %% ======= MÉTRICAS =======
    S->>MET: Iniciar coleta de métricas<br/>CPU, RAM, Rede, TCP e Portas Efêmeras
    MET->>MET: Salva métricas em JSON continuamente

    %% ======= TESTE PRINCIPAL =======
    Note over L: Teste Principal<br/>Duração: 10 minutos
    L->>M: Envia carga total RPS real
    M->>L: Respostas do servidor

    MET->>MET: Continua salvando métricas durante o teste
```


## Carga gradual

```mermaid

sequenceDiagram
    participant L as Linux Vegeta
    participant M as macOS Servidor
    participant S as Scripts start_all / server / metrics
    participant MET as Coletor de Métricas

    %% ======= INICIALIZAÇÃO =======
    L->>M: Executa start_all.sh remotamente
    M->>S: Inicializa scripts
    S->>M: Inicia servidor HTTP (nova JVM)

    %% ======= WARMUP (3 CICLOS) =======
    loop 3 ciclos de aquecimento
        Note over L: Warmup<br/>300 RPS · 60s
        L->>M: Envio de requisições (warmup)
        M->>L: Respostas

        Note over L,M: Pausa 60s
        Note over M: GC manual no servidor
        Note over L,M: Pausa 20s

        Note over L: Ajuste da taxa para<br/>limiar seguro de RPS
    end

    %% ======= TESTE PRINCIPAL (CARGA GRADUAL) =======
    loop Até ocorrerem erros de conexão
        Note over L: Teste principal<br/>Duração: 10s
        L->>M: Envio de requisições na taxa atual
        M->>L: Respostas do servidor

        Note over L,M: Pausa 60s
        Note over M: GC manual no servidor
        Note over L,M: Pausa 20s

        Note over L: Incremento de carga<br/>+50 RPS
    end

    %% ======= FINALIZAÇÃO =======
    Note over L,M: Pausa final 60s

    %% ======= REPETIÇÃO =======
    Note over M: Reinício do servidor<br/>Nova instância da JVM
    Note over L,M: Repetição completa do teste<br/>com outro mecanismo de threads
```

---

## 📁 Estrutura do Repositório

tcc/
├── Modelo_TCC_2025/                      # 📄 Documento do TCC (LaTeX)
│   ├── principal.tex                     # Arquivo principal do trabalho
│   ├── principal.pdf                     # PDF compilado
│   ├── imagens/                          # Figuras utilizadas no TCC
│   │   ├── multiplas.png
│   │   ├── onetoone.png
│   │   └── thread.png
│   ├── abntex2*.{cls,sty,bst,bib}        # Classes, estilos e bibliografia ABNT
│   ├── abntex2-modelo-references.bib     # Referências bibliográficas
│   └── arquivos_auxiliares/              # Arquivos gerados pelo LaTeX
│       ├── *.aux
│       ├── *.log
│       ├── *.toc
│       ├── *.bbl
│       ├── *.blg
│       ├── *.lof
│       ├── *.lot
│       └── *.idx
│
├── Teste/                                # 🧪 Experimentos e benchmarks
│   ├── Script/                           # Scripts de automação e execução
│   │   ├── prepare_environment.sh        # Preparação do ambiente
│   │   ├── jvm.sh                        # Configurações da JVM
│   │   ├── folder.sh                     # Organização de diretórios
│   │   ├── loadConstant/                 # Experimentos com carga constante
│   │   │   ├── benchmark_threads.sh
│   │   │   └── Results/
│   │   │       ├── Dados_Load_Constant.xlsx
│   │   │       ├── create_table.sh
│   │   │       └── get_data.sh
│   │   └── loadRamping/                  # Experimentos com carga progressiva
│   │       ├── benchmark_threads.sh
│   │       └── Results/
│   │           ├── Dados_Load_Ramping.xlsx
│   │           ├── create_table.sh
│   │           └── get_data.sh
│   │
│   └── Serve_Test/                       # 🚀 Servidor de benchmark
│       ├── README.md
│       ├── benchmark-server/             # Aplicação Spring Boot
│       │   ├── pom.xml
│       │   ├── mvnw
│       │   ├── mvnw.cmd
│       │   └── src/
│       │       ├── main/
│       │       │   ├── java/com/benchmark/server/
│       │       │   │   ├── BenchmarkServerApplication.java
│       │       │   │   └── controller/
│       │       │   │       └── ThreadBenchmarkController.java
│       │       │   └── resources/
│       │       │       └── application.properties
│       │       └── test/
│       │           └── java/com/benchmark/server/
│       │               └── BenchmarkServerApplicationTests.java
│       └── benchmark-server.zip           # Backup compactado do servidor
│
├── Trabalhos_Relacionados/               # 📚 Fundamentação teórica
│   ├── Avaliação dos mecanismos de concorrência na API do Java 8.pdf
│   ├── Benchmarking the Performance of Java Virtual Threads in High-Throughput Workloads.pdf
│   ├── Comparison of Concurrency Technologies in Java.pdf
│   ├── Tradução - Comparison of Concurrency Technologies in Java.pdf
│   └── Uma análise comparativa entre threads e green threads no Java.pdf
│
└── README.md                             # 📘 Descrição geral do repositório



## 🚀 Como Começar

### 1. Clone o Repositório

```bash
git clone https://github.com/StephanyeCunto/tcc
cd tcc
```

### 2. Configuração do Ambiente

#### Servidor de Benchmark (VM Azure)

```bash
cd Test/Serve_Test/benchmark-server

# Compilar o projeto
mvn clean package

# Executar o servidor
java -jar target/benchmark-server-0.0.1-SNAPSHOT.jar
```

O servidor estará disponível em: `http://<IP_DA_VM>:8080`

**VisualVM:**
```bash
# Linux/macOS
brew install visualvm  # ou baixe de https://visualvm.github.io/

# Conectar à VM via JMX
# Adicione ao servidor: -Dcom.sun.management.jmxremote.port=9090
```

### 3. Compilação do Documento LaTeX

```bash
cd Modelo_TCC_2025
latexmk -lualatex -pvc principal.tex
```
---

## 📊 API de Benchmark

| Endpoint | Método | Descrição | Exemplo de Uso |
|----------|--------|-----------|----------------|
| `/threads/virtual` | GET | Cria thread virtual (sleep 100ms) | `curl http://localhost:8080/threads/virtual` |
| `/threads/traditional` | GET | Cria thread tradicional (sleep 100ms) | `curl http://localhost:8080/threads/traditional` |
| `/threads/get` | GET | Retorna e reseta contador | `curl http://localhost:8080/threads/get` |
| `/threads/gc` | GET | Força Garbage Collection | `curl http://localhost:8080/threads/gc` |

**Resposta padrão:**
```json
{
  "message": "Thread virtual iniciada! Veja o console do servidor.",
  "counter": 42
}
```

**Comportamento Interno:**
- Cria thread usando `Thread.ofVirtual()` ou `new Thread()`
- Executa `Thread.sleep(100)` para simular I/O
- Incrementa contador atômico
- Aguarda conclusão com `join()`
---

## 📦 Pré-requisitos

### Para o Servidor

- **Java:** 19+ (com suporte a Virtual Threads)
- **Maven:** 3.8+
- **Spring Boot:** 3.x
- **Sistema:** Linux (Ubuntu/Debian recomendado)

**Instalação no Ubuntu:**

```bash
# Java 21 (LTS com Virtual Threads)
sudo apt update
sudo apt install openjdk-21-jdk

# Maven
sudo apt install maven

# Ferramentas de monitoramento
sudo apt install sysstat  # mpstat, iostat, vmstat
```

---

### Para Cliente de Testes (Máquina Local)



**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install default-jdk
sudo apt install visualvm

curl -L https://github.com/tsenart/vegeta/releases/download/v12.8.4/vegeta-12.8.4-linux-amd64.tar.gz -o vegeta.tar.gz
tar -xzf vegeta.tar.gz
sudo mv vegeta /usr/local/bin/
```

**macOS:**
```bash
# Instalar Java
brew install openjdk

# Instalar VisualVM
brew install --cask visualvm

# Instalar Vegeta
brew install vegeta
```

**Windows:**
- VisualVM: https://visualvm.github.io/  
- Vegeta: https://github.com/tsenart/vegeta/releases

---

### Para LaTeX

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install texlive-full latexmk biber
```

**macOS:**
```bash
brew install --cask mactex
```

**Windows:**
- [MiKTeX](https://miktex.org/download) ou [TeX Live](https://www.tug.org/texlive/)
- Ou use [Overleaf](https://www.overleaf.com/) (editor online)

---

## 📝 Compilando o Documento

### Método 1: Compilação Automática (Recomendado)

```bash
cd Modelo_TCC_2025
latexmk -lualatex -pvc principal.tex
```

**Flags úteis:**
- `-pvc`: Recompila automaticamente ao salvar
- `-lualatex`: Usa LuaLaTeX (melhor suporte a UTF-8 e português)

### Método 2: Compilação Manual Completa

Para garantir que referências e citações sejam processadas corretamente:

```bash
cd Modelo_TCC_2025

# 1ª compilação - Gera arquivos auxiliares
lualatex principal.tex

# Processa referências bibliográficas
bibtex principal

# 2ª compilação - Inclui referências
lualatex principal.tex

# 3ª compilação - Ajusta referências cruzadas
lualatex principal.tex
```

### Método 3: Usando latexmk Simplificado

```bash
cd Modelo_TCC_2025
latexmk -lualatex -bibtex principal.tex
```

💡 O arquivo `principal.pdf` será gerado automaticamente.

### Limpeza de Arquivos Temporários

```bash
# Remove arquivos auxiliares (mantém PDF)
latexmk -c

# Remove TODOS os arquivos gerados (inclusive PDF)
latexmk -C
```

---

## 📚 Gerenciando Referências

### Arquivo de Bibliografia

As referências ficam em `abntex2-modelo-references.bib`. 

**Exemplos de diferentes tipos de entrada:**

**Artigo:**
```bibtex
@article{sobrenome2025,
  author  = {Nome Sobrenome},
  title   = {Título do Artigo},
  journal = {Nome da Revista},
  year    = {2025},
  volume  = {1},
  number  = {1},
  pages   = {1--10}
}
```

**Livro:**
```bibtex
@book{autor2024,
  author    = {Autor da Silva},
  title     = {Título do Livro},
  publisher = {Editora},
  year      = {2024},
  address   = {São Paulo}
}
```

**Site:**
```bibtex
@online{site2025,
  author = {Organização},
  title  = {Título da Página},
  year   = {2025},
  url    = {https://exemplo.com},
  urlaccessdate = {05 nov. 2025}
}
```

### Citando no Texto

**Citação direta (Autor faz parte da frase):**
```latex
Segundo \citeonline{sobrenome2025}, os resultados demonstram...
```
→ *Segundo Sobrenome (2025), os resultados demonstram...*

**Citação indireta (Autor entre parênteses):**
```latex
Os resultados demonstram \cite{sobrenome2025}...
```
→ *Os resultados demonstram (SOBRENOME, 2025)...*

**Múltiplas citações:**
```latex
Diversos autores concordam \cite{autor2024,sobrenome2025,site2025}.
```
---

## 🛠️ Ferramentas Recomendadas

### Editores LaTeX

| Editor | Vantagens |
|--------|-----------|
| **[VS Code](https://code.visualstudio.com/)** + [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) | Leve, moderno, Git integrado |
| **[TeXstudio](https://www.texstudio.org/)** | Específico para LaTeX, muitos recursos |
| **[Overleaf](https://www.overleaf.com/)** | Online, colaborativo, sem instalação |

---

## 🧪 Metodologia de Testes

### Fluxo de Experimentos
```
1. Preparação do Ambiente
   ├─ Configurar servidor (Linux/macOS) com limites ajustados
   │    ├─ Aumentar portas efêmeras
   │    ├─ Ajustar fs.file-max e somaxconn
   │    └─ Aumentar ulimit (files/threads)
   ├─ Ajustar rede
   │    ├─ Verificar gargalos de WiFi vs cabo
   │    └─ Testar throughput máximo real com curl/speedtest
   └─ Preparar aplicação
        ├─ Habilitar GC logs
        ├─ Configurar pool de threads
        └─ Iniciar servidor em modo de produção

2. Baseline (Sem Carga)
   ├─ Verificar uso de CPU, RAM e GC
   ├─ Verificar número de portas efêmeras em uso
   ├─ Validar latência local (curl)
   └─ Registrar estado do sistema com script JSON contínuo

3. Testes de Carga (Vegeta)
   ├─ Cenário 1: Baixa carga
   │    └─ 100 req/s por 30s para validar estabilidade
   ├─ Cenário 2: Carga média
   │    └─ 500 req/s por 1 min (latência + portas efêmeras)
   ├─ Cenário 3: Alto volume
   │    └─ 1500 req/s por 2 min (testa fila TCP e GC)
   ├─ Cenário 4: Limite do servidor
   │    └─ Aumentar req/s progressivamente até saturar CPU ou portas
   └─ Registrar:
         ├─ mean, p90, p95, p99, max
         ├─ status codes
         └─ throughput real recebido

4. Monitoramento (VisualVM + Scripts)
   ├─ Monitorar:
   │    ├─ CPU por thread
   │    ├─ Heap/Non-Heap
   │    ├─ Frequência e duração de GC
   │    ├─ Threads vivas
   │    ├─ Deadlocks
   │    └─ File descriptors
   ├─ Coleta contínua em JSON:
   │    ├─ /proc/sys/net/... (portas, conexões)
   │    ├─ uso de memória
   │    ├─ load average
   │    └─ conexões ESTABLISHED / TIME_WAIT / CLOSE_WAIT
   └─ Detectar:
         ├─ Gargalo de rede
         ├─ Exaustão de portas efêmeras
         └─ Saturação de threads

5. Análise Final
   ├─ Identificar quando o servidor saturou
   │    ├─ CPU 100%
   │    ├─ limitação de WiFi/cabo
   │    ├─ fila TCP cheia (somaxconn)
   │    └─ erro por falta de portas
   ├─ Comparar conexões WiFi vs cabo
   ├─ Comparar latências reais com GC ativo
   ├─ Criar gráficos:
   │    ├─ Latência (p50, p90, p99)
   │    ├─ Throughput
   │    ├─ GC pauses
   │    ├─ Threads vivas
   │    └─ Portas efêmeras em uso
   └─ Gerar conclusão sobre:
         ├─ Capacidade máxima segura do servidor
         ├─ Pontos de gargalo
         └─ Recomendações de otimização
```

### Variáveis Mensuradas

| Variável | Ferramenta | Unidade |
|----------|-----------|---------|
| **Throughput** |Vegeta | req/s |
| **Latência** | Vegeta | ms |
| **CPU** | VisualVM | % |

---

## 🐛 Problemas Comuns

### LaTeX

| Problema | Solução |
|----------|---------|
| **Referências não aparecem** | Execute: `lualatex → bibtex → lualatex → lualatex` |
| **Acentos incorretos** | Use LuaLaTeX ao invés de pdfLaTeX |
| **Erro em imagens** | Verifique o caminho e se o arquivo existe em `imagens/` |
| **Undefined control sequence** | Verifique se todos os pacotes necessários estão instalados |
| **Compilação muito lenta** | Use `latexmk -c` para limpar arquivos temporários |

### Servidor e Testes

| Problema | Solução |
|----------|---------|
| **Servidor não inicia** | Verifique se a porta 8080 está livre: `lsof -i :8080` |
| **VisualVM não conecta** | Verifique configuração JMX e porta 9090 |
| **Métricas não coletadas** | Execute scripts com `sudo` e instale `sysstat` |

---

# 📚 Recursos Úteis

## LaTeX e ABNT
- [📘 Documentação abntex2](https://www.abntex.net.br/) - Guia oficial do padrão ABNT para LaTeX
- [📖 Overleaf Learn LaTeX](https://www.overleaf.com/learn) - Tutoriais interativos e exemplos práticos
- [📚 LaTeX Wikibook](https://en.wikibooks.org/wiki/LaTeX) - Referência completa da linguagem

---

## Java e Concorrência
- [📄 JEP 444: Virtual Threads](https://openjdk.org/jeps/444) - Especificação oficial das Virtual Threads
- [🔬 JMH Samples](https://hg.openjdk.org/code-tools/jmh/file/tip/jmh-samples/) - Exemplos práticos de benchmarks
- [📕 Java Concurrency in Practice](https://jcip.net/) - Livro referência sobre concorrência
- [🧵 Project Loom](https://openjdk.org/projects/loom/) - Projeto que introduziu Virtual Threads
- [📚 Java Documentation](https://docs.oracle.com/en/java/) - Documentação oficial da Oracle
- [🎓 Baeldung Java](https://www.baeldung.com/) - Tutoriais e guias sobre Java

---

## Ferramentas de Teste e Monitoramento
- [Vegeta] https://github.com/tsenart/vegeta  
- [Vegeta Manual](https://github.com/tsenart/vegeta#usage)
- [📊 VisualVM Documentation](https://visualvm.github.io/documentation.html) - Guia de monitoramento e profiling
- [🌱 Spring Boot Reference](https://docs.spring.io/spring-boot/docs/current/reference/html/) - Documentação do Spring Boot
- [🔧 Maven Documentation](https://maven.apache.org/guides/) - Guias de build e gerenciamento de dependências

---

## Sincronização e Backup
- [📘 Rclone Documentation](https://rclone.org/docs/) - Documentação oficial do Rclone
- [☁️ Google Drive with Rclone](https://rclone.org/drive/) - Guia específico para Google Drive
- [🎯 Rclone Filtering](https://rclone.org/filtering/) - Como filtrar arquivos na sincronização
- [🔄 Rclone Commands](https://rclone.org/commands/) - Referência completa de comandos

---

## Arquivos Grandes
- [📘 Git LFS Documentation](https://git-lfs.github.com/) - Documentação oficial
- [🐙 GitHub LFS Guide](https://docs.github.com/en/repositories/working-with-files/managing-large-files) - Guia do GitHub
- [🔧 Git LFS Tutorial](https://www.atlassian.com/git/tutorials/git-lfs) - Tutorial da Atlassian
- [💡 Git LFS Best Practices](https://github.com/git-lfs/git-lfs/wiki/Tutorial) - Wiki oficial

---

## Controle de Versão
- [🐙 Git Documentation](https://git-scm.com/doc) - Documentação oficial do Git
- [🪝 Git Hooks Documentation](https://git-scm.com/docs/githooks) - Guia sobre hooks do Git
- [📖 Pro Git Book](https://git-scm.com/book/en/v2) - Livro gratuito sobre Git
- [🎓 GitHub Guides](https://guides.github.com/) - Tutoriais do GitHub

---

## Comunidades e Fóruns
- [💬 Stack Overflow - LaTeX](https://tex.stackexchange.com/) - Perguntas e respostas sobre LaTeX
- [💬 Stack Overflow - Java](https://stackoverflow.com/questions/tagged/java) - Comunidade Java
- [🤖 Reddit - r/LaTeX](https://www.reddit.com/r/LaTeX/) - Discussões sobre LaTeX
- [☕ Reddit - r/java](https://www.reddit.com/r/java/) - Comunidade Java no Reddit
- [🌐 Dev.to - Java](https://dev.to/t/java) - Artigos e tutoriais sobre Java

---

## 📧 Contato

**Stephanye Cristine Antunes De Cunto**

Para dúvidas sobre o projeto ou colaborações, entre em contato através do GitHub.

---

## 📄 Licença

Este trabalho é de natureza acadêmica e está disponível para fins educacionais.

⚠️ **Nota sobre Plágio:** Este material é protegido por direitos autorais. Citações e referências devem seguir as normas ABNT.

---

**📌 Última atualização:** Dezembro de 2025