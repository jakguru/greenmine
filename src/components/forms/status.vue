<template>
  <v-card v-bind="wrapperBindings">
    <v-table>
      <thead>
        <tr>
          <th>&nbsp;</th>
          <th style="min-width: 200px">
            {{ $t(`pages.issue-statuses.form.cells.name`) }}
          </th>
          <th style="min-width: 70px">
            {{ $t(`pages.issue-statuses.form.cells.isClosed`) }}
          </th>
          <th style="min-width: 200px">
            {{ $t(`pages.issue-statuses.form.cells.description`) }}
          </th>
          <th style="min-width: 175px" class="text-center">
            {{ $t(`pages.issue-statuses.form.cells.defaultDoneRatio`) }}
          </th>
          <th style="min-width: 140px" class="text-center">
            {{ $t(`pages.issue-statuses.form.cells.icon`) }}
          </th>
          <th style="min-width: 220px" class="text-center">
            {{ $t(`pages.issue-statuses.form.cells.textColor`) }}
          </th>
          <th style="min-width: 220px" class="text-center">
            {{ $t(`pages.issue-statuses.form.cells.backgroundColor`) }}
          </th>
          <th style="min-width: 100px" class="text-center">
            {{ $t(`pages.issue-statuses.form.cells.order`) }}
          </th>
          <th style="min-width: 100px">&nbsp;</th>
          <th style="min-width: 40px">&nbsp;</th>
        </tr>
      </thead>
      <draggable
        v-model="existingEnumerations"
        tag="tbody"
        item-key="id"
        :group="{ name: 'issue-statuses', pull: 'clone', put: false }"
        class="draggable-group"
        ghost-class="ghost"
      >
        <template #item="{ element, index }">
          <tr>
            <td>
              <IssueStatusChip
                :id="element.id"
                :name="element.name"
                :is-closed="element.is_closed"
                :position="element.position"
                :description="element.description"
                :default-done-ratio="element.default_done_ratio"
                :icon="element.icon"
                :text-color="element.text_color"
                :background-color="element.background_color"
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
                v-model="element.is_closed"
                @update:model-value="
                  doUpdateFor(element.id, 'is_closed', $event)
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
                v-model="element.default_done_ratio"
                :items="availablePercentages"
                @update:model-value="
                  doUpdateFor(element.id, 'default_done_ratio', $event)
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
                v-model="element.text_color"
                @update:model-value="
                  doUpdateFor(element.id, 'text_color', $event)
                "
              />
            </td>
            <td>
              <VColorField
                v-bind="vOptionalTextFieldBindings"
                v-model="element.background_color"
                @update:model-value="
                  doUpdateFor(element.id, 'background_color', $event)
                "
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
            <IssueStatusChip
              v-if="toAdd.name"
              :name="toAdd.name"
              :is-closed="toAdd.is_closed"
              :position="toAdd.position"
              :description="toAdd.description"
              :default-done-ratio="toAdd.default_done_ratio"
              :icon="toAdd.icon"
              :text-color="toAdd.text_color"
              :background-color="toAdd.background_color"
            />
          </th>
          <th>
            <v-text-field
              v-bind="vTextFieldBindings"
              v-model="toAdd.name"
              :placeholder="$t(`pages.issue-statuses.form.cells.name`)"
            />
          </th>
          <th>
            <v-switch v-model="toAdd.is_closed" />
          </th>
          <th>
            <v-text-field
              v-bind="vTextFieldBindings"
              v-model="toAdd.description"
              :placeholder="$t(`pages.issue-statuses.form.cells.description`)"
            />
          </th>
          <th>
            <v-autocomplete
              v-bind="vOptionalTextFieldBindings"
              v-model="toAdd.default_done_ratio"
              :items="availablePercentages"
              :placeholder="
                $t(`pages.issue-statuses.form.cells.defaultDoneRatio`)
              "
            />
          </th>
          <th>
            <VSaveableIconField
              v-bind="vOptionalTextFieldBindings"
              v-model="toAdd.icon"
              :prepend-inner-icon="toAdd.icon"
              :placeholder="$t(`pages.issue-statuses.form.cells.icon`)"
            >
              <template #item="{ item, props }">
                <v-list-item v-bind="props" :prepend-icon="item.raw.value" />
              </template>
            </VSaveableIconField>
          </th>
          <th>
            <VColorField
              v-bind="vOptionalTextFieldBindings"
              v-model="toAdd.text_color"
              :placeholder="$t(`pages.issue-statuses.form.cells.textColor`)"
            />
          </th>
          <th>
            <VColorField
              v-bind="vOptionalTextFieldBindings"
              v-model="toAdd.background_color"
              :placeholder="
                $t(`pages.issue-statuses.form.cells.backgroundColor`)
              "
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
import { VSaveableTextField, VColorField } from "@/components/fields";
import { IssueStatusChip } from "@/components/issues";
import Draggable from "vuedraggable";
import type { PropType } from "vue";
import type { IssueStatus } from "@/friday";
import type { ApiService, ToastService, SwalService } from "@jakguru/vueprint";

export default defineComponent({
  name: "IssueStatusForm",
  components: {
    Draggable,
    VSaveableTextField,
    VColorField,
    IssueStatusChip,
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
      type: Array as PropType<IssueStatus[]>,
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
      default: "/issue_statuses",
    },
    modelPropertyKey: {
      type: String,
      default: "issue_status",
    },
    variant: {
      type: String as PropType<
        "flat" | "text" | "elevated" | "tonal" | "outlined" | "plain"
      >,
      default: "flat",
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
    const title = computed(() =>
      t(`pages.issue-statuses.form.${name.value}.title`),
    );
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
    const toAdd = ref<IssueStatus>({
      id: 0,
      name: "",
      is_closed: false,
      description: "",
      position: 0,
      default_done_ratio: null,
      icon: null,
      text_color: null,
      background_color: null,
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
            type: name.value,
            name: toAdd.value.name,
            description: toAdd.value.description,
            is_closed: toAdd.value.is_closed,
            default_done_ratio: toAdd.value.default_done_ratio,
            icon: toAdd.value.icon,
            text_color: toAdd.value.text_color,
            background_color: toAdd.value.background_color,
          },
        });
        if (status >= 200 && status < 300) {
          routeDataReloader.call();
          toAdd.value.name = "";
          toAdd.value.is_closed = false;
          toAdd.value.description = "";
          toAdd.value.icon = null;
          toAdd.value.default_done_ratio = null;
          toAdd.value.text_color = null;
          toAdd.value.background_color = null;
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
      updates: Partial<Omit<IssueStatus, "id">>,
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
    const existingEnumerations = ref<IssueStatus[]>(cloneObject(values.value));
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
            e.is_closed !== values.value[i].is_closed ||
            e.description !== values.value[i].description,
        );
        if (diff.length) {
          diff.forEach((e) => {
            doUpdate(e.id, {
              name: e.name,
              is_closed: e.is_closed,
              description: e.description,
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
