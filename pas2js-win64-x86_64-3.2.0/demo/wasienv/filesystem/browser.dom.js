"use strict";
var ZenFS_DOM = (() => {
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __name = (target, value) => __defProp(target, "name", { value, configurable: true });
  var __export = (target, all) => {
    for (var name in all)
      __defProp(target, name, { get: all[name], enumerable: true });
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

  // src/index.ts
  var src_exports = {};
  __export(src_exports, {
    IndexedDB: () => IndexedDB,
    IndexedDBStore: () => IndexedDBStore,
    IndexedDBTransaction: () => IndexedDBTransaction,
    WebAccess: () => WebAccess,
    WebAccessFS: () => WebAccessFS,
    WebStorage: () => WebStorage,
    WebStorageStore: () => WebStorageStore
  });

  // global-externals:@zenfs/core
  var core_default = ZenFS;
  var { ActionType, Async, AsyncIndexFS, AsyncTransaction, BigIntStats, BigIntStatsFs, Dir, Dirent, Errno, ErrnoError, Fetch, FetchFS, File, FileIndex, FileSystem, FileType, InMemory, InMemoryStore, IndexDirInode, IndexFS, IndexFileInode, IndexInode, Inode, LockedFS, Mutex, NoSyncFile, Overlay, OverlayFS, Port, PortFS, PortFile, PreloadFile, ReadStream, Readonly, SimpleAsyncStore, SimpleTransaction, Stats, StatsCommon, StatsFs, StoreFS, Sync, SyncIndexFS, SyncTransaction, Transaction, UnlockedOverlayFS, WriteStream, _toUnixTimestamp, access, accessSync, appendFile, appendFileSync, attachFS, checkOptions, chmod, chmodSync, chown, chownSync, close, closeSync, configure, constants, copyFile, copyFileSync, cp, cpSync, createReadStream, createWriteStream, decode, decodeDirListing, detachFS, encode, encodeDirListing, errorMessages, exists, existsSync, fchmod, fchmodSync, fchown, fchownSync, fdatasync, fdatasyncSync, flagToMode, flagToNumber, flagToString, fs, fstat, fstatSync, fsync, fsyncSync, ftruncate, ftruncateSync, futimes, futimesSync, isAppendable, isBackend, isBackendConfig, isExclusive, isReadable, isSynchronous, isTruncating, isWriteable, lchmod, lchmodSync, lchown, lchownSync, levenshtein, link, linkSync, lopenSync, lstat, lstatSync, lutimes, lutimesSync, mkdir, mkdirSync, mkdirpSync, mkdtemp, mkdtempSync, mount, mountObject, mounts, nop, normalizeMode, normalizeOptions, normalizePath, normalizeTime, open, openAsBlob, openSync, opendir, opendirSync, parseFlag, pathExistsAction, pathNotExistsAction, promises, randomIno, read, readFile, readFileSync, readSync, readdir, readdirSync, readlink, readlinkSync, readv, readvSync, realpath, realpathSync, rename, renameSync, resolveMountConfig, rm, rmSync, rmdir, rmdirSync, rootCred, rootIno, setImmediate, size_max, stat, statSync, statfs, statfsSync, symlink, symlinkSync, truncate, truncateSync, umount, unlink, unlinkSync, unwatchFile, utimes, utimesSync, watch, watchFile, write, writeFile, writeFileSync, writeSync, writev, writevSync } = ZenFS;

  // node_modules/@zenfs/core/dist/emulation/path.js
  function normalizeString(path, allowAboveRoot) {
    let res = "";
    let lastSegmentLength = 0;
    let lastSlash = -1;
    let dots = 0;
    let char = "\0";
    for (let i = 0; i <= path.length; ++i) {
      if (i < path.length) {
        char = path[i];
      } else if (char == "/") {
        break;
      } else {
        char = "/";
      }
      if (char == "/") {
        if (lastSlash === i - 1 || dots === 1) {
        } else if (dots === 2) {
          if (res.length < 2 || lastSegmentLength !== 2 || res.at(-1) !== "." || res.at(-2) !== ".") {
            if (res.length > 2) {
              const lastSlashIndex = res.lastIndexOf("/");
              if (lastSlashIndex === -1) {
                res = "";
                lastSegmentLength = 0;
              } else {
                res = res.slice(0, lastSlashIndex);
                lastSegmentLength = res.length - 1 - res.lastIndexOf("/");
              }
              lastSlash = i;
              dots = 0;
              continue;
            } else if (res.length !== 0) {
              res = "";
              lastSegmentLength = 0;
              lastSlash = i;
              dots = 0;
              continue;
            }
          }
          if (allowAboveRoot) {
            res += res.length > 0 ? "/.." : "..";
            lastSegmentLength = 2;
          }
        } else {
          if (res.length > 0)
            res += "/" + path.slice(lastSlash + 1, i);
          else
            res = path.slice(lastSlash + 1, i);
          lastSegmentLength = i - lastSlash - 1;
        }
        lastSlash = i;
        dots = 0;
      } else if (char === "." && dots !== -1) {
        ++dots;
      } else {
        dots = -1;
      }
    }
    return res;
  }
  __name(normalizeString, "normalizeString");
  function normalize(path) {
    if (!path.length)
      return ".";
    const isAbsolute = path.startsWith("/");
    const trailingSeparator = path.endsWith("/");
    path = normalizeString(path, !isAbsolute);
    if (!path.length) {
      if (isAbsolute)
        return "/";
      return trailingSeparator ? "./" : ".";
    }
    if (trailingSeparator)
      path += "/";
    return isAbsolute ? `/${path}` : path;
  }
  __name(normalize, "normalize");
  function join(...parts) {
    if (!parts.length)
      return ".";
    const joined = parts.join("/");
    if (!joined?.length)
      return ".";
    return normalize(joined);
  }
  __name(join, "join");
  function dirname(path) {
    if (path.length === 0)
      return ".";
    const hasRoot = path[0] === "/";
    let end = -1;
    let matchedSlash = true;
    for (let i = path.length - 1; i >= 1; --i) {
      if (path[i] === "/") {
        if (!matchedSlash) {
          end = i;
          break;
        }
      } else {
        matchedSlash = false;
      }
    }
    if (end === -1)
      return hasRoot ? "/" : ".";
    if (hasRoot && end === 1)
      return "//";
    return path.slice(0, end);
  }
  __name(dirname, "dirname");
  function basename(path, suffix) {
    let start = 0;
    let end = -1;
    let matchedSlash = true;
    if (suffix !== void 0 && suffix.length > 0 && suffix.length <= path.length) {
      if (suffix === path)
        return "";
      let extIdx = suffix.length - 1;
      let firstNonSlashEnd = -1;
      for (let i = path.length - 1; i >= 0; --i) {
        if (path[i] === "/") {
          if (!matchedSlash) {
            start = i + 1;
            break;
          }
        } else {
          if (firstNonSlashEnd === -1) {
            matchedSlash = false;
            firstNonSlashEnd = i + 1;
          }
          if (extIdx >= 0) {
            if (path[i] === suffix[extIdx]) {
              if (--extIdx === -1) {
                end = i;
              }
            } else {
              extIdx = -1;
              end = firstNonSlashEnd;
            }
          }
        }
      }
      if (start === end)
        end = firstNonSlashEnd;
      else if (end === -1)
        end = path.length;
      return path.slice(start, end);
    }
    for (let i = path.length - 1; i >= 0; --i) {
      if (path[i] === "/") {
        if (!matchedSlash) {
          start = i + 1;
          break;
        }
      } else if (end === -1) {
        matchedSlash = false;
        end = i + 1;
      }
    }
    if (end === -1)
      return "";
    return path.slice(start, end);
  }
  __name(basename, "basename");

  // src/utils.ts
  function errnoForDOMException(ex) {
    switch (ex.name) {
      case "IndexSizeError":
      case "HierarchyRequestError":
      case "InvalidCharacterError":
      case "InvalidStateError":
      case "SyntaxError":
      case "NamespaceError":
      case "TypeMismatchError":
      case "ConstraintError":
      case "VersionError":
      case "URLMismatchError":
      case "InvalidNodeTypeError":
        return "EINVAL";
      case "WrongDocumentError":
        return "EXDEV";
      case "NoModificationAllowedError":
      case "InvalidModificationError":
      case "InvalidAccessError":
      case "SecurityError":
      case "NotAllowedError":
        return "EACCES";
      case "NotFoundError":
        return "ENOENT";
      case "NotSupportedError":
        return "ENOTSUP";
      case "InUseAttributeError":
        return "EBUSY";
      case "NetworkError":
        return "ENETDOWN";
      case "AbortError":
        return "EINTR";
      case "QuotaExceededError":
        return "ENOSPC";
      case "TimeoutError":
        return "ETIMEDOUT";
      case "ReadOnlyError":
        return "EROFS";
      case "DataCloneError":
      case "EncodingError":
      case "NotReadableError":
      case "DataError":
      case "TransactionInactiveError":
      case "OperationError":
      case "UnknownError":
      default:
        return "EIO";
    }
  }
  __name(errnoForDOMException, "errnoForDOMException");
  function convertException(ex, path, syscall) {
    if (ex instanceof ErrnoError) {
      return ex;
    }
    const code = ex instanceof DOMException ? Errno[errnoForDOMException(ex)] : Errno.EIO;
    const error = new ErrnoError(code, ex.message, path, syscall);
    error.stack = ex.stack;
    error.cause = ex.cause;
    return error;
  }
  __name(convertException, "convertException");

  // src/access.ts
  var WebAccessFS = class extends Async(FileSystem) {
    _handles = /* @__PURE__ */ new Map();
    /**
     * @hidden
     */
    _sync;
    constructor({ handle }) {
      super();
      this._handles.set("/", handle);
      this._sync = InMemory.create({ name: "accessfs-cache" });
    }
    metadata() {
      return {
        ...super.metadata(),
        name: "WebAccess"
      };
    }
    async sync(path, data, stats) {
      const currentStats = await this.stat(path);
      if (stats.mtime !== currentStats.mtime) {
        await this.writeFile(path, data);
      }
    }
    async rename(oldPath, newPath) {
      try {
        const handle = await this.getHandle(oldPath);
        if (handle instanceof FileSystemDirectoryHandle) {
          const files = await this.readdir(oldPath);
          await this.mkdir(newPath);
          if (files.length == 0) {
            await this.unlink(oldPath);
          } else {
            for (const file of files) {
              await this.rename(join(oldPath, file), join(newPath, file));
              await this.unlink(oldPath);
            }
          }
        }
        if (!(handle instanceof FileSystemFileHandle)) {
          return;
        }
        const oldFile = await handle.getFile(), destFolder = await this.getHandle(dirname(newPath));
        if (!(destFolder instanceof FileSystemDirectoryHandle)) {
          return;
        }
        const newFile = await destFolder.getFileHandle(basename(newPath), { create: true });
        const writable = await newFile.createWritable();
        await writable.write(await oldFile.arrayBuffer());
        writable.close();
        await this.unlink(oldPath);
      } catch (ex) {
        throw convertException(ex, oldPath, "rename");
      }
    }
    async writeFile(fname, data) {
      const handle = await this.getHandle(dirname(fname));
      if (!(handle instanceof FileSystemDirectoryHandle)) {
        return;
      }
      const file = await handle.getFileHandle(basename(fname), { create: true });
      const writable = await file.createWritable();
      await writable.write(data);
      await writable.close();
    }
    async createFile(path, flag) {
      await this.writeFile(path, new Uint8Array());
      return this.openFile(path, flag);
    }
    async stat(path) {
      const handle = await this.getHandle(path);
      if (!handle) {
        throw ErrnoError.With("ENOENT", path, "stat");
      }
      if (handle instanceof FileSystemDirectoryHandle) {
        return new Stats({ mode: 511 | FileType.DIRECTORY, size: 4096 });
      }
      if (handle instanceof FileSystemFileHandle) {
        const { lastModified, size } = await handle.getFile();
        return new Stats({ mode: 511 | FileType.FILE, size, mtimeMs: lastModified });
      }
      throw new ErrnoError(Errno.EBADE, "Handle is not a directory or file", path, "stat");
    }
    async openFile(path, flag) {
      const handle = await this.getHandle(path);
      if (!(handle instanceof FileSystemFileHandle)) {
        throw ErrnoError.With("EISDIR", path, "openFile");
      }
      try {
        const file = await handle.getFile();
        const data = new Uint8Array(await file.arrayBuffer());
        const stats = new Stats({ mode: 511 | FileType.FILE, size: file.size, mtimeMs: file.lastModified });
        return new PreloadFile(this, path, flag, stats, data);
      } catch (ex) {
        throw convertException(ex, path, "openFile");
      }
    }
    async unlink(path) {
      const handle = await this.getHandle(dirname(path));
      if (handle instanceof FileSystemDirectoryHandle) {
        try {
          await handle.removeEntry(basename(path), { recursive: true });
        } catch (ex) {
          throw convertException(ex, path, "unlink");
        }
      }
    }
    async link(srcpath) {
      throw ErrnoError.With("ENOSYS", srcpath, "WebAccessFS.link");
    }
    async rmdir(path) {
      return this.unlink(path);
    }
    async mkdir(path) {
      const existingHandle = await this.getHandle(path);
      if (existingHandle) {
        throw ErrnoError.With("EEXIST", path, "mkdir");
      }
      const handle = await this.getHandle(dirname(path));
      if (!(handle instanceof FileSystemDirectoryHandle)) {
        throw ErrnoError.With("ENOTDIR", path, "mkdir");
      }
      await handle.getDirectoryHandle(basename(path), { create: true });
    }
    async readdir(path) {
      const handle = await this.getHandle(path);
      if (!(handle instanceof FileSystemDirectoryHandle)) {
        throw ErrnoError.With("ENOTDIR", path, "readdir");
      }
      const _keys = [];
      for await (const key of handle.keys()) {
        _keys.push(join(path, key));
      }
      return _keys;
    }
    async getHandle(path) {
      if (this._handles.has(path)) {
        return this._handles.get(path);
      }
      let walked = "/";
      for (const part of path.split("/").slice(1)) {
        const handle = this._handles.get(walked);
        if (!(handle instanceof FileSystemDirectoryHandle)) {
          throw ErrnoError.With("ENOTDIR", walked, "getHandle");
        }
        walked = join(walked, part);
        try {
          const dirHandle = await handle.getDirectoryHandle(part);
          this._handles.set(walked, dirHandle);
        } catch (_ex) {
          const ex = _ex;
          if (ex.name == "TypeMismatchError") {
            try {
              const fileHandle = await handle.getFileHandle(part);
              this._handles.set(walked, fileHandle);
            } catch (ex2) {
              convertException(ex2, walked, "getHandle");
            }
          }
          if (ex.name === "TypeError") {
            throw new ErrnoError(Errno.ENOENT, ex.message, walked, "getHandle");
          }
          convertException(ex, walked, "getHandle");
        }
      }
      return this._handles.get(path);
    }
  };
  __name(WebAccessFS, "WebAccessFS");
  var WebAccess = {
    name: "WebAccess",
    options: {
      handle: {
        type: "object",
        required: true,
        description: "The directory handle to use for the root"
      }
    },
    isAvailable() {
      return typeof FileSystemHandle == "function";
    },
    create(options) {
      return new WebAccessFS(options);
    }
  };

  // node_modules/@zenfs/core/dist/error.js
  var Errno2;
  (function(Errno3) {
    Errno3[Errno3["EPERM"] = 1] = "EPERM";
    Errno3[Errno3["ENOENT"] = 2] = "ENOENT";
    Errno3[Errno3["EINTR"] = 4] = "EINTR";
    Errno3[Errno3["EIO"] = 5] = "EIO";
    Errno3[Errno3["ENXIO"] = 6] = "ENXIO";
    Errno3[Errno3["EBADF"] = 9] = "EBADF";
    Errno3[Errno3["EAGAIN"] = 11] = "EAGAIN";
    Errno3[Errno3["ENOMEM"] = 12] = "ENOMEM";
    Errno3[Errno3["EACCES"] = 13] = "EACCES";
    Errno3[Errno3["EFAULT"] = 14] = "EFAULT";
    Errno3[Errno3["ENOTBLK"] = 15] = "ENOTBLK";
    Errno3[Errno3["EBUSY"] = 16] = "EBUSY";
    Errno3[Errno3["EEXIST"] = 17] = "EEXIST";
    Errno3[Errno3["EXDEV"] = 18] = "EXDEV";
    Errno3[Errno3["ENODEV"] = 19] = "ENODEV";
    Errno3[Errno3["ENOTDIR"] = 20] = "ENOTDIR";
    Errno3[Errno3["EISDIR"] = 21] = "EISDIR";
    Errno3[Errno3["EINVAL"] = 22] = "EINVAL";
    Errno3[Errno3["ENFILE"] = 23] = "ENFILE";
    Errno3[Errno3["EMFILE"] = 24] = "EMFILE";
    Errno3[Errno3["ETXTBSY"] = 26] = "ETXTBSY";
    Errno3[Errno3["EFBIG"] = 27] = "EFBIG";
    Errno3[Errno3["ENOSPC"] = 28] = "ENOSPC";
    Errno3[Errno3["ESPIPE"] = 29] = "ESPIPE";
    Errno3[Errno3["EROFS"] = 30] = "EROFS";
    Errno3[Errno3["EMLINK"] = 31] = "EMLINK";
    Errno3[Errno3["EPIPE"] = 32] = "EPIPE";
    Errno3[Errno3["EDOM"] = 33] = "EDOM";
    Errno3[Errno3["ERANGE"] = 34] = "ERANGE";
    Errno3[Errno3["EDEADLK"] = 35] = "EDEADLK";
    Errno3[Errno3["ENAMETOOLONG"] = 36] = "ENAMETOOLONG";
    Errno3[Errno3["ENOLCK"] = 37] = "ENOLCK";
    Errno3[Errno3["ENOSYS"] = 38] = "ENOSYS";
    Errno3[Errno3["ENOTEMPTY"] = 39] = "ENOTEMPTY";
    Errno3[Errno3["ELOOP"] = 40] = "ELOOP";
    Errno3[Errno3["ENOMSG"] = 42] = "ENOMSG";
    Errno3[Errno3["EBADE"] = 52] = "EBADE";
    Errno3[Errno3["EBADR"] = 53] = "EBADR";
    Errno3[Errno3["EXFULL"] = 54] = "EXFULL";
    Errno3[Errno3["ENOANO"] = 55] = "ENOANO";
    Errno3[Errno3["EBADRQC"] = 56] = "EBADRQC";
    Errno3[Errno3["ENOSTR"] = 60] = "ENOSTR";
    Errno3[Errno3["ENODATA"] = 61] = "ENODATA";
    Errno3[Errno3["ETIME"] = 62] = "ETIME";
    Errno3[Errno3["ENOSR"] = 63] = "ENOSR";
    Errno3[Errno3["ENONET"] = 64] = "ENONET";
    Errno3[Errno3["EREMOTE"] = 66] = "EREMOTE";
    Errno3[Errno3["ENOLINK"] = 67] = "ENOLINK";
    Errno3[Errno3["ECOMM"] = 70] = "ECOMM";
    Errno3[Errno3["EPROTO"] = 71] = "EPROTO";
    Errno3[Errno3["EBADMSG"] = 74] = "EBADMSG";
    Errno3[Errno3["EOVERFLOW"] = 75] = "EOVERFLOW";
    Errno3[Errno3["EBADFD"] = 77] = "EBADFD";
    Errno3[Errno3["ESTRPIPE"] = 86] = "ESTRPIPE";
    Errno3[Errno3["ENOTSOCK"] = 88] = "ENOTSOCK";
    Errno3[Errno3["EDESTADDRREQ"] = 89] = "EDESTADDRREQ";
    Errno3[Errno3["EMSGSIZE"] = 90] = "EMSGSIZE";
    Errno3[Errno3["EPROTOTYPE"] = 91] = "EPROTOTYPE";
    Errno3[Errno3["ENOPROTOOPT"] = 92] = "ENOPROTOOPT";
    Errno3[Errno3["EPROTONOSUPPORT"] = 93] = "EPROTONOSUPPORT";
    Errno3[Errno3["ESOCKTNOSUPPORT"] = 94] = "ESOCKTNOSUPPORT";
    Errno3[Errno3["ENOTSUP"] = 95] = "ENOTSUP";
    Errno3[Errno3["ENETDOWN"] = 100] = "ENETDOWN";
    Errno3[Errno3["ENETUNREACH"] = 101] = "ENETUNREACH";
    Errno3[Errno3["ENETRESET"] = 102] = "ENETRESET";
    Errno3[Errno3["ETIMEDOUT"] = 110] = "ETIMEDOUT";
    Errno3[Errno3["ECONNREFUSED"] = 111] = "ECONNREFUSED";
    Errno3[Errno3["EHOSTDOWN"] = 112] = "EHOSTDOWN";
    Errno3[Errno3["EHOSTUNREACH"] = 113] = "EHOSTUNREACH";
    Errno3[Errno3["EALREADY"] = 114] = "EALREADY";
    Errno3[Errno3["EINPROGRESS"] = 115] = "EINPROGRESS";
    Errno3[Errno3["ESTALE"] = 116] = "ESTALE";
    Errno3[Errno3["EREMOTEIO"] = 121] = "EREMOTEIO";
    Errno3[Errno3["EDQUOT"] = 122] = "EDQUOT";
  })(Errno2 || (Errno2 = {}));
  var errorMessages2 = {
    [Errno2.EPERM]: "Operation not permitted",
    [Errno2.ENOENT]: "No such file or directory",
    [Errno2.EINTR]: "Interrupted system call",
    [Errno2.EIO]: "Input/output error",
    [Errno2.ENXIO]: "No such device or address",
    [Errno2.EBADF]: "Bad file descriptor",
    [Errno2.EAGAIN]: "Resource temporarily unavailable",
    [Errno2.ENOMEM]: "Cannot allocate memory",
    [Errno2.EACCES]: "Permission denied",
    [Errno2.EFAULT]: "Bad address",
    [Errno2.ENOTBLK]: "Block device required",
    [Errno2.EBUSY]: "Resource busy or locked",
    [Errno2.EEXIST]: "File exists",
    [Errno2.EXDEV]: "Invalid cross-device link",
    [Errno2.ENODEV]: "No such device",
    [Errno2.ENOTDIR]: "File is not a directory",
    [Errno2.EISDIR]: "File is a directory",
    [Errno2.EINVAL]: "Invalid argument",
    [Errno2.ENFILE]: "Too many open files in system",
    [Errno2.EMFILE]: "Too many open files",
    [Errno2.ETXTBSY]: "Text file busy",
    [Errno2.EFBIG]: "File is too big",
    [Errno2.ENOSPC]: "No space left on disk",
    [Errno2.ESPIPE]: "Illegal seek",
    [Errno2.EROFS]: "Cannot modify a read-only file system",
    [Errno2.EMLINK]: "Too many links",
    [Errno2.EPIPE]: "Broken pipe",
    [Errno2.EDOM]: "Numerical argument out of domain",
    [Errno2.ERANGE]: "Numerical result out of range",
    [Errno2.EDEADLK]: "Resource deadlock would occur",
    [Errno2.ENAMETOOLONG]: "File name too long",
    [Errno2.ENOLCK]: "No locks available",
    [Errno2.ENOSYS]: "Function not implemented",
    [Errno2.ENOTEMPTY]: "Directory is not empty",
    [Errno2.ELOOP]: "Too many levels of symbolic links",
    [Errno2.ENOMSG]: "No message of desired type",
    [Errno2.EBADE]: "Invalid exchange",
    [Errno2.EBADR]: "Invalid request descriptor",
    [Errno2.EXFULL]: "Exchange full",
    [Errno2.ENOANO]: "No anode",
    [Errno2.EBADRQC]: "Invalid request code",
    [Errno2.ENOSTR]: "Device not a stream",
    [Errno2.ENODATA]: "No data available",
    [Errno2.ETIME]: "Timer expired",
    [Errno2.ENOSR]: "Out of streams resources",
    [Errno2.ENONET]: "Machine is not on the network",
    [Errno2.EREMOTE]: "Object is remote",
    [Errno2.ENOLINK]: "Link has been severed",
    [Errno2.ECOMM]: "Communication error on send",
    [Errno2.EPROTO]: "Protocol error",
    [Errno2.EBADMSG]: "Bad message",
    [Errno2.EOVERFLOW]: "Value too large for defined data type",
    [Errno2.EBADFD]: "File descriptor in bad state",
    [Errno2.ESTRPIPE]: "Streams pipe error",
    [Errno2.ENOTSOCK]: "Socket operation on non-socket",
    [Errno2.EDESTADDRREQ]: "Destination address required",
    [Errno2.EMSGSIZE]: "Message too long",
    [Errno2.EPROTOTYPE]: "Protocol wrong type for socket",
    [Errno2.ENOPROTOOPT]: "Protocol not available",
    [Errno2.EPROTONOSUPPORT]: "Protocol not supported",
    [Errno2.ESOCKTNOSUPPORT]: "Socket type not supported",
    [Errno2.ENOTSUP]: "Operation is not supported",
    [Errno2.ENETDOWN]: "Network is down",
    [Errno2.ENETUNREACH]: "Network is unreachable",
    [Errno2.ENETRESET]: "Network dropped connection on reset",
    [Errno2.ETIMEDOUT]: "Connection timed out",
    [Errno2.ECONNREFUSED]: "Connection refused",
    [Errno2.EHOSTDOWN]: "Host is down",
    [Errno2.EHOSTUNREACH]: "No route to host",
    [Errno2.EALREADY]: "Operation already in progress",
    [Errno2.EINPROGRESS]: "Operation now in progress",
    [Errno2.ESTALE]: "Stale file handle",
    [Errno2.EREMOTEIO]: "Remote I/O error",
    [Errno2.EDQUOT]: "Disk quota exceeded"
  };
  var ErrnoError2 = class extends Error {
    static fromJSON(json) {
      const err = new ErrnoError2(json.errno, json.message, json.path, json.syscall);
      err.code = json.code;
      err.stack = json.stack;
      return err;
    }
    static With(code, path, syscall) {
      return new ErrnoError2(Errno2[code], errorMessages2[Errno2[code]], path, syscall);
    }
    /**
     * Represents a ZenFS error. Passed back to applications after a failed
     * call to the ZenFS API.
     *
     * Error codes mirror those returned by regular Unix file operations, which is
     * what Node returns.
     * @param type The type of the error.
     * @param message A descriptive error message.
     */
    constructor(errno, message = errorMessages2[errno], path, syscall = "") {
      super(message);
      this.errno = errno;
      this.path = path;
      this.syscall = syscall;
      this.code = Errno2[errno];
      this.message = `${this.code}: ${message}${this.path ? `, '${this.path}'` : ""}`;
    }
    /**
     * @return A friendly error message.
     */
    toString() {
      return this.message;
    }
    toJSON() {
      return {
        errno: this.errno,
        code: this.code,
        path: this.path,
        stack: this.stack,
        message: this.message,
        syscall: this.syscall
      };
    }
    /**
     * The size of the API error in buffer-form in bytes.
     */
    bufferSize() {
      return 4 + JSON.stringify(this.toJSON()).length;
    }
  };
  __name(ErrnoError2, "ErrnoError");

  // node_modules/@zenfs/core/dist/backends/store/store.js
  var Transaction2 = class {
    constructor() {
      this.aborted = false;
    }
    async [Symbol.asyncDispose]() {
      if (this.aborted) {
        return;
      }
      await this.commit();
    }
    [Symbol.dispose]() {
      if (this.aborted) {
        return;
      }
      this.commitSync();
    }
  };
  __name(Transaction2, "Transaction");
  var AsyncTransaction2 = class extends Transaction2 {
    getSync(ino) {
      throw ErrnoError2.With("ENOSYS", void 0, "AsyncTransaction.getSync");
    }
    setSync(ino, data) {
      throw ErrnoError2.With("ENOSYS", void 0, "AsyncTransaction.setSync");
    }
    removeSync(ino) {
      throw ErrnoError2.With("ENOSYS", void 0, "AsyncTransaction.removeSync");
    }
    commitSync() {
      throw ErrnoError2.With("ENOSYS", void 0, "AsyncTransaction.commitSync");
    }
    abortSync() {
      throw ErrnoError2.With("ENOSYS", void 0, "AsyncTransaction.abortSync");
    }
  };
  __name(AsyncTransaction2, "AsyncTransaction");

  // src/IndexedDB.ts
  function wrap(request) {
    return new Promise((resolve, reject) => {
      request.onsuccess = () => resolve(request.result);
      request.onerror = (e) => {
        e.preventDefault();
        reject(convertException(request.error));
      };
    });
  }
  __name(wrap, "wrap");
  var IndexedDBTransaction = class extends AsyncTransaction2 {
    constructor(tx, store) {
      super();
      this.tx = tx;
      this.store = store;
    }
    get(key) {
      return wrap(this.store.get(key.toString()));
    }
    async set(key, data) {
      await wrap(this.store.put(data, key.toString()));
    }
    remove(key) {
      return wrap(this.store.delete(key.toString()));
    }
    async commit() {
      this.tx.commit();
    }
    async abort() {
      try {
        this.tx.abort();
      } catch (e) {
        throw convertException(e);
      }
    }
  };
  __name(IndexedDBTransaction, "IndexedDBTransaction");
  async function createDB(name, indexedDB = globalThis.indexedDB) {
    const req = indexedDB.open(name);
    req.onupgradeneeded = () => {
      const db = req.result;
      if (db.objectStoreNames.contains(name)) {
        db.deleteObjectStore(name);
      }
      db.createObjectStore(name);
    };
    const result = await wrap(req);
    return result;
  }
  __name(createDB, "createDB");
  var IndexedDBStore = class {
    constructor(db) {
      this.db = db;
    }
    sync() {
      throw new Error("Method not implemented.");
    }
    get name() {
      return IndexedDB.name + ":" + this.db.name;
    }
    clear() {
      return wrap(this.db.transaction(this.db.name, "readwrite").objectStore(this.db.name).clear());
    }
    clearSync() {
      throw ErrnoError.With("ENOSYS", void 0, "IndexedDBStore.clearSync");
    }
    transaction() {
      const tx = this.db.transaction(this.db.name, "readwrite");
      return new IndexedDBTransaction(tx, tx.objectStore(this.db.name));
    }
  };
  __name(IndexedDBStore, "IndexedDBStore");
  var IndexedDB = {
    name: "IndexedDB",
    options: {
      storeName: {
        type: "string",
        required: false,
        description: "The name of this file system. You can have multiple IndexedDB file systems operating at once, but each must have a different name."
      },
      idbFactory: {
        type: "object",
        required: false,
        description: "The IDBFactory to use. Defaults to globalThis.indexedDB."
      }
    },
    async isAvailable(idbFactory = globalThis.indexedDB) {
      try {
        if (!(idbFactory instanceof IDBFactory)) {
          return false;
        }
        const req = idbFactory.open("__zenfs_test");
        await wrap(req);
        idbFactory.deleteDatabase("__zenfs_test");
        return true;
      } catch (e) {
        idbFactory.deleteDatabase("__zenfs_test");
        return false;
      }
    },
    async create(options) {
      const db = await createDB(options.storeName || "zenfs", options.idbFactory);
      const store = new IndexedDBStore(db);
      const fs2 = new StoreFS(store);
      return fs2;
    }
  };

  // src/Storage.ts
  var WebStorageStore = class {
    constructor(_storage) {
      this._storage = _storage;
    }
    get name() {
      return WebStorage.name;
    }
    clear() {
      this._storage.clear();
    }
    clearSync() {
      this._storage.clear();
    }
    async sync() {
    }
    transaction() {
      return new SimpleTransaction(this);
    }
    get(key) {
      const data = this._storage.getItem(key.toString());
      if (typeof data != "string") {
        return;
      }
      return encode(data);
    }
    set(key, data) {
      try {
        this._storage.setItem(key.toString(), decode(data));
      } catch (e) {
        throw new ErrnoError(Errno.ENOSPC, "Storage is full.");
      }
    }
    delete(key) {
      try {
        this._storage.removeItem(key.toString());
      } catch (e) {
        throw new ErrnoError(Errno.EIO, "Unable to delete key " + key + ": " + e);
      }
    }
  };
  __name(WebStorageStore, "WebStorageStore");
  var WebStorage = {
    name: "WebStorage",
    options: {
      storage: {
        type: "object",
        required: false,
        description: "The Storage to use. Defaults to globalThis.localStorage."
      }
    },
    isAvailable(storage = globalThis.localStorage) {
      return storage instanceof globalThis.Storage;
    },
    create({ storage = globalThis.localStorage }) {
      return new StoreFS(new WebStorageStore(storage));
    }
  };
  return __toCommonJS(src_exports);
})();
//# sourceMappingURL=browser.js.map
