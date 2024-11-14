<template>
  <v-card v-bind="wrapperBindings">
    <v-toolbar color="transparent" density="compact">
      <v-toolbar-title>
        {{ title }}
      </v-toolbar-title>
    </v-toolbar>
    <v-divider />
    <v-table>
      <thead>
        <tr>
          <th style="min-width: 200px">
            {{ $t(`pages.enumerations.form.cells.name`) }}
          </th>
          <th v-if="showIsDefault" width="70">
            {{ $t(`pages.enumerations.form.cells.isDefault`) }}
          </th>
          <th width="70">
            {{ $t(`pages.enumerations.form.cells.isActive`) }}
          </th>
          <th width="100" class="text-center">
            {{ $t(`pages.enumerations.form.cells.order`) }}
          </th>
          <th width="100">&nbsp;</th>
          <th width="140">&nbsp;</th>
        </tr>
      </thead>
      <draggable
        v-model="existingEnumerations"
        tag="tbody"
        item-key="id"
        :group="{ name: 'enumerations', pull: 'clone', put: false }"
        class="draggable-group"
        ghost-class="ghost"
      >
        <template #item="{ element, index }">
          <tr>
            <td>
              <VSaveableTextField
                v-bind="vTextFieldBindings"
                v-model="element.name"
                @update:model-value="doUpdateFor(element.id, 'name', $event)"
              />
            </td>
            <td v-if="showIsDefault">
              <v-switch
                v-model="element.is_default"
                @update:model-value="
                  doUpdateFor(element.id, 'is_default', $event)
                "
              />
            </td>
            <td>
              <v-switch
                v-model="element.active"
                @update:model-value="doUpdateFor(element.id, 'active', $event)"
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
                block
                color="error"
                :loading="loading"
                @click="doRemove(element.id)"
              >
                {{ $t("labels.remove") }}
              </v-btn>
            </td>
          </tr>
        </template>
      </draggable>
      <tfoot>
        <tr>
          <th>
            <v-text-field
              v-bind="vTextFieldBindings"
              v-model="toAdd.name"
              :placeholder="$t(`pages.enumerations.form.cells.name`)"
            />
          </th>
          <th v-if="showIsDefault">
            <v-switch v-model="toAdd.is_default" />
          </th>
          <th>
            <v-switch v-model="toAdd.active" />
          </th>
          <th>&nbsp;</th>
          <th>&nbsp;</th>
          <th>
            <v-btn
              block
              :color="systemAccentColor"
              :loading="loading"
              @click="doAdd"
            >
              {{ $t("labels.add") }}
            </v-btn>
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
import { VSaveableTextField } from "@/components/fields";
import Draggable from "vuedraggable";
import type { PropType } from "vue";
import type { EnumerableValue } from "@/friday";
import type { ApiService, ToastService, SwalService } from "@jakguru/vueprint";

export default defineComponent({
  name: "EnumerableForm",
  components: {
    Draggable,
    VSaveableTextField,
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
      type: Array as PropType<EnumerableValue[]>,
      required: true,
    },
    lowColor: {
      type: String,
      default: "#607D8B",
    },
    highColor: {
      type: String,
      default: "#F44336",
    },
    endpoint: {
      type: String,
      default: "/enumerations",
    },
    showIsDefault: {
      type: Boolean,
      default: true,
    },
    modelPropertyKey: {
      type: String,
      default: "enumeration",
    },
    variant: {
      type: String as PropType<
        "flat" | "text" | "elevated" | "tonal" | "outlined" | "plain"
      >,
      default: "outlined",
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
      t(`pages.enumerations.form.${name.value}.title`),
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
    const routeDataReloader = useReloadRouteData(route, api, toast);
    const systemAccentColor = useSystemAccentColor();
    const toAdd = ref<EnumerableValue>({
      id: 0,
      name: "",
      is_default: false,
      active: true,
      position: 0,
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
            active: toAdd.value.active,
            is_default: props.showIsDefault
              ? toAdd.value.is_default
              : undefined,
          },
        });
        if (status >= 200 && status < 300) {
          routeDataReloader.call();
          toAdd.value.name = "";
          toAdd.value.is_default = false;
          toAdd.value.active = true;
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
      updates: Partial<Omit<EnumerableValue, "id">>,
    ) => {
      if (!api) {
        return;
      }
      if (!props.showIsDefault) {
        delete updates.is_default;
      }
      loading.value = true;
      try {
        const { status } = await api.put(`${props.endpoint}/${id}`, {
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
    const existingEnumerations = ref<EnumerableValue[]>(
      cloneObject(values.value),
    );
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
            e.is_default !== values.value[i].is_default ||
            e.active !== values.value[i].active,
        );
        if (diff.length) {
          diff.forEach((e) => {
            doUpdate(e.id, {
              name: e.name,
              is_default: e.is_default,
              active: e.active,
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
    return {
      wrapperBindings,
      title,
      vTextFieldBindings,
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
