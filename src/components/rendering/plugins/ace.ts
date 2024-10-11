import ace from "ace-builds";
import "ace-builds/src-noconflict/theme-dreamweaver";
import "ace-builds/src-noconflict/theme-monokai";
import "ace-builds/src-noconflict/ext-linking";

import themeDreamweaverUrl from "ace-builds/src-noconflict/theme-dreamweaver?url";
import themeMonokaiUrl from "ace-builds/src-noconflict/theme-monokai?url";
import modeAbapUrl from "ace-builds/src-noconflict/mode-abap?url";
import modeAbcUrl from "ace-builds/src-noconflict/mode-abc?url";
import modeActionscriptUrl from "ace-builds/src-noconflict/mode-actionscript?url";
import modeAdaUrl from "ace-builds/src-noconflict/mode-ada?url";
import modeAldaUrl from "ace-builds/src-noconflict/mode-alda?url";
import modeApacheConfUrl from "ace-builds/src-noconflict/mode-apache_conf?url";
import modeApexUrl from "ace-builds/src-noconflict/mode-apex?url";
import modeAqlUrl from "ace-builds/src-noconflict/mode-aql?url";
import modeAsciidocUrl from "ace-builds/src-noconflict/mode-asciidoc?url";
import modeAslUrl from "ace-builds/src-noconflict/mode-asl?url";
import modeAssemblyArm32Url from "ace-builds/src-noconflict/mode-assembly_arm32?url";
import modeAssemblyX86Url from "ace-builds/src-noconflict/mode-assembly_x86?url";
import modeAstroUrl from "ace-builds/src-noconflict/mode-astro?url";
import modeAutohotkeyUrl from "ace-builds/src-noconflict/mode-autohotkey?url";
import modeBatchfileUrl from "ace-builds/src-noconflict/mode-batchfile?url";
import modeBibtexUrl from "ace-builds/src-noconflict/mode-bibtex?url";
import modeCCppUrl from "ace-builds/src-noconflict/mode-c_cpp?url";
import modeC9searchUrl from "ace-builds/src-noconflict/mode-c9search?url";
import modeCirruUrl from "ace-builds/src-noconflict/mode-cirru?url";
import modeClojureUrl from "ace-builds/src-noconflict/mode-clojure?url";
import modeCobolUrl from "ace-builds/src-noconflict/mode-cobol?url";
import modeCoffeeUrl from "ace-builds/src-noconflict/mode-coffee?url";
import modeColdfusionUrl from "ace-builds/src-noconflict/mode-coldfusion?url";
import modeCrystalUrl from "ace-builds/src-noconflict/mode-crystal?url";
import modeCsharpUrl from "ace-builds/src-noconflict/mode-csharp?url";
import modeCsoundDocumentUrl from "ace-builds/src-noconflict/mode-csound_document?url";
import modeCsoundOrchestraUrl from "ace-builds/src-noconflict/mode-csound_orchestra?url";
import modeCsoundScoreUrl from "ace-builds/src-noconflict/mode-csound_score?url";
import modeCssUrl from "ace-builds/src-noconflict/mode-css?url";
import modeCurlyUrl from "ace-builds/src-noconflict/mode-curly?url";
import modeCuttlefishUrl from "ace-builds/src-noconflict/mode-cuttlefish?url";
import modeDUrl from "ace-builds/src-noconflict/mode-d?url";
import modeDartUrl from "ace-builds/src-noconflict/mode-dart?url";
import modeDiffUrl from "ace-builds/src-noconflict/mode-diff?url";
import modeDjangoUrl from "ace-builds/src-noconflict/mode-django?url";
import modeDockerfileUrl from "ace-builds/src-noconflict/mode-dockerfile?url";
import modeDotUrl from "ace-builds/src-noconflict/mode-dot?url";
import modeDroolsUrl from "ace-builds/src-noconflict/mode-drools?url";
import modeEdifactUrl from "ace-builds/src-noconflict/mode-edifact?url";
import modeEiffelUrl from "ace-builds/src-noconflict/mode-eiffel?url";
import modeEjsUrl from "ace-builds/src-noconflict/mode-ejs?url";
import modeElixirUrl from "ace-builds/src-noconflict/mode-elixir?url";
import modeElmUrl from "ace-builds/src-noconflict/mode-elm?url";
import modeErlangUrl from "ace-builds/src-noconflict/mode-erlang?url";
import modeFlixUrl from "ace-builds/src-noconflict/mode-flix?url";
import modeForthUrl from "ace-builds/src-noconflict/mode-forth?url";
import modeFortranUrl from "ace-builds/src-noconflict/mode-fortran?url";
import modeFsharpUrl from "ace-builds/src-noconflict/mode-fsharp?url";
import modeFslUrl from "ace-builds/src-noconflict/mode-fsl?url";
import modeFtlUrl from "ace-builds/src-noconflict/mode-ftl?url";
import modeGcodeUrl from "ace-builds/src-noconflict/mode-gcode?url";
import modeGherkinUrl from "ace-builds/src-noconflict/mode-gherkin?url";
import modeGitignoreUrl from "ace-builds/src-noconflict/mode-gitignore?url";
import modeGlslUrl from "ace-builds/src-noconflict/mode-glsl?url";
import modeGobstonesUrl from "ace-builds/src-noconflict/mode-gobstones?url";
import modeGolangUrl from "ace-builds/src-noconflict/mode-golang?url";
import modeGraphqlschemaUrl from "ace-builds/src-noconflict/mode-graphqlschema?url";
import modeGroovyUrl from "ace-builds/src-noconflict/mode-groovy?url";
import modeHamlUrl from "ace-builds/src-noconflict/mode-haml?url";
import modeHandlebarsUrl from "ace-builds/src-noconflict/mode-handlebars?url";
import modeHaskellUrl from "ace-builds/src-noconflict/mode-haskell?url";
import modeHaskellCabalUrl from "ace-builds/src-noconflict/mode-haskell_cabal?url";
import modeHaxeUrl from "ace-builds/src-noconflict/mode-haxe?url";
import modeHjsonUrl from "ace-builds/src-noconflict/mode-hjson?url";
import modeHtmlUrl from "ace-builds/src-noconflict/mode-html?url";
import modeHtmlElixirUrl from "ace-builds/src-noconflict/mode-html_elixir?url";
import modeHtmlRubyUrl from "ace-builds/src-noconflict/mode-html_ruby?url";
import modeIniUrl from "ace-builds/src-noconflict/mode-ini?url";
import modeIoUrl from "ace-builds/src-noconflict/mode-io?url";
import modeIonUrl from "ace-builds/src-noconflict/mode-ion?url";
import modeJackUrl from "ace-builds/src-noconflict/mode-jack?url";
import modeJadeUrl from "ace-builds/src-noconflict/mode-jade?url";
import modeJavaUrl from "ace-builds/src-noconflict/mode-java?url";
import modeJavascriptUrl from "ace-builds/src-noconflict/mode-javascript?url";
import modeJexlUrl from "ace-builds/src-noconflict/mode-jexl?url";
import modeJsonUrl from "ace-builds/src-noconflict/mode-json?url";
import modeJson5Url from "ace-builds/src-noconflict/mode-json5?url";
import modeJsoniqUrl from "ace-builds/src-noconflict/mode-jsoniq?url";
import modeJspUrl from "ace-builds/src-noconflict/mode-jsp?url";
import modeJssmUrl from "ace-builds/src-noconflict/mode-jssm?url";
import modeJsxUrl from "ace-builds/src-noconflict/mode-jsx?url";
import modeJuliaUrl from "ace-builds/src-noconflict/mode-julia?url";
import modeKotlinUrl from "ace-builds/src-noconflict/mode-kotlin?url";
import modeLatexUrl from "ace-builds/src-noconflict/mode-latex?url";
import modeLatteUrl from "ace-builds/src-noconflict/mode-latte?url";
import modeLessUrl from "ace-builds/src-noconflict/mode-less?url";
import modeLiquidUrl from "ace-builds/src-noconflict/mode-liquid?url";
import modeLispUrl from "ace-builds/src-noconflict/mode-lisp?url";
import modeLivescriptUrl from "ace-builds/src-noconflict/mode-livescript?url";
import modeLogiqlUrl from "ace-builds/src-noconflict/mode-logiql?url";
import modeLogtalkUrl from "ace-builds/src-noconflict/mode-logtalk?url";
import modeLslUrl from "ace-builds/src-noconflict/mode-lsl?url";
import modeLuaUrl from "ace-builds/src-noconflict/mode-lua?url";
import modeLuapageUrl from "ace-builds/src-noconflict/mode-luapage?url";
import modeLuceneUrl from "ace-builds/src-noconflict/mode-lucene?url";
import modeMakefileUrl from "ace-builds/src-noconflict/mode-makefile?url";
import modeMarkdownUrl from "ace-builds/src-noconflict/mode-markdown?url";
import modeMaskUrl from "ace-builds/src-noconflict/mode-mask?url";
import modeMatlabUrl from "ace-builds/src-noconflict/mode-matlab?url";
import modeMazeUrl from "ace-builds/src-noconflict/mode-maze?url";
import modeMediawikiUrl from "ace-builds/src-noconflict/mode-mediawiki?url";
import modeMelUrl from "ace-builds/src-noconflict/mode-mel?url";
import modeMipsUrl from "ace-builds/src-noconflict/mode-mips?url";
import modeMixalUrl from "ace-builds/src-noconflict/mode-mixal?url";
import modeMushcodeUrl from "ace-builds/src-noconflict/mode-mushcode?url";
import modeMysqlUrl from "ace-builds/src-noconflict/mode-mysql?url";
import modeNasalUrl from "ace-builds/src-noconflict/mode-nasal?url";
import modeNginxUrl from "ace-builds/src-noconflict/mode-nginx?url";
import modeNimUrl from "ace-builds/src-noconflict/mode-nim?url";
import modeNixUrl from "ace-builds/src-noconflict/mode-nix?url";
import modeNsisUrl from "ace-builds/src-noconflict/mode-nsis?url";
import modeNunjucksUrl from "ace-builds/src-noconflict/mode-nunjucks?url";
import modeObjectivecUrl from "ace-builds/src-noconflict/mode-objectivec?url";
import modeOcamlUrl from "ace-builds/src-noconflict/mode-ocaml?url";
import modeOdinUrl from "ace-builds/src-noconflict/mode-odin?url";
import modePartiqlUrl from "ace-builds/src-noconflict/mode-partiql?url";
import modePascalUrl from "ace-builds/src-noconflict/mode-pascal?url";
import modePerlUrl from "ace-builds/src-noconflict/mode-perl?url";
import modePgsqlUrl from "ace-builds/src-noconflict/mode-pgsql?url";
import modePhpUrl from "ace-builds/src-noconflict/mode-php?url";
import modePhpLaravelBladeUrl from "ace-builds/src-noconflict/mode-php_laravel_blade?url";
import modePigUrl from "ace-builds/src-noconflict/mode-pig?url";
import modePlsqlUrl from "ace-builds/src-noconflict/mode-plsql?url";
import modePowershellUrl from "ace-builds/src-noconflict/mode-powershell?url";
import modePraatUrl from "ace-builds/src-noconflict/mode-praat?url";
import modePrismaUrl from "ace-builds/src-noconflict/mode-prisma?url";
import modePrologUrl from "ace-builds/src-noconflict/mode-prolog?url";
import modePropertiesUrl from "ace-builds/src-noconflict/mode-properties?url";
import modeProtobufUrl from "ace-builds/src-noconflict/mode-protobuf?url";
import modePrqlUrl from "ace-builds/src-noconflict/mode-prql?url";
import modePuppetUrl from "ace-builds/src-noconflict/mode-puppet?url";
import modePythonUrl from "ace-builds/src-noconflict/mode-python?url";
import modeQmlUrl from "ace-builds/src-noconflict/mode-qml?url";
import modeRUrl from "ace-builds/src-noconflict/mode-r?url";
import modeRakuUrl from "ace-builds/src-noconflict/mode-raku?url";
import modeRazorUrl from "ace-builds/src-noconflict/mode-razor?url";
import modeRdocUrl from "ace-builds/src-noconflict/mode-rdoc?url";
import modeRedUrl from "ace-builds/src-noconflict/mode-red?url";
import modeRhtmlUrl from "ace-builds/src-noconflict/mode-rhtml?url";
import modeRobotUrl from "ace-builds/src-noconflict/mode-robot?url";
import modeRstUrl from "ace-builds/src-noconflict/mode-rst?url";
import modeRubyUrl from "ace-builds/src-noconflict/mode-ruby?url";
import modeRustUrl from "ace-builds/src-noconflict/mode-rust?url";
import modeSacUrl from "ace-builds/src-noconflict/mode-sac?url";
import modeSassUrl from "ace-builds/src-noconflict/mode-sass?url";
import modeScadUrl from "ace-builds/src-noconflict/mode-scad?url";
import modeScalaUrl from "ace-builds/src-noconflict/mode-scala?url";
import modeSchemeUrl from "ace-builds/src-noconflict/mode-scheme?url";
import modeScryptUrl from "ace-builds/src-noconflict/mode-scrypt?url";
import modeScssUrl from "ace-builds/src-noconflict/mode-scss?url";
import modeShUrl from "ace-builds/src-noconflict/mode-sh?url";
import modeSjsUrl from "ace-builds/src-noconflict/mode-sjs?url";
import modeSlimUrl from "ace-builds/src-noconflict/mode-slim?url";
import modeSmartyUrl from "ace-builds/src-noconflict/mode-smarty?url";
import modeSmithyUrl from "ace-builds/src-noconflict/mode-smithy?url";
import modeSnippetsUrl from "ace-builds/src-noconflict/mode-snippets?url";
import modeSoyTemplateUrl from "ace-builds/src-noconflict/mode-soy_template?url";
import modeSpaceUrl from "ace-builds/src-noconflict/mode-space?url";
import modeSparqlUrl from "ace-builds/src-noconflict/mode-sparql?url";
import modeSqlUrl from "ace-builds/src-noconflict/mode-sql?url";
import modeSqlserverUrl from "ace-builds/src-noconflict/mode-sqlserver?url";
import modeStylusUrl from "ace-builds/src-noconflict/mode-stylus?url";
import modeSvgUrl from "ace-builds/src-noconflict/mode-svg?url";
import modeSwiftUrl from "ace-builds/src-noconflict/mode-swift?url";
import modeTclUrl from "ace-builds/src-noconflict/mode-tcl?url";
import modeTerraformUrl from "ace-builds/src-noconflict/mode-terraform?url";
import modeTexUrl from "ace-builds/src-noconflict/mode-tex?url";
import modeTextUrl from "ace-builds/src-noconflict/mode-text?url";
import modeTextileUrl from "ace-builds/src-noconflict/mode-textile?url";
import modeTomlUrl from "ace-builds/src-noconflict/mode-toml?url";
import modeTsxUrl from "ace-builds/src-noconflict/mode-tsx?url";
import modeTurtleUrl from "ace-builds/src-noconflict/mode-turtle?url";
import modeTwigUrl from "ace-builds/src-noconflict/mode-twig?url";
import modeTypescriptUrl from "ace-builds/src-noconflict/mode-typescript?url";
import modeValaUrl from "ace-builds/src-noconflict/mode-vala?url";
import modeVbscriptUrl from "ace-builds/src-noconflict/mode-vbscript?url";
import modeVelocityUrl from "ace-builds/src-noconflict/mode-velocity?url";
import modeVerilogUrl from "ace-builds/src-noconflict/mode-verilog?url";
import modeVhdlUrl from "ace-builds/src-noconflict/mode-vhdl?url";
import modeVisualforceUrl from "ace-builds/src-noconflict/mode-visualforce?url";
import modeVueUrl from "ace-builds/src-noconflict/mode-vue?url";
import modeWollokUrl from "ace-builds/src-noconflict/mode-wollok?url";
import modeXmlUrl from "ace-builds/src-noconflict/mode-xml?url";
import modeXqueryUrl from "ace-builds/src-noconflict/mode-xquery?url";
import modeYamlUrl from "ace-builds/src-noconflict/mode-yaml?url";
import modeZeekUrl from "ace-builds/src-noconflict/mode-zeek?url";
import modeZigUrl from "ace-builds/src-noconflict/mode-zig?url";
import workerBaseUrl from "ace-builds/src-noconflict/worker-base?url";
import workerCoffeeUrl from "ace-builds/src-noconflict/worker-coffee.js?url";
import workerCssUrl from "ace-builds/src-noconflict/worker-css.js?url";
import workerHtmlUrl from "ace-builds/src-noconflict/worker-html.js?url";
import workerJavascriptUrl from "ace-builds/src-noconflict/worker-javascript.js?url";
import workerJsonUrl from "ace-builds/src-noconflict/worker-json.js?url";
import workerLuaUrl from "ace-builds/src-noconflict/worker-lua.js?url";
import workerPhpUrl from "ace-builds/src-noconflict/worker-php.js?url";
import workerXmlUrl from "ace-builds/src-noconflict/worker-xml.js?url";
import workerXqueryUrl from "ace-builds/src-noconflict/worker-xquery.js?url";
import workerYamlUrl from "ace-builds/src-noconflict/worker-yaml.js?url";

import extSearchboxUrl from "ace-builds/src-noconflict/ext-searchbox?url";
import "ace-builds/src-noconflict/ext-language_tools";

export type AceMode =
  | "abap"
  | "abc"
  | "actionscript"
  | "ada"
  | "alda"
  | "apache_conf"
  | "apex"
  | "aql"
  | "asciidoc"
  | "asl"
  | "assembly_arm32"
  | "assembly_x86"
  | "astro"
  | "autohotkey"
  | "batchfile"
  | "bibtex"
  | "c_cpp"
  | "c9search"
  | "cirru"
  | "clojure"
  | "cobol"
  | "coffee"
  | "coldfusion"
  | "crystal"
  | "csharp"
  | "csound_document"
  | "csound_orchestra"
  | "csound_score"
  | "css"
  | "curly"
  | "cuttlefish"
  | "d"
  | "dart"
  | "diff"
  | "django"
  | "dockerfile"
  | "dot"
  | "drools"
  | "edifact"
  | "eiffel"
  | "ejs"
  | "elixir"
  | "elm"
  | "erlang"
  | "flix"
  | "forth"
  | "fortran"
  | "fsharp"
  | "fsl"
  | "ftl"
  | "gcode"
  | "gherkin"
  | "gitignore"
  | "glsl"
  | "gobstones"
  | "golang"
  | "graphqlschema"
  | "groovy"
  | "haml"
  | "handlebars"
  | "haskell"
  | "haskell_cabal"
  | "haxe"
  | "hjson"
  | "html"
  | "html_elixir"
  | "html_ruby"
  | "ini"
  | "io"
  | "ion"
  | "jack"
  | "jade"
  | "java"
  | "javascript"
  | "jexl"
  | "json"
  | "json5"
  | "jsoniq"
  | "jsp"
  | "jssm"
  | "jsx"
  | "julia"
  | "kotlin"
  | "latex"
  | "latte"
  | "less"
  | "liquid"
  | "lisp"
  | "livescript"
  | "logiql"
  | "logtalk"
  | "lsl"
  | "lua"
  | "luapage"
  | "lucene"
  | "makefile"
  | "markdown"
  | "mask"
  | "matlab"
  | "maze"
  | "mediawiki"
  | "mel"
  | "mips"
  | "mixal"
  | "mushcode"
  | "mysql"
  | "nasal"
  | "nginx"
  | "nim"
  | "nix"
  | "nsis"
  | "nunjucks"
  | "objectivec"
  | "ocaml"
  | "odin"
  | "partiql"
  | "pascal"
  | "perl"
  | "pgsql"
  | "php"
  | "php_laravel_blade"
  | "pig"
  | "plsql"
  | "powershell"
  | "praat"
  | "prisma"
  | "prolog"
  | "properties"
  | "protobuf"
  | "prql"
  | "puppet"
  | "python"
  | "qml"
  | "r"
  | "raku"
  | "razor"
  | "rdoc"
  | "red"
  | "rhtml"
  | "robot"
  | "rst"
  | "ruby"
  | "rust"
  | "sac"
  | "sass"
  | "scad"
  | "scala"
  | "scheme"
  | "scrypt"
  | "scss"
  | "sh"
  | "sjs"
  | "slim"
  | "smarty"
  | "smithy"
  | "snippets"
  | "soy_template"
  | "space"
  | "sparql"
  | "sql"
  | "sqlserver"
  | "stylus"
  | "svg"
  | "swift"
  | "tcl"
  | "terraform"
  | "tex"
  | "text"
  | "textile"
  | "toml"
  | "tsx"
  | "turtle"
  | "twig"
  | "typescript"
  | "vala"
  | "vbscript"
  | "velocity"
  | "verilog"
  | "vhdl"
  | "visualforce"
  | "vue"
  | "wollok"
  | "xml"
  | "xquery"
  | "yaml"
  | "zeek"
  | "zig";

ace.require("ace/ext/language_tools");
ace.config.setModuleUrl("ace/theme/monokai", themeMonokaiUrl);
ace.config.setModuleUrl("ace/theme/dreamweaver", themeDreamweaverUrl);
ace.config.setModuleUrl("ace/mode/abap", modeAbapUrl);
ace.config.setModuleUrl("ace/mode/abc", modeAbcUrl);
ace.config.setModuleUrl("ace/mode/actionscript", modeActionscriptUrl);
ace.config.setModuleUrl("ace/mode/ada", modeAdaUrl);
ace.config.setModuleUrl("ace/mode/alda", modeAldaUrl);
ace.config.setModuleUrl("ace/mode/apache_conf", modeApacheConfUrl);
ace.config.setModuleUrl("ace/mode/apex", modeApexUrl);
ace.config.setModuleUrl("ace/mode/aql", modeAqlUrl);
ace.config.setModuleUrl("ace/mode/asciidoc", modeAsciidocUrl);
ace.config.setModuleUrl("ace/mode/asl", modeAslUrl);
ace.config.setModuleUrl("ace/mode/assembly_arm32", modeAssemblyArm32Url);
ace.config.setModuleUrl("ace/mode/assembly_x86", modeAssemblyX86Url);
ace.config.setModuleUrl("ace/mode/astro", modeAstroUrl);
ace.config.setModuleUrl("ace/mode/autohotkey", modeAutohotkeyUrl);
ace.config.setModuleUrl("ace/mode/batchfile", modeBatchfileUrl);
ace.config.setModuleUrl("ace/mode/bibtex", modeBibtexUrl);
ace.config.setModuleUrl("ace/mode/c_cpp", modeCCppUrl);
ace.config.setModuleUrl("ace/mode/c9search", modeC9searchUrl);
ace.config.setModuleUrl("ace/mode/cirru", modeCirruUrl);
ace.config.setModuleUrl("ace/mode/clojure", modeClojureUrl);
ace.config.setModuleUrl("ace/mode/cobol", modeCobolUrl);
ace.config.setModuleUrl("ace/mode/coffee", modeCoffeeUrl);
ace.config.setModuleUrl("ace/mode/coldfusion", modeColdfusionUrl);
ace.config.setModuleUrl("ace/mode/crystal", modeCrystalUrl);
ace.config.setModuleUrl("ace/mode/csharp", modeCsharpUrl);
ace.config.setModuleUrl("ace/mode/csound_document", modeCsoundDocumentUrl);
ace.config.setModuleUrl("ace/mode/csound_orchestra", modeCsoundOrchestraUrl);
ace.config.setModuleUrl("ace/mode/csound_score", modeCsoundScoreUrl);
ace.config.setModuleUrl("ace/mode/css", modeCssUrl);
ace.config.setModuleUrl("ace/mode/curly", modeCurlyUrl);
ace.config.setModuleUrl("ace/mode/cuttlefish", modeCuttlefishUrl);
ace.config.setModuleUrl("ace/mode/d", modeDUrl);
ace.config.setModuleUrl("ace/mode/dart", modeDartUrl);
ace.config.setModuleUrl("ace/mode/diff", modeDiffUrl);
ace.config.setModuleUrl("ace/mode/django", modeDjangoUrl);
ace.config.setModuleUrl("ace/mode/dockerfile", modeDockerfileUrl);
ace.config.setModuleUrl("ace/mode/dot", modeDotUrl);
ace.config.setModuleUrl("ace/mode/drools", modeDroolsUrl);
ace.config.setModuleUrl("ace/mode/edifact", modeEdifactUrl);
ace.config.setModuleUrl("ace/mode/eiffel", modeEiffelUrl);
ace.config.setModuleUrl("ace/mode/ejs", modeEjsUrl);
ace.config.setModuleUrl("ace/mode/elixir", modeElixirUrl);
ace.config.setModuleUrl("ace/mode/elm", modeElmUrl);
ace.config.setModuleUrl("ace/mode/erlang", modeErlangUrl);
ace.config.setModuleUrl("ace/mode/flix", modeFlixUrl);
ace.config.setModuleUrl("ace/mode/forth", modeForthUrl);
ace.config.setModuleUrl("ace/mode/fortran", modeFortranUrl);
ace.config.setModuleUrl("ace/mode/fsharp", modeFsharpUrl);
ace.config.setModuleUrl("ace/mode/fsl", modeFslUrl);
ace.config.setModuleUrl("ace/mode/ftl", modeFtlUrl);
ace.config.setModuleUrl("ace/mode/gcode", modeGcodeUrl);
ace.config.setModuleUrl("ace/mode/gherkin", modeGherkinUrl);
ace.config.setModuleUrl("ace/mode/gitignore", modeGitignoreUrl);
ace.config.setModuleUrl("ace/mode/glsl", modeGlslUrl);
ace.config.setModuleUrl("ace/mode/gobstones", modeGobstonesUrl);
ace.config.setModuleUrl("ace/mode/golang", modeGolangUrl);
ace.config.setModuleUrl("ace/mode/graphqlschema", modeGraphqlschemaUrl);
ace.config.setModuleUrl("ace/mode/groovy", modeGroovyUrl);
ace.config.setModuleUrl("ace/mode/haml", modeHamlUrl);
ace.config.setModuleUrl("ace/mode/handlebars", modeHandlebarsUrl);
ace.config.setModuleUrl("ace/mode/haskell", modeHaskellUrl);
ace.config.setModuleUrl("ace/mode/haskell_cabal", modeHaskellCabalUrl);
ace.config.setModuleUrl("ace/mode/haxe", modeHaxeUrl);
ace.config.setModuleUrl("ace/mode/hjson", modeHjsonUrl);
ace.config.setModuleUrl("ace/mode/html", modeHtmlUrl);
ace.config.setModuleUrl("ace/mode/html_elixir", modeHtmlElixirUrl);
ace.config.setModuleUrl("ace/mode/html_ruby", modeHtmlRubyUrl);
ace.config.setModuleUrl("ace/mode/ini", modeIniUrl);
ace.config.setModuleUrl("ace/mode/io", modeIoUrl);
ace.config.setModuleUrl("ace/mode/ion", modeIonUrl);
ace.config.setModuleUrl("ace/mode/jack", modeJackUrl);
ace.config.setModuleUrl("ace/mode/jade", modeJadeUrl);
ace.config.setModuleUrl("ace/mode/java", modeJavaUrl);
ace.config.setModuleUrl("ace/mode/javascript", modeJavascriptUrl);
ace.config.setModuleUrl("ace/mode/jexl", modeJexlUrl);
ace.config.setModuleUrl("ace/mode/json", modeJsonUrl);
ace.config.setModuleUrl("ace/mode/json5", modeJson5Url);
ace.config.setModuleUrl("ace/mode/jsoniq", modeJsoniqUrl);
ace.config.setModuleUrl("ace/mode/jsp", modeJspUrl);
ace.config.setModuleUrl("ace/mode/jssm", modeJssmUrl);
ace.config.setModuleUrl("ace/mode/jsx", modeJsxUrl);
ace.config.setModuleUrl("ace/mode/julia", modeJuliaUrl);
ace.config.setModuleUrl("ace/mode/kotlin", modeKotlinUrl);
ace.config.setModuleUrl("ace/mode/latex", modeLatexUrl);
ace.config.setModuleUrl("ace/mode/latte", modeLatteUrl);
ace.config.setModuleUrl("ace/mode/less", modeLessUrl);
ace.config.setModuleUrl("ace/mode/liquid", modeLiquidUrl);
ace.config.setModuleUrl("ace/mode/lisp", modeLispUrl);
ace.config.setModuleUrl("ace/mode/livescript", modeLivescriptUrl);
ace.config.setModuleUrl("ace/mode/logiql", modeLogiqlUrl);
ace.config.setModuleUrl("ace/mode/logtalk", modeLogtalkUrl);
ace.config.setModuleUrl("ace/mode/lsl", modeLslUrl);
ace.config.setModuleUrl("ace/mode/lua", modeLuaUrl);
ace.config.setModuleUrl("ace/mode/luapage", modeLuapageUrl);
ace.config.setModuleUrl("ace/mode/lucene", modeLuceneUrl);
ace.config.setModuleUrl("ace/mode/makefile", modeMakefileUrl);
ace.config.setModuleUrl("ace/mode/markdown", modeMarkdownUrl);
ace.config.setModuleUrl("ace/mode/mask", modeMaskUrl);
ace.config.setModuleUrl("ace/mode/matlab", modeMatlabUrl);
ace.config.setModuleUrl("ace/mode/maze", modeMazeUrl);
ace.config.setModuleUrl("ace/mode/mediawiki", modeMediawikiUrl);
ace.config.setModuleUrl("ace/mode/mel", modeMelUrl);
ace.config.setModuleUrl("ace/mode/mips", modeMipsUrl);
ace.config.setModuleUrl("ace/mode/mixal", modeMixalUrl);
ace.config.setModuleUrl("ace/mode/mushcode", modeMushcodeUrl);
ace.config.setModuleUrl("ace/mode/mysql", modeMysqlUrl);
ace.config.setModuleUrl("ace/mode/nasal", modeNasalUrl);
ace.config.setModuleUrl("ace/mode/nginx", modeNginxUrl);
ace.config.setModuleUrl("ace/mode/nim", modeNimUrl);
ace.config.setModuleUrl("ace/mode/nix", modeNixUrl);
ace.config.setModuleUrl("ace/mode/nsis", modeNsisUrl);
ace.config.setModuleUrl("ace/mode/nunjucks", modeNunjucksUrl);
ace.config.setModuleUrl("ace/mode/objectivec", modeObjectivecUrl);
ace.config.setModuleUrl("ace/mode/ocaml", modeOcamlUrl);
ace.config.setModuleUrl("ace/mode/odin", modeOdinUrl);
ace.config.setModuleUrl("ace/mode/partiql", modePartiqlUrl);
ace.config.setModuleUrl("ace/mode/pascal", modePascalUrl);
ace.config.setModuleUrl("ace/mode/perl", modePerlUrl);
ace.config.setModuleUrl("ace/mode/pgsql", modePgsqlUrl);
ace.config.setModuleUrl("ace/mode/php", modePhpUrl);
ace.config.setModuleUrl("ace/mode/php_laravel_blade", modePhpLaravelBladeUrl);
ace.config.setModuleUrl("ace/mode/pig", modePigUrl);
ace.config.setModuleUrl("ace/mode/plsql", modePlsqlUrl);
ace.config.setModuleUrl("ace/mode/powershell", modePowershellUrl);
ace.config.setModuleUrl("ace/mode/praat", modePraatUrl);
ace.config.setModuleUrl("ace/mode/prisma", modePrismaUrl);
ace.config.setModuleUrl("ace/mode/prolog", modePrologUrl);
ace.config.setModuleUrl("ace/mode/properties", modePropertiesUrl);
ace.config.setModuleUrl("ace/mode/protobuf", modeProtobufUrl);
ace.config.setModuleUrl("ace/mode/prql", modePrqlUrl);
ace.config.setModuleUrl("ace/mode/puppet", modePuppetUrl);
ace.config.setModuleUrl("ace/mode/python", modePythonUrl);
ace.config.setModuleUrl("ace/mode/qml", modeQmlUrl);
ace.config.setModuleUrl("ace/mode/r", modeRUrl);
ace.config.setModuleUrl("ace/mode/raku", modeRakuUrl);
ace.config.setModuleUrl("ace/mode/razor", modeRazorUrl);
ace.config.setModuleUrl("ace/mode/rdoc", modeRdocUrl);
ace.config.setModuleUrl("ace/mode/red", modeRedUrl);
ace.config.setModuleUrl("ace/mode/rhtml", modeRhtmlUrl);
ace.config.setModuleUrl("ace/mode/robot", modeRobotUrl);
ace.config.setModuleUrl("ace/mode/rst", modeRstUrl);
ace.config.setModuleUrl("ace/mode/ruby", modeRubyUrl);
ace.config.setModuleUrl("ace/mode/rust", modeRustUrl);
ace.config.setModuleUrl("ace/mode/sac", modeSacUrl);
ace.config.setModuleUrl("ace/mode/sass", modeSassUrl);
ace.config.setModuleUrl("ace/mode/scad", modeScadUrl);
ace.config.setModuleUrl("ace/mode/scala", modeScalaUrl);
ace.config.setModuleUrl("ace/mode/scheme", modeSchemeUrl);
ace.config.setModuleUrl("ace/mode/scrypt", modeScryptUrl);
ace.config.setModuleUrl("ace/mode/scss", modeScssUrl);
ace.config.setModuleUrl("ace/mode/sh", modeShUrl);
ace.config.setModuleUrl("ace/mode/sjs", modeSjsUrl);
ace.config.setModuleUrl("ace/mode/slim", modeSlimUrl);
ace.config.setModuleUrl("ace/mode/smarty", modeSmartyUrl);
ace.config.setModuleUrl("ace/mode/smithy", modeSmithyUrl);
ace.config.setModuleUrl("ace/mode/snippets", modeSnippetsUrl);
ace.config.setModuleUrl("ace/mode/soy_template", modeSoyTemplateUrl);
ace.config.setModuleUrl("ace/mode/space", modeSpaceUrl);
ace.config.setModuleUrl("ace/mode/sparql", modeSparqlUrl);
ace.config.setModuleUrl("ace/mode/sql", modeSqlUrl);
ace.config.setModuleUrl("ace/mode/sqlserver", modeSqlserverUrl);
ace.config.setModuleUrl("ace/mode/stylus", modeStylusUrl);
ace.config.setModuleUrl("ace/mode/svg", modeSvgUrl);
ace.config.setModuleUrl("ace/mode/swift", modeSwiftUrl);
ace.config.setModuleUrl("ace/mode/tcl", modeTclUrl);
ace.config.setModuleUrl("ace/mode/terraform", modeTerraformUrl);
ace.config.setModuleUrl("ace/mode/tex", modeTexUrl);
ace.config.setModuleUrl("ace/mode/text", modeTextUrl);
ace.config.setModuleUrl("ace/mode/textile", modeTextileUrl);
ace.config.setModuleUrl("ace/mode/toml", modeTomlUrl);
ace.config.setModuleUrl("ace/mode/tsx", modeTsxUrl);
ace.config.setModuleUrl("ace/mode/turtle", modeTurtleUrl);
ace.config.setModuleUrl("ace/mode/twig", modeTwigUrl);
ace.config.setModuleUrl("ace/mode/typescript", modeTypescriptUrl);
ace.config.setModuleUrl("ace/mode/vala", modeValaUrl);
ace.config.setModuleUrl("ace/mode/vbscript", modeVbscriptUrl);
ace.config.setModuleUrl("ace/mode/velocity", modeVelocityUrl);
ace.config.setModuleUrl("ace/mode/verilog", modeVerilogUrl);
ace.config.setModuleUrl("ace/mode/vhdl", modeVhdlUrl);
ace.config.setModuleUrl("ace/mode/visualforce", modeVisualforceUrl);
ace.config.setModuleUrl("ace/mode/vue", modeVueUrl);
ace.config.setModuleUrl("ace/mode/wollok", modeWollokUrl);
ace.config.setModuleUrl("ace/mode/xml", modeXmlUrl);
ace.config.setModuleUrl("ace/mode/xquery", modeXqueryUrl);
ace.config.setModuleUrl("ace/mode/yaml", modeYamlUrl);
ace.config.setModuleUrl("ace/mode/zeek", modeZeekUrl);
ace.config.setModuleUrl("ace/mode/zig", modeZigUrl);
ace.config.setModuleUrl("ace/mode/base", workerBaseUrl);
ace.config.setModuleUrl("ace/mode/coffee_worker", workerCoffeeUrl);
ace.config.setModuleUrl("ace/mode/css_worker", workerCssUrl);
ace.config.setModuleUrl("ace/mode/html_worker", workerHtmlUrl);
ace.config.setModuleUrl("ace/mode/javascript_worker", workerJavascriptUrl);
ace.config.setModuleUrl("ace/mode/json_worker", workerJsonUrl);
ace.config.setModuleUrl("ace/mode/lua_worker", workerLuaUrl);
ace.config.setModuleUrl("ace/mode/php_worker", workerPhpUrl);
ace.config.setModuleUrl("ace/mode/xml_worker", workerXmlUrl);
ace.config.setModuleUrl("ace/mode/xquery_worker", workerXqueryUrl);
ace.config.setModuleUrl("ace/mode/yaml_worker", workerYamlUrl);
ace.config.setModuleUrl("ace/ext/searchbox", extSearchboxUrl);

const fileExtensionToMode: Record<string, AceMode> = {
  abap: "abap",
  abc: "abc",
  as: "actionscript",
  ada: "ada",
  ald: "alda",
  conf: "apache_conf",
  apex: "apex",
  aql: "aql",
  adoc: "asciidoc",
  asl: "asl",
  s: "assembly_arm32",
  asm: "assembly_x86",
  astro: "astro",
  ahk: "autohotkey",
  bat: "batchfile",
  bib: "bibtex",
  c: "c_cpp",
  cpp: "c_cpp",
  cc: "c_cpp",
  h: "c_cpp",
  ino: "c_cpp",
  c9search_results: "c9search",
  cirru: "cirru",
  clj: "clojure",
  cob: "cobol",
  coffee: "coffee",
  cfm: "coldfusion",
  cr: "crystal",
  cs: "csharp",
  csd: "csound_document",
  orc: "csound_orchestra",
  sco: "csound_score",
  css: "css",
  curly: "curly",
  cuttlefish: "cuttlefish",
  d: "d",
  dart: "dart",
  diff: "diff",
  django: "django",
  dockerfile: "dockerfile",
  dot: "dot",
  drools: "drools",
  edi: "edifact",
  e: "eiffel",
  ejs: "ejs",
  ex: "elixir",
  elm: "elm",
  erl: "erlang",
  flix: "flix",
  forth: "forth",
  f: "fortran",
  fsi: "fsharp",
  fsl: "fsl",
  ftl: "ftl",
  gcode: "gcode",
  feature: "gherkin",
  gitignore: "gitignore",
  glsl: "glsl",
  gbs: "gobstones",
  go: "golang",
  gql: "graphqlschema",
  groovy: "groovy",
  haml: "haml",
  hbs: "handlebars",
  hs: "haskell",
  cabal: "haskell_cabal",
  hx: "haxe",
  hjson: "hjson",
  html: "html",
  eex: "html_elixir",
  erb: "html_ruby",
  ini: "ini",
  io: "io",
  ion: "ion",
  jack: "jack",
  jade: "jade",
  java: "java",
  js: "javascript",
  mjs: "javascript",
  jexl: "jexl",
  json: "json",
  json5: "json5",
  jq: "jsoniq",
  jsp: "jsp",
  jssm: "jssm",
  jsx: "jsx",
  jl: "julia",
  kt: "kotlin",
  tex: "latex",
  latte: "latte",
  less: "less",
  liquid: "liquid",
  lisp: "lisp",
  ls: "livescript",
  logic: "logiql",
  logtalk: "logtalk",
  lsl: "lsl",
  lua: "lua",
  lp: "luapage",
  lucene: "lucene",
  make: "makefile",
  md: "markdown",
  mask: "mask",
  maze: "maze",
  mediawiki: "mediawiki",
  mel: "mel",
  mixal: "mixal",
  mush: "mushcode",
  nas: "nasal",
  nginx: "nginx",
  nim: "nim",
  nix: "nix",
  nsi: "nsis",
  njk: "nunjucks",
  m: "objectivec",
  ml: "ocaml",
  odin: "odin",
  partiql: "partiql",
  p: "pascal",
  pl: "perl",
  pgsql: "pgsql",
  php: "php",
  "blade.php": "php_laravel_blade",
  pig: "pig",
  pck: "plsql",
  ps1: "powershell",
  praat: "praat",
  prisma: "prisma",
  pro: "prolog",
  properties: "properties",
  proto: "protobuf",
  prql: "prql",
  pp: "puppet",
  py: "python",
  qml: "qml",
  r: "r",
  raku: "raku",
  razor: "razor",
  rdoc: "rdoc",
  red: "red",
  rhtml: "rhtml",
  robot: "robot",
  rst: "rst",
  rb: "ruby",
  rs: "rust",
  sac: "sac",
  sass: "sass",
  scad: "scad",
  scala: "scala",
  scm: "scheme",
  scrypt: "scrypt",
  scss: "scss",
  sh: "sh",
  sjs: "sjs",
  slim: "slim",
  tpl: "smarty",
  smithy: "smithy",
  snippets: "snippets",
  soy: "soy_template",
  space: "space",
  sparql: "sparql",
  sql: "sql",
  ss: "sqlserver",
  styl: "stylus",
  svg: "svg",
  swift: "swift",
  tcl: "tcl",
  tf: "terraform",
  sty: "tex",
  txt: "text",
  textile: "textile",
  toml: "toml",
  tsx: "tsx",
  ttl: "turtle",
  twig: "twig",
  ts: "typescript",
  mts: "typescript",
  vala: "vala",
  vbs: "vbscript",
  vm: "velocity",
  v: "verilog",
  vhdl: "vhdl",
  page: "visualforce",
  vue: "vue",
  wlk: "wollok",
  xml: "xml",
  xq: "xquery",
  yaml: "yaml",
  yml: "yaml",
  zeek: "zeek",
  zig: "zig",
};

const mimeTypeToMode: Record<string, AceMode> = {
  "text/x-abap": "abap",
  "text/abc": "abc",
  "application/x-actionscript": "actionscript",
  "text/x-ada": "ada",
  "application/x-alda": "alda",
  "text/x-apache-conf": "apache_conf",
  "application/x-apex": "apex",
  "application/x-aql": "aql",
  "text/x-asciidoc": "asciidoc",
  "text/x-asl": "asl",
  "text/x-arm": "assembly_arm32",
  "text/x-x86-asm": "assembly_x86",
  "text/x-astro": "astro",
  "application/x-autohotkey": "autohotkey",
  "application/bat": "batchfile",
  "application/x-bibtex": "bibtex",
  "text/x-c": "c_cpp",
  "text/x-cpp": "c_cpp",
  "text/x-c9search": "c9search",
  "application/x-cirru": "cirru",
  "application/x-clojure": "clojure",
  "text/x-cobol": "cobol",
  "text/x-coffeescript": "coffee",
  "application/x-coldfusion": "coldfusion",
  "text/x-crystal": "crystal",
  "text/x-csharp": "csharp",
  "text/x-csound": "csound_document",
  "application/x-csound-orc": "csound_orchestra",
  "application/x-csound-sco": "csound_score",
  "text/css": "css",
  "text/x-curly": "curly",
  "application/x-cuttlefish": "cuttlefish",
  "text/x-d": "d",
  "application/dart": "dart",
  "text/x-diff": "diff",
  "text/x-django": "django",
  "application/x-dockerfile": "dockerfile",
  "application/x-dot": "dot",
  "application/x-drools": "drools",
  "application/edifact": "edifact",
  "application/x-eiffel": "eiffel",
  "application/x-ejs": "ejs",
  "application/x-elixir": "elixir",
  "text/x-elm": "elm",
  "text/x-erlang": "erlang",
  "application/x-flix": "flix",
  "text/x-forth": "forth",
  "text/x-fortran": "fortran",
  "text/x-fsharp": "fsharp",
  "text/x-fsl": "fsl",
  "application/x-ftl": "ftl",
  "text/x-gcode": "gcode",
  "application/x-gherkin": "gherkin",
  "text/x-gitignore": "gitignore",
  "text/x-glsl": "glsl",
  "application/x-gobstones": "gobstones",
  "text/x-go": "golang",
  "application/graphql": "graphqlschema",
  "application/x-groovy": "groovy",
  "text/x-haml": "haml",
  "text/x-handlebars-template": "handlebars",
  "text/x-haskell": "haskell",
  "application/x-haskell-cabal": "haskell_cabal",
  "text/haxe": "haxe",
  "application/hjson": "hjson",
  "text/html": "html",
  "text/x-eex": "html_elixir",
  "text/x-erb": "html_ruby",
  "text/plain": "text",
  "text/x-ini": "ini",
  "application/x-io": "io",
  "text/x-ion": "ion",
  "application/x-jack": "jack",
  "text/jade": "jade",
  "text/x-java-source": "java",
  "application/javascript": "javascript",
  "application/x-jexl": "jexl",
  "application/json": "json",
  "application/json5": "json5",
  "application/x-jq": "jsoniq",
  "text/x-jsp": "jsp",
  "application/x-jssm": "jssm",
  "text/x-julia": "julia",
  "application/x-kotlin": "kotlin",
  "application/x-latex": "latex",
  "application/x-latte": "latte",
  "text/x-less": "less",
  "application/x-liquid": "liquid",
  "text/x-lisp": "lisp",
  "text/x-livescript": "livescript",
  "application/x-logiql": "logiql",
  "text/x-logtalk": "logtalk",
  "text/x-lsl": "lsl",
  "text/x-lua": "lua",
  "application/x-luapage": "luapage",
  "application/x-lucene": "lucene",
  "text/x-makefile": "makefile",
  "text/markdown": "markdown",
  "text/x-mask": "mask",
  "text/x-matlab": "matlab",
  "application/x-maze": "maze",
  "application/x-mediawiki": "mediawiki",
  "text/x-mel": "mel",
  "text/x-mips-asm": "mips",
  "application/x-mixal": "mixal",
  "text/x-mush": "mushcode",
  "application/x-sql": "mysql",
  "text/x-nasal": "nasal",
  "application/x-nginx-conf": "nginx",
  "application/x-nim": "nim",
  "application/x-nix": "nix",
  "application/x-nsis": "nsis",
  "application/x-nunjucks": "nunjucks",
  "text/x-objectivec": "objectivec",
  "text/x-ocaml": "ocaml",
  "application/x-odin": "odin",
  "application/x-partiql": "partiql",
  "text/x-pascal": "pascal",
  "application/x-perl": "perl",
  "text/x-pgsql": "pgsql",
  "application/x-php": "php",
  "application/x-blade": "php_laravel_blade",
  "application/x-pig": "pig",
  "application/x-plsql": "plsql",
  "application/x-powershell": "powershell",
  "text/x-praat": "praat",
  "application/x-prisma": "prisma",
  "text/x-prolog": "prolog",
  "text/x-properties": "properties",
  "application/x-protobuf": "protobuf",
  "application/x-prql": "prql",
  "text/x-puppet": "puppet",
  "text/x-python": "python",
  "text/x-qml": "qml",
  "text/x-r": "r",
  "application/x-raku": "raku",
  "application/x-razor": "razor",
  "application/x-rdoc": "rdoc",
  "text/x-red": "red",
  "application/x-rhtml": "rhtml",
  "application/x-robot": "robot",
  "text/x-rst": "rst",
  "application/x-ruby": "ruby",
  "text/x-rust": "rust",
  "application/x-sac": "sac",
  "text/x-sass": "sass",
  "application/x-scad": "scad",
  "application/x-scala": "scala",
  "text/x-scheme": "scheme",
  "application/x-scrypt": "scrypt",
  "text/x-scss": "scss",
  "application/x-sh": "sh",
  "application/x-sjs": "sjs",
  "application/x-slim": "slim",
  "application/x-smarty": "smarty",
  "application/x-smithy": "smithy",
  "application/x-snippets": "snippets",
  "application/x-soy-template": "soy_template",
  "text/x-space": "space",
  "application/sparql-query": "sparql",
  "application/sql": "sql",
  "application/x-sqlserver": "sqlserver",
  "text/x-styl": "stylus",
  "image/svg+xml": "svg",
  "application/x-swift": "swift",
  "application/x-tcl": "tcl",
  "application/x-terraform": "terraform",
  "application/x-tex": "tex",
  "text/x-textile": "textile",
  "application/toml": "toml",
  "text/typescript": "typescript",
  "application/tsx": "tsx",
  "application/x-turtle": "turtle",
  "application/x-twig": "twig",
  "text/x-vala": "vala",
  "text/vbscript": "vbscript",
  "application/x-velocity": "velocity",
  "application/x-verilog": "verilog",
  "text/x-vhdl": "vhdl",
  "application/x-visualforce": "visualforce",
  "application/vue": "vue",
  "application/x-wollok": "wollok",
  "application/xml": "xml",
  "application/xquery": "xquery",
  "application/x-yaml": "yaml",
  "application/x-zeek": "zeek",
  "application/zig": "zig",
};

export const getModeForFile = (
  filename: string,
  mimeType?: string,
): AceMode => {
  // Extract file extension
  const extension = filename.split(".").pop();

  // Check if there's a match for the file extension
  if (extension && fileExtensionToMode[extension]) {
    return fileExtensionToMode[extension];
  }

  // If mime type is provided, check if it matches
  if (mimeType && mimeTypeToMode[mimeType]) {
    return mimeTypeToMode[mimeType];
  }

  // Default to 'text' mode if no match found
  return "text";
};

export const getAceMode = (input?: unknown): AceMode => {
  switch (input) {
    case "abap":
    case "abc":
    case "actionscript":
    case "ada":
    case "alda":
    case "apache_conf":
    case "apex":
    case "aql":
    case "asciidoc":
    case "asl":
    case "assembly_arm32":
    case "assembly_x86":
    case "astro":
    case "autohotkey":
    case "batchfile":
    case "bibtex":
    case "c_cpp":
    case "c9search":
    case "cirru":
    case "clojure":
    case "cobol":
    case "coffee":
    case "coldfusion":
    case "crystal":
    case "csharp":
    case "csound_document":
    case "csound_orchestra":
    case "csound_score":
    case "css":
    case "curly":
    case "cuttlefish":
    case "d":
    case "dart":
    case "diff":
    case "django":
    case "dockerfile":
    case "dot":
    case "drools":
    case "edifact":
    case "eiffel":
    case "ejs":
    case "elixir":
    case "elm":
    case "erlang":
    case "flix":
    case "forth":
    case "fortran":
    case "fsharp":
    case "fsl":
    case "ftl":
    case "gcode":
    case "gherkin":
    case "gitignore":
    case "glsl":
    case "gobstones":
    case "golang":
    case "graphqlschema":
    case "groovy":
    case "haml":
    case "handlebars":
    case "haskell":
    case "haskell_cabal":
    case "haxe":
    case "hjson":
    case "html":
    case "html_elixir":
    case "html_ruby":
    case "ini":
    case "io":
    case "ion":
    case "jack":
    case "jade":
    case "java":
    case "javascript":
    case "jexl":
    case "json":
    case "json5":
    case "jsoniq":
    case "jsp":
    case "jssm":
    case "jsx":
    case "julia":
    case "kotlin":
    case "latex":
    case "latte":
    case "less":
    case "liquid":
    case "lisp":
    case "livescript":
    case "logiql":
    case "logtalk":
    case "lsl":
    case "lua":
    case "luapage":
    case "lucene":
    case "makefile":
    case "markdown":
    case "mask":
    case "matlab":
    case "maze":
    case "mediawiki":
    case "mel":
    case "mips":
    case "mixal":
    case "mushcode":
    case "mysql":
    case "nasal":
    case "nginx":
    case "nim":
    case "nix":
    case "nsis":
    case "nunjucks":
    case "objectivec":
    case "ocaml":
    case "odin":
    case "partiql":
    case "pascal":
    case "perl":
    case "pgsql":
    case "php":
    case "php_laravel_blade":
    case "pig":
    case "plsql":
    case "powershell":
    case "praat":
    case "prisma":
    case "prolog":
    case "properties":
    case "protobuf":
    case "prql":
    case "puppet":
    case "python":
    case "qml":
    case "r":
    case "raku":
    case "razor":
    case "rdoc":
    case "red":
    case "rhtml":
    case "robot":
    case "rst":
    case "ruby":
    case "rust":
    case "sac":
    case "sass":
    case "scad":
    case "scala":
    case "scheme":
    case "scrypt":
    case "scss":
    case "sh":
    case "sjs":
    case "slim":
    case "smarty":
    case "smithy":
    case "snippets":
    case "soy_template":
    case "space":
    case "sparql":
    case "sql":
    case "sqlserver":
    case "stylus":
    case "svg":
    case "swift":
    case "tcl":
    case "terraform":
    case "tex":
    case "text":
    case "textile":
    case "toml":
    case "tsx":
    case "turtle":
    case "twig":
    case "typescript":
    case "vala":
    case "vbscript":
    case "velocity":
    case "verilog":
    case "vhdl":
    case "visualforce":
    case "vue":
    case "wollok":
    case "xml":
    case "xquery":
    case "yaml":
    case "zeek":
    case "zig":
      return input as AceMode;
    default:
      return "text" as AceMode;
  }
};
