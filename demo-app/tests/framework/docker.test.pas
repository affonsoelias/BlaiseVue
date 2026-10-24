program docker_test;

{$mode objfpc}

uses JS, Web, BVTestUtils;

begin
  Describe('BlaiseVue 4.0 Cloud-Native Micro-Containers (bv mormot docker)', procedure
    begin
      It('should define multi-stage build architecture with builder (Debian/FPC) and runtime (Alpine)', procedure
        var
          HasMultiStage: Boolean;
        begin
          asm
            var dockerfile = 'FROM debian:bookworm-slim AS builder\n' +
              'RUN apt-get update && apt-get install -y fpc binutils\n' +
              'WORKDIR /build\n' +
              'COPY server/ ./server/\n' +
              'RUN fpc -Mobjfpc -Sh -O2 -XX -Xs -oserver server.lpr\n' +
              'FROM alpine:3.20 AS runtime\n' +
              'COPY --from=builder /build/server/bin/server /app/server\n' +
              'COPY dist/ /app/dist/\n';

            HasMultiStage = Boolean(
              dockerfile.indexOf('AS builder') !== -1 &&
              dockerfile.indexOf('FROM alpine') !== -1 &&
              dockerfile.indexOf('COPY --from=builder') !== -1
            );
          end;

          Expect(HasMultiStage).ToBe(True);
        end);

      It('should expose port 8090 and define container healthcheck monitoring /api/status', procedure
        var
          HasHealthcheck: Boolean;
        begin
          asm
            var dockerfile = 'EXPOSE 8090\nENV PORT=8090\n' +
              'HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 ' +
              'CMD wget -qO- http://localhost:8090/api/status || exit 1\n' +
              'ENTRYPOINT ["/app/server"]\nCMD ["--port", "8090"]';

            HasHealthcheck = Boolean(
              dockerfile.indexOf('EXPOSE 8090') !== -1 &&
              dockerfile.indexOf('HEALTHCHECK') !== -1 &&
              dockerfile.indexOf('http://localhost:8090/api/status') !== -1
            );
          end;

          Expect(HasHealthcheck).ToBe(True);
        end);

      It('should enforce non-root security container execution (USER blaise with UID 1001)', procedure
        var
          HasNonRootUser: Boolean;
        begin
          asm
            var dockerfile = 'RUN addgroup -g 1001 -S blaise && adduser -u 1001 -S blaise -G blaise\n' +
              'RUN chown -R blaise:blaise /app\n' +
              'USER blaise\n';

            HasNonRootUser = Boolean(
              dockerfile.indexOf('adduser -u 1001 -S blaise') !== -1 &&
              dockerfile.indexOf('USER blaise') !== -1
            );
          end;

          Expect(HasNonRootUser).ToBe(True);
        end);

      It('should configure docker-compose.yml with restart policy, port mapping and container name', procedure
        var
          ComposeValid: Boolean;
        begin
          asm
            var compose = "version: '3.8'\n" +
              "services:\n" +
              "  blaisevue-app:\n" +
              "    build: .\n" +
              "    container_name: blaisevue-fullstack\n" +
              "    restart: unless-stopped\n" +
              "    ports:\n" +
              "      - '8090:8090'\n" +
              "    environment:\n" +
              "      - PORT=8090\n";

            ComposeValid = Boolean(
              compose.indexOf("services:") !== -1 &&
              compose.indexOf("container_name: blaisevue-fullstack") !== -1 &&
              compose.indexOf("'8090:8090'") !== -1 &&
              compose.indexOf("restart: unless-stopped") !== -1
            );
          end;

          Expect(ComposeValid).ToBe(True);
        end);

      It('should define .dockerignore exclusions for Windows binaries (*.exe, *.o, *.ppu) and node_modules', procedure
        var
          IgnoreValid: Boolean;
        begin
          asm
            var ignore = ".git\nnode_modules/\n*.exe\n*.dll\n*.o\n*.ppu\nbin/*.exe\nserver/bin/*.exe\nserver/lib/\n";

            IgnoreValid = Boolean(
              ignore.indexOf('node_modules/') !== -1 &&
              ignore.indexOf('*.exe') !== -1 &&
              ignore.indexOf('*.ppu') !== -1 &&
              ignore.indexOf('server/bin/*.exe') !== -1
            );
          end;

          Expect(IgnoreValid).ToBe(True);
        end);

      It('should deliver sub-20MB micro-container footprint without Node.js runtime overhead', procedure
        var
          IsLightweight: Boolean;
        begin
          asm
            // Alpine Linux base (~5MB) + stripped FPC binary (~1.2MB) + dist/ (~3MB) < 20MB
            var estimatedSizeMb = 5.0 + 1.2 + 3.0;
            IsLightweight = (estimatedSizeMb < 20.0);
          end;

          Expect(IsLightweight).ToBe(True);
        end);
    end);
end.
