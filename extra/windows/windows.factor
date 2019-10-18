! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax alien.c-types io kernel math
namespaces parser prettyprint words windows.types
windows.kernel32 ;
IN: windows

! You must LocalFree the return value!
FUNCTION: void* error_message ( DWORD id ) ;

: (win32-error-string) ( n -- string )
    error_message
    dup alien>u16-string
    swap LocalFree drop ;

: win32-error-string ( -- str )
    GetLastError (win32-error-string) ;

: (win32-error) ( n -- )
    dup zero? [
        drop
    ] [
        win32-error-string throw
    ] if ;

: win32-error ( -- )
    GetLastError (win32-error) ;

! For use with shared unix backend
: io-error ( n -- )
    zero? [ win32-error ] unless ;

: win32-error=0/f dup zero? swap f = or [ win32-error ] when ;
: win32-error>0 0 > [ win32-error ] when ;
: win32-error<0 0 < [ win32-error ] when ;
: win32-error<>0 zero? [ win32-error ] unless ;

: lo-word ( wparam -- lo ) <short> *short ; inline
: hi-word ( wparam -- hi ) -16 shift lo-word ; inline

