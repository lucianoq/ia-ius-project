#!/usr/local/bin/yap -L --
#
# .
:- consult('../aleph.pl').
:- read_all('mlj_f6').
:- induce.
:- write_rules('mlj_f6.rul').

