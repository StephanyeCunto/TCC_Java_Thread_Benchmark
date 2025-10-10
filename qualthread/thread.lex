\documentclass[12pt]{article}
\usepackage[utf8]{inputenc}
\usepackage{geometry}
\usepackage{booktabs}
\usepackage{array}
\usepackage[table]{xcolor}

\geometry{a4paper, margin=2.5cm}

\begin{document}

\section*{Callable + Future}

Callable + Future: Necessita de gerenciador de tarefas, faz sentido isso para o trabalho?  
Como definir qual gerenciador usar?  

\begin{itemize}
    \item Callable é uma interface funcional que cria uma tarefa
    \item Future é um objeto que representa o resultado de uma tarefa
    \item Normalmente utiliza ExecutorService ou Thread Pool. Thread pool é um mecanismo de gerenciamento de threads
    \item Pode ser utilizado também com FutureTask + Thread
    \item FutureTask é uma classe que implementa Runnable e Future. Ela serve como uma ponte entre Callable e Thread
\end{itemize}

\section*{Comparativo: Thread (herança) vs Runnable}

\begin{tabular}{|>{\raggedright}p{4cm}|>{\raggedright}p{6cm}|>{\raggedright\arraybackslash}p{6cm}|}
\hline
Aspecto & Thread (herança) & Runnable \\
\hline
Objeto de thread & Cada thread é um objeto distinto & Várias threads podem compartilhar o mesmo objeto Runnable \\
\hline
Estado compartilhado & Cada thread tem seu próprio conjunto de variáveis (estado isolado). Não há interferência entre threads & Se o mesmo Runnable for usado em várias threads, o estado interno do objeto é compartilhado. Variáveis da classe Runnable podem ser alteradas por várias threads ao mesmo tempo \\
\hline
Flexibilidade & Menos flexível (não pode estender outra classe) & Mais flexível, pode implementar Runnable e estender outra classe \\
\hline
Gerenciamento & Cada thread é autônoma, menos risco de conflito de estado interno, mas menos controle centralizado & Necessário gerenciar acesso ao estado compartilhado, garantindo sincronização quando necessário \\
\hline
\end{tabular}

\section*{Quando utilizar}

\subsection*{Thread}
\begin{itemize}
    \item Cada thread precisa de um objeto independente
    \item A classe não precisa estender outra
    \item Estado compartilhado não é necessário
    \item Mais simples de implementar
\end{itemize}

\subsection*{Runnable}
\begin{itemize}
    \item Várias threads compartilham o mesmo comportamento
    \item A classe já estende outra
    \item Para separar a lógica da thread do próprio objeto Thread
    \item Facilita o reuso
\end{itemize}

\end{document}
