! Copyright (C) 2010 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.destructors alien.libraries alien.syntax
combinators gobject-introspection literals math system vocabs ;
in: gobject.ffi

! these two are needed for the definition of GError and others.
! otherwise we generate GError and some others in this vocab as well.
<< "glib.ffi" require >>
use: glib.ffi

library: gobject

<< "gobject" {
    { [ os windows? ] [ "libgobject-2.0-0.dll" ] }
    { [ os macosx? ] [ "libgobject-2.0.dylib" ] }
    { [ os unix? ] [ "libgobject-2.0.so" ] }
} cond cdecl add-library >>

IMPLEMENT-STRUCTS: GValue GParamSpecVariant ;

gir: vocab:gobject/GObject-2.0.gir

forget: GIOCondition
forget: G_IO_IN
forget: G_IO_OUT
forget: G_IO_PRI
forget: G_IO_ERR
forget: G_IO_HUP
forget: G_IO_NVAL

destructor: g_object_unref

CONSTANT: G_TYPE_INVALID $[ 0 2 shift ] ;
CONSTANT: G_TYPE_NONE $[ 1 2 shift ] ;
CONSTANT: G_TYPE_INTERFACE $[ 2 2 shift ] ;
CONSTANT: G_TYPE_CHAR $[ 3 2 shift ] ;
CONSTANT: G_TYPE_UCHAR $[ 4 2 shift ] ;
CONSTANT: G_TYPE_BOOLEAN $[ 5 2 shift ] ;
CONSTANT: G_TYPE_INT $[ 6 2 shift ] ;
CONSTANT: G_TYPE_UINT $[ 7 2 shift ] ;
CONSTANT: G_TYPE_LONG $[ 8 2 shift ] ;
CONSTANT: G_TYPE_ULONG $[ 9 2 shift ] ;
CONSTANT: G_TYPE_INT64 $[ 10 2 shift ] ;
CONSTANT: G_TYPE_UINT64 $[ 11 2 shift ] ;
CONSTANT: G_TYPE_ENUM $[ 12 2 shift ] ;
CONSTANT: G_TYPE_FLAGS $[ 13 2 shift ] ;
CONSTANT: G_TYPE_FLOAT $[ 14 2 shift ] ;
CONSTANT: G_TYPE_DOUBLE $[ 15 2 shift ] ;
CONSTANT: G_TYPE_STRING $[ 16 2 shift ] ;
CONSTANT: G_TYPE_POINTER $[ 17 2 shift ] ;
CONSTANT: G_TYPE_BOXED $[ 18 2 shift ] ;
CONSTANT: G_TYPE_PARAM $[ 19 2 shift ] ;
CONSTANT: G_TYPE_OBJECT $[ 20 2 shift ] ;

! Macros

: g_signal_connect ( instance detailed_signal c_handler data -- result )
    f 0 g_signal_connect_data ;

: g_signal_connect_after ( instance detailed_signal c_handler data -- result )
    f G_CONNECT_AFTER g_signal_connect_data ;

: g_signal_connect_swapped ( instance detailed_signal c_handler data -- result )
    f G_CONNECT_SWAPPED g_signal_connect_data ;