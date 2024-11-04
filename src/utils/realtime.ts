import { appDebug } from "@/utils/app";
import type { BusService } from "@jakguru/vueprint";
import type Cable from "@rails/actioncable";

export interface RealtimeApplicationUpdateEventPayload {
  updated: boolean;
}

export interface RealtimeDisconnectedEventPayload {
  willAttemptReconnect: boolean;
}

export const hookRealtime = (bus: BusService, consumer: Cable.Consumer) => {
  appDebug("Creating Realtime Subscriptions");
  consumer.subscriptions.create(
    {
      channel: "FridayPlugin::RealTimeUpdatesChannel",
      room: "application",
    },
    {
      connected() {
        appDebug("Realtime updates channel connected");
        bus.emit("rtu:connected", {
          local: true,
        });
      },
      disconnected() {
        appDebug("Realtime updates channel disconnected");
        bus.emit("rtu:disconnected", {
          local: true,
        });
      },
      rejected() {
        appDebug("Realtime updates channel rejected");
        bus.emit("rtu:rejected", {
          local: true,
        });
      },
      received(data: RealtimeApplicationUpdateEventPayload) {
        appDebug("Realtime updates channel received", data);
        bus.emit(
          "rtu:application",
          {
            local: true,
          },
          data,
        );
      },
    },
  );
  consumer.subscriptions.create(
    {
      channel: "FridayPlugin::RealTimeUpdatesChannel",
      room: "enumerations",
    },
    {
      received(data: RealtimeApplicationUpdateEventPayload) {
        appDebug("Realtime updates channel for enumerations received", data);
        bus.emit(
          "rtu:enumerations",
          {
            local: true,
          },
          data,
        );
      },
    },
  );
};
