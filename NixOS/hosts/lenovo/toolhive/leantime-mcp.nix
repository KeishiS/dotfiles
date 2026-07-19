{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:

buildNpmPackage rec {
  pname = "leantime-mcp";
  version = "1.6.5";

  src = fetchFromGitHub {
    owner = "Leantime";
    repo = "leantime-mcp";
    rev = "98bc965875446508d7d0c531e2e993a14f3cf41a";
    hash = "sha256-BzDzRdbOgvzQLZ8fgchYKeU48v5IE6VySEjcMcr+xbI=";
  };

  npmDepsHash = "sha256-PPzlJoerSWjhBakggPA5a1O1s8LPk9bmrbn8JbQB5fQ=";

  npmBuildScript = "build";

  meta = {
    description = "Official MCP client bridge for the Leantime MCP Server plugin";
    homepage = "https://github.com/Leantime/leantime-mcp";
    license = lib.licenses.mit;
    mainProgram = "leantime-mcp";
  };
}
