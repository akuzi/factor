! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-text
USING: gadgets gadgets-controls gadgets-panes generic hashtables
help io kernel namespaces prettyprint styles threads ;

TUPLE: interactor output continuation busy? ;

C: interactor ( output -- gadget )
    [ set-interactor-output ] keep
    f <field> over set-gadget-delegate
    dup dup set-control-self ;

M: interactor graft* ( interactor -- )
    f over set-interactor-busy? delegate graft* ;

: interactor-eval ( string interactor -- )
    t over set-interactor-busy?
    interactor-continuation schedule-thread-with ;

SYMBOL: structured-input

: interactor-call ( quot gadget -- )
    dup interactor-busy? [
        2drop
    ] [
        dup interactor-output [
            "Command: " write over short.
        ] with-stream*
        >r structured-input set-global
        "\"structured-input\" \"gadgets-text\" lookup get-global call"
        r> interactor-eval
    ] if ;

: print-input ( string interactor -- )
    interactor-output [
        H{ { font-style bold } } [
            dup <input> presented associate
            [ write ] with-nesting terpri
        ] with-style
    ] with-stream* ;

: interactor-commit ( interactor -- )
    dup interactor-busy? [
        drop
    ] [
        dup field-commit
        over control-model clear-doc
        swap 2dup print-input interactor-eval
    ] if ;

interactor H{
    { T{ key-down f f "RETURN" } [ interactor-commit ] }
    { T{ key-down f { C+ } "b" } [ interactor-output pane-clear ] }
    { T{ key-down f { C+ } "d" } [ f swap interactor-eval ] }
} set-gestures

M: interactor stream-readln ( interactor -- line )
    f over set-interactor-busy?
    [ over set-interactor-continuation stop ] callcc1 nip ;
