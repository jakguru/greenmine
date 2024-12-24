<template>
  <v-card v-bind="wrapperBindings">
    <v-table>
      <thead>
        <tr>
          <th>&nbsp;</th>
          <th style="min-width: 200px">
            {{ $t(`pages.trackers.form.cells.name`) }}
          </th>
          <th style="min-width: 70px">
            {{ $t(`pages.trackers.form.cells.isInRoadmap`) }}
          </th>
          <th style="min-width: 200px">
            {{ $t(`pages.trackers.form.cells.description`) }}
          </th>
          <th style="min-width: 175px" class="text-center">
            {{ $t(`pages.trackers.form.cells.defaultStatusId`) }}
          </th>
          <th style="min-width: 200px" class="text-center">
            {{ $t(`pages.trackers.form.cells.coreFields`) }}
          </th>
          <th style="min-width: 200px" class="text-center">
            {{ $t(`pages.trackers.form.cells.customFields`) }}
          </th>
          <th style="min-width: 200px" class="text-center">
            {{ $t(`pages.trackers.form.cells.projects`) }}
          </th>
          <th style="min-width: 200px" class="text-center">
            {{ $t(`pages.trackers.form.cells.icon`) }}
          </th>
          <th style="min-width: 220px" class="text-center">
            {{ $t(`pages.trackers.form.cells.color`) }}
          </th>
          <th style="min-width: 100px" class="text-center">
            {{ $t(`pages.trackers.form.cells.position`) }}
          </th>
          <th width="100">&nbsp;</th>
          <th width="40">&nbsp;</th>
        </tr>
      </thead>
      <draggable
        v-model="existingEnumerations"
        tag="tbody"
        item-key="id"
        :group="{ name: 'trackers', pull: 'clone', put: false }"
        class="draggable-group"
        ghost-class="ghost"
      >
        <template #item="{ element, index }">
          <tr>
            <td>
              <TrackerChip
                :id="element.id"
                :name="element.name"
                :description="element.description"
                :icon="element.icon"
                :color="element.color"
              />
            </td>
            <td>
              <VSaveableTextField
                v-bind="vTextFieldBindings"
                v-model="element.name"
                @update:model-value="doUpdateFor(element.id, 'name', $event)"
              />
            </td>
            <td>
              <v-switch
                v-model="element.is_in_roadmap"
                @update:model-value="
                  doUpdateFor(element.id, 'is_in_roadmap', $event)
                "
              />
            </td>
            <td>
              <VSaveableTextField
                v-bind="vTextFieldBindings"
                v-model="element.description"
                @update:model-value="
                  doUpdateFor(element.id, 'description', $event)
                "
              />
            </td>
            <td>
              <v-autocomplete
                v-bind="vOptionalTextFieldBindings"
                v-model="element.default_status_id"
                item-title="label"
                item-value="value"
                :items="statuses"
                @update:model-value="
                  doUpdateFor(element.id, 'default_status_id', $event)
                "
              />
            </td>
            <td>
              <VAbbreviatedMultiSelect
                v-bind="vOptionalTextFieldBindings"
                v-model="element.core_fields"
                :items="coreFields"
                @update:model-value="
                  doUpdateFor(element.id, 'core_fields', $event)
                "
              />
            </td>
            <td>
              <VAbbreviatedMultiSelect
                v-bind="vOptionalTextFieldBindings"
                v-model="element.custom_field_ids"
                :items="issueCustomFields"
                @update:model-value="
                  doUpdateFor(element.id, 'custom_field_ids', $event)
                "
              />
            </td>
            <td>
              <VAbbreviatedMultiSelect
                v-bind="vOptionalTextFieldBindings"
                v-model="element.project_ids"
                :items="projects"
                @update:model-value="
                  doUpdateFor(element.id, 'project_ids', $event)
                "
              />
            </td>
            <td>
              <VSaveableIconField
                v-bind="vOptionalTextFieldBindings"
                v-model="element.icon"
                :prepend-inner-icon="element.icon"
                @update:model-value="doUpdateFor(element.id, 'icon', $event)"
              >
                <template #item="{ item, props }">
                  <v-list-item v-bind="props" :prepend-icon="item.raw.value" />
                </template>
              </VSaveableIconField>
            </td>
            <td>
              <VColorField
                v-bind="vOptionalTextFieldBindings"
                v-model="element.color"
                @update:model-value="doUpdateFor(element.id, 'color', $event)"
              />
            </td>
            <td class="text-center">
              <v-chip
                :color="positionColors[index]"
                variant="flat"
                size="small"
                class="font-weight-bold"
              >
                {{ ordinal(element.position) }}
              </v-chip>
            </td>
            <td>
              <div class="d-flex justify-end">
                <v-btn
                  size="x-small"
                  variant="text"
                  icon="mdi-chevron-up"
                  color="info"
                  :disabled="0 === index"
                  @click="onMoveEnumerationUp(index)"
                />
                <v-btn
                  size="x-small"
                  variant="text"
                  icon="mdi-chevron-down"
                  color="info"
                  :disabled="index === existingEnumerations.length - 1"
                  @click="onMoveEnumerationDown(index)"
                />
              </div>
            </td>
            <td>
              <v-btn
                icon="mdi-delete"
                color="error"
                :loading="loading"
                size="small"
                @click="doRemove(element.id)"
              />
            </td>
          </tr>
        </template>
      </draggable>
      <tfoot>
        <tr>
          <th>
            <TrackerChip
              v-if="toAdd.name"
              :name="toAdd.name"
              :position="toAdd.position"
              :description="toAdd.description"
              :icon="toAdd.icon"
              :color="toAdd.color"
            />
          </th>
          <th>
            <v-text-field
              v-bind="vTextFieldBindings"
              v-model="toAdd.name"
              :placeholder="$t(`pages.trackers.form.cells.name`)"
            />
          </th>
          <th>
            <v-switch v-model="toAdd.is_in_roadmap" />
          </th>
          <th>
            <v-text-field
              v-bind="vTextFieldBindings"
              v-model="toAdd.description"
              :placeholder="$t(`pages.trackers.form.cells.description`)"
            />
          </th>
          <th>
            <v-autocomplete
              v-bind="vOptionalTextFieldBindings"
              v-model="toAdd.default_status_id"
              item-title="label"
              item-value="value"
              :items="statuses"
              :placeholder="$t(`pages.trackers.form.cells.defaultStatusId`)"
            />
          </th>
          <th>
            <VAbbreviatedMultiSelect
              v-bind="vOptionalTextFieldBindings"
              v-model="toAdd.core_fields"
              :items="coreFields"
              :placeholder="$t(`pages.trackers.form.cells.coreFields`)"
            />
          </th>
          <th>
            <VAbbreviatedMultiSelect
              v-bind="vOptionalTextFieldBindings"
              v-model="toAdd.custom_field_ids"
              :items="issueCustomFields"
              :placeholder="$t(`pages.trackers.form.cells.customFields`)"
            />
          </th>
          <th>
            <VAbbreviatedMultiSelect
              v-bind="vOptionalTextFieldBindings"
              v-model="toAdd.project_ids"
              :items="projects"
              :placeholder="$t(`pages.trackers.form.cells.projects`)"
            />
          </th>
          <th>
            <VSaveableIconField
              v-bind="vOptionalTextFieldBindings"
              v-model="toAdd.icon"
              :prepend-inner-icon="toAdd.icon"
              :placeholder="$t(`pages.trackers.form.cells.icon`)"
            >
              <template #item="{ item, props }">
                <v-list-item v-bind="props" :prepend-icon="item.raw.value" />
              </template>
            </VSaveableIconField>
          </th>
          <th>
            <VColorField
              v-bind="vOptionalTextFieldBindings"
              v-model="toAdd.color"
              :placeholder="$t(`pages.trackers.form.cells.color`)"
            />
          </th>
          <th>&nbsp;</th>
          <th>&nbsp;</th>
          <th>
            <v-btn
              icon="mdi-plus"
              :color="systemAccentColor"
              :loading="loading"
              size="small"
              @click="doAdd"
            />
          </th>
        </tr>
      </tfoot>
    </v-table>
  </v-card>
</template>

<script lang="ts">
import { defineComponent, computed, ref, inject, watch } from "vue";
import { useI18n } from "vue-i18n";
import { useRoute } from "vue-router";
import {
  useReloadRouteData,
  useSystemAccentColor,
  checkObjectEquality,
  cloneObject,
} from "@/utils/app";
import { ordinal } from "@/utils/formatting";
import { calculateColorForPriority } from "@/utils/colors";
import {
  VSaveableTextField,
  VColorField,
  VAbbreviatedMultiSelect,
} from "@/components/fields";
import { TrackerChip } from "@/components/issues";
import Draggable from "vuedraggable";
import type { PropType } from "vue";
import type { Tracker, SelectableListItem } from "@/friday";
import type { ApiService, ToastService, SwalService } from "@jakguru/vueprint";

export default defineComponent({
  name: "TrackerForm",
  components: {
    Draggable,
    VSaveableTextField,
    VColorField,
    VAbbreviatedMultiSelect,
    TrackerChip,
  },
  props: {
    formAuthenticityToken: {
      type: String,
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
    values: {
      type: Array as PropType<Tracker[]>,
      required: true,
    },
    lowColor: {
      type: String,
      default: "#607D8B",
    },
    highColor: {
      type: String,
      default: "#607D8B",
    },
    endpoint: {
      type: String,
      default: "/trackers",
    },
    modelPropertyKey: {
      type: String,
      default: "tracker",
    },
    variant: {
      type: String as PropType<
        "flat" | "text" | "elevated" | "tonal" | "outlined" | "plain"
      >,
      default: "flat",
    },
    coreFields: {
      type: Array as PropType<SelectableListItem<string>[]>,
      required: true,
    },
    issueCustomFields: {
      type: Array as PropType<SelectableListItem<number>[]>,
      required: true,
    },
    projects: {
      type: Array as PropType<SelectableListItem<number>[]>,
      required: true,
    },
    statuses: {
      type: Array as PropType<SelectableListItem<number>[]>,
      required: true,
    },
  },
  emits: ["loading"],
  setup(props, { emit }) {
    const route = useRoute();
    const name = computed(() => props.name);
    const values = computed(() => props.values);
    const variant = computed(() => props.variant);
    const api = inject<ApiService>("api");
    const toast = inject<ToastService>("toast");
    const swal = inject<SwalService>("swal");
    const { t } = useI18n({ useScope: "global" });
    const title = computed(() => t(`pages.trackers.form.${name.value}.title`));
    const wrapperBindings = computed(() => ({
      class: "enumerable-form",
      variant: variant.value,
    }));
    const vTextFieldBindings = computed(() => ({
      density: "compact" as const,
      readonly: loading.value,
      disabled: loading.value,
    }));
    const vOptionalTextFieldBindings = computed(() => ({
      density: "compact" as const,
      readonly: loading.value,
      disabled: loading.value,
      clearable: !loading.value,
    }));
    const routeDataReloader = useReloadRouteData(route, api, toast);
    const systemAccentColor = useSystemAccentColor();
    const toAdd = ref<Tracker>({
      id: 0,
      name: "",
      default_status_id: 1,
      is_in_roadmap: false,
      description: "",
      core_fields: [],
      custom_field_ids: [],
      position: 0,
      icon: null,
      color: null,
      project_ids: [],
    });
    const loading = ref<boolean>(false);
    watch(
      () => loading.value,
      (newValue) => {
        emit("loading", newValue);
      },
    );
    const doAdd = async () => {
      if (!api) {
        return;
      }
      loading.value = true;
      try {
        const { status } = await api.post(props.endpoint, {
          authenticity_token: props.formAuthenticityToken,
          [props.modelPropertyKey]: {
            name: toAdd.value.name,
            default_status_id: toAdd.value.default_status_id,
            is_in_roadmap: toAdd.value.is_in_roadmap,
            description: toAdd.value.description,
            core_fields: toAdd.value.core_fields,
            custom_field_ids: toAdd.value.custom_field_ids,
            position: toAdd.value.position,
            icon: toAdd.value.icon,
            color: toAdd.value.color,
            project_ids: toAdd.value.project_ids,
          },
        });
        if (status >= 200 && status < 300) {
          routeDataReloader.call();
          toAdd.value.name = "";
          toAdd.value.default_status_id = 1;
          toAdd.value.is_in_roadmap = false;
          toAdd.value.description = "";
          toAdd.value.core_fields = [];
          toAdd.value.custom_field_ids = [];
          toAdd.value.position = 0;
          toAdd.value.icon = null;
          toAdd.value.color = null;
          toAdd.value.project_ids = [];
        }
      } catch {
        // noop
      }
      loading.value = false;
    };
    const doRemove = async (id: number) => {
      if (!api || !swal) {
        return;
      }
      const confirmation = await swal.fire({
        icon: "warning",
        title: t("labels.confirm.title"),
        text: t("labels.confirm.text"),
        showCancelButton: true,
        confirmButtonText: t("labels.confirm.cancel"),
        cancelButtonText: t("labels.confirm.ok"),
      });
      if (confirmation.isConfirmed) {
        return;
      }
      try {
        const { status } = await api.post(
          `${props.endpoint}/${id}`,
          {
            _method: "delete",
            authenticity_token: props.formAuthenticityToken,
          },
          {
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
            },
          },
        );
        if (status >= 200 && status < 400) {
          routeDataReloader.call();
        }
      } catch {
        // noop
      }
      loading.value = true;
      loading.value = false;
    };
    const doUpdate = async (
      id: number,
      updates: Partial<Omit<Tracker, "id">>,
    ) => {
      if (!api) {
        return;
      }
      loading.value = true;
      try {
        const { status } = await api.put(`${props.endpoint}/${id}`, {
          authenticity_token: props.formAuthenticityToken,
          [props.modelPropertyKey]: updates,
        });
        if (status >= 200 && status < 400) {
          routeDataReloader.call();
        }
      } catch {
        // noop
      }
      loading.value = false;
    };
    const existingEnumerations = ref<Tracker[]>(cloneObject(values.value));
    watch(
      () => values.value,
      (newValue) => {
        existingEnumerations.value = cloneObject(newValue);
      },
      { deep: true },
    );
    watch(
      () => existingEnumerations.value,
      (is, was) => {
        if (
          checkObjectEquality(is, was) ||
          checkObjectEquality(is, values.value)
        ) {
          const positionsAreInOrder = is.every((v, i) => v.position === i + 1);
          if (positionsAreInOrder) {
            return;
          }
        }
        // if the difference is sorting, we should find the item which was moved by determining which "position" is out of order
        const movedItem = is.find(
          (e, i) => e.position !== values.value[i].position,
        );
        if (movedItem) {
          const newPosition = is.findIndex((e) => e.id === movedItem.id) + 1;
          doUpdate(movedItem.id, { position: newPosition });
        }
        // look for differences other than sorting
        const diff = is.filter(
          (e, i) =>
            e.name !== values.value[i].name ||
            e.default_status_id !== values.value[i].default_status_id ||
            e.is_in_roadmap !== values.value[i].is_in_roadmap ||
            e.description !== values.value[i].description ||
            e.core_fields !== values.value[i].core_fields ||
            e.custom_field_ids !== values.value[i].custom_field_ids ||
            e.icon !== values.value[i].icon ||
            e.color !== values.value[i].color ||
            e.project_ids !== values.value[i].project_ids,
        );
        if (diff.length) {
          diff.forEach((e) => {
            doUpdate(e.id, {
              name: e.name,
              default_status_id: e.default_status_id,
              is_in_roadmap: e.is_in_roadmap,
              description: e.description,
              core_fields: e.core_fields,
              custom_field_ids: e.custom_field_ids,
              icon: e.icon,
              color: e.color,
              project_ids: e.project_ids,
            });
          });
        }
      },
      { deep: true },
    );
    const onMoveEnumerationUp = (index: number) => {
      if (index > 0) {
        const [item] = existingEnumerations.value.splice(index, 1);
        existingEnumerations.value.splice(index - 1, 0, item);
      }
    };
    const onMoveEnumerationDown = (index: number) => {
      if (index < existingEnumerations.value.length - 1) {
        const [item] = existingEnumerations.value.splice(index, 1);
        existingEnumerations.value.splice(index + 1, 0, item);
      }
    };
    const lowestPosition = computed(() =>
      Math.min(...[...values.value].map((e) => e.position)),
    );
    const highestPosition = computed(() =>
      Math.max(...[...values.value].map((e) => e.position)),
    );
    const lowColor = computed(() => props.lowColor);
    const highColor = computed(() => props.highColor);
    const positionColors = computed(() =>
      [...values.value].map((e) =>
        calculateColorForPriority(
          lowestPosition.value,
          highestPosition.value,
          e.position,
          lowColor.value,
          highColor.value,
        ),
      ),
    );
    const doUpdateFor = async (
      id: number,
      property: string,
      value: string | boolean,
    ) => {
      await doUpdate(id, { [property]: value });
    };
    const availablePercentages = computed(() => {
      const percentages = [];
      for (let i = 0; i <= 100; i += 5) {
        percentages.push(i);
      }
      return percentages.map((p) => ({
        title: `${p}%`,
        value: p,
      }));
    });
    return {
      wrapperBindings,
      title,
      vTextFieldBindings,
      vOptionalTextFieldBindings,
      systemAccentColor,
      ordinal,
      toAdd,
      doAdd,
      doRemove,
      loading,
      existingEnumerations,
      onMoveEnumerationUp,
      onMoveEnumerationDown,
      positionColors,
      doUpdateFor,
      availablePercentages,
    };
  },
});
</script>

<style lang="scss">
.enumerable-form {
  .draggable-group {
    cursor: move;
  }
}
</style>
