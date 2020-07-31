% Gastao Faria, n 90454

:- [codigo_comum].

/**
 * Legenda:
 *
 * H - Cabeca da lista (Head);
 * T - Cauda da lista (Tail);
 * N - Numero;
 * X, Y - Variavel.
 *
 */

%==================Predicados para a inicializacao de puzzles==================

% 3.1.1 Predicado obtem_letras_palavras/2--------------------------------------
% Ordena alfabeticamente e atomiza a lista de palavras fornecida "Lst_Pals",
% devolvendo a lista "Letras".
% O predicado auxiliar atomiza as palavras, palavra a palavra.
%------------------------------------------------------------------------------
obtem_letras_palavras_aux([], []).
obtem_letras_palavras_aux([H | T], [H1 | T1]) :-
   atom_chars(H, H1),
   obtem_letras_palavras_aux(T, T1).

obtem_letras_palavras(Lst_Pals, Letras) :-
   sort(Lst_Pals, Sorted),
   obtem_letras_palavras_aux(Sorted, Letras).

% 3.1.2 Predicado espaco_fila/2------------------------------------------------
% Devolve cada espaco "Esp" presente numa fila "Fila".
% O predicado nao_mebro verifica que um elemento nao pertence a uma lista.
% O predicado auxiliar verifica se o ultimo elemento de uma lista e '#' ou se a
% lista e vazia.
% O predicado auxiliar 1 verifica se o primeiro elemento de uma lista e '#' ou
% se a lista e vazia.
% O predicado em questao verifica se o candidato a espaco verifica seguintes
% condicoes: estar entre uma combinacao de '#', comecar na fila ou acabar na
% fila; e o comprimento ser maior ou igual a 3.
%------------------------------------------------------------------------------
nao_membro(_, []).
nao_membro(X, [H | T]) :-
   X \== H,
   nao_membro(X, T).

espaco_fila_aux([]).
espaco_fila_aux(Lista) :-
   last(Lista, X),
   X == '#'.

espaco_fila_aux1([]).
espaco_fila_aux1([H | _]) :-
   H == '#'.

espaco_fila(Fila, Esp) :-
   append([Pref, Esp, Suf], Fila),
   espaco_fila_aux(Pref),
   espaco_fila_aux1(Suf),
   length(Esp, Comp),
   Comp >= 3,
   nao_membro('#', Esp).

% 3.1.3 Predicado espacos_fila/2-----------------------------------------------
% Devolve uma lista "Espacos" contendo todos os espacos de uma fila "Fila".
% O predicado em questao recorre coloca todos os espacos numa lista recorrendo
% ao predicado espaco_fila.
%------------------------------------------------------------------------------
espacos_fila(Fila, Espacos) :-
   bagof(Espacos, espaco_fila(Fila, Espacos), Espacos),
   !;
   Espacos = [].

% 3.1.4 Predicado espacos_puzzle/2---------------------------------------------
% Devolve uma lista contendo todos os espacos "Espacos" presentes numa grelha
% "Grelha".
% O predicado em questao aplica o predicado espacos_fila as linhas de grelha
% e as da sua respetiva matriz transposta.
%------------------------------------------------------------------------------
espacos_puzzle(Grelha, Espacos) :-
   mat_transposta(Grelha, Transposta),
   append(Grelha, Transposta, Tudo),
   maplist(espacos_fila, Tudo, Aux),
   append(Aux, Pre),
   delete(Pre, [], Espacos).

% 3.1.5 Predicado espacos_com_posicoes_comuns/3--------------------------------
% Devolve uma lista contendo todos os espacos "Esps_com" de uma lista de
% espacos "Espacos" com posicoes em comum com um espaco "Esp", exceto o proprio
% espaco.
% O predicado pertence verifica se um elemento pertence a uma lista. Parecido a
% member mas nao unifica.
% O predicado auxiliar verfica se um espaco pertence a uma lista de espacos.
% O predicado auxiliar1 exclui o espaco em questao da lista.
% O predicado em questao aplica o auxiliar e o auxiliar1.
%------------------------------------------------------------------------------
pertence(X, [H | _]) :-
   X == H.
pertence(X, [_ | T]) :-
   pertence(X, T).

espacos_com_posicoes_comuns_aux(Esp, [H | _]) :-
   pertence(H, Esp).
espacos_com_posicoes_comuns_aux(Esp, [_ | T]) :-
   espacos_com_posicoes_comuns_aux(Esp, T).

espacos_com_posicoes_comuns_aux1([], _, []).
espacos_com_posicoes_comuns_aux1([H | T], Esp, T1) :-
   H == Esp,
   !,
   espacos_com_posicoes_comuns_aux1(T, Esp, T1).
espacos_com_posicoes_comuns_aux1([H | T], Esp, [H | T1]) :-
   H \== Esp,
   espacos_com_posicoes_comuns_aux1(T, Esp, T1).

espacos_com_posicoes_comuns(Espacos, Esp, Esps_com) :-
   include(espacos_com_posicoes_comuns_aux(Esp), Espacos, Pre),
   espacos_com_posicoes_comuns_aux1(Pre, Esp, Esps_com).

% 3.1.6 Predicado palavra_possivel_esp/4---------------------------------------
% Verifica se uma palavra "Pal", um espaco "Esp", uma lista de espacos_fila
% "Espacos" e uma lista de palavras "Letras" sao coerentes.
% O predicado cabe verifica se uma palavra cabe num espaco.
%------------------------------------------------------------------------------
cabe(Espaco, Palavra) :-
   copia(Espaco, Cop),
   Cop = Palavra.

copia(Espaco, Cop) :-
   maplist(copial_Elemento, Espaco, Cop).

copial_Elemento(El, _) :-
   var(El),
   !.
copial_Elemento(El, El).

palavra_possivel_esp_aux([], _).
palavra_possivel_esp_aux([H | T], Letras) :-
   palavra_possivel_esp_aux1(H, Letras),
   palavra_possivel_esp_aux(T, Letras).

palavra_possivel_esp_aux1(_, []) :-
   !,
   fail.
palavra_possivel_esp_aux1(Esp, [H | _]) :-
   cabe(Esp, H),
   !.
palavra_possivel_esp_aux1(Esp, [_ | T]) :-
   palavra_possivel_esp_aux1(Esp, T).

palavra_possivel_esp(Pal, Esp, Espacos, Letras) :-
   cabe(Esp, Pal),
   espacos_com_posicoes_comuns(Espacos, Esp, Esps_com),
   Esp = Pal,
   palavra_possivel_esp_aux(Esps_com, Letras).

% 3.1.7 Predicado palavras_possiveis_esp/4-------------------------------------
% Aplicacao do predicado palavra_possivel_esp. Devolve a lista de palavras
% possiveis "Pals_Possiveis", que resulta de "Letras", "Espacos" e "Esp".
%------------------------------------------------------------------------------
palavras_possiveis_esp(Letras, Espacos, Esp, Pals_Possiveis) :-
   findall(X, (member(X, Letras),
palavra_possivel_esp(X, Esp, Espacos, Letras)), Pals_Possiveis),
   !.

% 3.1.8 Predicado palavras_possiveis/3-----------------------------------------
% Recebe uma lista de palavras "Letras" e uma lista de espacos "Espacos" e
% devolve uma lista "Pals_Possiveis" que contem as palavras possiveis para cada
% espaco.
%------------------------------------------------------------------------------
palavras_possiveis_aux(_, _, [], []).
palavras_possiveis_aux(Letras, Espacos, [H | T], [H1 | T1]) :-
   palavras_possiveis_esp(Letras, Espacos, H, X),
   append([[H, X]], H1),
   palavras_possiveis_aux(Letras, Espacos, T, T1).

palavras_possiveis(Letras, Espacos, Pals_Possiveis) :-
   palavras_possiveis_aux(Letras, Espacos, Espacos, Pals_Possiveis).

% 3.1.9 Predicado letras_comuns/2----------------------------------------------
% Recebe uma lista de palavras "Lst_Pals" e devolve uma lista "Letras_comuns"
% que contem uma lista de (posicoes, letras) que se encontram em todas as
% palavras.
% O predicado verifica_letra verifica se se uma certa letra se encontra numa
% certa posicao.
%------------------------------------------------------------------------------
verifica_letra([], _, _).
verifica_letra([H | T], N, El) :-
   nth1(N, H, X),
   X == El,
   verifica_letra(T, N, El).

letras_comuns_aux(_, [], [], _).
letras_comuns_aux(Lst_Pals, [H1 | T1], [H | T], N) :-
	verifica_letra(Lst_Pals, N, H),
   H1 = (N, H),
   N1 is N + 1,
	letras_comuns_aux(Lst_Pals, T1, T, N1).
letras_comuns_aux(Lst_Pals, Letras_comuns, [_ | T], N) :-
   N1 is N + 1,
	letras_comuns_aux(Lst_Pals, Letras_comuns, T, N1).

letras_comuns(Lst_Pals, Letras_comuns) :-
   Lst_Pals = [Pal | _],
   letras_comuns_aux(Lst_Pals, Letras_comuns, Pal, 1),
   !.

% 3.1.10 Predicado atribui_comuns/1--------------------------------------------
% Atualiza os espacos da lista "Pals_Possiveis" substituindo as variaveis por
% letras que estejam presentes em todas as palavras da mesma linha.
% O predicado check e parecido ao member, mas nao devolve false.
%------------------------------------------------------------------------------
check(_ , []) :-
   fail.
check(X, [H | _]) :-
   X = H,
   !.
check(X, [_ | T]) :-
   check(X, T).

atribui_comuns_aux([], _, _).
atribui_comuns_aux([H | T], Letras_comuns, N) :-
   X = (N, H),
   check(X, Letras_comuns),
   N1 is N + 1,
   atribui_comuns_aux(T, Letras_comuns, N1).
atribui_comuns_aux([_ | T], Letras_comuns, N) :-
   N1 is N + 1,
   atribui_comuns_aux(T, Letras_comuns, N1).

atribui_comuns([]).
atribui_comuns([H | T]) :-
   nth1(2, H, El),
   letras_comuns(El, Letras_comuns),
   nth1(1, H, Espaco),
   atribui_comuns_aux(Espaco, Letras_comuns, 1),
   atribui_comuns(T),
   !.

% 3.1.11 Predicado retira_impossiveis/2----------------------------------------
% Devolve a lista "Novas_Pals_Possiveis", que e igual a "Pals_Possiveis"
% excluindo as palavras impossiveis.
%------------------------------------------------------------------------------
retira_impossiveis([], []).
retira_impossiveis([H | T], [H1 | T1]) :-
   nth1(1, H, Pal),
   append([Pal], [], X),
   nth1(2, H, Lista),
   include(subsumes_term(Pal), Lista, Y),
   append(X, [Y], H1),
   retira_impossiveis(T, T1).

% 3.1.12 Predicado obtem_unicas/2----------------------------------------------
% Devolve uma lista "Unicas" que contem todas as palavras unicas para um
% espaco da lista "Pals_Possiveis".
% O predicado em questao verifica se o comprimento da lista de palavras
% candidatas a um espaco e unitario, e se for, adiciona o a lista.
%------------------------------------------------------------------------------
obtem_unicas([], []).
obtem_unicas([H | T], [H1 | T1]) :-
   nth1(2, H, Lista),
   length(Lista, Len),
   Len == 1,
   nth1(1, Lista, Pal),
   H1 = Pal,
   obtem_unicas(T, T1),
   !.
obtem_unicas([H | T], T1) :-
   nth1(2, H, Lista),
   length(Lista, Len),
   Len > 1,
   obtem_unicas(T, T1).

% 3.1.13 Predicado retira_unicas/2---------------------------------------------
% Devolve a lista de "Novas_Pals_Possiveis" que resulta de retirar as palavras
% que aparecem isoladas em linhas de outras linhas onde tambem estejam
% presentes, de "Pals_Possiveis".
% O predicado auxiliar retira as palavras unicas de uma linha.
% O predicado auxiliar1 aplica o predicado auxiliar a toda a lista.
%------------------------------------------------------------------------------
retira_unicas_aux([], _, []).
retira_unicas_aux([H | T], Unicas, T1) :-
   pertence(H, Unicas),
   retira_unicas_aux(T, Unicas, T1).
retira_unicas_aux([H | T], Unicas, [H1 | T1]) :-
   H1 = H,
   retira_unicas_aux(T, Unicas, T1).

retira_unicas_aux1([], [], _).
retira_unicas_aux1([H | T], [H1 | T1], Unicas) :-
   nth1(2, H, Lista),
   length(Lista, Len),
   Len == 1,
   H1 = H,
   retira_unicas_aux1(T, T1, Unicas).
retira_unicas_aux1([H | T], [H1 | T1], Unicas) :-
   nth1(2, H, Lista),
   length(Lista, Len),
   Len > 1,
   retira_unicas_aux(Lista, Unicas, Final),
   nth1(1, H, Cabeca),
   H1 = [Cabeca | [Final]],
   retira_unicas_aux1(T, T1, Unicas).

retira_unicas(Pals_Possiveis, Novas_Pals_Possiveis) :-
   obtem_unicas(Pals_Possiveis, Unicas),
   retira_unicas_aux1(Pals_Possiveis, Novas_Pals_Possiveis, Unicas),
   !.

% 3.1.14 Predicado simplifica/2------------------------------------------------
% Aplica sucessivamente os predicados os predicados atribui_comuns,
% retira_impossiveis e retira_unicas sobre uma lista de palvaras possiveis
% "Pals_Possiveis", ate nao se verificarem mais alteracoes, devolvendo
% "Novas_Pals_Possiveis".
%------------------------------------------------------------------------------
simplifica(Pals_Possiveis, Novas_Pals_Possiveis) :-
   atribui_comuns(Pals_Possiveis),
   retira_impossiveis(Pals_Possiveis, Nova),
   retira_unicas(Nova, Novas_Pals_Possiveis),
   Pals_Possiveis == Novas_Pals_Possiveis.
simplifica(Pals_Possiveis, Novas_Pals_Possiveis) :-
   atribui_comuns(Pals_Possiveis),
   retira_impossiveis(Pals_Possiveis, Nova),
   retira_unicas(Nova, Novas),
   simplifica(Novas, Novas_Pals_Possiveis).

% 3.1.15 Predicado inicializa/2------------------------------------------------
% Devolve uma lista das palavras possiveis "Pals_Possiveis" de um puzzle "Puz",
% recorrendo a aplicacao dos predicados definidos na seccao 3.1 .
%------------------------------------------------------------------------------
inicializa(Puz, Pals_Possiveis) :-
   nth1(1, Puz, Lst_Pals),
   nth1(2, Puz, Grelha),
   obtem_letras_palavras(Lst_Pals, Letras),
   espacos_puzzle(Grelha, Espacos),
   palavras_possiveis(Letras, Espacos, Pals),
   simplifica(Pals, Pals_Possiveis).

%=========Predicados para a resolucao de listas de palavras possiveis=========

% 3.2.1 Predicado escolhe_menos_alternativas/2---------------------------------
% Devolve uma lista "Escolha" que contem a primeira linha de uma lista de
% palavras "Pals_Possiveis" cujo o numero de palavras e menor e superior a 1.
% O predicado todas_len verifica que todas os elementos de uma lista tem um
% comprimento superior a 1.
% O predicado auxiliar seleciona cujo o comprimento e igual ao contador, que
% comeca em 2 e incrementa se nao houver nenhuma linha com uma lista de
% palavras com esse comprimento.
%------------------------------------------------------------------------------
todas_len([]) :-
   fail.
todas_len([H | _]) :-
   nth1(2, H, Pals),
   length(Pals, Len),
   Len > 1,
   !.
todas_len([_ | T]) :-
   todas_len(T).

escolhe_menos_alternativas_aux(Pals_Possiveis, [], Escolha, N) :-
   N1 is N + 1,
   escolhe_menos_alternativas_aux(Pals_Possiveis, Pals_Possiveis, Escolha, N1).
escolhe_menos_alternativas_aux(_, [H | _], Escolha, N) :-
   nth1(2, H, Pals),
   length(Pals, Len),
   Len == N,
   Escolha = H.
escolhe_menos_alternativas_aux(Pals_Possiveis, [_ | T], Escolha, N) :-
   escolhe_menos_alternativas_aux(Pals_Possiveis, T, Escolha, N),
   !.

escolhe_menos_alternativas(Pals_Possiveis, Escolha) :-
   todas_len(Pals_Possiveis),
   escolhe_menos_alternativas_aux(Pals_Possiveis, Pals_Possiveis, Escolha, 2).

% 3.2.2 Predicado experimenta_pal/3--------------------------------------------
% Devolve "Novas_Pals_Possiveis", que resulta da unificacacao do espaco de
% "Escolha" com cada uma das suas palavras. Escolha e uma linha de
% "Pals_Possiveis".
% O predicado em questao percorre a lista das palavras possiveis e iguala cada
% a linha da lista das novas palavras possiveis, exceto no caso em que a linha
% coincide com a escolha, caso em que acontece o que foi descrito.
%------------------------------------------------------------------------------
experimenta_pal(_, [], []).
experimenta_pal(Escolha, [H | T], [H1 | T1]) :-
   H == Escolha,
   nth1(1, H, Cabeca),
   nth1(2, H, Pre_Cauda),
   member(Pal, Pre_Cauda),
   Cabeca = Pal,
   append([Cabeca], [[Pal]], H1),
   experimenta_pal(Escolha, T, T1).
experimenta_pal(Escolha, [H | T], [H1 | T1]) :-
   H \== Escolha,
   H1 = H,
   experimenta_pal(Escolha, T, T1).

% 3.2.3 Predicado resolve_aux/2------------------------------------------------
% Aplica sucessivamente os predicados os predicados escolhe_menos_alternativas,
% experimenta_pal e simplifica sobre uma lista de palvaras possiveis
% "Pals_Possiveis", ate se esgotarem as alternativas, devolvendo
% "Novas_Pals_Possiveis".
%------------------------------------------------------------------------------
resolve_aux(Pals_Possiveis, Novas_Pals_Possiveis) :-
   escolhe_menos_alternativas(Pals_Possiveis, Escolha),
   !,
   experimenta_pal(Escolha, Pals_Possiveis, Novas),
   simplifica(Novas, Novas2),
   resolve_aux(Novas2, Novas_Pals_Possiveis),
   !.
resolve_aux(Novas_Pals_Possiveis, Novas_Pals_Possiveis) :-
   !.

%====================Predicados para a resolucao de puzzles====================

% 3.3.1 Predicado resolve/1----------------------------------------------------
% Resolve um puzzle recorrendo aos predicados inicializa/2 e resolve_aux/2.
%------------------------------------------------------------------------------
resolve(Puz) :-
   inicializa(Puz, Pals_Possiveis),
   resolve_aux(Pals_Possiveis, _).
