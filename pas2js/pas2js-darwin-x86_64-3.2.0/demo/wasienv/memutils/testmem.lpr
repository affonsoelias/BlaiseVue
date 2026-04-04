program testmem;

uses wasmtypes, webassembly, wasm.http.api, wasm.memutils;

procedure DoGrow(aPages : longint);

begin
  writeln('Growing wasm memory with ',aPages,' pages of 64k');
end;

var
  i : integer;
  p : pointer;

begin
  MemGrowNotifyCallBack:=@DoGrow;
  for I:=1 to 20 do
    getmem(p,1024*256*i);
end.

