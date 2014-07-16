:- module( persona, 
            [ nome/1
            , nome/2
            , allnome/1
            , cognome/1
            , cognome/2
            , allcognome/1
            , persona/2
            , persona/3
            , allpersona/1
            , rispersona/0
            , soggetto/2
            , soggetto/3
            , allsoggetto/1
            , rissoggetto/0
            , giudice/2
            , giudice/3
            , allgiudice/1
            , risgiudice/0
            , curatore/2
            , curatore/3
            , allcuratore/1
            , riscuratore/0
            , tag_nome/0
            , tag_cognome/0
            , tag_persona/0
            , tag_soggetto/0
            , tag_giudice/0
            , tag_curatore/0
            ] 
).

:- consult('persona_kb.pl').

:- use_module(kb).

%% Trova la prima persona
persona(Cognome, Nome) :-
    kb:tag(_, persona(Cognome, Nome)).

persona(IDTag, Cognome, Nome) :-
    kb:tag(IDTag, persona(Cognome, Nome)).

%% Trova il primo cognome 
cognome(Cognome) :-
    kb:tag(_, cognome(Cognome)).

cognome(IDTag, Cognome) :-
    kb:tag(IDTag, cognome(Cognome)).

%% Trova il primo nome
nome(Nome) :-
    kb:tag(_, nome(Nome)).

nome(IDTag, Nome) :-
    kb:tag(IDTag, nome(Nome)).    

%% Trova il primo soggetto    
soggetto(Cognome, Nome) :-
    kb:tag(_, soggetto(Cognome, Nome)).

soggetto(IDTag, Cognome, Nome) :-
    kb:tag(IDTag, soggetto(Cognome, Nome)).

%% Trova il primo giudice    
giudice(Cognome, Nome) :-
    kb:tag(_, giudice(Cognome, Nome)).

giudice(IDTag, Cognome, Nome) :-
    kb:tag(IDTag, giudice(Cognome, Nome)).

%% Trova il primo curatore    
curatore(Cognome, Nome) :-
    kb:tag(_, curatore(Cognome, Nome)).

curatore(IDTag, Cognome, Nome) :-
    kb:tag(IDTag, curatore(Cognome, Nome)).

%% Trova tutte le persone
allpersona(ListaPersone) :-
    findall((IDTag, Cognome, Nome) ,kb:tag(IDTag, persona(Cognome,Nome)), ListaPersone).

%% Risultati
rispersona :-
    \+kb:vuole(persona), !.
rispersona :-
    allpersona( ListaPersone ),
    write('Le persone trovate sono: '), 
    write( ListaPersone ).

%% Trova tutti i cognomi
allcognome(ListaCognomi) :-
    findall((IDTag, Cognome) ,kb:tag(IDTag, cognome(Cognome)), ListaCognomi).

%% Trova tutti i nomi
allnome(ListaNomi) :-
    findall((IDTag, Nome) ,kb:tag(IDTag, nome(Nome)), ListaNomi).

%% Trova tutti i soggetti
allsoggetto(ListaSoggetti) :-
    findall((IDTag, Cognome, Nome) ,kb:tag(IDTag, soggetto(Cognome, Nome)), ListaSoggetti).

%% Risultati
rissoggetto :-
    \+kb:vuole(soggetto), !.
rissoggetto :-
    allsoggetto( ListaSoggetti ),
    write('I soggetti trovati sono: '), 
    write( ListaSoggetti ).

%% Trova tutti i giudici
allgiudice(ListaGiudici) :-
    findall((IDTag, Cognome, Nome) ,kb:tag(IDTag, giudice(Cognome, Nome)), ListaGiudici).

%% Risultati
risgiudice :-
    \+kb:vuole(giudice), !.
risgiudice :-
    allgiudice( ListaGiudici ),
    write('I giudici trovati sono: '), 
    write( ListaGiudici ).

%% Trova tutti i curatori
allcuratore(ListaCuratori) :-
    findall((IDTag, Cognome, Nome) ,kb:tag(IDTag, curatore(Cognome, Nome)), ListaCuratori).

%% Risultati
riscuratore :-
    \+kb:vuole(curatore), !.
riscuratore :-
    allcuratore( ListaCuratori ),
    write('I curatori trovati sono: '), 
    write( ListaCuratori ).

%% Tagga tutte le persone
tag_persona :-
    \+kb:vuole(persona), !.
tag_persona :-
    kb:fatto(persona), !.
tag_persona :-
    tag_cognome,
    tag_nome,
    findall((X,Y), tag_persona(X,Y), _),
    asserta(kb:fatto(persona)).

tag_persona(C, N) :-
    kb:tag(IDTag1, cognome(C)),
    kb:tag(IDTag2, nome(N)),
    kb:next(IDTag1, IDTag2),
    
    findall( Precedente, kb:next(Precedente, IDTag1), ListaPrecedenti ),
    findall( Successivo, kb:next(IDTag2, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[PERSONA] Presenza nel documento di : ',C,N],' ',Spiegazione),
    Dipendenze=[IDTag1, IDTag2],
    assertTag(persona(C, N), ListaPrecedenti, ListaSuccessivi, Spiegazione, Dipendenze).

tag_persona(C, N) :-
    kb:tag(IDTag1, cognome(C)),
    kb:tag(IDTag2, nome(N)),
    kb:next(IDTag2, IDTag1),
    
    findall( Precedente, kb:next(Precedente, IDTag2), ListaPrecedenti ),
    findall( Successivo, kb:next(IDTag1, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[PERSONA] Presenza nel documento di : ',C,N],' ',Spiegazione),
    Dipendenze=[IDTag1, IDTag2],
    assertTag(persona(C, N), ListaPrecedenti, ListaSuccessivi, Spiegazione, Dipendenze).


%% Tagga tutti i cognomi
tag_cognome :-
    kb:fatto(cognome), !.
tag_cognome :- 
    findall(X, tag_cognome(X), _),
    asserta(kb:fatto(cognome)).

tag_cognome(Cognome) :- 
    kb:next(IDToken1, IDToken2),
    kb:token(IDToken1, Token1),
    kb:token(IDToken2, Token2),
    cognome_kb(Token1, Token2),
    atomic_list_concat([Token1, Token2], ' ', Cognome),
    findall( Precedente, kb:next(Precedente, IDToken1), ListaPrecedenti ),
    findall( Successivo, kb:next(IDToken2, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[COGNOME] Presenza nel documento di : ',Cognome],' ',Spiegazione),
    assertTag(cognome(Cognome), ListaPrecedenti, ListaSuccessivi, Spiegazione, []).

tag_cognome(Cognome) :- 
    kb:token(IDToken1, Cognome),
    cognome_kb(Cognome),
    findall( Precedente, kb:next(Precedente, IDToken1), ListaPrecedenti ),
    findall( Successivo, kb:next(IDToken1, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[COGNOME] Presenza nel documento di : ',Cognome],' ',Spiegazione),
    assertTag(cognome(Cognome), ListaPrecedenti, ListaSuccessivi, Spiegazione, []).

cognome_kb(A, B) :-
	cognome_kb(A),
	cognome_kb(B).

cognome_kb(A, B) :-
    atomic_list_concat([A, B], ' ', C),
    cognome_kb(C).

%% Tagga tutti i nomi
tag_nome :-
    kb:fatto(nome), !.

tag_nome :- 
    findall(X, tag_nome(X), _),
    asserta(kb:fatto(nome)).

tag_nome(Nome) :- 
    kb:next(IDToken1, IDToken2),
    kb:next(IDToken2, IDToken3),
    kb:token(IDToken1, Token1),
    kb:token(IDToken2, Token2),
    kb:token(IDToken3, Token3),
    nome_kb(Token1, Token2, Token3),
    atomic_list_concat([Token1, Token2, Token3], ' ', Nome),
    findall( Precedente, kb:next(Precedente, IDToken1), ListaPrecedenti ),
    findall( Successivo, kb:next(IDToken3, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[NOME] Presenza nel documento di : ',Nome],' ',Spiegazione),
    assertTag(nome(Nome), ListaPrecedenti, ListaSuccessivi, Spiegazione, []).

tag_nome(Nome) :- 
    kb:next(IDToken1, IDToken2),
    kb:token(IDToken1, Token1),
    kb:token(IDToken2, Token2),
    nome_kb(Token1, Token2),
    atomic_list_concat([Token1, Token2], ' ', Nome),
    findall( Precedente, kb:next(Precedente, IDToken1), ListaPrecedenti ),
    findall( Successivo, kb:next(IDToken2, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[NOME] Presenza nel documento di : ',Nome],' ',Spiegazione),
    assertTag(nome(Nome), ListaPrecedenti, ListaSuccessivi, Spiegazione, []).

tag_nome(Nome) :- 
    kb:token(IDToken1, Nome),
    nome_kb(Nome),
    findall( Precedente, kb:next(Precedente, IDToken1), ListaPrecedenti ),
    findall( Successivo, kb:next(IDToken1, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[NOME] Presenza nel documento di : ',Nome],' ',Spiegazione),
    assertTag(nome(Nome), ListaPrecedenti, ListaSuccessivi, Spiegazione, []).

nome_kb(A,B,C) :- 
    nome_kb(A),
    nome_kb(B),
    nome_kb(C).

nome_kb(A,B) :-
    nome_kb(A),
    nome_kb(B).

%% Tagga tutti i soggetti
tag_soggetto :-
    kb:fatto(soggetto), !.
tag_soggetto :- 
    tag_persona,
    findall((C,N), tag_soggetto(C,N), _),
    asserta(kb:fatto(soggetto)).

tag_soggetto(C,N) :-
    kb:tag(IDTag, persona(C,N)),
    kb:token(IDToken, Token),
    simbolo_soggetto(Token),
    stessa_frase(IDToken, IDTag),
%    !,    
    atomic_list_concat(['[SOGGETTO] Presenza nel documento dell termine',Token,'e della persona',C,N,' nella stessa frase'],' ',Spiegazione),
    assertTag(soggetto(C,N), Spiegazione, [IDTag]).

simbolo_soggetto('sottoscritto').
simbolo_soggetto('sottoscritta').

%% Tagga tutti i curatori
tag_curatore :-
    kb:fatto(curatore), !.
tag_curatore :- 
    tag_persona,
    findall((C,N), tag_curatore(C,N), _),
    asserta(kb:fatto(curatore)).
tag_curatore(C,N) :-
    kb:tag(IDTag, persona(C,N)),
    kb:token(IDToken, Token),
    simbolo_curatore(Token),
    stessa_frase(IDToken, IDTag),
%    !,
    atomic_list_concat(['[CURATORE] Presenza nel documento dell termine',Token,'e della persona',C,N,' nella stessa frase'],' ',Spiegazione),
    assertTag(curatore(C,N), Spiegazione, [IDTag]).

simbolo_curatore('curatore').
simbolo_curatore('commissario').

%% Tagga tutti i giudici
tag_giudice :-
    kb:fatto(giudice), !.
tag_giudice :- 
    tag_persona,
    findall(_, tag_simbolo_curatore(_), _),
    findall(_, tag_simbolo_soggetto(_), _),
    findall(_, tag_simbolo_giudice(_), _),
    findall((C,N), tag_giudice(C,N), _),
    asserta(kb:fatto(giudice)).

tag_giudice(C,N) :-
    kb:tag(IDTag, persona(C,N)),
    kb:token(IDToken, Token),
    simbolo_giudice(Token),
    stessa_frase(IDToken, IDTag),
%    !,
    atomic_list_concat(['[GIUDICE] Presenza nel documento dell termine',Token,'e della persona',C,N,' nella stessa frase'],' ',Spiegazione),
    assertTag(giudice(C,N), Spiegazione, [IDTag]).

simbolo_giudice('giudice').

%% Tagga parola giudice 
tag_simbolo_giudice(Token) :- 
    kb:token(IDToken, Token),
    simbolo_giudice(Token),
    findall( Precedente, kb:next(Precedente, IDToken), ListaPrecedenti ),
    findall( Successivo, kb:next(IDToken, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[GIUDICE] Presenza nel documento del termine',Token],' ',Spiegazione),
    assertTag(simbolo_giudice(Token), ListaPrecedenti, ListaSuccessivi, Spiegazione, []).

%% Tagga parola curatore 
tag_simbolo_curatore(Token) :- 
    kb:token(IDToken, Token),
    simbolo_curatore(Token),
    findall( Precedente, kb:next(Precedente, IDToken), ListaPrecedenti ),
    findall( Successivo, kb:next(IDToken, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[CURATORE] Presenza nel documento del termine',Token],' ',Spiegazione),
    assertTag(simbolo_curatore(Token), ListaPrecedenti, ListaSuccessivi, Spiegazione, []).

%% Tagga parola soggetto
tag_simbolo_soggetto(Token) :- 
    kb:token(IDToken, Token),
    simbolo_soggetto(Token),
    findall( Precedente, kb:next(Precedente, IDToken), ListaPrecedenti ),
    findall( Successivo, kb:next(IDToken, Successivo), ListaSuccessivi ),
    atomic_list_concat(['[SOGGETTO] Presenza nel documento del termine',Token],' ',Spiegazione),
    assertTag(simbolo_soggetto(Token), ListaPrecedenti, ListaSuccessivi, Spiegazione, []).

