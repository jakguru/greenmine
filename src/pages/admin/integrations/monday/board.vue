<template>
  <v-container fluid>
    <v-card min-height="100" color="surface" class="position-relative">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{
            !id
              ? $t("pages.admin-integrations-monday-id-board.title")
              : $t("pages.admin-integrations-monday-id-board.title")
          }}
        </v-toolbar-title>
      </v-toolbar>
      <v-divider />
      <v-breadcrumbs v-bind="breadcrumbsBindings" />
      <v-divider />
      <v-toolbar color="transparent">
        <v-slide-group show-arrows class="mx-2">
          <v-slide-group-item>
            <v-btn
              variant="elevated"
              :color="accentColor"
              size="x-small"
              class="ma-2"
              type="button"
              height="24px"
              style="position: relative; top: 1px"
              :href="model.board_meta_data.url"
              target="_blank"
            >
              <v-img
                :src="iconGitlab"
                :aspect-ratio="1"
                width="13"
                height="13"
                class="me-2"
              />
              {{
                $t(
                  "pages.admin-integrations-monday-id-board.content.openInMonday",
                )
              }}
            </v-btn>
          </v-slide-group-item>
          <v-slide-group-item>
            <v-btn
              variant="elevated"
              color="light-blue-lighten-3"
              size="x-small"
              class="ma-2"
              type="button"
              height="24px"
              style="position: relative; top: 1px"
              :loading="enqueueingJobToInstallWebhooks"
              @click="doEnqueueJobToInstallWebhooks"
            >
              <v-img
                :src="iconWebhooks"
                :aspect-ratio="1"
                width="13"
                height="13"
                class="me-2"
              />
              {{
                $t(
                  "pages.admin-integrations-monday-id-board.content.enqueueJobToInstallWebhooks",
                )
              }}
            </v-btn>
          </v-slide-group-item>
          <v-slide-group-item>
            <v-btn
              variant="elevated"
              color="light-blue-lighten-3"
              size="x-small"
              class="ma-2"
              type="button"
              height="24px"
              style="position: relative; top: 1px"
              :loading="enqueueingJobToRefreshBoardMeta"
              @click="doEnqueueJobToRefreshBoardMeta"
            >
              <v-icon class="me-2" size="12">mdi-sync</v-icon>
              {{
                $t(
                  "pages.admin-integrations-monday-id-board.content.enqueueJobToRefreshBoardMeta",
                )
              }}
            </v-btn>
          </v-slide-group-item>
        </v-slide-group>
      </v-toolbar>
      <v-divider />
      <FridayForm
        v-bind="fridayFormBindings"
        ref="renderedForm"
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
import {
  defineComponent,
  computed,
  inject,
  ref,
  // watch,
  onMounted,
  onBeforeUnmount,
} from "vue";
import { useI18n } from "vue-i18n";
import { useRoute } from "vue-router";
import {
  useSystemAccentColor,
  useReloadRouteData,
  checkObjectEquality,
  useCopyToClipboard,
  useOnError,
} from "@/utils/app";
import { useActionCableConsumer } from "@/utils/realtime";
import iconGitlab from "@/assets/images/icon-monday.svg?url";
import iconWebhooks from "@/assets/images/icon-webhooks.svg?url";
import { FridayForm } from "@/components/forms";

import type { PropType } from "vue";
import type { ToastService, ApiService, BusService } from "@jakguru/vueprint";
import type {
  MondayBoard,
  MondayBoardValuesProp,
  QueryResponse,
} from "@/friday";
import type Cable from "@rails/actioncable";
import type {
  FridayFormStructure,
  FridayFormComponent,
} from "@/components/forms";
import { VAutocomplete } from "vuetify/components";

export default defineComponent({
  name: "AdminIntegrationsMondayBoard",
  components: {
    FridayForm,
  },
  props: {
    formAuthenticityToken: {
      type: String,
      required: true,
    },
    id: {
      type: [String, Number] as PropType<string | number | null | undefined>,
      default: null,
    },
    parentName: {
      type: String,
      required: true,
    },
    parentId: {
      type: [String, Number] as PropType<string | number | null | undefined>,
      required: true,
    },
    model: {
      type: Object as PropType<MondayBoard>,
      required: true,
    },
    boards: {
      type: Object as PropType<QueryResponse>,
      required: true,
    },
    values: {
      type: Object as PropType<MondayBoardValuesProp>,
      required: true,
    },
  },
  setup(props) {
    const { t } = useI18n({ useScope: "global" });
    const toast = inject<ToastService>("toast");
    const api = inject<ApiService>("api");
    const bus = inject<BusService>("bus");
    const route = useRoute();
    const reloadRouteDataAction = useReloadRouteData(route, api, toast);
    const accentColor = useSystemAccentColor();
    const copyToClipboard = useCopyToClipboard(
      t("messages.copiedToClipboard"),
      t("messages.failedToCopyToClipboard"),
    );
    const formAuthenticityToken = computed(() => props.formAuthenticityToken);
    const parentName = computed(() => props.parentName);
    const id = computed(() => props.id);
    const parentId = computed(() => props.parentId);
    const model = computed(() => props.model);
    const values = computed(() => props.values);
    const projectValues = computed(() => values.value.projects);
    const fieldValues = computed(() => values.value.fields);
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.admin.title"), to: { name: "admin" } },
        {
          title: t("pages.admin-integrations.title"),
          to: { name: "admin-integrations" },
        },
        {
          title: t("pages.admin-integrations-monday.title"),
          to: { name: "admin-integrations-monday" },
        },
        {
          title: parentName.value,
          to: {
            name: "admin-integrations-monday-id",
            params: { id: parentId.value },
            query: { tab: "boards" },
          },
        },
        {
          title: model.value.board_meta_data.name,
        },
      ],
    }));
    const enqueueingJobToInstallWebhooks = ref(false);
    const doEnqueueJobToInstallWebhooks = async () => {
      if (!api || !toast) {
        return;
      }
      enqueueingJobToInstallWebhooks.value = true;
      const { status } = await api.post(
        `/admin/integrations/monday/${parentId.value}/boards/${model.value.monday_board_id}/actions/install-webhooks`,
        {
          authenticity_token: formAuthenticityToken.value,
        },
      );
      if (202 === status) {
        toast.fire({
          icon: "success",
          title: t(
            "pages.admin-integrations-monday-id-board.onEnqueueJobToInstallWebhooks.success",
          ),
        });
      } else {
        toast.fire({
          icon: "error",
          title: t(
            "pages.admin-integrations-monday-id-board.onEnqueueJobToInstallWebhooks.error",
          ),
        });
      }
      enqueueingJobToInstallWebhooks.value = false;
    };

    const enqueueingJobToRefreshBoardMeta = ref(false);
    const doEnqueueJobToRefreshBoardMeta = async () => {
      if (!api || !toast) {
        return;
      }
      enqueueingJobToRefreshBoardMeta.value = true;
      const { status } = await api.post(
        `/admin/integrations/monday/${parentId.value}/boards/${model.value.monday_board_id}/actions/refresh-board-meta`,
        {
          authenticity_token: formAuthenticityToken.value,
        },
      );
      if (202 === status) {
        toast.fire({
          icon: "success",
          title: t(
            "pages.admin-integrations-monday-id-board.onEnqueueJobToRefreshBoardMeta.success",
          ),
        });
      } else {
        toast.fire({
          icon: "error",
          title: t(
            "pages.admin-integrations-monday-id-board.onEnqueueJobToRefreshBoardMeta.error",
          ),
        });
      }
      enqueueingJobToRefreshBoardMeta.value = false;
    };

    const consumer = useActionCableConsumer();
    const boardMondayBoardSubscription = ref<Cable.Subscription | undefined>(
      undefined,
    );
    onMounted(() => {
      if (consumer) {
        if (boardMondayBoardSubscription.value) {
          boardMondayBoardSubscription.value.unsubscribe();
        }
        boardMondayBoardSubscription.value = consumer.subscriptions.create(
          {
            channel: "FridayPlugin::RealTimeUpdatesChannel",
            room: "board_monday_board",
          },
          {
            received: (data: {
              monday_instance_id: number;
              monday_board_id: number;
              from?: string;
            }) => {
              if (
                data.monday_instance_id === parentId.value &&
                data.monday_board_id === id.value &&
                (!data.from || bus?.uuid !== data.from)
              ) {
                reloadRouteDataAction.call();
              }
            },
          },
        );
      }
    });
    onBeforeUnmount(() => {
      if (boardMondayBoardSubscription.value) {
        boardMondayBoardSubscription.value.unsubscribe();
      }
    });
    const renderedForm = ref<FridayFormComponent | null>(null);
    const currentFieldValues = ref<Record<string, unknown>>({});
    const formStructure = computed<FridayFormStructure>(
      () =>
        [
          [
            {
              cols: 12,
              md: 4,
              fieldComponent: VAutocomplete,
              formKey: "project_id",
              valueKey: "project_id",
              label: t(
                `pages.admin-integrations-monday-id-board.fields.project_id`,
              ),
              bindings: {
                label: t(
                  `pages.admin-integrations-monday-id-board.fields.project_id`,
                ),
                items: projectValues.value,
                itemTitle: "label",
              },
            },
          ],
          ...[...model.value.board_meta_data.columns].map((column) => [
            {
              cols: 12,
              md: 4,
              fieldComponent: VAutocomplete,
              formKey: column.id,
              valueKey: column.id,
              label: t(
                `pages.admin-integrations-monday-id-board.fields.field_mapping_for`,
                { id: column.id, type: column.type, title: column.title },
              ),
              bindings: {
                label: t(
                  `pages.admin-integrations-monday-id-board.fields.field_mapping_for`,
                  { id: column.id, type: column.type, title: column.title },
                ),
                items: [...fieldValues.value].filter((field) =>
                  field.monday_types.includes(column.type),
                ),
                itemTitle: "label",
              },
            },
          ]),
        ] as FridayFormStructure,
    );
    const formValues = computed<Record<string, unknown>>(() => ({
      project_id: model.value.project_id,
      ...model.value.board_field_mapping,
    }));
    const modifyPayload = (payload: Record<string, unknown>) => {
      const copiedPayload = { ...payload };
      delete copiedPayload.project_id;
      return {
        authenticity_token: formAuthenticityToken.value,
        monday_board: {
          project_id: payload.project_id,
          board_field_mappings: copiedPayload,
        },
      };
    };
    const fridayFormBindings = computed(() => ({
      action: `/admin/integrations/monday/${parentId.value}/boards/${model.value.monday_board_id}`,
      method: "put",
      structure: formStructure.value.filter(
        (r) => Array.isArray(r) && r.length > 0,
      ),
      // getFieldOverrides: (
      //   formKey: string,
      //   _value: unknown,
      //   values: Record<string, unknown>,
      // ) => {
      //   switch (formKey) {
      //     case "inherit_members":
      //       if (!values.parent_id) {
      //         return { disabled: true, readonly: true, modelValue: false };
      //       }
      //       break;
      //   }
      //   return {};
      // },
      values: formValues.value,
      modifyPayload,
      validHttpStatus: 201,
      "onUpdate:values": (values: Record<string, unknown>) => {
        if (!checkObjectEquality(values, currentFieldValues.value)) {
          currentFieldValues.value = values;
        }
      },
    }));
    const onSuccess = (_status: number, _payload: unknown) => {
      reloadRouteDataAction.call();
      if (!toast) {
        alert(t(`pages.admin-integrations-monday-id-board.onSave.success`));
        return;
      } else {
        toast.fire({
          title: t(`pages.admin-integrations-monday-id-board.onSave.success`),
          icon: "success",
        });
        return;
      }
    };
    const onError = useOnError("pages.admin-integrations-monday-id-board");
    return {
      breadcrumbsBindings,
      accentColor,
      iconGitlab,
      copyToClipboard,
      projectValues,
      iconWebhooks,
      enqueueingJobToInstallWebhooks,
      doEnqueueJobToInstallWebhooks,
      enqueueingJobToRefreshBoardMeta,
      doEnqueueJobToRefreshBoardMeta,
      fridayFormBindings,
      onSuccess,
      onError,
      renderedForm,
    };
  },
});
</script>
