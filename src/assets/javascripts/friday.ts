import "../stylesheets/friday.scss";

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

import FridayApp from "@/app.vue";

import type {
  VueMainBootstrapOptions,
  VueClientBootstrapOptions,
} from "@jakguru/vueprint/plugins";

const mainColors = {
  primary: "#0273EA",
  secondary: "#62B682",
  accent: "#5F1A37",
  panel: "#6162FF",
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
          background: "#E8ECF4",
          surface: "#FFFFFF",
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
      defaults: {
        VTextField: {
          variant: "outlined",
          hideDetails: "auto",
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

const pinia = createPinia();
createApp(FridayApp)
  .use(i18n)
  .use(router)
  .use(pinia)
  .use(VueMainBootstrap, vueprintMainPluginOptions)
  .use(VueClientBootstrap, vueprintClientPluginOptions)
  .use(head)
  .mount("#friday-app");
