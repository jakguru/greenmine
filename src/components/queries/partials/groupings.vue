<template>
  <v-card min-height="100" class="query-filters-panel">
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-items class="ml-auto">
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
    <v-list-item v-if="displayOptionItems.length > 0">
      <v-list-item-title>{{ $t("labels.groupBy") }}:</v-list-item-title>
      <v-radio-group v-model="val" hide-details>
        <v-radio :label="$t('labels.none')" value="" />
        <v-radio
          v-for="item in displayOptionItems"
          :key="item.value"
          :label="item.text"
          :value="item.value"
        />
      </v-radio-group>
    </v-list-item>
    <v-divider />
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-items></v-toolbar-items>
      <v-toolbar-items class="ml-auto">
        <v-btn
          variant="text"
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
import { defineComponent, computed } from "vue";
import { useI18n } from "vue-i18n";

import type {
  QueryColumn,
  QueryAvailableFilter,
  QueryPermissions,
} from "@/redmine";
import type { PropType } from "vue";

export default defineComponent({
  name: "QueriesPartialGroupings",
  props: {
    value: {
      type: String,
      required: true,
    },
    options: {
      type: Array as PropType<Array<QueryColumn>>,
      required: true,
    },
    columns: {
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
    const val = computed({
      get: () => props.value,
      set: (value: Array<string>) => emit("update:value", value),
    });
    const permission = computed(() => props.permission);
    const apply = () => {
      emit("submit");
    };
    const save = () => {
      if (!permission.value.save) {
        return;
      }
      emit("save");
    };
    const options = computed(() => props.options);
    const columns = computed(() => props.columns);
    const type = computed(() => props.type);
    const getQueryFieldName = (key: string) => {
      if (
        columns.value[key] &&
        columns.value[key].options &&
        columns.value[key].options.name
      ) {
        return columns.value[key].options.name;
      }
      return t(`columns.${type.value.toLowerCase()}.${key}`);
    };
    const displayOptionItems = computed(() =>
      [...options.value].map((o) => ({
        text: getQueryFieldName(o.name),
        value: o.name,
      })),
    );
    return {
      val,
      apply,
      save,
      displayOptionItems,
    };
  },
});
</script>
