import languages from "@/constants/languages";
import { useI18n } from "@/plugins/i18n";
import { useLocale } from "vuetify";
import { inject } from "vue";
import type { LocalStorageService } from "@jakguru/vueprint";
import type { WritableComputedRef, Ref } from "vue";
import type * as messages from "@/locales";

type Language = keyof typeof messages;

export const asArray = Object.keys(languages).map((key) => languages[key]);

export const setLocale = (
  locale: WritableComputedRef<string>,
  isRtl: Ref<boolean>,
  is: string,
): void => {
  const language = languages[is];
  if (!language) {
    return;
  }
  const ls = inject<LocalStorageService>("ls");
  if (locale.value !== language.iso) {
    if (ls) {
      ls.set("locale", language.iso);
    }
  }
  locale.value = language.iso;
  isRtl.value = language.rtl;
};

export const initializeLocale = (): void => {
  const { locale } = useI18n({ useScope: "global" });
  const { isRtl } = useLocale();
  const ls = inject<LocalStorageService>("ls");
  let iso = locale.value;
  if (ls) {
    ls.promise.then(() => {
      iso = ls.get("locale") || locale.value || "en";
      const language = languages[iso];
      if (!language) {
        return;
      }
      locale.value = language.iso as Language;
      //   setLocale(language.iso);
      isRtl.value = language.rtl;
    });
  } else {
    const language = languages[iso];
    if (!language) {
      return;
    }
    locale.value = language.iso as Language;
    //   setLocale(language.iso);
    isRtl.value = language.rtl;
  }
};
