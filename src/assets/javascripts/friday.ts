import "../stylesheets/friday.scss";
import "vite/modulepreload-polyfill";
import { createApp } from "vue";
import { createPinia } from "pinia";
import { router } from "@/plugins/router";
import { i18n, useI18n } from "@/plugins/i18n";
import { head } from "@/plugins/head";
import VueMainBootstrap from "@jakguru/vueprint/plugins/main";
import VueClientBootstrap from "@jakguru/vueprint/plugins/client";
import * as VuetifyComponents from "vuetify/components";
import * as VuetifyDirectives from "vuetify/directives";
import { createVueI18nAdapter } from "vuetify/locale/adapters/vue-i18n";
import icons from "@/constants/icons";
import { VAutocomplete } from "vuetify/components/VAutocomplete";

import { createConsumer } from "@rails/actioncable";
import FridayApp from "@/app.vue";

import type {
  VueMainBootstrapOptions,
  VueClientBootstrapOptions,
} from "@jakguru/vueprint/plugins";
import type { App, Plugin } from "vue";

const mainColors = {
  primary: "#0273EA",
  secondary: "#62B682",
  accent: "#00854d",
  panel: "#6162FF",
  bazooka: "#f65f7c",
  asphalt: "#676879",
  mud: "#323338",
  grass: "#037f4c",
  done: "#00c875",
  bright: "#9cd326",
  saladish: "#cab641",
  yolk: "#ffcb00",
  working: "#fdab3d",
  peach: "#ffadad",
  sunset: "#ff7575",
  stuck: "#df2f4a",
  sofia: "#e50073",
  lipstick: "#ff5ac4",
  bubble: "#faa1f1",
  purple: "#9d50dd",
  berry: "#7e3b8a",
  indigo: "#5559df",
  navy: "#225091",
  aquamarine: "#4eccc6",
  chili: "#66ccff",
  river: "#74afcc",
  winter: "#9aadbd",
  explosive: "#c4c4c4",
  american: "#757575",
  blackish: "#333333",
  orchid: "#e484bd",
  tan: "#bca58a",
  sky: "#a1e3f6",
  coffee: "#cd9282",
  royal: "#216edf",
  lavender: "#bda8f9",
  steel: "#a9bee8",
  lilac: "#9d99b9",
  pecan: "#563e3e",
  marble: "#f7f7f7",
  gainsboro: "#e1e1e1",
  glitter: "#d9f0ff",
  turquoise: "#66ccff",
  aqua: "#00d1d1",
  jeans: "#597bfc",
  eggplant: "#181d37",
  mustered: "#cab641",
  jade: "#03c875",
  cannabis: "#00a359",
  amethyst: "#9d50dd",
  charcoal: "#2b2c5c",
  gold: "#ffcc00",
  iris: "#595ad4",
  malachite: "#00cd6f",
  "snow-white": "#ffffff",
  "riverstone-gray": "#f6f7fb",
  "wolf-gray": "#c3c6d4",
  "dark-marble": "#f1f1f1",
  "jaco-gray": "#9699a6",
  "storm-gray": "#6b6d77",
  "trolley-grey": "#757575",
};

const vueprintMainPluginOptions: VueMainBootstrapOptions = {
  api: {
    baseURL: "/",
  },
  identity: {
    tokenRefresh: async (_api, _signal) => {
      throw new Error("Not implemented");
    },
    tokenRefreshBuffer: 60 * 5,
  },
  bus: {
    namespace: "friday",
  },
  ls: {
    namespace: "friday",
  },
  vuetify: {
    defaultTheme: "friday-light",
    themes: {
      "friday-dark": {
        dark: true,
        colors: {
          ...mainColors,
          primary: "#0273EA",
          background: "#282F4C",
          surface: "#181B34",
          cancel: "#FF0000",
          error: "#D9534F",
          highlight: "#FFFFFF",
          info: "#5BC0DE",
          notify: "#5BC0DE",
          question: "#337AB7",
          success: "#5CB85C",
          warning: "#F0AD4E",
        },
      },
      "friday-light": {
        dark: false,
        colors: {
          ...mainColors,
          primary: "#628DB6",
          background: "#E8ECF4",
          surface: "#F6F6F6",
          cancel: "#FF0000",
          error: "#D9534F",
          highlight: "#000000",
          info: "#5BC0DE",
          notify: "#5BC0DE",
          question: "#337AB7",
          success: "#5CB85C",
          warning: "#F0AD4E",
        },
      },
    },
    options: {
      ssr: false,
      aliases: {
        VSaveableIconField: VAutocomplete,
      },
      defaults: {
        VTextField: {
          variant: "outlined",
          hideDetails: "auto",
        },
        VTextarea: {
          variant: "outlined",
          hideDetails: "auto",
          resize: "none",
        },
        VDateInput: {
          variant: "outlined",
          hideDetails: "auto",
          prependIcon: null,
        },
        VSelect: {
          variant: "outlined",
          hideDetails: "auto",
          itemTitle: "title",
          itemValue: "value",
        },
        VAutocomplete: {
          variant: "outlined",
          hideDetails: "auto",
          itemTitle: "title",
          itemValue: "value",
        },
        VCombobox: {
          variant: "outlined",
          hideDetails: "auto",
          itemTitle: "title",
          itemValue: "value",
        },
        VSwitch: {
          color: "primary",
          hideDetails: "auto",
        },
        VFileInput: {
          variant: "outlined",
          hideDetails: "auto",
        },
        VSaveableIconField: {
          variant: "outlined",
          hideDetails: "auto",
          itemTitle: "title",
          itemValue: "value",
          items: icons.map((i) => ({ title: i, value: i })),
        },
      },
      components: VuetifyComponents,
      directives: VuetifyDirectives,
      locale: {
        // @ts-expect-error bad types
        adapter: createVueI18nAdapter({ i18n, useI18n }),
      },
    },
  },
};

const vueprintClientPluginOptions: VueClientBootstrapOptions = {
  // Configuration for the Client plugin
  webfontloader: {
    custom: {
      families: [
        "Material Design Icons",
        "InterVariable",
        "Inter",
        "InterDisplay",
      ],
    },
  },
};

const consumer = createConsumer();

const pinia = createPinia();
const fridayApp = createApp(FridayApp, {
  consumer,
})
  .use(i18n)
  .use(router)
  .use(pinia)
  .use(VueMainBootstrap, vueprintMainPluginOptions)
  .use(VueClientBootstrap, vueprintClientPluginOptions)
  .use(head)
  .use({
    install: (app: App) => {
      app.config.globalProperties.$actioncable = consumer;
      app.provide("actioncable", consumer);
    },
  } as Plugin)
  .mount("#friday-app");

if (window) {
  window._friday = fridayApp as any as ReturnType<typeof createApp>;
}
