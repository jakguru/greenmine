import { inject } from "vue";
import { appDebug } from "@/utils/app";
import type { BusService } from "@jakguru/vueprint";
import type Cable from "@rails/actioncable";
import type { Node, Edge } from "@vue-flow/core";

export interface RealtimeModelEventPayload {
  updated: number[];
}

export interface RealtimeApplicationUpdateEventPayload {
  updated: boolean;
}

export interface RealtimeApplicationUpdateEventWithTabUUIDPayload {
  updated: boolean;
  from: string | null;
  nodes: Node[];
  edges: Edge[];
}

export interface RealtimeDisconnectedEventPayload {
  willAttemptReconnect: boolean;
}
// rtu_gitlab_instance_projects
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
  consumer.subscriptions.create(
    {
      channel: "FridayPlugin::RealTimeUpdatesChannel",
      room: "issues",
    },
    {
      received(data: RealtimeModelEventPayload) {
        appDebug("Realtime updates channel for issues received", data);
        bus.emit(
          "rtu:issues",
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
      room: "sprints",
    },
    {
      received(data: RealtimeModelEventPayload) {
        appDebug("Realtime updates channel for sprints received", data);
        bus.emit(
          "rtu:sprints",
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
      room: "issue_statuses",
    },
    {
      received(data: RealtimeApplicationUpdateEventPayload) {
        appDebug("Realtime updates channel for issue-statuses received", data);
        bus.emit(
          "rtu:issue-statuses",
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
      room: "trackers",
    },
    {
      received(data: RealtimeApplicationUpdateEventPayload) {
        appDebug("Realtime updates channel for trackers received", data);
        bus.emit(
          "rtu:trackers",
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
      room: "workflows",
    },
    {
      received(data: RealtimeApplicationUpdateEventWithTabUUIDPayload) {
        appDebug("Realtime updates channel for workflows received", data);
        bus.emit(
          "rtu:workflows",
          {
            local: true,
          },
          data,
        );
      },
    },
  );
};

export const useActionCableConsumer = () => {
  return inject<Cable.Consumer>("actioncable");
};
