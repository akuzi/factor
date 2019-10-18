IN: temporary
USING: alien io.buffers kernel kernel.private libc
sequences tools.test ;

: buffer-set ( string buffer -- )
    2dup buffer-ptr string>memory
    >r length r> buffer-reset ;

: string>buffer ( string -- buffer )
    dup length <buffer> tuck buffer-set ;

[ "" 65536 ] [
    65536 <buffer>
    dup (buffer>>)
    over buffer-capacity
    rot buffer-free
] unit-test

[ "hello world" "" ] [
    "hello world" string>buffer
    dup (buffer>>)
    0 pick buffer-reset
    over (buffer>>)
    rot buffer-free
] unit-test

[ "hello" ] [
    "hello world" string>buffer
    5 over buffer> swap buffer-free
] unit-test

[ 11 ] [
    "hello world" string>buffer
    [ buffer-length ] keep buffer-free
] unit-test

[ "hello world" ] [
    "hello" 1024 <buffer> [ buffer-set ] keep
    " world" over >buffer
    dup (buffer>>) swap buffer-free
] unit-test

[ CHAR: e ] [
    "hello" string>buffer
    1 over buffer-consume [ buffer-pop ] keep buffer-free
] unit-test

[ "hello" CHAR: \r ] [
    "hello\rworld" string>buffer
    "\r" over buffer-until
    rot buffer-free
] unit-test

[ "hello" CHAR: \r ] [
    "hello\rworld" string>buffer
    "\n\r" over buffer-until
    rot buffer-free
] unit-test

[ "hello\rworld" f ] [
    "hello\rworld" string>buffer
    "X" over buffer-until
    rot buffer-free
] unit-test

100 <buffer>
[ dup 1000 swap n>buffer ] unit-test-fails
buffer-free
