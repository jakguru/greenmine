/// <reference types="vite/client" />

import type {
  RealtimeApplicationUpdateEventPayload,
  RealtimeApplicationUpdateEventWithTabUUIDPayload,
  RealtimeModelEventPayload,
} from "./utils/realtime";

declare module "@jakguru/vueprint" {
  interface BusEventCallbackSignatures {
    "theme:changed": (current: string, from?: string) => void;
    "rtu:connected": (from?: string) => void;
    "rtu:disconnected": (from?: string) => void;
    "rtu:rejected": (from?: string) => void;
    "rtu:application": (
      data: RealtimeApplicationUpdateEventPayload,
      from?: string,
    ) => void;
    "rtu:enumerations": (
      data: RealtimeApplicationUpdateEventPayload,
      from?: string,
    ) => void;
    "rtu:issues": (data: RealtimeModelEventPayload, from?: string) => void;
    "rtu:sprints": (data: RealtimeModelEventPayload, from?: string) => void;
    "rtu:issue-statuses": (
      data: RealtimeApplicationUpdateEventPayload,
      from?: string,
    ) => void;
    "rtu:trackers": (
      data: RealtimeApplicationUpdateEventPayload,
      from?: string,
    ) => void;
    "rtu:workflows": (
      data: RealtimeApplicationUpdateEventWithTabUUIDPayload,
      from?: string,
    ) => void;
  }
}
export {};

interface ImportMeta {
  readonly env: Record<string, string>;
}
