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
            <v-autocomplete
              v-model="val[filter.key].values"
              :items="filter.valueOptions"
              item-title="text"
              item-value="value"
              density="compact"
              outlined
              hide-details
              width="250"
              multiple
              chips
              deletable-chips
            >
              <template
                v-if="getQueryFieldIsRemotable(filter.key)"
                #append-inner
              >
                <v-btn
                  size="x-small"
                  color="info"
                  @click="loadRemoteValuesForField.bind(null, filter.key)"
                >
                  <v-icon>mdi-refresh</v-icon>
                </v-btn>
              </template>
            </v-autocomplete>
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
} from "@/redmine";
import type { PropType } from "vue";
import type { ApiService } from "@jakguru/vueprint";

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
    const loadRemoteValuesForField = async (field: string, e?: Event) => {
      if (e) {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();
      }
      if (!api) {
        return;
      }
      const { status, data } = await api.get<Array<[string, string]>>(
        `/queries/filter?type=${type.value}&name=${field}`,
      );
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
    const existingFilters = computed(() =>
      [...existingFilterKeys.value].map((key) => ({
        key,
        name: getQueryFieldName(key),
        operatorOptions: getQueryFieldOperationChoices(key),
        valueOptions: remoteLoadedValues.value[key] || [],
      })),
    );
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
    };
  },
});
</script>
