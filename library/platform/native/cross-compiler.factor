! :folding=none:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: cross-compiler
USE: arithmetic
USE: kernel
USE: lists
USE: parser
USE: stack
USE: stdio
USE: streams
USE: strings
USE: vectors
USE: vectors
USE: vocabularies
USE: words

IN: kernel
DEFER: getenv
DEFER: setenv
DEFER: save-image
DEFER: handle?
DEFER: room

IN: strings
DEFER: str=
DEFER: str-hashcode

IN: io-internals
DEFER: open-file
DEFER: server-socket
DEFER: close-fd
DEFER: accept-fd
DEFER: read-line-fd-8
DEFER: write-fd-8
DEFER: flush-fd
DEFER: shutdown-fd

IN: words
DEFER: <word>
DEFER: word-primitive
DEFER: set-word-primitive
DEFER: word-parameter
DEFER: set-word-parameter
DEFER: word-plist
DEFER: set-word-plist

IN: cross-compiler

: primitives, ( -- )
    1 [
        execute
        call
        ifte
        cons?
        cons
        car
        cdr
        rplaca
        rplacd
        vector?
        <vector>
        vector-length
        set-vector-length
        vector-nth
        set-vector-nth
        string?
        str-length
        str-nth
        str-compare
        str=
        str-hashcode
        index-of*
        substring
        sbuf?
        <sbuf>
        sbuf-length
        set-sbuf-length
        sbuf-nth
        set-sbuf-nth
        sbuf-append
        sbuf>str
        fixnum?
        bignum?
        +
        -
        *
        /
        mod
        /mod
        bitand
        bitor
        bitxor
        bitnot
        shift>
        shift<
        <
        <=
        >
        >=
        word?
        <word>
        word-primitive
        set-word-primitive
        word-parameter
        set-word-parameter
        word-plist
        set-word-plist
        drop
        dup
        swap
        over
        pick
        nip
        tuck
        rot
        >r
        r>
        eq?
        getenv
        setenv
        open-file
        garbage-collection
        save-image
        datastack
        callstack
        set-datastack
        set-callstack
        handle?
        exit*
        server-socket
        close-fd
        accept-fd
        read-line-fd-8
        write-fd-8
        flush-fd
        shutdown-fd
        room
    ] [
        swap succ tuck primitive,
    ] each drop ;

: worddef, ( word -- )
    dup compound-or-compiled? [
        dup word-of-worddef swap compound>list compound,
    ] [
        drop
    ] ifte ;

: version, ( -- )
    "version" [ "kernel" ] search
    version unit
    <compound>
    worddef, ;

: cross-compile ( quot -- )
    [ dup worddef? [ worddef, ] [ drop ] ifte ] each ;

: cross-compile-resource ( resource -- )
    parse-resource cross-compile ;

: make-image ( -- )
    #! Make an image for the C interpreter.
    [
        "/library/platform/native/boot.factor" run-resource
    ] with-image

    ! Uncomment this on sparc and powerpc.
    ! "big-endian" on
    "factor.image" write-image ;
