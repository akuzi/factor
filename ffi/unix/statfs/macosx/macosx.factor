! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct literals
unix.ffi unix.types ;
in: unix.statfs.macosx

CONSTANT: MNT_RDONLY  0x00000001 ;
CONSTANT: MNT_SYNCHRONOUS 0x00000002 ;
CONSTANT: MNT_NOEXEC  0x00000004 ;
CONSTANT: MNT_NOSUID  0x00000008 ;
CONSTANT: MNT_NODEV   0x00000010 ;
CONSTANT: MNT_UNION   0x00000020 ;
CONSTANT: MNT_ASYNC   0x00000040 ;
CONSTANT: MNT_EXPORTED 0x00000100 ;
CONSTANT: MNT_QUARANTINE  0x00000400 ;
CONSTANT: MNT_LOCAL   0x00001000 ;
CONSTANT: MNT_QUOTA   0x00002000 ;
CONSTANT: MNT_ROOTFS  0x00004000 ;
CONSTANT: MNT_DOVOLFS 0x00008000 ;
CONSTANT: MNT_DONTBROWSE  0x00100000 ;
CONSTANT: MNT_IGNORE_OWNERSHIP 0x00200000 ;
CONSTANT: MNT_AUTOMOUNTED 0x00400000 ;
CONSTANT: MNT_JOURNALED   0x00800000 ;
CONSTANT: MNT_NOUSERXATTR 0x01000000 ;
CONSTANT: MNT_DEFWRITE    0x02000000 ;
CONSTANT: MNT_MULTILABEL  0x04000000 ;
CONSTANT: MNT_NOATIME 0x10000000 ;
ALIAS: MNT_UNKNOWNPERMISSIONS MNT_IGNORE_OWNERSHIP ;

CONSTANT: MNT_VISFLAGMASK
    flags{
        MNT_RDONLY MNT_SYNCHRONOUS MNT_NOEXEC
        MNT_NOSUID MNT_NODEV MNT_UNION
        MNT_ASYNC MNT_EXPORTED MNT_QUARANTINE
        MNT_LOCAL MNT_QUOTA
        MNT_ROOTFS MNT_DOVOLFS MNT_DONTBROWSE
        MNT_IGNORE_OWNERSHIP MNT_AUTOMOUNTED MNT_JOURNALED
        MNT_NOUSERXATTR MNT_DEFWRITE MNT_MULTILABEL MNT_NOATIME
    } ;

CONSTANT: MNT_UPDATE  0x00010000 ;
CONSTANT: MNT_RELOAD  0x00040000 ;
CONSTANT: MNT_FORCE   0x00080000 ;

CONSTANT: MNT_CMDFLAGS flags{ MNT_UPDATE MNT_RELOAD MNT_FORCE } ;

CONSTANT: VFS_GENERIC 0 ;
CONSTANT: VFS_NUMMNTOPS 1 ;
CONSTANT: VFS_MAXTYPENUM 1 ;
CONSTANT: VFS_CONF 2 ;
CONSTANT: VFS_SET_PACKAGE_EXTS 3 ;

CONSTANT: MNT_WAIT    1 ;
CONSTANT: MNT_NOWAIT  2 ;

CONSTANT: VFS_CTL_VERS1   0x01 ;

CONSTANT: VFS_CTL_STATFS  0x00010001 ;
CONSTANT: VFS_CTL_UMOUNT  0x00010002 ;
CONSTANT: VFS_CTL_QUERY   0x00010003 ;
CONSTANT: VFS_CTL_NEWADDR 0x00010004 ;
CONSTANT: VFS_CTL_TIMEO   0x00010005 ;
CONSTANT: VFS_CTL_NOLOCKS 0x00010006 ;

STRUCT: vfsquery
    { vq_flags uint32_t }
    { vq_spare uint32_t[31] } ;

CONSTANT: VQ_NOTRESP  0x0001 ;
CONSTANT: VQ_NEEDAUTH 0x0002 ;
CONSTANT: VQ_LOWDISK  0x0004 ;
CONSTANT: VQ_MOUNT    0x0008 ;
CONSTANT: VQ_UNMOUNT  0x0010 ;
CONSTANT: VQ_DEAD     0x0020 ;
CONSTANT: VQ_ASSIST   0x0040 ;
CONSTANT: VQ_NOTRESPLOCK  0x0080 ;
CONSTANT: VQ_UPDATE   0x0100 ;
CONSTANT: VQ_FLAG0200 0x0200 ;
CONSTANT: VQ_FLAG0400 0x0400 ;
CONSTANT: VQ_FLAG0800 0x0800 ;
CONSTANT: VQ_FLAG1000 0x1000 ;
CONSTANT: VQ_FLAG2000 0x2000 ;
CONSTANT: VQ_FLAG4000 0x4000 ;
CONSTANT: VQ_FLAG8000 0x8000 ;

CONSTANT: NFSV4_MAX_FH_SIZE 128 ;
CONSTANT: NFSV3_MAX_FH_SIZE 64 ;
CONSTANT: NFSV2_MAX_FH_SIZE 32 ;
ALIAS: NFS_MAX_FH_SIZE NFSV4_MAX_FH_SIZE ;

CONSTANT: MFSNAMELEN 15 ;
CONSTANT: MNAMELEN 90 ;
CONSTANT: MFSTYPENAMELEN 16 ;

STRUCT: fsid_t
    { val int32_t[2] } ;

STRUCT: statfs64
    { f_bsize uint32_t }
    { f_iosize int32_t }
    { f_blocks uint64_t }
    { f_bfree uint64_t }
    { f_bavail uint64_t }
    { f_files uint64_t }
    { f_ffree uint64_t }
    { f_fsid fsid_t }
    { f_owner uid_t }
    { f_type uint32_t }
    { f_flags uint32_t }
    { f_fssubtype uint32_t }
    { f_fstypename { char MFSTYPENAMELEN } }
    { f_mntonname { char MAXPATHLEN } }
    { f_mntfromname { char MAXPATHLEN } }
    { f_reserved uint32_t[8] } ;

FUNCTION-ALIAS: statfs64-func int statfs64 ( c-string path, statfs64* buf ) ;
FUNCTION: int getmntinfo64 ( statfs64** mntbufp, int flags ) ;