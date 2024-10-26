<template>
  <QueriesOptionMenu
    v-bind="optionsMenuBindings"
    @submit="onSubmit"
    @reset="onReset"
    @refresh="onRefresh"
  >
    <template #bottom-actions>
      <v-btn :disabled="!canShowAddFilter" variant="text" @click="doAddFilter">
        <v-icon>mdi-plus</v-icon>
        <span class="ms-2">{{ $t("labels.addFilter") }}</span>
      </v-btn>
    </template>
    <template #content>
      <v-table class="bg-transparent my-2 query-filters-panel">
        <tbody>
          <tr v-if="filterValueRows.length === 0">
            <td colspan="5" class="text-center">
              {{ $t("labels.noFilters") }}
            </td>
          </tr>
          <tr v-for="(_r, i) in filterValueRows" :key="`filter-row-${i}`">
            <td v-if="0 === i">
              <strong>{{ $t("labels.queries.where") }}</strong>
            </td>
            <td v-else>
              <strong>{{ $t("labels.queries.and") }}</strong>
            </td>
            <td>
              <v-autocomplete
                v-model="filterValueRows[i].field"
                :items="getAvailableFilterOptions(filterValueRows[i].field)"
                item-title="name"
                item-value="field"
                density="compact"
                outlined
                hide-details
                width="150"
                :return-object="true"
                @update:model-value="
                  updateFilterValueRowOperatorFor(i, filterValueRows[i].field)
                "
              />
            </td>
            <td>
              <template
                v-if="
                  filterValueRows[i].field &&
                  fieldTypeOperatorOptions[filterValueRows[i].field.type]
                "
              >
                <v-autocomplete
                  v-model="filterValueRows[i].operator"
                  :items="
                    fieldTypeOperatorOptions[filterValueRows[i].field.type]
                  "
                  item-title="label"
                  item-value="value"
                  density="compact"
                  outlined
                  hide-details
                  width="150"
                  :return-object="false"
                  @update:model-value="
                    (op) =>
                      updateFilterValueRowValuesForOperatorFor(
                        i,
                        filterValueRows[i].field,
                        op,
                      )
                  "
                />
              </template>
            </td>
            <td>
              <div
                v-if="filterValueRowValueCellConfigurations[i]"
                class="w-100 h-100 d-flex align-center"
              >
                <ValuesCellComponent
                  v-for="(cell, fi) in filterValueRowValueCellConfigurations[i]"
                  :id="`filter-${i}-cell-${fi}`"
                  :key="`filter-${i}-cell-${fi}`"
                  :configuration="cell"
                />
              </div>
            </td>
            <td>
              <v-btn
                icon="mdi-close"
                size="x-small"
                color="error"
                variant="tonal"
                @click="doRemoveFilter(i)"
              />
            </td>
          </tr>
        </tbody>
      </v-table>
    </template>
    <template #top="{ close }">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-items class="ml-auto">
          <v-btn
            variant="text"
            :loading="submitting"
            :disabled="filterValueRows.length === 0"
            @click="onClearAll"
          >
            <v-icon>mdi-notification-clear-all</v-icon>
            <span class="ms-2">{{ $t("labels.clearAll") }}</span>
          </v-btn>
          <v-btn icon="mdi-close" @click="close" />
        </v-toolbar-items>
      </v-toolbar>
      <v-divider />
    </template>
  </QueriesOptionMenu>
</template>

<script lang="ts">
import { defineComponent, computed, ref, watch, inject } from "vue";
import {
  useSystemSurfaceColor,
  useSystemAccentColor,
  useAppData,
} from "@/utils/app";
import { useI18n } from "vue-i18n";
import { ValuesCellComponent } from "./values-cell-component";
import QueriesOptionMenu from "./option-menu.vue";
import qs from "qs";

import type { PropType } from "vue";
import type { QueryData, Filter } from "@/friday";
import type { ApiService } from "@jakguru/vueprint";
import type { ValuesCellConfiguration } from "./values-cell-component";

interface FilterOptionValue {
  value: string;
  label: string;
}

interface FilterOption {
  field: string;
  type: string;
  name: string;
  remote: boolean;
  values?: Array<FilterOptionValue>;
}

interface FilterValueRow {
  field: FilterOption | undefined;
  operator: string | undefined;
  values: Array<any>;
}

export default defineComponent({
  name: "QueriesPartialFilters",
  components: {
    QueriesOptionMenu,
    ValuesCellComponent,
  },
  props: {
    modelValue: {
      type: Object as PropType<QueryData>,
      required: true,
    },
    submitting: {
      type: Boolean,
      default: false,
    },
    dirty: {
      type: Boolean,
      default: false,
    },
  },
  emits: [
    "update:modelValue",
    "update:value",
    "update",
    "submit",
    "refresh",
    "reset",
  ],
  setup(props, { emit }) {
    const { t } = useI18n({ useScope: "global" });
    const surfaceColor = useSystemSurfaceColor();
    const accentColor = useSystemAccentColor();
    const appData = useAppData();
    const api = inject<ApiService>("api");
    const modelValue = computed({
      get: () => props.modelValue,
      set: (value) => {
        emit("update:modelValue", value);
        emit("update:value", value);
        emit("update", value);
      },
    });
    const submitting = computed(() => props.submitting);
    const dirty = computed(() => props.dirty);
    const selectedFiltersCount = computed(() => {
      return Object.keys(modelValue.value.filters.current).length;
    });
    const selectedFiltersColor = computed(() =>
      selectedFiltersCount.value > 0 ? accentColor.value : surfaceColor.value,
    );
    const optionsMenuBindings = computed(() => ({
      class: ["me-2", "my-2"],
      dirty: dirty.value,
      submitting: submitting.value,
      color: selectedFiltersColor.value,
      icon: "mdi-filter",
      title: t("labels.filters"),
      count: selectedFiltersCount.value,
    }));
    const onSubmit = (e?: Event) => {
      e?.preventDefault();
      emit("submit");
    };
    const onReset = (e?: Event) => {
      e?.preventDefault();
      emit("reset");
    };
    const onRefresh = (e?: Event) => {
      e?.preventDefault();
      emit("refresh");
    };
    const allFilterOptions = computed<FilterOption[]>(() =>
      Object.keys(modelValue.value.filters.available).map((k) => ({
        field: k,
        type: modelValue.value.filters.available[k].options?.type || "unknown",
        name:
          modelValue.value.filters.available[k].options?.name ||
          t(`columns.${modelValue.value.type.toLowerCase()}.${k}`),
        remote: modelValue.value.filters.available[k].remote || false,
        values: Array.isArray(
          modelValue.value.filters.available[k].options?.values,
        )
          ? modelValue.value.filters.available[k].options?.values.map((va) => ({
              value: va[1],
              label: va[0],
            }))
          : undefined,
      })),
    );
    const currentFilterFields = computed<string[]>(() =>
      Object.keys(modelValue.value.filters.current),
    );
    const availableFilterOptions = computed<FilterOption[]>(() =>
      allFilterOptions.value.filter(
        (fo) => !currentFilterFields.value.includes(fo.field),
      ),
    );
    const filterValueRows = ref<FilterValueRow[]>([]);
    const remoteValues = ref<Record<string, FilterOptionValue[]>>({});
    const remoteAutocompletes = ref<Record<string, FilterOptionValue[]>>({});
    const remoteValuesLoading = ref<Record<string, boolean>>({});
    const remoteAutocompleteLoading = ref<Record<string, boolean>>({});
    const remoteValuesChoicesAbortControllers = ref<
      Record<string, AbortController>
    >({});
    const remoteValuesAutocompletesAbortControllers = ref<
      Record<string, AbortController>
    >({});
    const fieldValueOptions = computed(() => {
      const byField: Record<string, FilterOptionValue[]> = {};
      allFilterOptions.value.forEach((fo) => {
        const key = fo.field;
        const values = new Map<string, FilterOptionValue>();
        if (remoteAutocompletes.value[key]) {
          remoteAutocompletes.value[key].forEach((v) => {
            values.set(v.value, v);
          });
        }
        if (remoteValues.value[key]) {
          remoteValues.value[key].forEach((v) => {
            values.set(v.value, v);
          });
        }
        if (fo.values) {
          fo.values.forEach((v) => {
            values.set(v.value, v);
          });
        }
        byField[key] = Array.from(values.values());
      });
      return byField;
    });
    const fieldValuesLoading = computed(() => {
      const byField: Record<string, boolean> = {};
      allFilterOptions.value.forEach((fo) => {
        const key = fo.field;
        byField[key] =
          remoteValuesLoading.value[key] ||
          remoteAutocompleteLoading.value[key];
      });
      return byField;
    });
    const fetchRemoteValuesFor = async (filter: FilterOption) => {
      if (!api) {
        return;
      }
      if (filter.type === "relation" || !filter.remote) {
        return;
      }
      if (remoteValuesChoicesAbortControllers.value[filter.field]) {
        remoteValuesChoicesAbortControllers.value[filter.field].abort();
      }
      remoteValuesChoicesAbortControllers.value[filter.field] =
        new AbortController();
      remoteValuesLoading.value[filter.field] = true;
      try {
        const { status, data } = await api.get<Array<[string, string]>>(
          `/queries/filter?type=${modelValue.value.type}&name=${filter.field}`,
          {
            signal:
              remoteValuesChoicesAbortControllers.value[filter.field].signal,
          },
        );
        if (status === 200) {
          remoteValues.value[filter.field] = data.map((va) => ({
            value: va[1],
            label: va[0],
          }));
        }
      } catch {
        // noop
      }
      remoteValuesLoading.value[filter.field] = false;
    };
    const fetchAutocompleteValuesFor = async (
      filter: FilterOption,
      search: string,
    ) => {
      if (!api) {
        return;
      }
      if (remoteValuesAutocompletesAbortControllers.value[filter.field]) {
        remoteValuesAutocompletesAbortControllers.value[filter.field].abort();
      }
      remoteValuesAutocompletesAbortControllers.value[filter.field] =
        new AbortController();
      remoteAutocompleteLoading.value[filter.field] = true;
      try {
        const { status, data } = await api.get<
          Array<{ id: number; value: number; label: string }>
        >(`/issues/auto_complete?${qs.stringify({ term: search })}`, {
          signal:
            remoteValuesAutocompletesAbortControllers.value[filter.field]
              .signal,
        });
        if (status === 200) {
          const current = new Map<string, FilterOptionValue>();
          remoteAutocompletes.value[filter.field].forEach((v) => {
            current.set(v.value, v);
          });
          data.forEach((va) => {
            current.set(va.value.toString(), {
              value: va.value.toString(),
              label: va.label,
            });
          });
          remoteAutocompletes.value[filter.field] = Array.from(
            current.values(),
          );
        }
      } catch {
        // noop
      }
      remoteAutocompleteLoading.value[filter.field] = false;
    };
    const fetchRemoteValuesForPossiblyUndefined = async (
      filter?: FilterOption,
    ) => {
      if (!filter) {
        return;
      }
      return await fetchRemoteValuesFor(filter);
    };
    const fetchAutocompleteValuesForPossiblyUndefined = async (
      filter?: FilterOption,
      search?: string,
    ) => {
      if (!filter || !search) {
        return;
      }
      return await fetchAutocompleteValuesFor(filter, search);
    };
    // const operatorsByFieldType = computed(() => [].map((operator) => ({
    //   value: operator,
    //   label: t(`labels.queries.operators.${operator}`),
    // })));
    const operatorsByFieldType = computed(() => ({
      ...appData.value.queries[modelValue.value.type].operators,
    }));
    const fieldTypeOperatorOptions = computed(() => {
      const byType: Record<string, FilterOptionValue[]> = {};
      Object.keys(operatorsByFieldType.value).forEach((type) => {
        byType[type] = operatorsByFieldType.value[type].map(
          (operator: string) => ({
            value: operator,
            label: t(`labels.queries.operators.${operator}`),
          }),
        );
      });
      return byType;
    });
    watch(
      () => modelValue.value,
      (mv) => {
        const keys = Object.keys(mv.filters.current);
        const toSet: FilterValueRow[] = [];
        keys.forEach((k) => {
          const field = allFilterOptions.value.find((fo) => fo.field === k);
          if (field) {
            toSet.push({
              field,
              operator: mv.filters.current[k].operator,
              values: mv.filters.current[k].values,
            });
          }
        });
        const isDifferent =
          JSON.stringify(toSet) !== JSON.stringify(filterValueRows.value);
        if (!isDifferent) {
          return;
        }
        toSet.forEach((row) => {
          fetchRemoteValuesForPossiblyUndefined(row.field);
        });
        filterValueRows.value = toSet;
      },
      { deep: true, immediate: true },
    );
    watch(
      () => filterValueRows.value,
      (rows) => {
        const toSet = rows.reduce(
          (acc, row) => {
            if (row.field && row.operator) {
              acc[row.field.field] = {
                operator: row.operator,
                values: row.values,
              };
            }
            return acc;
          },
          {} as Record<string, Filter>,
        );
        const isDifferent =
          JSON.stringify(toSet) !==
          JSON.stringify(modelValue.value.filters.current);
        if (!isDifferent) {
          return;
        }
        modelValue.value.filters.current = toSet;
      },
      { deep: true },
    );
    const canShowAddFilter = computed(
      () =>
        availableFilterOptions.value.length > 0 &&
        !filterValueRows.value.find((r) => undefined === r.field),
    );
    const doAddFilter = () => {
      if (canShowAddFilter.value) {
        filterValueRows.value.push({
          field: undefined,
          operator: undefined,
          values: [],
        });
      }
    };
    const doRemoveFilter = (index: number) => {
      filterValueRows.value.splice(index, 1);
    };
    const getAvailableFilterOptions = (current?: FilterOption) => {
      return [current, ...availableFilterOptions.value].filter(
        (v) => "object" === typeof v && null !== v,
      );
    };
    const updateFilterValueRowOperatorFor = (
      index: number,
      field?: FilterOption,
    ) => {
      fetchRemoteValuesForPossiblyUndefined(field);
      if (!field) {
        filterValueRows.value[index].operator = undefined;
      } else {
        if (
          "undefined" !== typeof filterValueRows.value[index].operator &&
          !fieldTypeOperatorOptions.value[field.type].some(
            (op) => op.value === filterValueRows.value[index].operator,
          )
        ) {
          filterValueRows.value[index].operator =
            fieldTypeOperatorOptions.value[field.type][0].value;
        }
      }
    };
    const updateFilterValueRowValuesForOperatorFor = (
      index: number,
      field?: FilterOption,
      operator?: string,
    ) => {
      if (!field) {
        return;
      }
      switch (field.type) {
        case "list":
        case "list_with_history":
        case "list_optional":
        case "list_optional_with_history":
        case "list_status":
        case "list_subprojects":
          filterValueRows.value[index].values = [];
          break;
        case "date":
        case "date_past":
          switch (operator) {
            case "><":
              filterValueRows.value[index].values = [undefined, undefined];
              break;
            case "nd":
            case "t":
            case "ld":
            case "nw":
            case "w":
            case "lw":
            case "l2w":
            case "nm":
            case "m":
            case "lm":
            case "y":
            case "!*":
            case "*":
              filterValueRows.value[index].values = [];
              break;
            default:
              filterValueRows.value[index].values = [undefined];
              break;
          }
          break;
        case "string":
        case "text":
        case "search":
          switch (operator) {
            case "s":
            case "!*":
            case "*":
              filterValueRows.value[index].values = [];
              break;
            default:
              filterValueRows.value[index].values = [""];
              break;
          }
          break;
        case "integer":
        case "float":
        case "tree":
          switch (operator) {
            case "s":
            case "!*":
            case "*":
              filterValueRows.value[index].values = [];
              break;
            default:
              filterValueRows.value[index].values = [undefined];
              break;
          }
          break;
        case "relation":
          filterValueRows.value[index].values = [];
          break;
        default:
          filterValueRows.value[index].values = [];
          break;
      }
    };
    const getValueCellConfigurationFor = (
      index: number,
      field?: FilterOption,
      operator?: string,
    ): ValuesCellConfiguration[] => {
      if (!field || !operator) {
        return [];
      }
      const cells: ValuesCellConfiguration[] = [];
      switch (field.type) {
        case "list":
        case "list_with_history":
        case "list_optional":
        case "list_optional_with_history":
        case "list_status":
        case "list_subprojects":
          switch (operator) {
            case "o":
            case "c":
            case "*":
              break;
            default:
              cells.push({
                component: "VAutocomplete",
                bindings: {
                  items: fieldValueOptions.value[field.field] || [],
                  returnObject: false,
                  itemTitle: "label",
                  itemValue: "value",
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 350,
                  multiple: true,
                  chips: true,
                  closableChips: true,
                  loading: fieldValuesLoading.value[field.field],
                },
                onUpdateModelValue: (value: FilterOptionValue[]) => {
                  filterValueRows.value[index].values = value;
                },
                modelValue: filterValueRows.value[index].values,
              });
              break;
          }
          break;
        case "date":
        case "date_past":
          switch (operator) {
            case "><":
              cells.push({
                component: "VTextField",
                bindings: {
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 150,
                  type: "date",
                },
                onUpdateModelValue: (value: any) => {
                  filterValueRows.value[index].values[0] = value;
                },
                modelValue: filterValueRows.value[index].values[0],
              });
              cells.push({
                component: "GlueCell",
                bindings: {
                  text: t("labels.queries.and"),
                },
              });
              cells.push({
                component: "VTextField",
                bindings: {
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 150,
                  type: "date",
                },
                onUpdateModelValue: (value: any) => {
                  filterValueRows.value[index].values[1] = value;
                },
                modelValue: filterValueRows.value[index].values[1],
              });
              break;
            case "nd":
            case "t":
            case "ld":
            case "nw":
            case "w":
            case "lw":
            case "l2w":
            case "nm":
            case "m":
            case "lm":
            case "y":
            case "!*":
            case "*":
              break;
            case ">t-":
            case "<t-":
            case ">t+":
            case "<t+":
              cells.push({
                component: "VTextField",
                bindings: {
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 350,
                  type: "number",
                },
                onUpdateModelValue: (value: any) => {
                  filterValueRows.value[index].values[0] = value;
                },
                modelValue: filterValueRows.value[index].values[0],
                suffix: t("labels.days"),
              });
              break;
            case "><t-":
            case "t-":
            case "><t+":
            case "t+":
              cells.push({
                component: "VTextField",
                bindings: {
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 350,
                  type: "number",
                },
                onUpdateModelValue: (value: any) => {
                  filterValueRows.value[index].values[0] = value;
                },
                modelValue: filterValueRows.value[index].values[0],
                suffix: t("labels.days"),
              });
              break;
            default:
              cells.push({
                component: "VTextField",
                bindings: {
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 350,
                  type: "date",
                },
                onUpdateModelValue: (value: any) => {
                  filterValueRows.value[index].values[0] = value;
                },
                modelValue: filterValueRows.value[index].values[0],
              });
              break;
          }
          break;
        case "string":
        case "text":
        case "search":
          switch (operator) {
            case "s":
            case "!*":
            case "*":
              break;
            default:
              cells.push({
                component: "VTextField",
                bindings: {
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 350,
                  type: "search" === field.type ? "search" : "text",
                },
                onUpdateModelValue: (value: any) => {
                  filterValueRows.value[index].values[0] = value;
                },
                modelValue: filterValueRows.value[index].values[0],
              });
              break;
          }
          break;
        case "integer":
        case "float":
        case "tree":
          switch (operator) {
            case "s":
            case "!*":
            case "*":
              break;
            default:
              cells.push({
                component: "VTextField",
                bindings: {
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 350,
                  type: "number",
                },
                onUpdateModelValue: (value: any) => {
                  filterValueRows.value[index].values[0] = value;
                },
                modelValue: filterValueRows.value[index].values[0],
              });
              break;
          }
          break;
        case "relation":
          switch (operator) {
            case "=":
            case "!":
              cells.push({
                component: "VCombobox",
                bindings: {
                  items: fieldValueOptions.value[field.field] || [],
                  returnObject: false,
                  itemTitle: "label",
                  itemValue: "value",
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 350,
                  multiple: true,
                  chips: true,
                  closableChips: true,
                  loading: fieldValuesLoading.value[field.field],
                  "onUpdate:search": (search: string) => {
                    fetchAutocompleteValuesFor(field, search);
                  },
                },
                onUpdateModelValue: (value: any) => {
                  filterValueRows.value[index].values = value;
                },
                modelValue: filterValueRows.value[index].values,
              });
              break;
            case "=p":
            case "=!p":
            case "!p":
            case "*o":
            case "!o":
              cells.push({
                component: "VAutocomplete",
                bindings: {
                  items: fieldValueOptions.value[field.field] || [],
                  returnObject: false,
                  itemTitle: "label",
                  itemValue: "value",
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 350,
                  multiple: true,
                  chips: true,
                  closableChips: true,
                  loading: fieldValuesLoading.value[field.field],
                  "onUpdate:search": (search: string) => {
                    fetchAutocompleteValuesFor(field, search);
                  },
                },
                onUpdateModelValue: (value: any) => {
                  filterValueRows.value[index].values = value;
                },
                modelValue: filterValueRows.value[index].values,
              });
              break;
          }
          break;
        default:
          break;
      }
      return cells;
    };
    const filterValueRowValueCellConfigurations = computed(() =>
      [...filterValueRows.value].map((r, i) => {
        return getValueCellConfigurationFor(i, r.field, r.operator);
      }),
    );
    const onClearAll = () => {
      filterValueRows.value = [];
    };
    return {
      optionsMenuBindings,
      onSubmit,
      onReset,
      onRefresh,
      onClearAll,
      filterValueRows,
      canShowAddFilter,
      doAddFilter,
      doRemoveFilter,
      fieldValueOptions,
      fieldValuesLoading,
      fetchRemoteValuesFor,
      fetchAutocompleteValuesFor,
      fetchRemoteValuesForPossiblyUndefined,
      fetchAutocompleteValuesForPossiblyUndefined,
      getAvailableFilterOptions,
      fieldTypeOperatorOptions,
      updateFilterValueRowOperatorFor,
      updateFilterValueRowValuesForOperatorFor,
      filterValueRowValueCellConfigurations,
    };
  },
});
</script>

<style lang="scss">
.query-filters-panel {
  .glue-cell {
    width: 50px;
    height: 100%;
    display: flex;
    align-items: center;
    text-align: center;
    justify-content: center;
  }
}
</style>
