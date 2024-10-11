import { defineComponent, h, computed } from "vue";
import MarkdownIt from "markdown-it";
import anchorPlugin from "markdown-it-anchor";
import markdownItAttrs from "markdown-it-attrs";
import { full as emoji } from "markdown-it-emoji";
import mathjax3 from "markdown-it-mathjax3";
import * as cheerio from "cheerio";
// import hljs from "highlight.js"; // https://highlightjs.org
// import "highlight.js/styles/monokai-sublime.css";
import RenderCode from "./code.vue";
import { getAceMode } from "./plugins/ace";

import type { Element, Text, ChildNode } from "domhandler";
import type { VNode } from "vue";
import type { Options } from "markdown-it";
import type { BuiltinTheme, Highlighter } from "shiki";
import type {
  LanguageInput,
  ShikiTransformer,
  ThemeRegistrationAny,
} from "@shikijs/types";
import type { ContainerOptions } from "./plugins/containers";
import type { Options as ImageOptions } from "./plugins/images";

const md = MarkdownIt({
  html: false,
  xhtmlOut: true,
  breaks: true,
  linkify: true,
});
md.set({
  highlight: function (str, lang) {
    return `<pre greenmine-code-lang="${lang}">${md.utils.escapeHtml(str)}</pre>`;
  },
});
md.use(anchorPlugin, {});
md.use(markdownItAttrs, {});
md.use(emoji);
md.use(mathjax3);

export const Markdown = defineComponent({
  name: "MarkdownRenderer",
  props: {
    raw: {
      type: String,
      required: true,
    },
  },
  setup(props) {
    const raw = computed(() => props.raw);
    const html = computed(() => md.render(raw.value));
    const $ = computed(() => cheerio.load(html.value));
    const root = computed(() => $.value("body"));
    const recursiveBuildHyperscript = (
      node: Element | Text | ChildNode,
    ): VNode | string => {
      if (node.type === "text") {
        return node.data;
      } else if (node.type === "tag") {
        const props = node.attribs;
        if (node.name === "p") {
          const existingClass = props.class || "";
          props.class = [existingClass, "text-body-1"].join(" ").trim();
        }
        // replace code block with custom component
        if (
          node.name === "pre" &&
          "string" === typeof props["greenmine-code-lang"]
        ) {
          return h(RenderCode, {
            content: $.value(node).text(),
            mode: getAceMode(props["greenmine-code-lang"]),
          });
        }
        const children = node.children.map((child) =>
          recursiveBuildHyperscript(child),
        );
        return h(node.name, props, children);
      } else {
        return "";
      }
    };
    return () =>
      h(
        "div",
        {
          class: "greenmine-rendered-markdown",
        },
        [
          ...root.value
            .children()
            .toArray()
            .map((child) => recursiveBuildHyperscript(child)),
        ],
      );
  },
});

export type ThemeOptions =
  | ThemeRegistrationAny
  | BuiltinTheme
  | {
      light: ThemeRegistrationAny | BuiltinTheme;
      dark: ThemeRegistrationAny | BuiltinTheme;
    };

export interface MarkdownOptions extends Options {
  /* ==================== General Options ==================== */

  /**
   * Setup markdown-it instance before applying plugins
   */
  preConfig?: (md: MarkdownIt) => void;
  /**
   * Setup markdown-it instance
   */
  config?: (md: MarkdownIt) => void;
  /**
   * Disable cache (experimental)
   */
  cache?: boolean;
  externalLinks?: Record<string, string>;

  /* ==================== Syntax Highlighting ==================== */

  /**
   * Custom theme for syntax highlighting.
   *
   * You can also pass an object with `light` and `dark` themes to support dual themes.
   *
   * @example { theme: 'github-dark' }
   * @example { theme: { light: 'github-light', dark: 'github-dark' } }
   *
   * You can use an existing theme.
   * @see https://shiki.style/themes
   * Or add your own theme.
   * @see https://shiki.style/guide/load-theme
   */
  theme?: ThemeOptions;
  /**
   * Languages for syntax highlighting.
   * @see https://shiki.style/languages
   */
  languages?: LanguageInput[];
  /**
   * Custom language aliases.
   *
   * @example { 'my-lang': 'js' }
   * @see https://shiki.style/guide/load-lang#custom-language-aliases
   */
  languageAlias?: Record<string, string>;
  /**
   * Show line numbers in code blocks
   * @default false
   */
  lineNumbers?: boolean;
  /**
   * Fallback language when the specified language is not available.
   */
  defaultHighlightLang?: string;
  /**
   * Transformers applied to code blocks
   * @see https://shiki.style/guide/transformers
   */
  codeTransformers?: ShikiTransformer[];
  /**
   * Setup Shiki instance
   */
  shikiSetup?: (shiki: Highlighter) => void | Promise<void>;
  /**
   * The tooltip text for the copy button in code blocks
   * @default 'Copy Code'
   */
  codeCopyButtonTitle?: string;

  /* ==================== Markdown It Plugins ==================== */

  /**
   * Options for `markdown-it-anchor`
   * @see https://github.com/valeriangalliat/markdown-it-anchor
   */
  anchor?: anchorPlugin.AnchorOptions;
  /**
   * Options for `markdown-it-attrs`
   * @see https://github.com/arve0/markdown-it-attrs
   */
  attrs?: {
    leftDelimiter?: string;
    rightDelimiter?: string;
    allowedAttributes?: Array<string | RegExp>;
    disable?: boolean;
  };
  /**
   * Options for `markdown-it-emoji`
   * @see https://github.com/markdown-it/markdown-it-emoji
   */
  emoji?: {
    defs?: Record<string, string>;
    enabled?: string[];
    shortcuts?: Record<string, string | string[]>;
  };
  /**
   * Options for `@mdit-vue/plugin-frontmatter`
   * @see https://github.com/mdit-vue/mdit-vue/tree/main/packages/plugin-frontmatter
   */
  frontmatter?: undefined;
  /**
   * Options for `@mdit-vue/plugin-headers`
   * @see https://github.com/mdit-vue/mdit-vue/tree/main/packages/plugin-headers
   */
  headers?: undefined;
  /**
   * Options for `@mdit-vue/plugin-sfc`
   * @see https://github.com/mdit-vue/mdit-vue/tree/main/packages/plugin-sfc
   */
  sfc?: undefined;
  /**
   * Options for `@mdit-vue/plugin-toc`
   * @see https://github.com/mdit-vue/mdit-vue/tree/main/packages/plugin-toc
   */
  toc?: undefined;
  /**
   * Options for `@mdit-vue/plugin-component`
   * @see https://github.com/mdit-vue/mdit-vue/tree/main/packages/plugin-component
   */
  component?: undefined;
  /**
   * Options for `markdown-it-container`
   * @see https://github.com/markdown-it/markdown-it-container
   */
  container?: ContainerOptions;
  /**
   * Math support (experimental)
   *
   * You need to install `markdown-it-mathjax3` and set `math` to `true` to enable it.
   * You can also pass options to `markdown-it-mathjax3` here.
   * @default false
   * @see https://vitepress.dev/guide/markdown#math-equations
   */
  math?: boolean | any;
  image?: ImageOptions;
  /**
   * Allows disabling the github alerts plugin
   * @default true
   * @see https://vitepress.dev/guide/markdown#github-flavored-alerts
   */
  gfmAlerts?: boolean;
}
