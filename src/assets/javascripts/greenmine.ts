import "@jakguru/vueprint/vueprint.css";
import "../stylesheets/greenmine.scss";
import "../stylesheets/glass.scss";

import { createApp, h } from "vue";
import { createPinia } from "pinia";
import { router } from "@/assets/javascripts/plugins/router";
import { i18n, useI18n } from "@/assets/javascripts/plugins/i18n";
import VueMainBootstrap from "@jakguru/vueprint/plugins/main";
import VueClientBootstrap from "@jakguru/vueprint/plugins/client";
import * as VuetifyComponents from "vuetify/components";
import * as VuetifyDirectives from "vuetify/directives";
import { createVueI18nAdapter } from "vuetify/locale/adapters/vue-i18n";

import GreenmineApp from "../../app.vue";

import type {
  VueMainBootstrapOptions,
  VueClientBootstrapOptions,
} from "@jakguru/vueprint/plugins";

const mainColors = {
  primary: "#62B682",
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
    namespace: "greenmine",
  },
  ls: {
    namespace: "greenmine",
  },
  vuetify: {
    defaultTheme: "greenmine-light",
    themes: {
      "greenmine-dark": {
        dark: true,
        colors: {
          ...mainColors,
          accent: "#FF6600",
          background: "#424242",
          cancel: "#FF0000",
          error: "#D9534F",
          highlight: "#FFFFFF",
          info: "#5BC0DE",
          notify: "#5BC0DE",
          question: "#337AB7",
          secondary: "#333333",
          success: "#5CB85C",
          surface: "#242424",
          warning: "#F0AD4E",
        },
      },
      "greenmine-light": {
        dark: false,
        colors: {
          ...mainColors,
          accent: "#FF6600",
          background: "#DFDFDF",
          cancel: "#FF0000",
          error: "#D9534F",
          highlight: "#000000",
          info: "#5BC0DE",
          notify: "#5BC0DE",
          question: "#337AB7",
          secondary: "#666666",
          success: "#5CB85C",
          surface: "#F7F7F7",
          warning: "#F0AD4E",
        },
      },
    },
    options: {
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
        adapter: createVueI18nAdapter({ i18n, useI18n }),
      },
    },
  },
};

const vueprintClientPluginOptions: VueClientBootstrapOptions = {
  // Configuration for the Client plugin
};
const pinia = createPinia();
const app = createApp({
  render: () => h(GreenmineApp),
})
  .use(i18n)
  .use(router)
  .use(pinia)
  .use(VueMainBootstrap, vueprintMainPluginOptions)
  .use(VueClientBootstrap, vueprintClientPluginOptions);

app.mount("#greenmine-app");
