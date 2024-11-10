import { h } from "vue";
import qs from "qs";
import { VMenu } from "vuetify/components/VMenu";
import { VCard } from "vuetify/components/VCard";
import { VListItem } from "vuetify/components/VList";

import type { ApiService } from "@jakguru/vueprint";
import type { Item } from "@/friday";
import type { ActionMenuItem } from "@/components/queries/partials/action-menu";
import type { useI18n } from "vue-i18n";
type I18nT = ReturnType<typeof useI18n>["t"];

export interface IssueActionPermissions {
  edit: boolean;
  log_time: boolean;
  copy: boolean;
  add_watchers: boolean;
  delete: boolean;
  add_subtask: boolean;
  assign_to_sprint: boolean;
  unassign_from_sprint: boolean;
}

export interface IssueActionStatus {
  id: number;
  name: string;
}

export interface IssueActionAssignee {
  id: number;
  name: string;
}

export interface IssueActionTracker {
  id: number;
  name: string;
}

export interface IssueActionVersion {
  id: number;
  name: string;
}

export interface IssueActionUrgency {
  id: number;
  name: string;
}

export interface IssueActionImpact {
  id: number;
  name: string;
}

export interface IssueActionSprint {
  id: number;
  name: string;
  starts: string; // Assuming ISO 8601 format
  ends: string; // Assuming ISO 8601 format
}

export interface IssueActionValues {
  statuses: IssueActionStatus[];
  assignees: IssueActionAssignee[];
  trackers: IssueActionTracker[];
  versions: IssueActionVersion[];
  urgencies: IssueActionUrgency[];
  impacts: IssueActionImpact[];
  sprints: IssueActionSprint[];
}

export interface IssueActionResponseData {
  permissions: IssueActionPermissions;
  values: IssueActionValues;
}

export const getContextMenuActionsAndOptions = async (
  api: ApiService | undefined | null,
  issues: Item[],
) => {
  if (!api) {
    return false;
  }
  const ids = issues.map((issue) => issue.id);
  const { status, data } = await api.get<IssueActionResponseData>(
    `/ui/actions/issues?${qs.stringify({ ids }, { arrayFormat: "brackets" })}`,
  );
  if (status !== 200) {
    return false;
  }
  return data;
};

const makeActionMenuSubmenu = (
  title: string,
  values: { id: number; name: string }[],
  items: Item[],
  callback: (
    issues: Item[],
    value: { id: number; name: string },
  ) => void | Promise<void>,
) => {
  return {
    component: h(
      VMenu,
      {
        openOnHover: true,
        submenu: true,
      },
      {
        activator: ({ props }: { props: any }) =>
          h(VListItem, {
            ...props,
            title,
            appendIcon: "mdi-menu-right",
            density: "compact",
          }),
        default: () =>
          h(
            VCard,
            {
              color: "background",
            },
            [
              values.map((v) =>
                h(VListItem, {
                  title: v.name,
                  density: "compact",
                  onClick: () => {
                    callback(items, v);
                  },
                }),
              ),
            ],
          ),
      },
    ),
  };
};

const getActionMenuItems = async (
  api: ApiService | undefined | null,
  t: I18nT,
  issues: Item[],
  onDone: () => void,
  onFilterTo: () => void,
): Promise<ActionMenuItem[]> => {
  if (!api) {
    return [
      {
        component: h(VListItem, {
          title: t("issueActionMenu.filterTo.title"),
          appendIcon: "mdi-filter",
          density: "compact",
          onClick: () => onFilterTo(),
        }),
      },
    ];
  }
  const fromApi = await getContextMenuActionsAndOptions(api, issues);
  if (!fromApi) {
    return [
      {
        component: h(VListItem, {
          title: t("issueActionMenu.filterTo.title"),
          appendIcon: "mdi-filter",
          density: "compact",
          onClick: () => onFilterTo(),
        }),
      },
    ];
  }
  const ret: ActionMenuItem[] = [];
  if (issues.length === 1) {
    ret.push({
      component: h(VListItem, {
        title: fromApi.permissions.edit
          ? t("issueActionMenu.edit.title")
          : t("issueActionMenu.view.title"),
        appendIcon: fromApi.permissions.edit ? "mdi-pencil" : "mdi-eye",
        density: "compact",
        to: {
          name: "issues-id",
          params: { id: issues[0].id },
        },
      }),
    });
  }
  if (fromApi.permissions.assign_to_sprint) {
    ret.push(
      makeActionMenuSubmenu(
        t("issueActionMenu.assignToSprint.title"),
        fromApi.values.sprints,
        issues,
        () => {
          console.log("assign to sprint");
          onDone();
        },
      ),
    );
  }
  if (fromApi.permissions.unassign_from_sprint) {
    ret.push({
      component: h(VListItem, {
        title: t("issueActionMenu.unassignFromSprint.title"),
        appendIcon: "mdi-close-octagon",
        density: "compact",
        onClick: () => {
          console.log("unassign from sprint");
          onDone();
        },
      }),
    });
  }
  if (fromApi.permissions.edit) {
    if (fromApi.values.statuses.length > 0) {
      ret.push(
        makeActionMenuSubmenu(
          t("issueActionMenu.changeStatus.title"),
          fromApi.values.statuses,
          issues,
          () => {
            console.log("change status");
            onDone();
          },
        ),
      );
    }
    if (fromApi.values.assignees.length > 0) {
      ret.push(
        makeActionMenuSubmenu(
          t("issueActionMenu.assignTo.title"),
          fromApi.values.assignees,
          issues,
          () => {
            console.log("assign to");
            onDone();
          },
        ),
      );
    }
    ret.push(
      makeActionMenuSubmenu(
        t("issueActionMenu.doneRatio.title"),
        [10, 20, 30, 40, 50, 60, 70, 80, 90, 100].map((v) => ({
          id: v,
          name: `${v}%`,
        })),
        issues,
        () => {
          console.log("set done ratio");
          onDone();
        },
      ),
    );
    if (fromApi.values.trackers.length > 0) {
      ret.push(
        makeActionMenuSubmenu(
          t("issueActionMenu.changeTracker.title"),
          fromApi.values.trackers,
          issues,
          () => {
            console.log("change tracker");
            onDone();
          },
        ),
      );
    }
    if (fromApi.values.versions.length > 0) {
      ret.push(
        makeActionMenuSubmenu(
          t("issueActionMenu.changeVersion.title"),
          fromApi.values.versions,
          issues,
          () => {
            console.log("change version");
            onDone();
          },
        ),
      );
    }
    if (fromApi.values.urgencies.length > 0) {
      ret.push(
        makeActionMenuSubmenu(
          t("issueActionMenu.changeUrgency.title"),
          fromApi.values.urgencies,
          issues,
          () => {
            console.log("change urgency");
            onDone();
          },
        ),
      );
    }
    if (fromApi.values.impacts.length > 0) {
      ret.push(
        makeActionMenuSubmenu(
          t("issueActionMenu.changeImpact.title"),
          fromApi.values.impacts,
          issues,
          () => {
            console.log("change impact");
            onDone();
          },
        ),
      );
    }
  }
  if (issues.length === 1 && fromApi.permissions.copy) {
    ret.push({
      component: h(VListItem, {
        title: t("issueActionMenu.copy.title"),
        appendIcon: "mdi-content-copy",
        density: "compact",
        onClick: () => {
          console.log("copy");
          onDone();
        },
      }),
    });
  }
  ret.push({
    component: h(VListItem, {
      title: t("issueActionMenu.filterTo.title"),
      appendIcon: "mdi-filter",
      density: "compact",
      onClick: () => onFilterTo(),
    }),
  });
  if (fromApi.permissions.delete) {
    ret.push({
      component: h(VListItem, {
        title: t("issueActionMenu.delete.title"),
        appendIcon: "mdi-delete",
        density: "compact",
        onClick: () => {
          console.log("delete");
          onDone();
        },
      }),
    });
  }
  if (ret.length === 0) {
    ret.push({
      component: h(VListItem, {
        title: t("issueActionMenu.filterTo.title"),
        appendIcon: "mdi-filter",
        density: "compact",
        onClick: () => onFilterTo(),
      }),
    });
  }
  return ret;
};

export const useGetActionMenuItems = (
  api: ApiService | undefined | null,
  t: I18nT,
) => {
  return getActionMenuItems.bind(null, api, t);
};
