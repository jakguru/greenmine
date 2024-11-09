<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px"
            >mdi-debug-step-over</v-icon
          >
          {{
            $t("pages.sprints-id.specificTitle", {
              id: sprint.id ? sprint.id : 0,
              name: sprint.name,
            })
          }}
        </v-toolbar-title>
        <v-toolbar-items class="ms-auto">
          <v-btn
            :to="{
              name: 'sprints-id',
              params: { id: navigation.previous },
              query: $route.query,
            }"
          >
            <v-icon>mdi-chevron-left</v-icon>
          </v-btn>
          <v-btn
            :to="{
              name: 'sprints-id',
              params: { id: navigation.next },
              query: $route.query,
            }"
          >
            <v-icon>mdi-chevron-right</v-icon>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-divider />
      <v-breadcrumbs v-bind="breadcrumbsBindings" />
      <v-divider />
      <v-tabs v-bind="vTabBindings" />
      <v-divider />
      <template v-if="tab === 'summary'">
        <v-container fluid>
          <v-row>
            <v-col cols="12">
              <v-progress-linear
                :model-value="rate"
                :color="accentColor"
                height="30"
              >
                <span>{{ parseInt(rate.toString()) }}%</span>
              </v-progress-linear>
            </v-col>
          </v-row>
          <v-row>
            <v-col cols="12">
              <SprintBurndown :sprint="sprint" />
            </v-col>
          </v-row>
        </v-container>
      </template>
      <template v-else-if="tab === 'issues'">
        <v-container fluid>
          <v-row v-if="!isBacklog">
            <v-col cols="12">
              <SprintCapacity :sprint="sprint" :workload="workload" />
            </v-col>
          </v-row>
          <v-toolbar color="transparent">
            <v-slide-group show-arrows class="mx-2">
              <v-slide-group-item v-if="showFiltersMenu">
                <QueriesPartialFilters
                  v-model:model-value="value"
                  :dirty="dirty"
                  :submitting="submitting"
                  @submit="onSubmit"
                />
              </v-slide-group-item>
              <v-slide-group-item v-if="showColumnsMenu">
                <QueriesPartialColumns
                  v-model:model-value="value"
                  :dirty="dirty"
                  :submitting="submitting"
                  @submit="onSubmit"
                />
              </v-slide-group-item>
              <v-slide-group-item v-if="showSortingMenu">
                <QueriesPartialSorting
                  v-model:model-value="value"
                  :dirty="dirty"
                  :submitting="submitting"
                  @submit="onSubmit"
                />
              </v-slide-group-item>
              <v-slide-group-item v-if="showGroupingsMenu">
                <QueriesPartialGroupings
                  v-model:model-value="value"
                  :dirty="dirty"
                  :submitting="submitting"
                  @submit="onSubmit"
                />
              </v-slide-group-item>
              <v-slide-group-item v-if="showAdditional">
                <QueriesPartialOptions
                  v-model:model-value="value"
                  :dirty="dirty"
                  :submitting="submitting"
                  @submit="onSubmit"
                />
              </v-slide-group-item>
              <v-slide-group-item>
                <v-btn
                  variant="elevated"
                  :color="accentColor"
                  size="x-small"
                  class="ma-2"
                  type="submit"
                  height="24px"
                  :disabled="!dirty"
                  :loading="submitting"
                  style="position: relative; top: 1px"
                >
                  <v-icon class="me-2">mdi-check</v-icon>
                  {{ $t("labels.apply") }}
                </v-btn>
              </v-slide-group-item>
              <v-slide-group-item>
                <v-btn
                  variant="elevated"
                  :color="accentColor"
                  size="x-small"
                  class="ma-2"
                  type="button"
                  height="24px"
                  :loading="submitting"
                  :disabled="!dirty"
                  style="position: relative; top: 1px"
                  @click="onReset"
                >
                  <v-icon class="me-2">mdi-restore</v-icon>
                  {{ $t("labels.reset") }}
                </v-btn>
              </v-slide-group-item>
              <v-slide-group-item>
                <v-btn
                  variant="elevated"
                  :color="accentColor"
                  size="x-small"
                  class="ma-2"
                  type="button"
                  height="24px"
                  :loading="submitting"
                  style="position: relative; top: 1px"
                  @click="onRefresh"
                >
                  <v-icon class="me-2">mdi-refresh</v-icon>
                  {{ $t("labels.refresh") }}
                </v-btn>
              </v-slide-group-item>
            </v-slide-group>
          </v-toolbar>
          <QueriesPartialDataTable
            v-model:model-value="value"
            v-model:payload-value="payloadValue"
            :query="query"
            :payload="payload"
            :submitting="submitting"
            :dirty="dirty"
            @submit="onSubmit"
          />
        </v-container>
      </template>
      <template
        v-else-if="tab === 'edit' && permissions.edit === true && sprint.id"
      >
        <FridayForm
          v-bind="fridayFormBindings"
          @success="onSuccess"
          @error="onError"
        >
          <template #afterRows="{ isLoading, submit, reset }">
            <v-row>
              <v-col cols="12">
                <div class="d-flex w-100 justify-end">
                  <v-btn
                    variant="elevated"
                    :color="accentColor"
                    size="x-small"
                    class="ma-2"
                    type="button"
                    height="24px"
                    :loading="isLoading"
                    @click="reset"
                  >
                    <v-icon class="me-2">mdi-restore</v-icon>
                    {{ $t("labels.reset") }}
                  </v-btn>
                  <v-btn
                    variant="elevated"
                    :color="accentColor"
                    size="x-small"
                    class="ma-2 me-0"
                    type="button"
                    height="24px"
                    :loading="isLoading"
                    @click="submit"
                  >
                    <v-icon class="me-2">mdi-check</v-icon>
                    {{ $t("labels.save") }}
                  </v-btn>
                </div>
              </v-col>
            </v-row>
          </template>
        </FridayForm>
      </template>
      <template
        v-else-if="tab === 'edit' && permissions.edit === false && sprint.id"
      >
        I am a pretty no permissions screen
      </template>
      <template v-else>
        I am a pretty section for a tab which doesn't exist
      </template>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, inject, onMounted, ref, watch } from "vue";
import { useHead } from "@unhead/vue";
import { useI18n } from "vue-i18n";
import { useRoute, useRouter } from "vue-router";
import { makeNewQueryPayloadFromQueryAndQueryPayload } from "@/friday";
import {
  useSystemAccentColor,
  cloneObject,
  checkObjectEquality,
  loadRouteData,
} from "@/utils/app";
import { VTextField } from "vuetify/components/VTextField";
import { SprintBurndown, SprintCapacity } from "@/components/charts/sprint";
import { Joi, getFormFieldValidator, FridayForm } from "@/components/forms";
import { toISODate } from "@/utils/formatting";
import {
  QueriesPartialFilters,
  QueriesPartialColumns,
  QueriesPartialSorting,
  QueriesPartialGroupings,
  QueriesPartialOptions,
  QueriesPartialDataTable,
} from "@/components/queries/partials";
import { useRouteDataStore } from "@/stores/routeData";

import type { PropType } from "vue";
import type {
  SwalService,
  ToastService,
  ApiService,
  BusService,
  BusEventCallbackSignatures,
} from "@jakguru/vueprint";
import type { FridayFormStructure } from "@/components/forms";
import type {
  QueryResponsePayload,
  QueryData,
  Sprint,
  Issue,
  QueryResponse,
  Progress,
  WorkloadAllocation,
  Release,
  BreakdownByCalculatedPriority,
  BreakdownByTracker,
  BreakdownByActivity,
  BreakdownByProject,
  SprintNavigation,
  SprintPermissions,
} from "@/friday";
import type { RealtimeModelEventPayload } from "@/utils/realtime";

export default defineComponent({
  name: "SprintsID",
  components: {
    FridayForm,
    SprintBurndown,
    SprintCapacity,
    QueriesPartialFilters,
    QueriesPartialColumns,
    QueriesPartialSorting,
    QueriesPartialGroupings,
    QueriesPartialOptions,
    QueriesPartialDataTable,
  },
  props: {
    formAuthenticityToken: {
      type: String as PropType<string>,
      required: true,
    },
    sprint: {
      type: Object as PropType<Sprint>,
      required: true,
    },
    issues: {
      type: Object as PropType<QueryResponse<Issue>>,
      required: true,
    },
    rate: {
      type: Number as PropType<number>,
      required: true,
    },
    progress: {
      type: Object as PropType<Progress>,
      required: true,
    },
    workload: {
      type: Array as PropType<Array<WorkloadAllocation>>,
      required: true,
    },
    releases: {
      type: Array as PropType<Array<Release>>,
      required: true,
    },
    byCalculatedPriority: {
      type: Object as PropType<BreakdownByCalculatedPriority>,
      required: true,
    },
    byTracker: {
      type: Object as PropType<BreakdownByTracker>,
      required: true,
    },
    byActivity: {
      type: Object as PropType<BreakdownByActivity>,
      required: true,
    },
    byProject: {
      type: Object as PropType<BreakdownByProject>,
      required: true,
    },
    navigation: {
      type: Object as PropType<SprintNavigation>,
      required: true,
    },
    permissions: {
      type: Object as PropType<SprintPermissions>,
      required: true,
    },
  },
  setup(props) {
    const toast = inject<ToastService>("toast");
    const swal = inject<SwalService>("swal");
    const api = inject<ApiService>("api");
    const bus = inject<BusService>("bus");
    const route = useRoute();
    const router = useRouter();
    const accentColor = useSystemAccentColor();
    const sprint = computed(() => props.sprint);
    const isBacklog = computed(
      () => sprint.value.id === null || sprint.value.id === 0,
    );
    const permissions = computed(() => props.permissions);
    const { t } = useI18n({ useScope: "global" });
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.sprints.title"), to: { name: "sprints" } },
        {
          title: t("pages.sprints-id.specificTitle", {
            id: props.sprint.id ? props.sprint.id : 0,
            name: props.sprint.name,
          }),
        },
      ],
    }));
    const tabs = computed(() =>
      [
        { text: t("pages.sprints-id.content.tabs.summary"), value: "summary" },
        { text: t("pages.sprints-id.content.tabs.issues"), value: "issues" },
        permissions.value.edit && sprint.value.id
          ? { text: t("pages.sprints-id.content.tabs.edit"), value: "edit" }
          : undefined,
      ].filter((v) => "undefined" !== typeof v),
    );
    const tab = computed({
      get: () => (route.query.tab as string | undefined) ?? "summary",
      set: (v: string) => {
        router.push({ query: Object.assign({}, route.query, { tab: v }) });
      },
    });
    const vTabBindings = computed(() => ({
      modelValue: tab.value,
      items: tabs.value,
      density: "compact" as const,
      mandatory: true,
      showArrows: true,
      sliderColor: "accent",
      "onUpdate:modelValue": (v: unknown) => {
        if (typeof v === "string") {
          tab.value = v;
        }
      },
    }));
    const onSuccess = (_status: number, _data: any) => {
      if (!toast) {
        alert(t("pages.sprints-id.onSave.success"));
        return;
      } else {
        toast.fire({
          title: t("pages.sprints-id.onSave.success"),
          icon: "success",
        });
        return;
      }
    };
    const onError = (_status: number, payload: unknown) => {
      if (payload instanceof Error) {
        console.error(payload);
      }
      if (!swal) {
        alert(t("pages.sprints-id.onSave.error"));
        return;
      } else {
        swal.fire({
          title: t("pages.sprints-id.onSave.error"),
          icon: "error",
        });
        return;
      }
    };
    onMounted(() => {
      useHead({
        title: t("pages.sprints-id.specificTitle", {
          id: sprint.value.id ? sprint.value.id : 0,
          name: sprint.value.name,
        }),
      });
    });

    const formAuthenticityToken = computed(() => props.formAuthenticityToken);
    const modifyPayload = (payload: Record<string, unknown>) => {
      return {
        authenticity_token: formAuthenticityToken.value,
        _method: "patch",
        sprint: payload,
      };
    };
    const formStructure = computed<FridayFormStructure>(() => {
      return [
        [
          {
            cols: 12,
            md: 4,
            fieldComponent: VTextField,
            formKey: "name",
            valueKey: "name",
            label: t("pages.sprints-new.fields.name"),
            validator: getFormFieldValidator(
              t,
              Joi.string().required(),
              t("pages.sprints-new.fields.name"),
            ),
            bindings: {
              type: "text",
              label: t("pages.sprints-new.fields.name"),
            },
          },
        ],
        [
          {
            cols: 12,
            md: 4,
            fieldComponent: VTextField,
            formKey: "start_date",
            valueKey: "start_date",
            label: t("pages.sprints-new.fields.start_date"),
            validator: getFormFieldValidator(
              t,
              Joi.date().required(),
              t("pages.sprints-new.fields.name"),
            ),
            bindings: {
              type: "date",
              label: t("pages.sprints-new.fields.start_date"),
            },
          },
        ],
        [
          {
            cols: 12,
            md: 4,
            fieldComponent: VTextField,
            formKey: "end_date",
            valueKey: "end_date",
            label: t("pages.sprints-new.fields.end_date"),
            validator: getFormFieldValidator(
              t,
              Joi.date().required(),
              t("pages.sprints-new.fields.name"),
            ),
            bindings: {
              type: "date",
              label: t("pages.sprints-new.fields.end_date"),
            },
          },
        ],
      ];
    });
    const fridayFormBindings = computed(() => ({
      action: router.resolve({
        name: "sprints-id",
        params: { id: sprint.value.id },
      }).href,
      method: "put",
      structure: formStructure.value,
      values: {
        name: sprint.value.name,
        start_date: toISODate(sprint.value.start_date),
        end_date: toISODate(sprint.value.end_date),
      },
      modifyPayload,
      validHttpStatus: 201,
    }));

    const issues = computed(() => props.issues);
    const query = computed(() => issues.value.query);
    const value = ref<QueryData>(cloneObject(query.value));
    const payload = computed(() => issues.value.payload);
    const payloadValue = ref<QueryResponsePayload>(cloneObject(payload.value));
    const dirty = computed(
      () =>
        !checkObjectEquality(value.value, query.value) ||
        !checkObjectEquality(payloadValue.value, payload.value),
    );
    watch(
      () => query.value,
      (v) => {
        value.value = cloneObject(v);
      },
      { immediate: true, deep: true },
    );
    watch(
      () => payload.value,
      (v) => {
        payloadValue.value = cloneObject(v);
      },
      { immediate: true, deep: true },
    );
    const onReset = () => {
      value.value = cloneObject(query.value);
    };
    const submitting = ref(false);
    const onSubmit = (e?: Event) => {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
      }
      if (submitting.value) {
        return;
      }
      const payload = makeNewQueryPayloadFromQueryAndQueryPayload(
        value.value,
        payloadValue.value,
      );
      submitting.value = true;
      router
        // @ts-expect-error the query object's type is correct, but the router's type is not
        .push({ ...route, query: { tab: tab.value, ...payload } })
        .catch((e) => {
          console.warn(e);
          // noop
        })
        .finally(() => {
          submitting.value = false;
        });
    };
    const routeDataStore = useRouteDataStore();
    const onRefresh = async (e?: Event) => {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
      }
      if (submitting.value) {
        return;
      }
      submitting.value = true;
      try {
        const d = await loadRouteData(route, api, toast);
        value.value = d.query;
        payloadValue.value = d.payload;
        routeDataStore.set(d);
        routeDataStore.store(d);
      } catch {
        // noop
      }
      submitting.value = false;
    };
    const showFiltersMenu = computed(() => {
      return Object.keys(query.value.filters.available).length > 0;
    });
    const showColumnsMenu = computed(() => {
      return (
        query.value.display.current === "list" &&
        query.value.columns.available.inline.length > 0
      );
    });
    const showSortingMenu = computed(() => {
      return (
        query.value.columns.available.sortable &&
        query.value.columns.available.sortable.length > 0
      );
    });
    const showGroupingsMenu = computed(() => {
      return (
        query.value.display.current === "list" &&
        query.value.columns.available.groupable.length > 0
      );
    });
    const showBlockable = computed(() => {
      return query.value.columns.available.block.length > 0;
    });
    const showTotalable = computed(() => {
      return query.value.columns.available.totalable.length > 0;
    });
    const showAdditional = computed(() => {
      return showBlockable.value || showTotalable.value;
    });
    router.afterEach(() => {
      submitting.value = false;
    });
    const modelRealtimeUpdateKey = computed<
      keyof BusEventCallbackSignatures | undefined
    >(() => undefined);
    const onModelRealtimeUpdate = (incoming: RealtimeModelEventPayload) => {
      const currentEntityIds = [...payload.value.items].map((i) => i.id);
      const hasMatch = incoming.updated.some((u) =>
        currentEntityIds.includes(u),
      );
      if (hasMatch) {
        onRefresh();
      }
    };
    watch(
      () => modelRealtimeUpdateKey.value,
      (is, was) => {
        if (bus) {
          if (was) {
            bus.off(was, onModelRealtimeUpdate, { local: true });
          }
          if (is) {
            bus.on(is, onModelRealtimeUpdate, { local: true });
          }
        }
      },
      { immediate: true },
    );
    return {
      breadcrumbsBindings,
      vTabBindings,
      tab,
      accentColor,
      onSuccess,
      onError,
      fridayFormBindings,
      isBacklog,

      value,
      dirty,
      submitting,
      onSubmit,
      onReset,
      onRefresh,
      query,
      payload,
      payloadValue,
      showFiltersMenu,
      showColumnsMenu,
      showSortingMenu,
      showGroupingsMenu,
      showAdditional,
    };
  },
});
</script>
