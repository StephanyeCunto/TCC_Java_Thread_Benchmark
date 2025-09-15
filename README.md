# 📚 README - Projeto LaTeX com Banco de Dados de Artigos

## Visão Geral
Este projeto utiliza LaTeX para criar um documento que gerencia uma base de dados de artigos acadêmicos, gerando automaticamente uma lista formatada e seções com resumos e anotações.

## 🚀 Compilação

### Recomendação: Use LuaLaTeX
Para melhor suporte a Unicode (acentos, emojis, caracteres especiais), prefira `lualatex`:

```bash
# Compilação automática (recomendado)
latexmk -lualatex -pvc main.tex

# Compilação manual
lualatex main.tex
lualatex main.tex
```

**Flags úteis:**
- `-pvc`: Recompila automaticamente quando o arquivo é salvo
- `-lualatex`: Usa o engine LuaLaTeX

## Estrutura do Projeto

```
projeto/
├── main.tex          # Documento principal
├── artigosDB.tex     # Base de dados dos artigos
└── README.md         # Este arquivo
```

## 📦 Pacotes Utilizados

### Essenciais
```latex
\usepackage[brazil]{babel}        % Português brasileiro
\usepackage[utf8]{inputenc}       % UTF-8 (desnecessário no LuaLaTeX)
\usepackage{geometry}             % Controle de margens e layout
\usepackage{datatool}             % Manipulação de bases de dados
\usepackage{longtable}            % Tabelas que quebram páginas
```

### Links e Formatação
```latex
\usepackage{hyperref}             % Links clicáveis
\usepackage{xcolor}               % Cores
\usepackage{xstring}              % Manipulação de strings
\usepackage{etoolbox}             % Ferramentas adicionais
\usepackage{indentfirst}          % Indentação do primeiro parágrafo
\usepackage{setspace}             % Controle de espaçamento entre linhas
\usepackage{times}                % Fonte Times New Roman
```

### Utilitários e Correções
```latex
\usepackage{silence}              % Suprime avisos específicos
\WarningFilter{tracklang}{No `datatool' support for dialect `brazil'}
```

### Pacotes Adicionais Recomendados
```latex
\usepackage{lipsum}               % Texto fictício para testes
\usepackage{abntex2}              % Para trabalhos acadêmicos brasileiros
\usepackage{memoir}               % Classe avançada para documentos
```

## Configurações de Layout

```latex
\geometry{ top=3cm, bottom=2cm, left=3cm, right=2cm}  % Margens
\onehalfspacing                                        % Espaçamento 1,5
\setlength{\parindent}{1.5cm}                         % Indentação de parágrafo
```

## Estrutura da Base de Dados

Cada artigo na base de dados (`artigosDB.tex`) contém os seguintes campos:

- `num` - Número sequencial do artigo
- `titulo` - Título do artigo
- `producao` - Tipo de produção (Artigo, TCC, Dissertação, Tese)
- `autor` - Nome do(s) autor(es)
- `ano` - Ano de publicação
- `link` - URL para acesso ao documento
- `so` - Sistema operacional (campo adicional)
- `resumo` - Resumo do artigo
- `notas` - Anotações pessoais

## Como Adicionar Novos Artigos

1. Abra o arquivo `artigosDB.tex`
2. Adicione uma nova entrada seguindo este padrão:

```latex
\DTLnewrow{artigos}
\DTLnewdbentry{artigos}{num}{NÚMERO}
\DTLnewdbentry{artigos}{titulo}{TÍTULO DO ARTIGO}
\DTLnewdbentry{artigos}{producao}{TIPO}
\DTLnewdbentry{artigos}{autor}{NOME DO AUTOR}
\DTLnewdbentry{artigos}{ano}{ANO}
\DTLnewdbentry{artigos}{link}{URL}
\DTLnewdbentry{artigos}{so}{SISTEMA}
\DTLnewdbentry{artigos}{resumo}{TEXTO DO RESUMO}
\DTLnewdbentry{artigos}{notas}{SUAS ANOTAÇÕES}
```

## 📝 Estruturas e Códigos Úteis

### Tabela Longa com DataTool
```latex
\begin{longtable}{|c|p{8.5cm}|c|c|p{1.5cm}|}
    \hline
    \textbf{N\textsuperscript{o}} & \textbf{Título} & \textbf{Ano} & \textbf{Links} & \textbf{Sistema} \\
    \hline
    \endfirsthead
    
    \hline
    \textbf{N\textsuperscript{o}} & \textbf{Título} & \textbf{Ano} & \textbf{Links} & \textbf{Sistema} \\
    \hline
    \endhead
    
    \hline
    \endlastfoot

    \DTLforeach{artigos}{\num=num,\titulo=titulo,\ano=ano,\link=link,\so=so}{  
        \num & \titulo & \ano & \href{\link}{Acesso} & \so
        \DTLiflastrow{}{\\ \hline}
    }
\end{longtable}
```

### Texto Fictício para Testes
```latex
\usepackage{lipsum}
% No documento:
\lipsum[1-3]  % Gera 3 parágrafos de Lorem ipsum
```

### Filtros Avançados com DataTool
```latex
% Filtrar por ano específico
\DTLforeach*{artigos}{\ano=ano}{\DTLiffirstrow{ano}{2020}{\DTLbreak}}{\conteudo}

% Filtrar por tipo de produção
\DTLforeach*{artigos}{\producao=producao}{%
    \IfStrEq{\producao}{Artigo}{\conteudo}{\DTLbreak}
}
```

## Comandos de Compilação

### LuaLaTeX (Recomendado)
```bash
# Compilação automática com preview contínuo
latexmk -lualatex -pvc main.tex

# Compilação manual completa
lualatex main.tex
lualatex main.tex
```

### PDFLaTeX (Alternativo)
```bash
# Compilação completa
pdflatex main.tex
pdflatex main.tex

# Para projetos com referências
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

**Dica**: O LuaLaTeX oferece melhor suporte para Unicode e é mais moderno.

## Estrutura do Documento Final

1. **Sumário** - Gerado automaticamente
2. **Lista de Artigos** - Tabela com todos os artigos
3. **Resumos e Anotações** - Seções detalhadas para cada artigo

## Personalizações Possíveis

### Adicionar Nova Coluna na Tabela
```latex
\begin{longtable}{|c|p{8cm}|c|c|p{1.5cm}|c|} % Adicione |c| no final
    % Adicione \textbf{Nova Coluna} no cabeçalho
    % Adicione \novocampo na linha de dados
```

### Modificar Formatação
- **Espaçamento**: Altere `\onehalfspacing` para `\doublespacing` ou `\singlespacing`
- **Fonte**: Substitua `times` por outro pacote de fonte
- **Margens**: Modifique os valores em `\geometry{}`

### Adicionar Filtros
```latex
% Filtrar por ano
\DTLforeach*{artigos}{\ano=ano}{\DTLiffirstrow{ano}{2020}{\DTLbreak}}{\conteudo}

% Filtrar por tipo
\DTLforeach*{artigos}{\producao=producao}{\IfStrEq{\producao}{Artigo}{\conteudo}{\DTLbreak}}
```

## ⚠️ Problemas Comuns e Soluções

### 1. Linha Extra em Tabelas
**Problema**: Tabela com linha desnecessária no final

**Solução**: Use `\DTLiflastrow{}{\\ \hline}` no loop:
```latex
\DTLforeach{artigos}{\num=num,\titulo=titulo}{  
    \num & \titulo
    \DTLiflastrow{}{\\ \hline}  % Evita linha extra
}
```

### 2. Avisos do datatool
**Problema**: Warnings sobre suporte de dialeto

**Solução**: Adicione antes de `\usepackage{datatool}`:
```latex
\usepackage{silence} 
\WarningFilter{tracklang}{No `datatool' support for dialect `brazil'}
```

### 3. Comando Terminado com Espaço
**Problema**: Warning "Command terminated with space"

**Solução**: Cuidado com `\\ ` (barra dupla + espaço). Use apenas `\\`.

### 4. Caracteres Especiais não Aparecem
**Problema**: Acentos e caracteres especiais não renderizam

**Soluções**:
- Use `lualatex` em vez de `pdflatex`
- Certifique-se de que o arquivo está salvo em UTF-8
- Para caracteres específicos, use comandos LaTeX: `\~a` para ã

### 5. Tabela Não Quebra Páginas
**Problema**: Tabela grande não continua na próxima página

**Solução**: Use `longtable` em vez de `table`:
```latex
\begin{longtable}{|c|p{8cm}|c|}
    % conteúdo da tabela
\end{longtable}
```

### 6. Links Não Funcionam
**Problema**: URLs não são clicáveis

**Soluções**:
- Confirme que `\usepackage{hyperref}` está carregado
- Verifique se as URLs no banco de dados estão corretas
- Use `\href{url}{texto}` para links

### 7. Pacotes Duplicados
**Problema**: Erro de pacote já carregado

**Solução**: Evite repetir `\usepackage` do mesmo pacote no projeto.

## 🔗 Links e Recursos Úteis

### Documentação Oficial
- [Documentação do datatool](https://ctan.org/pkg/datatool)
- [Lista de pacotes CTAN](https://ctan.org/pkg)
- [Overleaf – Learn LaTeX](https://www.overleaf.com/learn)

### Guias e Tutoriais
- [LaTeX Wikibook](https://en.wikibooks.org/wiki/LaTeX)
- [Detexify - Símbolos LaTeX](http://detexify.kirelabs.org/classify.html)
- [Tables Generator](https://www.tablesgenerator.com/latex_tables)

### Ferramentas Online
- [Overleaf](https://www.overleaf.com/) - Editor LaTeX online
- [ShareLaTeX](https://www.sharelatex.com/) - Editor colaborativo
- [LaTeX Live](https://latexlive.com/) - Compilador online simples