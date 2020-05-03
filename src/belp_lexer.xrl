Definitions.

VAR   = ([A-Za-z_][0-9a-zA-Z_]*)
CMP   = (=|!=|~|!~)
STR   = ('[^'\n]*'|"[^"\n]*")
WS    = ([\000-\s]|%.*)

Rules.
false   : {token, {false,    TokenLine}}.
FALSE   : {token, {false,    TokenLine}}.
true    : {token, {true,     TokenLine}}.
TRUE    : {token, {true,     TokenLine}}.
or      : {token, {or_op,    TokenLine, list_to_atom(TokenChars)}}.
OR      : {token, {or_op,    TokenLine, list_to_atom(TokenChars)}}.
and     : {token, {and_op,   TokenLine, list_to_atom(TokenChars)}}.
AND     : {token, {and_op,   TokenLine, list_to_atom(TokenChars)}}.
not     : {token, {not_op,   TokenLine, list_to_atom(TokenChars)}}.
NOT     : {token, {not_op,   TokenLine, list_to_atom(TokenChars)}}.
!       : {token, {not_op,   TokenLine, list_to_atom(TokenChars)}}.
{CMP}   : {token, {cmp_op,   TokenLine, list_to_atom(TokenChars)}}.
{VAR}   : {token, {var,      TokenLine, list_to_binary(TokenChars)}}.
{STR}   : {token, {string,   TokenLine, list_to_binary(strip(TokenChars, TokenLen))}}.
[()]    : {token, {list_to_atom(TokenChars), TokenLine}}.
{WS}+   : skip_token.

Erlang code.

strip(TokenChars, TokenLen) ->
    lists:sublist(TokenChars, 2, TokenLen - 2).
