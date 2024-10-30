<template>
  <v-container fluid :class="!isFriday ? 'fill-height' : ''">
    <div
      v-if="!isFriday"
      class="w-100 h-100 d-flex justify-center align-center"
    >
      <v-empty-state
        :headline="$t('pages.settings-plugin-id.content.incompatible.headline')"
        :title="$t('pages.settings-plugin-id.content.incompatible.title')"
        :text="$t('pages.settings-plugin-id.content.incompatible.text')"
        :image="fourOhSixImage"
      ></v-empty-state>
    </div>
    <v-card v-else min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          <v-icon size="20" class="me-3" style="position: relative; top: -2px"
            >mdi-puzzle</v-icon
          >
          {{
            $t("pages.settings-plugin-id.specificTitle", {
              plugin: plugin.name,
            })
          }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-breadcrumbs v-bind="breadcrumbsBindings" />
      <v-divider />
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
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, onMounted, inject } from "vue";
import fourOhSixImage from "@/assets/images/406.svg?url";
import { useHead } from "@unhead/vue";
import { useI18n } from "vue-i18n";
import { VTextField } from "vuetify/components/VTextField";
import { useRoute } from "vue-router";
import { useSystemAccentColor } from "@/utils/app";

import { Joi, getFormFieldValidator, FridayForm } from "@/components/forms";

import type { PropType } from "vue";
import type { PluginData } from "@/redmine";
import type { FridayFormStructure } from "@/components/forms";
import type { SwalService, ToastService } from "@jakguru/vueprint";

export default defineComponent({
  name: "SettingsPluginId",
  components: { FridayForm },
  props: {
    plugin: {
      type: Object as PropType<PluginData>,
      required: true,
    },
    settings: {
      type: Object as PropType<Record<string, unknown>>,
      required: true,
    },
  },
  setup(props) {
    const toast = inject<ToastService>("toast");
    const swal = inject<SwalService>("swal");
    const route = useRoute();
    const accentColor = useSystemAccentColor();
    const plugin = computed(() => props.plugin);
    const settings = computed(() => props.settings);
    const isFriday = computed(() => plugin.value.id === "friday");
    const { t } = useI18n({ useScope: "global" });
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.admin.title"), to: { name: "admin" } },
        {
          title: t("pages.admin-plugins.title"),
          to: { name: "admin-plugins" },
        },
        {
          title: t("pages.settings-plugin-id.specificTitle", {
            plugin: plugin.value.name,
          }),
        },
      ],
    }));
    onMounted(() => {
      useHead({
        title: t("pages.settings-plugin-id.specificTitle", {
          plugin: plugin.value.name,
        }),
      });
    });
    const formStructure = computed<FridayFormStructure>(() => [
      [
        {
          cols: 12,
          fieldComponent: VTextField,
          formKey: "repository_base_path",
          valueKey: "repository_base_path",
          label: t("pages.settings-plugin-id.fields.repository_base_path"),
          validator: getFormFieldValidator(
            t,
            Joi.string().required(),
            t("pages.settings-plugin-id.fields.repository_base_path"),
          ),
          bindings: {
            label: t("pages.settings-plugin-id.fields.repository_base_path"),
          },
        },
      ],
    ]);
    const modifyPayload = (payload: Record<string, unknown>) => {
      return { settings: payload };
    };
    const fridayFormBindings = computed(() => ({
      action: route.fullPath,
      method: "post",
      structure: formStructure.value,
      values: settings.value,
      modifyPayload,
    }));
    const onSuccess = () => {
      if (!toast) {
        alert(t("pages.settings-plugin-id.onSave.success"));
        return;
      } else {
        toast.fire({
          title: t("pages.settings-plugin-id.onSave.success"),
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
        alert(t("pages.settings-plugin-id.onSave.error"));
        return;
      } else {
        swal.fire({
          title: t("pages.settings-plugin-id.onSave.error"),
          icon: "error",
        });
        return;
      }
    };
    return {
      breadcrumbsBindings,
      isFriday,
      fourOhSixImage,
      fridayFormBindings,
      accentColor,
      onSuccess,
      onError,
    };
  },
});
</script>
