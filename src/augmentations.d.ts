/// <reference types="vite/client" />

declare module "@jakguru/vueprint" {
  interface BusEventCallbackSignatures {
    "theme:changed": (current: string, from?: string) => void;
  }
}
export {};

interface ImportMeta {
  readonly env: Record<string, string>;
}
