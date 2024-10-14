import { getCurrentInstance } from "vue";
import dot from "dot-object";

import type { InjectionKey, Ref } from "vue";
import type { DefaultsInstance } from "vuetify";

// @ts-ignore
const DefaultsSymbol: InjectionKey<Ref<DefaultsInstance>> =
  Symbol.for("vuetify:defaults");

export const useDefaults = (defined: any, component: string) => {
  if (
    "object" !== typeof defined ||
    null === defined ||
    Array.isArray(defined)
  ) {
    defined = {};
  }
  const vm = getCurrentInstance();
  if (vm) {
    const vuetifyDefinedDefaults =
      vm.appContext.provides[DefaultsSymbol as unknown as string];
    if (vuetifyDefinedDefaults.value[component]) {
      const defaulted = dot.dot(vuetifyDefinedDefaults.value[component]);
      const current = dot.dot(defined);
      const merged: any = {};
      Object.keys(defaulted).forEach((key) => {
        merged[key] = defaulted[key];
      });
      Object.keys(current).forEach((key) => {
        merged[key] = current[key];
      });
      defined = dot.object(merged);
    }
  }
  return defined;
};

export const getDefault = <T = any>(
  key: string,
  component: string,
  otherwise?: T,
) => {
  const vm = getCurrentInstance();
  if (vm) {
    const vuetifyDefinedDefaults =
      vm.appContext.provides[DefaultsSymbol as unknown as string];
    if (vuetifyDefinedDefaults.value[component]) {
      const defaulted = dot.dot(vuetifyDefinedDefaults.value[component]);
      return defaulted[key];
    }
  }
  return otherwise;
};
