<template>
  <v-card min-height="100">
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-items class="ml-auto">
        <v-btn variant="text" :loading="isApplying" @click="clearAll">
          <v-icon>mdi-notification-clear-all</v-icon>
          <span class="ms-2">{{ $t("labels.clearAll") }}</span>
        </v-btn>
        <v-btn
          v-if="permission.save"
          variant="text"
          :loading="isSaving"
          @click="save"
        >
          <v-icon>mdi-content-save</v-icon>
          <span class="ms-2">{{ $t("labels.save") }}</span>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider />
    <v-table class="bg-transparent my-2">
      <tbody>
        <tr v-if="existingFilters.length === 0">
          <td colspan="5" class="text-center">{{ $t("labels.noFilters") }}</td>
        </tr>
        <tr v-for="(filter, i) in existingFilters" :key="`filter-${i}`">
          <td v-if="0 === i">
            <strong>{{ $t("labels.queries.where") }}</strong>
          </td>
          <td v-else>
            <strong>{{ $t("labels.queries.and") }}</strong>
          </td>
          <td>{{ filter.name }}</td>
          <td>
            <v-autocomplete
              v-model="val[filter.key].operator"
              :items="filter.operatorOptions"
              item-title="text"
              item-value="value"
              density="compact"
              outlined
              hide-details
              width="150"
              :return-object="false"
              @update:model-value="loadRemoteValuesForField(filter.key)"
            />
          </td>
          <td>
            <template
              v-for="(cell, fi) in filter.valueCells"
              :key="`filter-${i}-cell-${fi}`"
            >
              <ValuesCellComponent
                :id="`filter-${i}-cell-${fi}`"
                :configuration="cell"
              />
            </template>
          </td>
          <td>
            <v-btn
              icon="mdi-close"
              size="x-small"
              color="error"
              variant="tonal"
              @click="remove(filter.key)"
            />
          </td>
        </tr>
      </tbody>
    </v-table>
    <v-divider />
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-items>
        <v-menu v-model="addNewFilterShowMenu" :close-on-content-click="false">
          <template #activator="{ props }">
            <v-btn v-bind="props" variant="text">
              <v-icon>mdi-plus</v-icon>
              <span class="ms-2">{{ $t("labels.addFilter") }}</span>
            </v-btn>
          </template>
          <v-list density="compact">
            <template
              v-for="(avail, i) in availableOptions"
              :key="`avail-${i}`"
            >
              <v-list-item
                :id="`avail-${i}-list-item`"
                :title="getQueryFieldName(avail.field)"
                @click="
                  addNewFilter({
                    field: avail.field,
                    remote: avail.options.remote,
                    options: avail.options,
                    filter: avail.filter,
                    values: avail.options.values,
                  })
                "
              />
            </template>
          </v-list>
        </v-menu>
      </v-toolbar-items>
      <v-toolbar-items class="ml-auto">
        <v-btn
          variant="flat"
          color="secondary"
          :loading="isApplying"
          @click="apply"
        >
          <v-icon>mdi-check</v-icon>
          <span class="ms-2">{{ $t("labels.apply") }}</span>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
  </v-card>
</template>

<script lang="ts">
import { defineComponent, computed, watch, inject, ref } from "vue";
import { useI18n } from "vue-i18n";
import { useAppData, matchesSchema, appDebug } from "@/utils/app";
import { ValuesCellComponent } from "./values-cell-component";
import Joi from "joi";
import qs from "qs";

import type {
  QueryFilterRaw,
  QueryAvailableFilter,
  QueryPermissions,
  QueryAvailableFilterOptions,
  QueryAvailableFilterOptionsValues,
} from "@/redmine";
import type { PropType } from "vue";
import type { ApiService } from "@jakguru/vueprint";
import type { ValuesCellConfiguration } from "./values-cell-component";

interface AvailableOptionInterface {
  field: string;
  remote: boolean;
  options: QueryAvailableFilterOptions;
  values?: any;
  filter: string;
}

export default defineComponent({
  name: "QueriesPartialFilters",
  components: {
    ValuesCellComponent,
  },
  props: {
    value: {
      type: Object as PropType<QueryFilterRaw>,
      required: true,
    },
    options: {
      type: Object as PropType<Record<string, QueryAvailableFilter>>,
      required: true,
    },
    permission: {
      type: Object as PropType<QueryPermissions["query"]>,
      required: true,
    },
    type: {
      type: String as PropType<string>,
      required: true,
    },
    isApplying: {
      type: Boolean as PropType<boolean>,
      default: false,
    },
    isSaving: {
      type: Boolean as PropType<boolean>,
      default: false,
    },
    isClearing: {
      type: Boolean as PropType<boolean>,
      default: false,
    },
  },
  emits: ["update:value", "submit", "save"],
  setup(props, { emit }) {
    const { t } = useI18n({ useScope: "global" });
    const appData = useAppData();
    const api = inject<ApiService>("api");
    const type = computed(() => props.type);
    const permission = computed(() => props.permission);
    const val = computed({
      get: () => props.value,
      set: (value: QueryFilterRaw) => emit("update:value", value),
    });
    const existingFilterKeys = computed(() => Object.keys(val.value));
    const options = computed(() => props.options);
    const availableOptions = computed(() =>
      Object.keys(options.value)
        .filter((key) => !existingFilterKeys.value.includes(key))
        .map((key) => ({ filter: key, ...options.value[key] })),
    );
    const clearAll = () => {
      val.value = {};
      emit("submit");
    };
    const apply = () => {
      emit("submit");
    };
    const save = () => {
      if (!permission.value.save) {
        return;
      }
      emit("save");
    };
    const remove = (key: string) => {
      delete val.value[key];
    };
    const getQueryFieldName = (key: string) => {
      if (
        options.value[key] &&
        options.value[key].options &&
        options.value[key].options.name
      ) {
        return options.value[key].options.name;
      }
      return t(`columns.${type.value.toLowerCase()}.${key}`);
    };
    const getQueryFieldOperationChoices = (key: string) => {
      if (
        !options.value[key] ||
        !options.value[key].options ||
        !options.value[key].options.type
      ) {
        return [];
      }
      const fieldType = options.value[key].options.type;
      const verifiedAppData = matchesSchema<any>(
        appData.value,
        Joi.object({
          queries: Joi.object({
            [type.value]: Joi.object({
              operators: Joi.object({
                [fieldType]: Joi.array().items(Joi.string()).required(),
              })
                .required()
                .unknown(),
            }).unknown(),
          }).unknown(),
        }).unknown(),
        true,
      );
      if (!verifiedAppData) {
        return [];
      }
      const ret = verifiedAppData.queries[type.value].operators[fieldType].map(
        (op: string) => ({
          value: op,
          text: t(`labels.queries.operators.${op}`),
        }),
      );
      return ret;
    };
    const getQueryFieldIsRemotable = (key: string) => {
      if (
        options.value[key] &&
        options.value[key].options.remote &&
        !options.value[key].options.values
      ) {
        return true;
      }
      return false;
    };
    const remoteLoadedValues = ref<Record<string, any>>({});
    const loadingRemoteValuesForField = ref<Record<string, boolean>>({});
    const loadingRemoveValuesForFieldAbortControllers: Record<
      string,
      AbortController
    > = {};
    const autocompleteValuesForField = ref<Record<string, Array<any>>>({});
    const isLoadingRemoteValuesForField = computed(
      () => loadingRemoteValuesForField.value,
    );
    const remoteValuesForFieldLastUpdatedAt = ref<Record<string, number>>({});
    const loadRemoteValuesForField = async (field: string, e?: Event) => {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();
      }
      if (!api) {
        return;
      }
      if (true === loadingRemoteValuesForField.value[field]) {
        return;
      }
      loadingRemoteValuesForField.value[field] = true;
      const { status, data } = await api.get<Array<[string, string]>>(
        `/queries/filter?type=${type.value}&name=${field}`,
      );
      loadingRemoteValuesForField.value[field] = false;
      if (status === 200) {
        remoteLoadedValues.value[field] = data.map(([text, value]) => ({
          text,
          value,
        }));
        remoteValuesForFieldLastUpdatedAt.value[field] = Date.now();
      }
    };
    const getIssueAutoCompleteValues = async (
      field: string,
      search: string,
    ) => {
      if (!api) {
        return;
      }
      if (loadingRemoveValuesForFieldAbortControllers[field]) {
        loadingRemoveValuesForFieldAbortControllers[field].abort();
      }
      loadingRemoveValuesForFieldAbortControllers[field] =
        new AbortController();
      loadingRemoteValuesForField.value[field] = true;
      try {
        const { status, data } = await api.get<
          Array<{ id: number; value: number; label: string }>
        >(`/issues/auto_complete?${qs.stringify({ term: search })}`, {
          signal: loadingRemoveValuesForFieldAbortControllers[field].signal,
        });
        if (status === 200) {
          autocompleteValuesForField.value[field] = data.map((d) => ({
            text: d.label,
            value: d.id,
          }));
        }
      } catch {
        // noop
      }
      loadingRemoteValuesForField.value[field] = false;
    };
    watch(
      () => val.value,
      (latest, previous) => {
        Object.keys(latest).forEach((key) => {
          if (getQueryFieldIsRemotable(key)) {
            if (
              typeof previous !== "undefined" &&
              JSON.stringify(Object.keys(latest)) ===
                JSON.stringify(Object.keys(previous)) &&
              "undefined" !== typeof remoteLoadedValues.value[key]
            ) {
              appDebug("skipping remote load for", key);
              return;
            }
            appDebug("loading remote values for", key);
            loadRemoteValuesForField(key);
          }
        });
      },
      { deep: true, immediate: true },
    );
    const getValuesCellConfigurations = (
      key: string,
      operator: string,
      values: string,
      _lastUpdatedAt: number,
    ) => {
      const opts = options.value[key];
      const type = opts.options.type;
      const cells: ValuesCellConfiguration[] = [];
      switch (type) {
        case "list":
        case "list_with_history":
        case "list_optional":
        case "list_optional_with_history":
        case "list_status":
        case "list_subprojects":
          switch (operator) {
            case "o":
            case "c":
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
              val.value[key].values = [];
              break;
            default:
              cells.push({
                component: "VAutocomplete",
                bindings: {
                  items: values,
                  returnObject: false,
                  itemTitle: "text",
                  itemValue: "value",
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 350,
                  multiple: true,
                  chips: true,
                  closableChips: true,
                  loading: isLoadingRemoteValuesForField.value[key] || false,
                },
                onUpdateModelValue: (value: any) => {
                  val.value[key].values = value;
                },
                modelValue: val.value[key].values,
              });
              break;
          }
          break;
        case "date":
        case "date_past":
          switch (operator) {
            case '"><"':
              // 2 cells needed
              if (val.value[key].values.length !== 2) {
                val.value[key].values = [undefined, undefined];
              }
              cells.push({
                component: "DateFieldWithPicker",
                bindings: {
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 150,
                },
                onUpdateModelValue: (value: any) => {
                  val.value[key].values[0] = value;
                },
                modelValue: val.value[key].values[0],
              });
              cells.push({
                component: "GlueCell",
                bindings: {
                  text: t("labels.queries.and"),
                },
              });
              cells.push({
                component: "DateFieldWithPicker",
                bindings: {
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 150,
                },
                onUpdateModelValue: (value: any) => {
                  val.value[key].values[1] = value;
                },
                modelValue: val.value[key].values[1],
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
              val.value[key].values = [];
              break;
            default:
              if (val.value[key].values.length !== 1) {
                val.value[key].values = [undefined];
              }
              cells.push({
                component: "DateFieldWithPicker",
                bindings: {
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 150,
                },
                onUpdateModelValue: (value: any) => {
                  val.value[key].values[0] = value;
                },
                modelValue: val.value[key].values[0],
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
              val.value[key].values = [];
              break;
            default:
              if (val.value[key].values.length !== 1) {
                val.value[key].values = [""];
              }
              cells.push({
                component: "VTextField",
                bindings: {
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 350,
                  type: "search" === type ? "search" : "text",
                },
                onUpdateModelValue: (value: any) => {
                  val.value[key].values[0] = value;
                },
                modelValue: val.value[key].values[0],
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
              val.value[key].values = [];
              break;
            case '"><"':
              // 2 cells needed
              if (val.value[key].values.length !== 2) {
                val.value[key].values = ["", ""];
              }
              cells.push({
                component: "VTextField",
                bindings: {
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 150,
                  type: "number",
                },
                onUpdateModelValue: (value: any) => {
                  val.value[key].values[0] = value;
                },
                modelValue: val.value[key].values[0],
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
                  type: "number",
                },
                onUpdateModelValue: (value: any) => {
                  val.value[key].values[1] = value;
                },
                modelValue: val.value[key].values[1],
              });
              break;
            default:
              if (val.value[key].values.length !== 1) {
                val.value[key].values = [""];
              }
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
                  val.value[key].values[0] = value;
                },
                modelValue: val.value[key].values[0],
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
                  items: autocompleteValuesForField.value[key] || [],
                  returnObject: false,
                  itemTitle: "text",
                  itemValue: "value",
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 350,
                  multiple: true,
                  chips: true,
                  closableChips: true,
                  loading: isLoadingRemoteValuesForField.value[key] || false,
                  "onUpdate:search": (search: string) => {
                    appDebug("searching for", search);
                    getIssueAutoCompleteValues(key, search);
                  },
                },
                onUpdateModelValue: (value: any) => {
                  val.value[key].values = value;
                },
                modelValue: val.value[key].values,
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
                  items: values,
                  returnObject: false,
                  itemTitle: "text",
                  itemValue: "value",
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 350,
                  multiple: true,
                  chips: true,
                  closableChips: true,
                  loading: isLoadingRemoteValuesForField.value[key] || false,
                },
                onUpdateModelValue: (value: any) => {
                  val.value[key].values = value;
                },
                modelValue: val.value[key].values,
              });
              break;
            case "!*":
            case "*":
              val.value[key].values = [];
              break;
          }
          break;
      }
      return cells;
    };
    const getOptionsFromLocalValues = (
      values?: QueryAvailableFilterOptionsValues,
    ) => {
      if (Array.isArray(values)) {
        return values.map(([text, value]) => ({ text, value }));
      } else if ("object" === typeof values && null !== values) {
        if ("name" in values && "value" in values) {
          return [
            {
              text: values.name,
              value: values.value,
            },
          ];
        }
      }
      return [];
    };
    const existingFilters = computed(() =>
      [...existingFilterKeys.value].map((key) => {
        const values = getQueryFieldIsRemotable(key)
          ? remoteLoadedValues.value[key]
          : getOptionsFromLocalValues(options.value[key].options.values);
        return {
          key,
          name: getQueryFieldName(key),
          operatorOptions: getQueryFieldOperationChoices(key),
          type: options.value[key].options.type,
          valueCells: getValuesCellConfigurations(
            key,
            val.value[key].operator,
            values,
            remoteValuesForFieldLastUpdatedAt.value[key],
          ),
          values,
          lastUpdatedAt: remoteValuesForFieldLastUpdatedAt.value[key],
        };
      }),
    );
    const addNewFilterShowMenu = ref(false);
    const addNewFilter = (filter: AvailableOptionInterface) => {
      addNewFilterShowMenu.value = false;
      if (getQueryFieldIsRemotable(filter.filter)) {
        loadRemoteValuesForField(filter.filter);
      }
      val.value[filter.filter] = {
        operator: getQueryFieldOperationChoices(filter.filter)[0].value,
        values: [],
      };
    };
    return {
      val,
      availableOptions,
      clearAll,
      apply,
      save,
      remove,
      existingFilterKeys,
      getQueryFieldName,
      getQueryFieldOperationChoices,
      getQueryFieldIsRemotable,
      loadRemoteValuesForField,
      existingFilters,
      remoteLoadedValues,
      isLoadingRemoteValuesForField,
      addNewFilterShowMenu,
      addNewFilter,
    };
  },
});
</script>
