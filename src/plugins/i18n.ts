import { createI18n, useI18n } from "vue-i18n";
import * as locales from "@/locales";

export const getHtmlLocale = () => {
  if (document) {
    const html = document.querySelector("html");
    if (html) {
      const locale = html.getAttribute("lang") || "en";
      if (locale.includes("-")) {
        return locale.split("-")[0].toLowerCase();
      } else {
        return locale.toLowerCase();
      }
    }
  }
  return "en";
};

const settings = {
  locale: getHtmlLocale(),
  fallbackLocale: "en",
  legacy: false,
  messages: { ...locales },
};

export const i18n = createI18n(settings);

export { useI18n };
