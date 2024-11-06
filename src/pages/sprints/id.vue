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
import { defineComponent, computed, inject, onMounted } from "vue";
import { useHead } from "@unhead/vue";
import { useI18n } from "vue-i18n";
import { VTextField } from "vuetify/components/VTextField";
import { useRouter } from "vue-router";
import { useSystemAccentColor } from "@/utils/app";
import { Joi, getFormFieldValidator, FridayForm } from "@/components/forms";

import type { PropType } from "vue";
import type { FridayFormStructure } from "@/components/forms";
import type { SwalService, ToastService } from "@jakguru/vueprint";
import type {
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
} from "@/friday";

export default defineComponent({
  name: "SprintsID",
  components: { FridayForm },
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
  },
  setup(props) {
    const toast = inject<ToastService>("toast");
    const swal = inject<SwalService>("swal");
    const router = useRouter();
    const accentColor = useSystemAccentColor();
    const formAuthenticityToken = computed(() => props.formAuthenticityToken);
    const sprint = computed(() => props.sprint);
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
    const modifyPayload = (payload: Record<string, unknown>) => {
      return {
        authenticity_token: formAuthenticityToken.value,
        sprint: payload,
      };
    };
    const onSuccess = (_status: number, data: any) => {
      router.push({ name: "sprints-id", params: { id: data.id } });
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
    const formStructure = computed<FridayFormStructure>(() => {
      return [
        [
          {
            cols: 12,
            md: 4,
            fieldComponent: VTextField,
            formKey: "name",
            valueKey: "name",
            label: t("pages.sprints-id.fields.name"),
            validator: getFormFieldValidator(
              t,
              Joi.string().required(),
              t("pages.sprints-id.fields.name"),
            ),
            bindings: {
              type: "text",
              label: t("pages.sprints-id.fields.name"),
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
            label: t("pages.sprints-id.fields.start_date"),
            validator: getFormFieldValidator(
              t,
              Joi.date().required(),
              t("pages.sprints-id.fields.name"),
            ),
            bindings: {
              type: "date",
              label: t("pages.sprints-id.fields.start_date"),
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
            label: t("pages.sprints-id.fields.end_date"),
            validator: getFormFieldValidator(
              t,
              Joi.date().required(),
              t("pages.sprints-id.fields.name"),
            ),
            bindings: {
              type: "date",
              label: t("pages.sprints-id.fields.end_date"),
            },
          },
        ],
      ];
    });
    const fridayFormBindings = computed(() => ({
      action: router.resolve({ name: "sprints" }).href,
      method: "post",
      structure: formStructure.value,
      values: {
        name: "",
        start_date: null,
        end_date: null,
      },
      modifyPayload,
      validHttpStatus: 201,
    }));
    onMounted(() => {
      useHead({
        title: t("pages.sprints-id.specificTitle", {
          id: sprint.value.id ? sprint.value.id : 0,
          name: sprint.value.name,
        }),
      });
    });
    return {
      breadcrumbsBindings,
      fridayFormBindings,
      accentColor,
      onSuccess,
      onError,
    };
  },
});
</script>
