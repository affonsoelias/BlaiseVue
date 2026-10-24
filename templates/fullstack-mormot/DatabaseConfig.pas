unit DatabaseConfig;

{
  DatabaseConfig - Multi-Database ORM Configuration for mORMot 2
  --------------------------------------------------------------
  Supports Pluggable Database Engines:
  - SQLite3 (Zero-Config Embedded Local File)
  - PostgreSQL (High-Throughput Enterprise RDBMS via native libpq)
  - MySQL / MariaDB
  - Firebird SQL (Traditional Commercial Pascal Standard)
}

{$I mormot.defines.inc}

interface

uses
  sysutils,
  classes,
  mormot.core.base,
  mormot.core.os;

type
  TBlaiseDatabaseEngine = (deSqlite, dePostgres, deMySql, deFirebird);

  TBlaiseDatabaseConfig = record
    Engine: TBlaiseDatabaseEngine;
    ConnectionString: RawUtf8;
    Host: RawUtf8;
    Port: Integer;
    DatabaseName: RawUtf8;
    UserName: RawUtf8;
    Password: RawUtf8;
    class function EngineToString(AEngine: TBlaiseDatabaseEngine): string; static;
    class function StringToEngine(const AStr: string): TBlaiseDatabaseEngine; static;
    class function GetDefaultUrl(AEngine: TBlaiseDatabaseEngine): string; static;
    class function LoadFromEnv(const EnvPath: string = ''): TBlaiseDatabaseConfig; static;
  end;

implementation

{ TBlaiseDatabaseConfig }

class function TBlaiseDatabaseConfig.EngineToString(AEngine: TBlaiseDatabaseEngine): string;
begin
  case AEngine of
    deSqlite:   Result := 'sqlite';
    dePostgres: Result := 'postgres';
    deMySql:    Result := 'mysql';
    deFirebird: Result := 'firebird';
  else
    Result := 'sqlite';
  end;
end;

class function TBlaiseDatabaseConfig.StringToEngine(const AStr: string): TBlaiseDatabaseEngine;
var
  S: string;
begin
  S := LowerCase(Trim(AStr));
  if (S = 'postgres') or (S = 'postgresql') or (S = 'pgsql') then
    Result := dePostgres
  else if (S = 'mysql') or (S = 'mariadb') then
    Result := deMySql
  else if (S = 'firebird') or (S = 'fb') then
    Result := deFirebird
  else
    Result := deSqlite;
end;

class function TBlaiseDatabaseConfig.GetDefaultUrl(AEngine: TBlaiseDatabaseEngine): string;
begin
  case AEngine of
    deSqlite:   Result := 'sqlite://server/data.db';
    dePostgres: Result := 'postgres://postgres:postgres@localhost:5432/blaisevue_app';
    deMySql:    Result := 'mysql://root:password@localhost:3306/blaisevue_app';
    deFirebird: Result := 'firebird://SYSDBA:masterkey@localhost:3050/server/data.fdb';
  else
    Result := 'sqlite://server/data.db';
  end;
end;

class function TBlaiseDatabaseConfig.LoadFromEnv(const EnvPath: string): TBlaiseDatabaseConfig;
var
  Lines: TStringList;
  i, EqPos: Integer;
  Key, Val, TargetFile: string;
  EngineStr, UrlStr: string;
begin
  Result.Engine := deSqlite;
  Result.ConnectionString := 'sqlite://server/data.db';
  Result.Host := 'localhost';
  Result.Port := 8090;
  Result.DatabaseName := 'data.db';
  Result.UserName := '';
  Result.Password := '';

  // 1. Try reading .env
  TargetFile := EnvPath;
  if (TargetFile = '') and FileExists('.env') then
    TargetFile := '.env'
  else if (TargetFile = '') and FileExists('../.env') then
    TargetFile := '../.env';

  EngineStr := '';
  UrlStr := '';

  if (TargetFile <> '') and FileExists(TargetFile) then
  begin
    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(TargetFile);
      for i := 0 to Lines.Count - 1 do
      begin
        Key := Trim(Lines[i]);
        if (Key = '') or (Key[1] = '#') then Continue;
        EqPos := Pos('=', Key);
        if EqPos > 1 then
        begin
          Val := Trim(Copy(Key, EqPos + 1, MaxInt));
          Key := UpperCase(Trim(Copy(Key, 1, EqPos - 1)));
          if Key = 'DATABASE_ENGINE' then EngineStr := Val
          else if Key = 'DATABASE_URL' then UrlStr := Val;
        end;
      end;
    finally
      Lines.Free;
    end;
  end;

  // 2. Check System Environment Variables fallback
  if EngineStr = '' then EngineStr := GetEnvironmentVariable('DATABASE_ENGINE');
  if UrlStr = '' then UrlStr := GetEnvironmentVariable('DATABASE_URL');

  if EngineStr <> '' then
    Result.Engine := StringToEngine(EngineStr);

  if UrlStr <> '' then
    Result.ConnectionString := RawUtf8(UrlStr)
  else
    Result.ConnectionString := RawUtf8(GetDefaultUrl(Result.Engine));
end;

end.
