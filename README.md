# 📚 TCC - Trabalho de Conclusão de Curso

> **Análise de Desempenho em Java: Threads Tradicionais vs. Threads Virtuais**  
> **Autora:** Stephanye Cristine Antunes De Cunto  
> **Orientadora:** Me. Bianca Portes de Castro  
> **Coorientador:** Dr. José Rui Castro de Sousa  
> **Ano:** 2025

[![Java](https://img.shields.io/badge/Java-19+-orange.svg)](https://www.oracle.com/java/)
[![LaTeX](https://img.shields.io/badge/LaTeX-abntex2-blue.svg)](https://www.abntex.net.br/)
[![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow.svg)]()

---

## 📋 Sobre o Projeto

Este repositório contém o desenvolvimento do Trabalho de Conclusão de Curso (TCC), que investiga as diferenças de desempenho entre **threads tradicionais** (gerenciadas pelo sistema operacional) e **threads virtuais** (gerenciadas pela JVM, introduzidas no Java 19).

### 📊 Status Atual

- ✅ Revisão bibliográfica em andamento
- ✅ Ambiente de desenvolvimento configurado (VM Azure)
- 🔄 Definição da metodologia em andamento
- ⏳ Implementação dos benchmarks (pendente)
- ⏳ Coleta de dados (pendente)
- ⏳ Análise de resultados (pendente)

---

## 📁 Estrutura do Repositório

```
tcc/
├── Modelo_TCC_2025/              # 📄 Documento principal (LaTeX)
│   ├── principal.tex             # Arquivo principal do TCC
│   ├── principal.pdf             # PDF compilado
│   ├── imagens/                  # Figuras e diagramas
│   ├── abntex2*.{cls,sty,bst}    # Classes e estilos ABNT
│   └── abntex2-modelo-references.bib  # Referências bibliográficas
│
├── Teste_JMH/                    # 🔬 Testes e experimentos com JMH
│   ├── JHM.tex                   # Documentação sobre JMH
│   └── test/                     # Projeto Maven de exemplo
│
├── coletarMetricas/              # 📈 Guias de monitoramento
│   └── coletarMetricasLinux.tex  # Documentação: mpstat, vmstat, iostat
│
├── VM/                           # ☁️ Documentação do ambiente
│   ├── Vm Java Quickstart.pdf
│   └── especificacoes_vm_azure_detalhado.pdf
│
├── quadro/                       # 📊 Trabalhos relacionados
│   └── quadro.tex                # Comparativo de estudos similares
│
├── proposta/                     # 📝 Materiais da proposta
│   └── main.tex
│
├── resumo/                       # 📌 Resumos e materiais complementares
│   ├── resumo.tex
│   └── resumo2.tex
│
├── .gitignore
└── README.md
```

---

## 🚀 Como Começar

### Clone o Repositório

```bash
git clone https://github.com/StephanyeCunto/tcc
cd tcc
```

### Compilação Rápida

```bash
cd Modelo_TCC_2025
latexmk -lualatex -pvc principal.tex
```

O PDF será gerado e atualizado automaticamente a cada salvamento.

---

## 📦 Pré-requisitos

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

### Gerenciadores de Referências

- **[JabRef](https://www.jabref.org/)** - Interface gráfica para arquivos .bib
- **[Zotero](https://www.zotero.org/)** - Organiza e exporta para BibTeX
- **[Mendeley](https://www.mendeley.com/)** - Gerenciador de referências da Elsevier

---

## 📖 Materiais de Referência no Repositório

### Documentação Incluída

| Arquivo | Descrição |
|---------|-----------|
| **`JHM.pdf`** | Guia sobre Java Microbenchmark Harness (JMH) |
| **`coletarMetricasLinux.pdf`** | Ferramentas de monitoramento: mpstat, vmstat, iostat |
| **`quadro.pdf`** | Comparativo de trabalhos relacionados |
| **`especificacoes_vm_azure_detalhado.pdf`** | Especificações da VM Azure (4 vCPUs, 31 GB RAM) |

---

## 🐛 Problemas Comuns

| Problema | Solução |
|----------|---------|
| **Referências não aparecem** | Execute: `lualatex → bibtex → lualatex → lualatex` |
| **Acentos incorretos** | Use LuaLaTeX ao invés de pdfLaTeX |
| **Erro em imagens** | Verifique o caminho e se o arquivo existe em `imagens/` |
| **Undefined control sequence** | Verifique se todos os pacotes necessários estão instalados |
| **Compilação muito lenta** | Use `latexmk -c` para limpar arquivos temporários |

---

## 📚 Recursos Úteis

### LaTeX e ABNT
- [Documentação abntex2](https://www.abntex.net.br/) - Guia oficial
- [Overleaf Learn LaTeX](https://www.overleaf.com/learn) - Tutoriais
- [LaTeX Wikibook](https://en.wikibooks.org/wiki/LaTeX) - Referência completa
- [Detexify](http://detexify.kirelabs.org/) - Encontre símbolos desenhando
- [Tables Generator](https://www.tablesgenerator.com/) - Gerador de tabelas

### Java e Concorrência
- [JEP 444: Virtual Threads](https://openjdk.org/jeps/444) - Especificação oficial
- [JMH Samples](https://hg.openjdk.org/code-tools/jmh/file/tip/jmh-samples/) - Exemplos de benchmarks
- [Java Concurrency in Practice](https://jcip.net/) - Livro referência

### Comunidades
- [Stack Overflow - LaTeX](https://tex.stackexchange.com/)
- [Stack Overflow - Java](https://stackoverflow.com/questions/tagged/java)
- [Reddit - r/LaTeX](https://www.reddit.com/r/LaTeX/)

---

## 🗂️ Controle de Versão

### Arquivos Ignorados (.gitignore)

```gitignore
# LaTeX - Arquivos auxiliares
*.aux *.bbl *.blg *.idx *.lof *.log
*.loq *.lot *.toc *.out *.fdb_latexmk
*.fls *.ilg *.ind *.synctex.gz

# Java - Build
target/
*.class
*.jar

# IDEs e Sistema
.idea/
.vscode/
.DS_Store
*~
```

### Comandos Git Úteis

```bash
# Ver status
git status

# Adicionar alterações
git add .

# Fazer commit
git commit -m "Descrição da alteração"

# Enviar para repositório
git push

# Ver histórico
git log --oneline
```

---

## 📋 Checklist de Progresso

### Documentação
- [x] README configurado
- [x] Estrutura organizada
- [x] Materiais de referência
- [ ] Metodologia definida

### Ambiente
- [x] VM Azure configurada
- [ ] Ferramentas documentadas
- [ ] Ambiente Java configurado

### Implementação
- [ ] Benchmarks implementados
- [ ] Scripts de coleta
- [ ] Testes realizados

### Escrita
- [ ] Introdução
- [ ] Revisão bibliográfica
- [ ] Metodologia
- [ ] Resultados
- [ ] Conclusão

---

## 📧 Contato

**Stephanye Cristine Antunes De Cunto**

---

## 📄 Licença

Este trabalho é de natureza acadêmica e está disponível para fins educacionais.

⚠️ **Nota sobre Plágio:** Este material é protegido por direitos autorais. Citações e referências devem seguir as normas ABNT.

---

**📌 Última atualização:** Novembro de 2025