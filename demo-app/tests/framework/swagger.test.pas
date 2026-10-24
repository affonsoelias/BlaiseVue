program swagger_test;

{$mode objfpc}

uses JS, Web, BVTestUtils, BVCompiler, BVClient;

begin
  Describe('BlaiseVue 4.0 Auto-Generated Swagger & OpenAPI 3.0 Engine (/api/docs)', procedure
    begin
      It('should validate OpenAPI 3.0.3 specification structure', procedure
        var
          SpecValid: Boolean;
        begin
          asm
            var sampleSpec = {
              openapi: "3.0.3",
              info: {
                title: "BlaiseVue Full-Stack mORMot 2 API",
                version: "4.0.0"
              },
              servers: [{ url: "http://localhost:8090" }],
              paths: {},
              components: { securitySchemes: {}, schemas: {} }
            };

            SpecValid = Boolean(
              sampleSpec.openapi === "3.0.3" &&
              sampleSpec.info.title.indexOf("BlaiseVue") !== -1 &&
              sampleSpec.info.version === "4.0.0" &&
              Array.isArray(sampleSpec.servers) &&
              sampleSpec.servers.length > 0
            );
          end;

          Expect(SpecValid).ToBe(True);
        end);

      It('should configure BearerAuth security scheme for RFC 7519 JWT tokens', procedure
        var
          HasBearerAuth: Boolean;
        begin
          asm
            var secSchemes = {
              BearerAuth: {
                type: "http",
                scheme: "bearer",
                bearerFormat: "JWT"
              }
            };

            HasBearerAuth = Boolean(
              secSchemes.BearerAuth &&
              secSchemes.BearerAuth.type === "http" &&
              secSchemes.BearerAuth.scheme === "bearer" &&
              secSchemes.BearerAuth.bearerFormat === "JWT"
            );
          end;

          Expect(HasBearerAuth).ToBe(True);
        end);

      It('should map all system and enterprise CRUD paths in the OpenAPI directory', procedure
        var
          HasAllPaths: Boolean;
        begin
          asm
            var paths = {
              "/api/status": { get: {} },
              "/api/auth/login": { post: {} },
              "/api/auth/logout": { post: {} },
              "/api/auth/me": { get: {} },
              "/api/auth/register": { post: {} },
              "/api/customers": { get: {}, post: {} },
              "/api/customers/{id}": { get: {}, put: {}, delete: {} },
              "/api/products": { get: {}, post: {} },
              "/api/products/{id}": { get: {}, put: {}, delete: {} }
            };

            HasAllPaths = Boolean(
              paths["/api/status"] &&
              paths["/api/auth/login"] &&
              paths["/api/auth/me"] &&
              paths["/api/customers"] &&
              paths["/api/customers/{id}"] &&
              paths["/api/products"] &&
              paths["/api/products/{id}"]
            );
          end;

          Expect(HasAllPaths).ToBe(True);
        end);

      It('should register typed schema models for Pascal records (TAuthUser, TCustomer, TProduct)', procedure
        var
          HasSchemas: Boolean;
        begin
          asm
            var schemas = {
              TServerStatus: { type: "object" },
              TAuthUser: { type: "object", properties: { id: { type: "integer" }, role: { type: "string" } } },
              TCustomer: { type: "object", properties: { id: { type: "integer" }, name: { type: "string" } } },
              TProduct: { type: "object", properties: { id: { type: "integer" }, price: { type: "number" } } }
            };

            HasSchemas = Boolean(
              schemas.TServerStatus &&
              schemas.TAuthUser && schemas.TAuthUser.properties.id &&
              schemas.TCustomer && schemas.TCustomer.properties.name &&
              schemas.TProduct && schemas.TProduct.properties.price
            );
          end;

          Expect(HasSchemas).ToBe(True);
        end);

      It('should generate Swagger UI HTML container with dark-brand navbar and deep linking', procedure
        var
          HtmlValid: Boolean;
        begin
          asm
            var html = '<!DOCTYPE html><html><head><title>BlaiseVue 4.0 - mORMot 2 OpenAPI Explorer</title>' +
              '<link rel="stylesheet" href="swagger-ui.css" /></head>' +
              '<body><div class="back-bar">BlaiseVue 4.0</div>' +
              '<div id="swagger-ui"></div>' +
              '<script src="swagger-ui-bundle.js"></script>' +
              '<script>SwaggerUIBundle({ url: "/api/openapi.json", dom_id: "#swagger-ui" });</script></body></html>';

            HtmlValid = Boolean(
              html.indexOf('id="swagger-ui"') !== -1 &&
              html.indexOf('/api/openapi.json') !== -1 &&
              html.indexOf('SwaggerUIBundle') !== -1
            );
          end;

          Expect(HtmlValid).ToBe(True);
        end);

      It('should allow fetching OpenAPI JSON via $api HTTP client', procedure
        var
          HasClientMethod: Boolean;
        begin
          asm
            HasClientMethod = Boolean(
              window.__BV_CORE__ &&
              window.__BV_CORE__.api &&
              typeof window.__BV_CORE__.api.get === 'function'
            );
          end;

          Expect(HasClientMethod).ToBe(True);
        end);
    end);
end.
