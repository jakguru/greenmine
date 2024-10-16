<template>
  <v-card min-height="100">
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-items class="ml-auto">
        <v-btn variant="text" @click="clearAll">
          <v-icon>mdi-notification-clear-all</v-icon>
          <span class="ms-2">{{ $t("labels.clearAll") }}</span>
        </v-btn>
        <v-btn v-if="permission.save" variant="text" @click="save">
          <v-icon>mdi-content-save</v-icon>
          <span class="ms-2">{{ $t("labels.save") }}</span>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider />
    <v-table class="bg-transparent">
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
              width="100"
            />
          </td>
          <td>
            <pre v-text="JSON.stringify(filter.valueCells, null, 2)" />
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
                @click="addNewFilter(avail)"
              />
            </template>
          </v-list>
        </v-menu>
      </v-toolbar-items>
    </v-toolbar>
  </v-card>
</template>

<script lang="ts">
import { defineComponent, computed, watch, inject, ref } from "vue";
import { useI18n } from "vue-i18n";
import { useAppData, matchesSchema } from "@/utils/app";
import Joi from "joi";

import type {
  QueryFilterRaw,
  QueryAvailableFilter,
  QueryPermissions,
  QueryAvailableFilterOptions,
} from "@/redmine";
import type { PropType } from "vue";
import type { ApiService } from "@jakguru/vueprint";

interface AvailableOptionInterface {
  field: string;
  remote: boolean;
  options: QueryAvailableFilterOptions;
  values?: any;
  filter: string;
}

interface ValuesCellConfiguration {
  component: string;
  bindings: Record<string, any>;
}

export default defineComponent({
  name: "QueriesPartialFilters",
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
    const save = () => {
      if (!permission.value.save) {
        return;
      }
      emit("save");
    };
    const remove = (key: string) => {
      const newVal = { ...val.value };
      delete newVal[key];
      val.value = newVal;
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
        options.value[key].remote &&
        !options.value[key].values
      ) {
        return true;
      }
      return false;
    };
    const remoteLoadedValues = ref<Record<string, any>>({});
    const loadingRemoteValuesForField = ref<Record<string, boolean>>({});
    const isLoadingRemoteValuesForField = computed(
      () => loadingRemoteValuesForField.value,
    );
    const loadRemoteValuesForField = async (field: string, e?: Event) => {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();
      }
      if (!api) {
        return;
      }
      if (loadingRemoteValuesForField.value[field]) {
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
      }
    };
    watch(
      () => val.value,
      (latest) => {
        Object.keys(latest).forEach((key) => {
          if (getQueryFieldIsRemotable(key)) {
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
          cells.push({
            component: "VAutoComplete",
            bindings: {
              modelValue: val.value[key].values,
              items: values,
              itemText: "text",
              itemValue: "value",
              density: "compact",
              outlined: true,
              hideDetails: true,
              width: 350,
              multiple: true,
              chips: true,
              deletableChips: true,
              loading: isLoadingRemoteValuesForField.value[key] || false,
            },
          });
          break;
        case "date":
        case "date_past":
          switch (operator) {
            case '"><"':
              // 2 cells needed
              val.value[key].values = [undefined, undefined];
              cells.push({
                component: "DateFieldWithPicker",
                bindings: {
                  modelValue: val.value[key].values[0],
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 150,
                },
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
                  modelValue: val.value[key].values[1],
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 150,
                },
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
              val.value[key].values = [undefined];
              cells.push({
                component: "DateFieldWithPicker",
                bindings: {
                  modelValue: val.value[key].values[0],
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 150,
                },
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
              val.value[key].values = [""];
              cells.push({
                component: "VTextField",
                bindings: {
                  modelValue: val.value[key].values[0],
                  density: "compact",
                  outlined: true,
                  hideDetails: true,
                  width: 350,
                  type: "search" === type ? "search" : "text",
                },
              });
              break;
          }
          break;
      }
      return cells;
    };
    const existingFilters = computed(() =>
      [...existingFilterKeys.value].map((key) => ({
        key,
        name: getQueryFieldName(key),
        operatorOptions: getQueryFieldOperationChoices(key),
        type: options.value[key].options.type,
        valueCells: getValuesCellConfigurations(
          key,
          val.value[key].operator,
          getQueryFieldIsRemotable(key)
            ? remoteLoadedValues.value[key]
            : options.value[key].values || [],
        ),
      })),
    );
    const addNewFilterShowMenu = ref(false);
    const addNewFilter = (filter: AvailableOptionInterface) => {
      addNewFilterShowMenu.value = false;
      if (getQueryFieldIsRemotable(filter.filter)) {
        loadRemoteValuesForField(filter.filter);
      }
      val.value = {
        ...val.value,
        [filter.filter]: {
          operator: getQueryFieldOperationChoices(filter.filter)[0].value,
          values: [],
        },
      };
    };
    return {
      val,
      availableOptions,
      clearAll,
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
