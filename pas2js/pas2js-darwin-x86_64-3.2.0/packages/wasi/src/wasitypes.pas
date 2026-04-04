unit wasitypes;

{$mode ObjFPC}
{$INTERFACES CORBA}

interface

uses JS;

Type
  TWasmMemoryLocation = Integer;
  // The imports as expected by WASI
  IWASI = interface ['{A03AC61B-3C68-4DA8-AC4F-53ED01814673}']
    // Please keep these sorted !!
    function args_get(argv, argvBuf : TWasmMemoryLocation) : NativeInt;
    function args_sizes_get(argc, argvBufSize : TWasmMemoryLocation) : NativeInt;
    function clock_res_get(clockId, resolution: NativeInt): NativeInt;

    function clock_time_get(clockId, precision : NativeInt; time: TWasmMemoryLocation): NativeInt;
    function environ_get(environ, environBuf : TWasmMemoryLocation) : NativeInt;
    function environ_sizes_get(environCount, environBufSize : TWasmMemoryLocation) : NativeInt;
    function fd_advise (fd, offset, len, advice : NativeInt) : NativeInt;
    function fd_allocate (fd, offset, len : NativeInt) : NativeInt;
    function fd_close(fd : NativeInt) : NativeInt;
    function fd_datasync (fd : NativeInt) : NativeInt;
    function fd_fdstat_get(fd : NativeInt; bufPtr: TWasmMemoryLocation) : NativeInt;
    function fd_fdstat_set_flags (fd, flags: NativeInt) : NativeInt;
    function fd_fdstat_set_rights (fd, fsRightsBase, fsRightsInheriting: NativeInt) : NativeInt;
    function fd_filestat_get (fd : NativeInt; bufPtr: TWasmMemoryLocation) : NativeInt;
    function fd_filestat_set_size (fd, stSize: NativeInt) : NativeInt;
    function fd_filestat_set_times (fd, stAtim, stMtim, fstflags: NativeInt) : NativeInt;
    function fd_pread(fd: NativeInt; iovs : TWasmMemoryLocation; iovsLen, offset: NativeInt; nread : TWasmMemoryLocation) : NativeInt;
    function fd_prestat_dir_name(fd : NativeInt; pathPtr : TWasmMemoryLocation; pathLen : NativeInt) : NativeInt;
    function fd_prestat_get(fd: NativeInt; bufPtr: TWasmMemoryLocation) : NativeInt;
    function fd_pwrite(fd, iovs, iovsLen, offset, nwritten : NativeInt) : NativeInt;
    function fd_read(fd: NativeInt; iovs : TWasmMemoryLocation; iovsLen: NativeInt; nread : TWasmMemoryLocation) : NativeInt;
    function fd_readdir(fd : NativeInt; bufPtr: TWasmMemoryLocation; bufLen, cookie: NativeInt; bufusedPtr : TWasmMemoryLocation) : NativeInt;
    function fd_renumber(afrom,ato : NativeInt) : NativeInt;
    function fd_seek(fd, offset, whence : NativeInt; newOffsetPtr : TWasmMemoryLocation) : NativeInt;
    function fd_sync(fd : NativeInt) : NativeInt;
    function fd_tell(fd: NativeInt; offsetPtr: TWasmMemoryLocation): NativeInt;
    function fd_write(fd,iovs,iovsLen,nwritten : NativeInt) : NativeInt;
    function path_create_directory (fd, pathPtr, pathLen : NativeInt) : NativeInt;
    function path_filestat_get (fd, flags : NativeInt; pathPtr : TWasmMemoryLocation;  pathLen : Nativeint; bufPtr : TWasmMemoryLocation) : NativeInt;
    function path_filestat_set_times(fd, fstflags, pathPtr, pathLen, stAtim, stMtim : NativeInt) : NativeInt;
    function path_link (oldFd, oldFlags : NativeInt; oldPath: TWasmMemoryLocation; oldPathLen, newFd : NativeInt; NewPath: TWasmMemoryLocation; newPathLen: NativeInt) : NativeInt;
    function path_open (dirfd, dirflags : NativeInt; pathPtr : TWasmMemoryLocation; pathLen, oflags, fsRightsBase, fsRightsInheriting, fsFlags : NativeInt; fd : TWasmMemoryLocation) : NativeInt;
    function path_readlink (fd: NativeInt; pathPtr: TWasmMemoryLocation; pathLen: NativeInt; buf: TWasmMemoryLocation; bufLen : NativeInt; bufused : TWasmMemoryLocation) : NativeInt;
    function path_remove_directory (fd : NativeInt; pathPtr: TWasmMemoryLocation; pathLen : NativeInt) : NativeInt;
    function path_rename (oldFd, oldPath, oldPathLen, newFd, newPath, newPathLen : NativeInt) : NativeInt;
    function path_symlink (oldPath, oldPathLen, fd, newPath, newPathLen : NativeInt) : NativeInt;
    function path_unlink_file (fd, pathPtr, pathLen : NativeInt) : NativeInt;
    function poll_oneoff(sin, sout, nsubscriptions, nevents : NativeInt) : NativeInt;
    function proc_exit(rval : NativeInt) : NativeInt;
    function proc_raise (sig : NativeInt) : NativeInt;
    function random_get (bufPtr, bufLen: NativeInt) : NativeInt;
    function sched_yield() : NativeInt;
    function sock_recv() : NativeInt;
    function sock_send() : NativeInt;
    function sock_shutdown() : NativeInt;
  end;


Const
  WASI_ESUCCESS = 0;
  WASI_E2BIG = 1;
  WASI_EACCES = 2;
  WASI_EADDRINUSE = 3;
  WASI_EADDRNOTAVAIL = 4;
  WASI_EAFNOSUPPORT = 5;
  WASI_EAGAIN = 6;
  WASI_EALREADY = 7;
  WASI_EBADF = 8;
  WASI_EBADMSG = 9;
  WASI_EBUSY = 10;
  WASI_ECANCELED = 11;
  WASI_ECHILD = 12;
  WASI_ECONNABORTED = 13;
  WASI_ECONNREFUSED = 14;
  WASI_ECONNRESET = 15;
  WASI_EDEADLK = 16;
  WASI_EDESTADDRREQ = 17;
  WASI_EDOM = 18;
  WASI_EDQUOT = 19;
  WASI_EEXIST = 20;
  WASI_EFAULT = 21;
  WASI_EFBIG = 22;
  WASI_EHOSTUNREACH = 23;
  WASI_EIDRM = 24;
  WASI_EILSEQ = 25;
  WASI_EINPROGRESS = 26;
  WASI_EINTR = 27;
  WASI_EINVAL = 28;
  WASI_EIO = 29;
  WASI_EISCONN = 30;
  WASI_EISDIR = 31;
  WASI_ELOOP = 32;
  WASI_EMFILE = 33;
  WASI_EMLINK = 34;
  WASI_EMSGSIZE = 35;
  WASI_EMULTIHOP = 36;
  WASI_ENAMETOOLONG = 37;
  WASI_ENETDOWN = 38;
  WASI_ENETRESET = 39;
  WASI_ENETUNREACH = 40;
  WASI_ENFILE = 41;
  WASI_ENOBUFS = 42;
  WASI_ENODEV = 43;
  WASI_ENOENT = 44;
  WASI_ENOEXEC = 45;
  WASI_ENOLCK = 46;
  WASI_ENOLINK = 47;
  WASI_ENOMEM = 48;
  WASI_ENOMSG = 49;
  WASI_ENOPROTOOPT = 50;
  WASI_ENOSPC = 51;
  WASI_ENOSYS = 52;
  WASI_ENOTCONN = 53;
  WASI_ENOTDIR = 54;
  WASI_ENOTEMPTY = 55;
  WASI_ENOTRECOVERABLE = 56;
  WASI_ENOTSOCK = 57;
  WASI_ENOTSUP = 58;
  WASI_ENOTTY = 59;
  WASI_ENXIO = 60;
  WASI_EOVERFLOW = 61;
  WASI_EOWNERDEAD = 62;
  WASI_EPERM = 63;
  WASI_EPIPE = 64;
  WASI_EPROTO = 65;
  WASI_EPROTONOSUPPORT = 66;
  WASI_EPROTOTYPE = 67;
  WASI_ERANGE = 68;
  WASI_EROFS = 69;
  WASI_ESPIPE = 70;
  WASI_ESRCH = 71;
  WASI_ESTALE = 72;
  WASI_ETIMEDOUT = 73;
  WASI_ETXTBSY = 74;
  WASI_EXDEV = 75;
  WASI_ENOTCAPABLE = 76;

  WASI_SIGABRT = 0;
  WASI_SIGALRM = 1;
  WASI_SIGBUS = 2;
  WASI_SIGCHLD = 3;
  WASI_SIGCONT = 4;
  WASI_SIGFPE = 5;
  WASI_SIGHUP = 6;
  WASI_SIGILL = 7;
  WASI_SIGINT = 8;
  WASI_SIGKILL = 9;
  WASI_SIGPIPE = 10;
  WASI_SIGQUIT = 11;
  WASI_SIGSEGV = 12;
  WASI_SIGSTOP = 13;
  WASI_SIGTERM = 14;
  WASI_SIGTRAP = 15;
  WASI_SIGTSTP = 16;
  WASI_SIGTTIN = 17;
  WASI_SIGTTOU = 18;
  WASI_SIGURG = 19;
  WASI_SIGUSR1 = 20;
  WASI_SIGUSR2 = 21;
  WASI_SIGVTALRM = 22;
  WASI_SIGXCPU = 23;
  WASI_SIGXFSZ = 24;

  WASI_FILETYPE_UNKNOWN = 0;
  WASI_FILETYPE_BLOCK_DEVICE = 1;
  WASI_FILETYPE_CHARACTER_DEVICE = 2;
  WASI_FILETYPE_DIRECTORY = 3;
  WASI_FILETYPE_REGULAR_FILE = 4;
  WASI_FILETYPE_SOCKET_DGRAM = 5;
  WASI_FILETYPE_SOCKET_STREAM = 6;
  WASI_FILETYPE_SYMBOLIC_LINK = 7;

  WASI_FDFLAG_APPEND = $0001;
  WASI_FDFLAG_DSYNC = $0002;
  WASI_FDFLAG_NONBLOCK = $0004;
  WASI_FDFLAG_RSYNC = $0008;
  WASI_FDFLAG_SYNC = $0010;

  WASI_RIGHT_FD_DATASYNC             = $0000000000000001;
  WASI_RIGHT_FD_READ                 = $0000000000000002;
  WASI_RIGHT_FD_SEEK                 = $0000000000000004;
  WASI_RIGHT_FD_FDSTAT_SET_FLAGS     = $0000000000000008;
  WASI_RIGHT_FD_SYNC                 = $0000000000000010;
  WASI_RIGHT_FD_TELL                 = $0000000000000020;
  WASI_RIGHT_FD_WRITE                = $0000000000000040;
  WASI_RIGHT_FD_ADVISE               = $0000000000000080;
  WASI_RIGHT_FD_ALLOCATE             = $0000000000000100;
  WASI_RIGHT_PATH_CREATE_DIRECTORY   = $0000000000000200;
  WASI_RIGHT_PATH_CREATE_FILE        = $0000000000000400;
  WASI_RIGHT_PATH_LINK_SOURCE        = $0000000000000800;
  WASI_RIGHT_PATH_LINK_TARGET        = $0000000000001000;
  WASI_RIGHT_PATH_OPEN               = $0000000000002000;
  WASI_RIGHT_FD_READDIR              = $0000000000004000;
  WASI_RIGHT_PATH_READLINK           = $0000000000008000;
  WASI_RIGHT_PATH_RENAME_SOURCE      = $0000000000010000;
  WASI_RIGHT_PATH_RENAME_TARGET      = $0000000000020000;
  WASI_RIGHT_PATH_FILESTAT_GET       = $0000000000040000;
  WASI_RIGHT_PATH_FILESTAT_SET_SIZE  = $0000000000080000;
  WASI_RIGHT_PATH_FILESTAT_SET_TIMES = $0000000000100000;
  WASI_RIGHT_FD_FILESTAT_GET         = $0000000000200000;
  WASI_RIGHT_FD_FILESTAT_SET_SIZE    = $0000000000400000;
  WASI_RIGHT_FD_FILESTAT_SET_TIMES   = $0000000000800000;
  WASI_RIGHT_PATH_SYMLINK            = $0000000001000000;
  WASI_RIGHT_PATH_REMOVE_DIRECTORY   = $0000000002000000;
  WASI_RIGHT_PATH_UNLINK_FILE        = $0000000004000000;
  WASI_RIGHT_POLL_FD_READWRITE       = $0000000008000000;
  WASI_RIGHT_SOCK_SHUTDOWN           = $0000000010000000;

  RIGHTS_ALL = WASI_RIGHT_FD_DATASYNC or WASI_RIGHT_FD_READ
  or WASI_RIGHT_FD_SEEK or WASI_RIGHT_FD_FDSTAT_SET_FLAGS or WASI_RIGHT_FD_SYNC
  or WASI_RIGHT_FD_TELL or WASI_RIGHT_FD_WRITE or WASI_RIGHT_FD_ADVISE
  or WASI_RIGHT_FD_ALLOCATE or WASI_RIGHT_PATH_CREATE_DIRECTORY
  or WASI_RIGHT_PATH_CREATE_FILE or WASI_RIGHT_PATH_LINK_SOURCE
  or WASI_RIGHT_PATH_LINK_TARGET or WASI_RIGHT_PATH_OPEN or WASI_RIGHT_FD_READDIR
  or WASI_RIGHT_PATH_READLINK or WASI_RIGHT_PATH_RENAME_SOURCE
  or WASI_RIGHT_PATH_RENAME_TARGET or WASI_RIGHT_PATH_FILESTAT_GET
  or WASI_RIGHT_PATH_FILESTAT_SET_SIZE or WASI_RIGHT_PATH_FILESTAT_SET_TIMES
  or WASI_RIGHT_FD_FILESTAT_GET or WASI_RIGHT_FD_FILESTAT_SET_TIMES
  or WASI_RIGHT_FD_FILESTAT_SET_SIZE or WASI_RIGHT_PATH_SYMLINK
  or WASI_RIGHT_PATH_UNLINK_FILE or WASI_RIGHT_PATH_REMOVE_DIRECTORY
  or WASI_RIGHT_POLL_FD_READWRITE or WASI_RIGHT_SOCK_SHUTDOWN;

  RIGHTS_BLOCK_DEVICE_BASE = RIGHTS_ALL;
  RIGHTS_BLOCK_DEVICE_INHERITING = RIGHTS_ALL;

  RIGHTS_CHARACTER_DEVICE_BASE = RIGHTS_ALL;
  RIGHTS_CHARACTER_DEVICE_INHERITING = RIGHTS_ALL;

  RIGHTS_REGULAR_FILE_BASE = WASI_RIGHT_FD_DATASYNC or WASI_RIGHT_FD_READ
                           or WASI_RIGHT_FD_SEEK or WASI_RIGHT_FD_FDSTAT_SET_FLAGS or WASI_RIGHT_FD_SYNC
                           or WASI_RIGHT_FD_TELL or WASI_RIGHT_FD_WRITE or WASI_RIGHT_FD_ADVISE
                           or WASI_RIGHT_FD_ALLOCATE or WASI_RIGHT_FD_FILESTAT_GET
                           or WASI_RIGHT_FD_FILESTAT_SET_SIZE or WASI_RIGHT_FD_FILESTAT_SET_TIMES
                           or WASI_RIGHT_POLL_FD_READWRITE;
  RIGHTS_REGULAR_FILE_INHERITING = 00;

  RIGHTS_DIRECTORY_BASE = WASI_RIGHT_FD_FDSTAT_SET_FLAGS
                        or WASI_RIGHT_FD_SYNC or WASI_RIGHT_FD_ADVISE or WASI_RIGHT_PATH_CREATE_DIRECTORY
                        or WASI_RIGHT_PATH_CREATE_FILE or WASI_RIGHT_PATH_LINK_SOURCE
                        or WASI_RIGHT_PATH_LINK_TARGET or WASI_RIGHT_PATH_OPEN or WASI_RIGHT_FD_READDIR
                        or WASI_RIGHT_PATH_READLINK or WASI_RIGHT_PATH_RENAME_SOURCE
                        or WASI_RIGHT_PATH_RENAME_TARGET or WASI_RIGHT_PATH_FILESTAT_GET
                        or WASI_RIGHT_PATH_FILESTAT_SET_SIZE or WASI_RIGHT_PATH_FILESTAT_SET_TIMES
                        or WASI_RIGHT_FD_FILESTAT_GET or WASI_RIGHT_FD_FILESTAT_SET_TIMES
                        or WASI_RIGHT_PATH_SYMLINK or WASI_RIGHT_PATH_UNLINK_FILE
                        or WASI_RIGHT_PATH_REMOVE_DIRECTORY or WASI_RIGHT_POLL_FD_READWRITE;
  RIGHTS_DIRECTORY_INHERITING = RIGHTS_DIRECTORY_BASE
                        or RIGHTS_REGULAR_FILE_BASE;

  RIGHTS_SOCKET_BASE = WASI_RIGHT_FD_READ or WASI_RIGHT_FD_FDSTAT_SET_FLAGS
                     or WASI_RIGHT_FD_WRITE or WASI_RIGHT_FD_FILESTAT_GET
                     or WASI_RIGHT_POLL_FD_READWRITE or WASI_RIGHT_SOCK_SHUTDOWN;

  RIGHTS_SOCKET_INHERITING = RIGHTS_ALL;

  RIGHTS_TTY_BASE = WASI_RIGHT_FD_READ or WASI_RIGHT_FD_FDSTAT_SET_FLAGS
                  or WASI_RIGHT_FD_WRITE or WASI_RIGHT_FD_FILESTAT_GET
                  or WASI_RIGHT_POLL_FD_READWRITE;

  RIGHTS_TTY_INHERITING = 0;

  WASI_CLOCK_MONOTONIC = 0;
  WASI_CLOCK_PROCESS_CPUTIME_ID = 1;
  WASI_CLOCK_REALTIME = 2;
  WASI_CLOCK_THREAD_CPUTIME_ID = 3;

  WASI_EVENTTYPE_CLOCK = 0;
  WASI_EVENTTYPE_FD_READ = 1;
  WASI_EVENTTYPE_FD_WRITE = 2;

  WASI_FILESTAT_SET_ATIM = 1 << 0;
  WASI_FILESTAT_SET_ATIM_NOW = 1 << 1;
  WASI_FILESTAT_SET_MTIM = 1 << 2;
  WASI_FILESTAT_SET_MTIM_NOW = 1 << 3;

  WASI_O_CREAT = 1 << 0;
  WASI_O_DIRECTORY = 1 << 1;
  WASI_O_EXCL = 1 << 2;
  WASI_O_TRUNC = 1 << 3;

  WASI_PREOPENTYPE_DIR = 0;

  WASI_DIRCOOKIE_START = 0;

  WASI_STDIN_FILENO = 0;
  WASI_STDOUT_FILENO = 1;
  WASI_STDERR_FILENO = 2;

  WASI_WHENCE_CUR = 0;
  WASI_WHENCE_END = 1;
  WASI_WHENCE_SET = 2;

  __WASI_CLOCKID_REALTIME           = 0;
  __WASI_CLOCKID_MONOTONIC          = 1;
  __WASI_CLOCKID_PROCESS_CPUTIME_ID = 2;
  __WASI_CLOCKID_THREAD_CPUTIME_ID  = 3;

  __WASI_ERRNO_SUCCESS        = 0;
  __WASI_ERRNO_2BIG           = 1;
  __WASI_ERRNO_ACCES          = 2;
  __WASI_ERRNO_ADDRINUSE      = 3;
  __WASI_ERRNO_ADDRNOTAVAIL   = 4;
  __WASI_ERRNO_AFNOSUPPORT    = 5;
  __WASI_ERRNO_AGAIN          = 6;
  __WASI_ERRNO_ALREADY        = 7;
  __WASI_ERRNO_BADF           = 8;
  __WASI_ERRNO_BADMSG         = 9;
  __WASI_ERRNO_BUSY           = 10;
  __WASI_ERRNO_CANCELED       = 11;
  __WASI_ERRNO_CHILD          = 12;
  __WASI_ERRNO_CONNABORTED    = 13;
  __WASI_ERRNO_CONNREFUSED    = 14;
  __WASI_ERRNO_CONNRESET      = 15;
  __WASI_ERRNO_DEADLK         = 16;
  __WASI_ERRNO_DESTADDRREQ    = 17;
  __WASI_ERRNO_DOM            = 18;
  __WASI_ERRNO_DQUOT          = 19;
  __WASI_ERRNO_EXIST          = 20;
  __WASI_ERRNO_FAULT          = 21;
  __WASI_ERRNO_FBIG           = 22;
  __WASI_ERRNO_HOSTUNREACH    = 23;
  __WASI_ERRNO_IDRM           = 24;
  __WASI_ERRNO_ILSEQ          = 25;
  __WASI_ERRNO_INPROGRESS     = 26;
  __WASI_ERRNO_INTR           = 27;
  __WASI_ERRNO_INVAL          = 28;
  __WASI_ERRNO_IO             = 29;
  __WASI_ERRNO_ISCONN         = 30;
  __WASI_ERRNO_ISDIR          = 31;
  __WASI_ERRNO_LOOP           = 32;
  __WASI_ERRNO_MFILE          = 33;
  __WASI_ERRNO_MLINK          = 34;
  __WASI_ERRNO_MSGSIZE        = 35;
  __WASI_ERRNO_MULTIHOP       = 36;
  __WASI_ERRNO_NAMETOOLONG    = 37;
  __WASI_ERRNO_NETDOWN        = 38;
  __WASI_ERRNO_NETRESET       = 39;
  __WASI_ERRNO_NETUNREACH     = 40;
  __WASI_ERRNO_NFILE          = 41;
  __WASI_ERRNO_NOBUFS         = 42;
  __WASI_ERRNO_NODEV          = 43;
  __WASI_ERRNO_NOENT          = 44;
  __WASI_ERRNO_NOEXEC         = 45;
  __WASI_ERRNO_NOLCK          = 46;
  __WASI_ERRNO_NOLINK         = 47;
  __WASI_ERRNO_NOMEM          = 48;
  __WASI_ERRNO_NOMSG          = 49;
  __WASI_ERRNO_NOPROTOOPT     = 50;
  __WASI_ERRNO_NOSPC          = 51;
  __WASI_ERRNO_NOSYS          = 52;
  __WASI_ERRNO_NOTCONN        = 53;
  __WASI_ERRNO_NOTDIR         = 54;
  __WASI_ERRNO_NOTEMPTY       = 55;
  __WASI_ERRNO_NOTRECOVERABLE = 56;
  __WASI_ERRNO_NOTSOCK        = 57;
  __WASI_ERRNO_NOTSUP         = 58;
  __WASI_ERRNO_NOTTY          = 59;
  __WASI_ERRNO_NXIO           = 60;
  __WASI_ERRNO_OVERFLOW       = 61;
  __WASI_ERRNO_OWNERDEAD      = 62;
  __WASI_ERRNO_PERM           = 63;
  __WASI_ERRNO_PIPE           = 64;
  __WASI_ERRNO_PROTO          = 65;
  __WASI_ERRNO_PROTONOSUPPORT = 66;
  __WASI_ERRNO_PROTOTYPE      = 67;
  __WASI_ERRNO_RANGE          = 68;
  __WASI_ERRNO_ROFS           = 69;
  __WASI_ERRNO_SPIPE          = 70;
  __WASI_ERRNO_SRCH           = 71;
  __WASI_ERRNO_STALE          = 72;
  __WASI_ERRNO_TIMEDOUT       = 73;
  __WASI_ERRNO_TXTBSY         = 74;
  __WASI_ERRNO_XDEV           = 75;
  __WASI_ERRNO_NOTCAPABLE     = 76;


const
  __WASI_RIGHTS_FD_DATASYNC             = 1;
  __WASI_RIGHTS_FD_READ                 = 2;
  __WASI_RIGHTS_FD_SEEK                 = 4;
  __WASI_RIGHTS_FD_FDSTAT_SET_FLAGS     = 8;
  __WASI_RIGHTS_FD_SYNC                 = 16;
  __WASI_RIGHTS_FD_TELL                 = 32;
  __WASI_RIGHTS_FD_WRITE                = 64;
  __WASI_RIGHTS_FD_ADVISE               = 128;
  __WASI_RIGHTS_FD_ALLOCATE             = 256;
  __WASI_RIGHTS_PATH_CREATE_DIRECTORY   = 512;
  __WASI_RIGHTS_PATH_CREATE_FILE        = 1024;
  __WASI_RIGHTS_PATH_LINK_SOURCE        = 2048;
  __WASI_RIGHTS_PATH_LINK_TARGET        = 4096;
  __WASI_RIGHTS_PATH_OPEN               = 8192;
  __WASI_RIGHTS_FD_READDIR              = 16384;
  __WASI_RIGHTS_PATH_READLINK           = 32768;
  __WASI_RIGHTS_PATH_RENAME_SOURCE      = 65536;
  __WASI_RIGHTS_PATH_RENAME_TARGET      = 131072;
  __WASI_RIGHTS_PATH_FILESTAT_GET       = 262144;
  __WASI_RIGHTS_PATH_FILESTAT_SET_SIZE  = 524288;
  __WASI_RIGHTS_PATH_FILESTAT_SET_TIMES = 1048576;
  __WASI_RIGHTS_FD_FILESTAT_GET         = 2097152;
  __WASI_RIGHTS_FD_FILESTAT_SET_SIZE    = 4194304;
  __WASI_RIGHTS_FD_FILESTAT_SET_TIMES   = 8388608;
  __WASI_RIGHTS_PATH_SYMLINK            = 16777216;
  __WASI_RIGHTS_PATH_REMOVE_DIRECTORY   = 33554432;
  __WASI_RIGHTS_PATH_UNLINK_FILE        = 67108864;
  __WASI_RIGHTS_POLL_FD_READWRITE       = 134217728;
  __WASI_RIGHTS_SOCK_SHUTDOWN           = 268435456;

const
  __WASI_SIGNAL_NONE   = 0;
  __WASI_SIGNAL_HUP    = 1;
  __WASI_SIGNAL_INT    = 2;
  __WASI_SIGNAL_QUIT   = 3;
  __WASI_SIGNAL_ILL    = 4;
  __WASI_SIGNAL_TRAP   = 5;
  __WASI_SIGNAL_ABRT   = 6;
  __WASI_SIGNAL_BUS    = 7;
  __WASI_SIGNAL_FPE    = 8;
  __WASI_SIGNAL_KILL   = 9;
  __WASI_SIGNAL_USR1   = 10;
  __WASI_SIGNAL_SEGV   = 11;
  __WASI_SIGNAL_USR2   = 12;
  __WASI_SIGNAL_PIPE   = 13;
  __WASI_SIGNAL_ALRM   = 14;
  __WASI_SIGNAL_TERM   = 15;
  __WASI_SIGNAL_CHLD   = 16;
  __WASI_SIGNAL_CONT   = 17;
  __WASI_SIGNAL_STOP   = 18;
  __WASI_SIGNAL_TSTP   = 19;
  __WASI_SIGNAL_TTIN   = 20;
  __WASI_SIGNAL_TTOU   = 21;
  __WASI_SIGNAL_URG    = 22;
  __WASI_SIGNAL_XCPU   = 23;
  __WASI_SIGNAL_XFSZ   = 24;
  __WASI_SIGNAL_VTALRM = 25;
  __WASI_SIGNAL_PROF   = 26;
  __WASI_SIGNAL_WINCH  = 27;
  __WASI_SIGNAL_POLL   = 28;
  __WASI_SIGNAL_PWR    = 29;
  __WASI_SIGNAL_SYS    = 30;

  __WASI_ROFLAGS_RECV_DATA_TRUNCATED = 1;


const
  __WASI_WHENCE_SET = 0;
  __WASI_WHENCE_CUR = 1;
  __WASI_WHENCE_END = 2;

  __WASI_FILETYPE_UNKNOWN          = 0;
  __WASI_FILETYPE_BLOCK_DEVICE     = 1;
  __WASI_FILETYPE_CHARACTER_DEVICE = 2;
  __WASI_FILETYPE_DIRECTORY        = 3;
  __WASI_FILETYPE_REGULAR_FILE     = 4;
  __WASI_FILETYPE_SOCKET_DGRAM     = 5;
  __WASI_FILETYPE_SOCKET_STREAM    = 6;
  __WASI_FILETYPE_SYMBOLIC_LINK    = 7;



  __WASI_OFLAGS_CREAT     = 1;
  __WASI_OFLAGS_DIRECTORY = 2;
  __WASI_OFLAGS_EXCL      = 4;
  __WASI_OFLAGS_TRUNC     = 8;

  __WASI_FSTFLAGS_ATIM     = 1;
  __WASI_FSTFLAGS_ATIM_NOW = 2;
  __WASI_FSTFLAGS_MTIM     = 4;
  __WASI_FSTFLAGS_MTIM_NOW = 8;

  __WASI_ADVICE_NORMAL     = 0;
  __WASI_ADVICE_SEQUENTIAL = 1;
  __WASI_ADVICE_RANDOM     = 2;
  __WASI_ADVICE_WILLNEED   = 3;
  __WASI_ADVICE_DONTNEED   = 4;
  __WASI_ADVICE_NOREUSE    = 5;


  __WASI_FDFLAGS_APPEND   = 1;
  __WASI_FDFLAGS_DSYNC    = 2;
  __WASI_FDFLAGS_NONBLOCK = 4;
  __WASI_FDFLAGS_RSYNC    = 8;
  __WASI_FDFLAGS_SYNC     = 16;



  __WASI_SUBCLOCKFLAGS_SUBSCRIPTION_CLOCK_ABSTIME = 1;

  __WASI_RIFLAGS_RECV_PEEK    = 1;
  __WASI_RIFLAGS_RECV_WAITALL = 2;

  __WASI_LOOKUPFLAGS_SYMLINK_FOLLOW = 1;

  __WASI_EVENTRWFLAGS_FD_READWRITE_HANGUP = 1;

type
  PUInt8 = NativeInt;
  size_t = longint;
  // Int64 not really implemented.
  WasiInt64 = NativeInt;
  WasiUInt64 = NativeInt;

  __wasi_size_t = longint;
  __wasi_filesize_t = WasiUInt64;
  __wasi_timestamp_t = WasiUInt64;
  __wasi_clockid_t = UInt32;
  __wasi_errno_t = UInt16;
  __wasi_fd_t = longint;
  __wasi_filedelta_t = WasiInt64;
  __wasi_whence_t = UInt8;
  __wasi_dircookie_t = WasiUInt64;
  __wasi_dirnamlen_t = UInt32;
  __wasi_inode_t = WasiUInt64;
  __wasi_filetype_t = UInt8;
  __wasi_rights_t = WasiUInt64;
  __wasi_exitcode_t = UInt32;
  __wasi_signal_t = UInt8;
  __wasi_riflags_t = UInt16;
  __wasi_roflags_t = UInt16;
  __wasi_siflags_t = UInt16;
  __wasi_sdflags_t = UInt8;
  __wasi_preopentype_t = UInt8;
  __wasi_advice_t = UInt8;
  __wasi_fdflags_t = UInt16;
  __wasi_device_t = WasiUInt64;
  __wasi_fstflags_t = UInt16;
  __wasi_lookupflags_t = UInt32;
  __wasi_oflags_t = UInt16;
  __wasi_linkcount_t = WasiUInt64;
  __wasi_userdata_t = WasiUInt64;
  __wasi_eventtype_t = UInt8;
  __wasi_eventrwflags_t = UInt16;
  __wasi_subclockflags_t = UInt16;



  __wasi_iovec_t = record
    buf: PUInt8;
    buf_len: __wasi_size_t;
  end;
  TWASIIOVec = __wasi_iovec_t;

  __wasi_ciovec_t = record
    buf: PUInt8;
    buf_len: __wasi_size_t;
  end;
  TWASICIOVec = __wasi_ciovec_t;

  __wasi_dirent_t = record
    d_next: __wasi_dircookie_t;
    d_ino: __wasi_inode_t;
    d_namlen: __wasi_dirnamlen_t;
    d_type: __wasi_filetype_t;
  end;
  TWASIDirent = __wasi_dirent_t;

  __wasi_fdstat_t = record
    fs_filetype: __wasi_filetype_t;
    fs_flags: __wasi_fdflags_t;
    fs_rights_base: __wasi_rights_t;
    fs_rights_inheriting: __wasi_rights_t;
  end;
  TWASIFDStat = __wasi_fdstat_t;

  __wasi_filestat_t = record
    dev: __wasi_device_t;
    ino: __wasi_inode_t;
    filetype: __wasi_filetype_t;
    nlink: __wasi_linkcount_t;
    size: __wasi_filesize_t;
    atim: __wasi_timestamp_t;
    mtim: __wasi_timestamp_t;
    ctim: __wasi_timestamp_t;
  end;
  TWASIFilestat = __wasi_filestat_t;

  __wasi_event_fd_readwrite_t = record
    nbytes: __wasi_filesize_t;
    flags: __wasi_eventrwflags_t;
  end;
  TWASIEventFDReadWrite = __wasi_event_fd_readwrite_t;

  __wasi_event_t = record
    userdata: __wasi_userdata_t;
    error: __wasi_errno_t;
    type_: __wasi_eventtype_t;
    fd_readwrite: __wasi_event_fd_readwrite_t;
  end;
  TWASIEvent = __wasi_event_t;

  __wasi_subscription_clock_t = record
    id: __wasi_clockid_t;
    timeout: __wasi_timestamp_t;
    precision: __wasi_timestamp_t;
    flags: __wasi_subclockflags_t;
  end;
  TWASISubscriptionClock = __wasi_subscription_clock_t;

  __wasi_subscription_fd_readwrite_t = record
    file_descriptor: __wasi_fd_t;
  end;
  TWASISubscriptionDSReadWrite = __wasi_subscription_fd_readwrite_t;

  // The following 3 represent a part of the variant record.
  __wasi_subscription_u_u_t_0 = record
    clock: __wasi_subscription_clock_t;
  end;
  __wasi_subscription_u_u_t_1 = record
    fd_read: __wasi_subscription_fd_readwrite_t
  end;
  __wasi_subscription_u_u_t_2 = record
    fd_write: __wasi_subscription_fd_readwrite_t
  end;

  __wasi_subscription_u_u_t = Record
    // Note, this is a variant record
     Clock :  __wasi_subscription_clock_t; {case 0}
     fd_read: __wasi_subscription_fd_readwrite_t; {case 1}
     fd_write: __wasi_subscription_fd_readwrite_t; {case 2}
  end;

  __wasi_subscription_u_t = record
    tag: __wasi_eventtype_t;
    u: __wasi_subscription_u_u_t;
  end;

  __wasi_subscription_t = record
    userdata: __wasi_userdata_t;
    u: __wasi_subscription_u_t;
  end;

  __wasi_prestat_dir_t = record
    pr_name_len: __wasi_size_t;
  end;
  TWASIPrestatDir = __wasi_prestat_dir_t;

  __wasi_prestat_u_t = record
     dir: __wasi_prestat_dir_t;
  end;
  TWasiPrestatU = __wasi_prestat_u_t;

  __wasi_prestat_t = record
    tag: __wasi_preopentype_t;
    u: __wasi_prestat_u_t;
  end;
  TWasiPreStat = __wasi_prestat_t;

  TDirentType = (dtUnknown,dtFile,dtDirectory,dtSymlink,dtSocket,dtBlockDevice,dtCharacterDevice,dtFIFO);
  TWasiFSDirent = record
    ino: NativeInt;
    name : String;
    EntryType: TDirentType;
    next : NativeInt;
  end;

  { EWasiFSError }

  { IWASIFS }
  TSeekWhence = (swBeginning, swCurrent, swEnd);
  TSetTimesFlag = (stfatime,stfaTimeNow,stfmTime,stfmTimeNow);
  TSetTimesFlags = set of TSetTimesFlag;

  IWASIFS = Interface
    Function MkDirAt(FD : Integer; const aPath : String) : NativeInt;
    Function RmDirAt(FD : Integer; const aPath : String) : NativeInt;
    function StatAt(FD : Integer; const aPath : String; var stat: TWasiFileStat) : NativeInt;
    function StatFD(FD : Integer; var stat: TWasiFileStat) : NativeInt;
    Function UTimesAt(FD : Integer; aPath : String; aTime,MTime : TJSDate; UpdateLink : boolean) : NativeInt;
    Function UTimes(FD : Integer; aTime,MTime : TJSDate; Flags : TSetTimesFlags) : NativeInt;
    Function LinkAt(OldFD : Integer; OldPath : String; NewFD : Integer; NewPath : String) : NativeInt;
    Function SymLinkAt(FD : Integer; Path : String; Target : String) : NativeInt;
    Function RenameAt(OldFD : Integer; OldPath : String; NewFD : Integer; NewPath : String) : NativeInt;
    Function UnLinkAt(FD : Integer; const aPath : String) : NativeInt;
    function OpenAt(FD : Integer; FDFlags : NativeInt; aPath : String; Flags, fsRightsBase, fsRightsInheriting, fsFlags: NativeInt; out Openfd: Integer): NativeInt;
    function ReadLinkAt(FD : Integer; aPath : String; out aTarget : String): NativeInt;
    function Close(FD : Integer): NativeInt;
    function Write(FD : Integer; Data : TJSUint8Array; AtPos : Integer; Out Written : Integer) : NativeInt;
    function Sync(FD : Integer) : NativeInt;
    function DataSync(FD : Integer) : NativeInt;
    function Seek(FD : integer; Offset : Integer; Whence : TSeekWhence; out NewPos : Integer) : NativeInt;
    Function Read(FD : Integer; Data : TJSUint8Array; AtPos : Integer; Out BytesRead : Integer) : NativeInt;
    function ReadDir(FD: Integer; Cookie: NativeInt; out DirEnt: TWasiFSDirent): NativeInt;
    Function GetPrestat(FD: Integer) : String;
    Procedure PreLoadFile(aPath : String; aData : TJSDataView);
  end;

Const
  DirentMap : Array [TDirentType] of Integer =
                  (__WASI_FILETYPE_UNKNOWN,
                   __WASI_FILETYPE_REGULAR_FILE,
                   __WASI_FILETYPE_DIRECTORY,
                   __WASI_FILETYPE_SYMBOLIC_LINK,
                   __WASI_FILETYPE_SOCKET_STREAM,
                   __WASI_FILETYPE_BLOCK_DEVICE,
                   __WASI_FILETYPE_CHARACTER_DEVICE,
                   __WASI_FILETYPE_UNKNOWN);

implementation

end.

