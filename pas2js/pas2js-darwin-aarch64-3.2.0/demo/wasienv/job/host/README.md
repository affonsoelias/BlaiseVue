This directory contains a generic pas2js program to load a webassembly
module using JOB. 

By default it loads demo.wasm, but by creating a file host-config.js with
the following contents:
```javascript
var 
  wasmFilename = "wasmdemo.wasm";
```
you can change the loaded file without needing to recompile the application.

You can also specify the webassembly module to load in the hash part of the
URL:

```
http://localhost:8080/index.html#wasmdemo.wasm
```
will achieve the same as the config file.

