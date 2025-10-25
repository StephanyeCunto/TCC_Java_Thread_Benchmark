# 📚 TCC - Trabalho de Conclusão de Curso

Repositório contendo o desenvolvimento do Trabalho de Conclusão de Curso em LaTeX, utilizando as normas ABNT através do abntex2.

## 📁 Estrutura do Projeto

```
tcc/
├── Modelo_TCC_2025/          # 📄 Documento principal do TCC
│   ├── principal.tex         # Arquivo principal LaTeX
│   ├── principal.pdf         # PDF compilado
│   ├── imagens/              # Figuras e diagramas
│   ├── abntex2*.{cls,sty,bst} # Classes e estilos ABNT
│   └── abntex2-modelo-references.bib # Referências bibliográficas
├── proposta/                 # 📝 Proposta inicial do TCC
│   └── main.tex
├── resumo/                   # 📌 Resumos e materiais complementares
│   ├── resumo.tex
│   └── resumo2.tex
├── VM/                       # ☁️ Documentação sobre VM Azure e Java
│   ├── Vm Java Quickstart.pdf
│   └── especificacoes_vm_azure_detalhado.pdf
├── .gitignore                # Arquivos ignorados pelo Git
└── README.md                 # Este arquivo
```

## 🚀 Como Começar

### Pré-requisitos

Você precisa ter uma distribuição LaTeX instalada no seu sistema:

- **Linux (Ubuntu/Debian):**
  ```bash
  sudo apt-get update
  sudo apt-get install texlive-full latexmk biber
  ```

- **macOS:**
  ```bash
  brew install --cask mactex
  ```

- **Windows:**
  - Instale o [MiKTeX](https://miktex.org/download) ou [TeX Live](https://www.tug.org/texlive/)
  - Ou use [Overleaf](https://www.overleaf.com/) (editor online)

### Compilação

#### Método 1: Compilação Automática (Recomendado)

Use LuaLaTeX para melhor suporte a Unicode (acentos, emojis, caracteres especiais):

```bash
cd Modelo_TCC_2025
latexmk -lualatex -pvc principal.tex
```

**Flags úteis:**
- `-pvc`: Recompila automaticamente quando salva o arquivo
- `-lualatex`: Usa o engine LuaLaTeX (melhor para português)

#### Método 2: Compilação Manual Completa

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

**💡 Dica:** O arquivo `principal.pdf` será gerado automaticamente.

#### Método 3: Usando latexmk (Automático)

O latexmk detecta automaticamente quando rodar BibTeX:

```bash
cd Modelo_TCC_2025
latexmk -lualatex -bibtex principal.tex
```

## 📚 Gerenciando Referências

### Arquivo de Bibliografia

As referências ficam em `abntex2-modelo-references.bib`. Exemplo de entrada:

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

@book{autor2024,
  author    = {Autor da Silva},
  title     = {Título do Livro},
  publisher = {Editora},
  year      = {2024},
  address   = {São Paulo}
}

@online{site2025,
  author = {Organização},
  title  = {Título da Página},
  year   = {2025},
  url    = {https://exemplo.com},
  urlaccessdate = {25 out. 2025}
}
```

### Citando no Texto

**Citação direta (Autor faz parte da frase):**
```latex
Segundo \citeonline{sobrenome2025}, os resultados demonstram...
```
Resultado: Segundo Sobrenome (2025), os resultados demonstram...

**Citação indireta (Autor entre parênteses):**
```latex
Os resultados demonstram \cite{sobrenome2025}...
```
Resultado: Os resultados demonstram (SOBRENOME, 2025)...

**Múltiplas citações:**
```latex
Diversos autores concordam \cite{autor2024,sobrenome2025,site2025}.
```
## 🛠️ Ferramentas Recomendadas

### Editores LaTeX

- **[VS Code](https://code.visualstudio.com/)** + [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop)
- **[TeXstudio](https://www.texstudio.org/)** - Editor dedicado para LaTeX
- **[Overleaf](https://www.overleaf.com/)** - Editor online colaborativo

## 🐛 Problemas Comuns

### Erro: "undefined control sequence"
**Solução:** Verifique se todos os pacotes necessários estão instalados e se não há comandos com erros de digitação.

### Referências não aparecem
**Solução:** Execute a sequência completa de compilação (lualatex → bibtex → lualatex → lualatex).

### Acentos aparecem incorretos
**Solução:** Use LuaLaTeX ou XeLaTeX ao invés de pdfLaTeX, ou configure corretamente a codificação UTF-8.

### Erro ao compilar imagens
**Solução:** Verifique se o caminho para a imagem está correto e se o arquivo existe na pasta `imagens/`.

## 📖 Recursos Úteis

- [Documentação abntex2](https://www.abntex.net.br/)
- [Overleaf Learn LaTeX](https://www.overleaf.com/learn)
- [LaTeX Wikibook](https://en.wikibooks.org/wiki/LaTeX)
- [Detexify](http://detexify.kirelabs.org/classify.html) - Encontre símbolos LaTeX desenhando
- [Tables Generator](https://www.tablesgenerator.com/) - Gerador de tabelas LaTeX

## 🗂️ Controle de Versão

Os seguintes arquivos estão no `.gitignore` e não são versionados:

```
*.aux *.bbl *.blg *.idx *.lof *.log 
*.loq *.lot *.toc *.out *.fdb *.fls
*.fdb_latexmk *.DS_Store
```