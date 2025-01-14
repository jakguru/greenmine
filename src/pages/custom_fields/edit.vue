<template>
  <v-container fluid>
    <v-card min-height="100" color="surface">
      <v-toolbar color="transparent" density="compact">
        <v-toolbar-title class="font-weight-bold d-flex align-center" tag="h1">
          {{
            !id
              ? $t("pages.custom-fields-new.title")
              : $t("pages.custom-fields-id-edit.title")
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
      <v-divider v-if="id && 'enumeration' === reportedFieldFormat" />
      <v-sheet
        v-if="id && 'enumeration' === reportedFieldFormat"
        color="transparent"
        class="py-3"
      >
        <EnumerableForm
          :form-authenticity-token="formAuthenticityToken"
          name="pages.custom-fields-id-edit.content.enumerations"
          :values="enumerations"
          :endpoint="`/custom_fields/${id}/manage-enumerations`"
          model-property-key="custom_field_enumeration"
          low-color="#607D8B"
          high-color="#607D8B"
          variant="plain"
          :show-is-default="false"
        />
      </v-sheet>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, computed, inject, ref, h, watch } from "vue";
import { useI18n } from "vue-i18n";
import { VTextField } from "vuetify/components/VTextField";
import { VTextarea } from "vuetify/components/VTextarea";
import { VAutocomplete } from "vuetify/components/VAutocomplete";
import { VSwitch } from "vuetify/components/VSwitch";
import { useRoute, useRouter } from "vue-router";
import {
  useSystemAccentColor,
  useReloadRouteData,
  useReloadAppData,
  cloneObject,
  checkObjectEquality,
  useOnError,
} from "@/utils/app";
import {
  Joi,
  getFormFieldValidator,
  FridayForm,
  tlds,
} from "@/components/forms";
import {
  VPasswordFieldWithGenerator,
  VMarkdownField,
  VQueryColumnSelectionField,
  VCSVField,
  VLBSVField,
} from "@/components/fields";
import EnumerableForm from "@/components/forms/enumerable.vue";

import type { PropType } from "vue";
import type {
  FridayFormStructure,
  FridayFormStructureField,
} from "@/components/forms";
import type {
  ToastService,
  LocalStorageService,
  ApiService,
} from "@jakguru/vueprint";
import type { EnumerableValue } from "@/friday";

interface SelectItem {
  value: string | number;
  label: string | null;
}

interface Props {
  items?: SelectItem[];
  disabled?: boolean;
  required?: boolean;
  optional?: boolean;
  type?: string;
  min?: number;
  max?: number;
  steps?: string;
  multiple?: boolean;
}

interface FieldDefinition {
  type: string;
  props: Props;
  value: string | number | boolean | null | (string | number)[];
}

interface CustomField {
  field_format: FieldDefinition;
  name: FieldDefinition;
  description?: FieldDefinition;
  role_ids?: FieldDefinition;
  tracker_ids?: FieldDefinition;
  is_for_all?: FieldDefinition;
  project_ids?: FieldDefinition;
  visible?: FieldDefinition;
  editable?: FieldDefinition;
}

interface FormsByType {
  [key: string]: CustomField;
}

interface FormByTypeAndFormat {
  [key: string]: {
    [key: string]: {
      is_filter?: FieldDefinition;
      searchable?: FieldDefinition;
    };
  };
}

interface FormsByFormat {
  [key: string]: {
    [key: string]: FieldDefinition;
  };
}

interface TypesItem {
  value: string;
  label: string;
}

export default defineComponent({
  name: "CustomFieldsEdit",
  components: {
    FridayForm,
    EnumerableForm,
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
    type: {
      type: String as PropType<string | null | undefined>,
      default: null,
    },
    types: {
      type: Array as PropType<TypesItem[]>,
      required: true,
    },
    formsByType: {
      type: Object as PropType<FormsByType>,
      required: true,
    },
    formsByFormat: {
      type: Object as PropType<FormsByFormat>,
      required: true,
    },
    formByTypeAndFormat: {
      type: Object as PropType<FormByTypeAndFormat>,
      required: true,
    },
    enumerations: {
      type: Array as PropType<EnumerableValue[]>,
      required: true,
    },
  },
  setup(props) {
    const toast = inject<ToastService>("toast");
    const ls = inject<LocalStorageService>("ls");
    const api = inject<ApiService>("api");
    const route = useRoute();
    const router = useRouter();
    const reloadRouteDataAction = useReloadRouteData(route, api, toast);
    const reloadAppDataAction = useReloadAppData(ls, api);
    const accentColor = useSystemAccentColor();
    const formAuthenticityToken = computed(() => props.formAuthenticityToken);
    const id = computed(() => props.id);
    const type = computed(() => props.type);
    const types = computed(() => props.types);
    const formsByType = computed(() => props.formsByType);
    const formsByFormat = computed(() => props.formsByFormat);
    const formByTypeAndFormat = computed(() => props.formByTypeAndFormat);
    const { t } = useI18n({ useScope: "global" });
    const i18nPrefix = computed(() =>
      id.value ? "pages.custom-fields-id-edit" : "pages.custom-fields-new",
    );
    const breadcrumbsBindings = computed(() => ({
      items: [
        { title: t("pages.admin.title"), to: { name: "admin" } },
        {
          title: t("pages.custom-fields.title"),
          to: { name: "custom-fields" },
        },
        {
          title: t(`${i18nPrefix.value}.title`),
        },
      ],
    }));
    const modifyPayload = (payload: Record<string, unknown>) => {
      return {
        authenticity_token: formAuthenticityToken.value,
        type: payload.type,
        custom_field: {
          ...payload,
          type: undefined,
        },
      };
    };
    const onSuccess = (_status: number, payload: unknown) => {
      reloadRouteDataAction.call();
      reloadAppDataAction.call();
      if (!toast) {
        alert(t(`${i18nPrefix.value}.onSave.success`));
        return;
      } else {
        if (
          "object" === typeof payload &&
          null !== payload &&
          "id" in payload &&
          payload.id !== id.value
        ) {
          router.push({
            name: "custom-fields-id-edit",
            params: {
              id: (payload.id as number).toString(),
            },
          });
        }
        toast.fire({
          title: t(`${i18nPrefix.value}.onSave.success`),
          icon: "success",
        });
        return;
      }
    };
    const onError = useOnError(i18nPrefix.value);
    const currentFieldValues = ref<Record<string, unknown>>({});
    const reportedType = computed(() => currentFieldValues.value.type || null);
    const reportedFieldFormat = computed(
      () => currentFieldValues.value.field_format || "",
    );
    watch(
      () => type.value,
      (is, was) => {
        if (is && is !== was) {
          currentFieldValues.value.type = is;
        }
      },
      { immediate: true },
    );
    const knownFields = computed(() => {
      const ret: Record<string, FieldDefinition | undefined> = {};
      if (
        reportedType.value &&
        formsByType.value[reportedType.value as keyof typeof formsByType.value]
      ) {
        Object.keys(
          formsByType.value[
            reportedType.value as keyof typeof formsByType.value
          ],
        ).forEach((key) => {
          // @ts-ignore
          ret[key] = formsByType.value[reportedType.value][key] || null;
        });
      }
      if (
        formsByFormat.value[
          reportedFieldFormat.value as keyof typeof formsByFormat.value
        ]
      ) {
        Object.keys(
          formsByFormat.value[
            reportedFieldFormat.value as keyof typeof formsByFormat.value
          ],
        ).forEach((key) => {
          ret[key] =
            formsByFormat.value[
              reportedFieldFormat.value as keyof typeof formsByFormat.value
            ][key] || null;
        });
      }
      if (
        reportedType.value &&
        formByTypeAndFormat.value[
          reportedType.value as keyof typeof formByTypeAndFormat.value
        ] &&
        formByTypeAndFormat.value[
          reportedType.value as keyof typeof formByTypeAndFormat.value
          // @ts-ignore
        ][reportedFieldFormat.value]
      ) {
        Object.keys(
          formByTypeAndFormat.value[
            reportedType.value as keyof typeof formByTypeAndFormat.value
            // @ts-ignore
          ][reportedFieldFormat.value],
        ).forEach((key) => {
          ret[key] =
            // @ts-ignore
            formByTypeAndFormat.value[reportedType.value][
              reportedFieldFormat.value
            ][key] || null;
        });
      }
      return ret;
    });
    const makeFridayFormFieldFor = (
      key: string,
      options: {
        cols: number;
        xs?: number;
        sm?: number;
        md?: number;
        lg?: number;
        xl?: number;
        xxl?: number;
        bindings?: Record<string, unknown>;
      },
    ): FridayFormStructureField => {
      const settingsFieldInfo = knownFields.value[key];
      if (!settingsFieldInfo) {
        return {
          cols: options.cols,
          xs: options.xs,
          sm: options.sm,
          md: options.md,
          lg: options.lg,
          xl: options.xl,
          xxl: options.xxl,
          fieldComponent: h("span", `Unknown field: ${key}`),
          formKey: key,
          valueKey: key,
          label: t(`${i18nPrefix.value}.content.fields.${key}`),
          bindings: {
            ...options.bindings,
            label: t(`${i18nPrefix.value}.content.fields.${key}`),
            falseValue: "0",
            trueValue: "1",
          },
        };
      }
      switch (settingsFieldInfo.type) {
        case "checkbox":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VSwitch,
            formKey: key,
            valueKey: key,
            label: t(`${i18nPrefix.value}.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              label: t(`${i18nPrefix.value}.content.fields.${key}`),
              falseValue: "0",
              trueValue: "1",
            },
          };
        case "select":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VAutocomplete,
            formKey: key,
            valueKey: key,
            label: t(`${i18nPrefix.value}.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              items: settingsFieldInfo.props.items!.map((i: any) => ({
                label: t(i.label),
                value: i.value,
              })),
              label: t(`${i18nPrefix.value}.content.fields.${key}`),
              itemTitle: "label",
              itemValue: "value",
              chips: true === settingsFieldInfo.props.multiple,
              closableChips: true === settingsFieldInfo.props.multiple,
            },
          };
        case "csv":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VCSVField,
            formKey: key,
            valueKey: key,
            label: t(`${i18nPrefix.value}.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              label: t(`${i18nPrefix.value}.content.fields.${key}`),
            },
          };
        case "lbsv":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VLBSVField,
            formKey: key,
            valueKey: key,
            label: t(`${i18nPrefix.value}.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              label: t(`${i18nPrefix.value}.content.fields.${key}`),
            },
          };
        case "password":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VPasswordFieldWithGenerator,
            formKey: key,
            valueKey: key,
            label: t(`${i18nPrefix.value}.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              label: t(`${i18nPrefix.value}.content.fields.${key}`),
              length: 20,
              numbers: true,
              lowercase: true,
              uppercase: true,
              strict: true,
            },
          };
        case "markdown":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VMarkdownField,
            formKey: key,
            valueKey: key,
            label: t(`${i18nPrefix.value}.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              label: t(`${i18nPrefix.value}.content.fields.${key}`),
            },
          };
        case "querycolumnselection":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VQueryColumnSelectionField,
            formKey: key,
            valueKey: key,
            label: t(`${i18nPrefix.value}.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              label: t(`${i18nPrefix.value}.content.fields.${key}`),
              items: settingsFieldInfo.props.items!.map((i: any) => ({
                label: t(i.label),
                value: i.value,
              })),
            },
          };
        case "textarea":
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VTextarea,
            formKey: key,
            valueKey: key,
            label: t(`${i18nPrefix.value}.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              label: t(`${i18nPrefix.value}.content.fields.${key}`),
            },
          };
        case "text":
        default:
          return {
            cols: options.cols,
            xs: options.xs,
            sm: options.sm,
            md: options.md,
            lg: options.lg,
            xl: options.xl,
            xxl: options.xxl,
            fieldComponent: VTextField,
            formKey: key,
            valueKey: key,
            label: t(`${i18nPrefix.value}.content.fields.${key}`),
            bindings: {
              ...options.bindings,
              ...settingsFieldInfo.props,
              label: t(`${i18nPrefix.value}.content.fields.${key}`),
            },
            validator: getFormFieldValidator(
              t,
              (() => {
                if (!settingsFieldInfo.props) {
                  return Joi.string().required();
                }
                switch (settingsFieldInfo.props.type) {
                  case "email":
                    return settingsFieldInfo.props.optional
                      ? Joi.string()
                          .email({ tlds: { allow: tlds } })
                          .optional()
                          .allow("")
                          .allow(null)
                      : Joi.string()
                          .email({ tlds: { allow: tlds } })
                          .required();
                  case "number":
                    if (
                      settingsFieldInfo.props.min &&
                      settingsFieldInfo.props.max
                    ) {
                      return settingsFieldInfo.props.optional
                        ? Joi.number()
                            .min(settingsFieldInfo.props.min)
                            .max(settingsFieldInfo.props.max)
                            .optional()
                            .allow("", null)
                        : Joi.number()
                            .min(settingsFieldInfo.props.min)
                            .max(settingsFieldInfo.props.max)
                            .required();
                    } else if (settingsFieldInfo.props.min) {
                      return settingsFieldInfo.props.optional
                        ? Joi.number()
                            .min(settingsFieldInfo.props.min)
                            .optional()
                            .allow("", null)
                        : Joi.number()
                            .min(settingsFieldInfo.props.min)
                            .required();
                    } else if (settingsFieldInfo.props.max) {
                      return settingsFieldInfo.props.optional
                        ? Joi.number()
                            .max(settingsFieldInfo.props.max)
                            .optional()
                            .allow("", null)
                        : Joi.number()
                            .max(settingsFieldInfo.props.max)
                            .required();
                    } else {
                      return settingsFieldInfo.props.optional
                        ? Joi.number().optional().allow("").allow(null)
                        : Joi.number().required();
                    }
                  default:
                    return settingsFieldInfo.props.optional
                      ? Joi.string().optional().allow("").allow(null)
                      : Joi.string().required();
                }
              })(),
              t(`${i18nPrefix.value}.content.fields.${key}`),
            ),
          };
      }
    };
    const formatSpecificOptionsStructure = computed<FridayFormStructure>(() => {
      if (!reportedType.value || !reportedFieldFormat.value) {
        return [];
      }
      switch (reportedFieldFormat.value) {
        case "attachment":
          return [[makeFridayFormFieldFor("extensions_allowed", { cols: 12 })]];
        case "bool":
          return [
            [
              makeFridayFormFieldFor("default_value", { cols: 12, sm: 6 }),
              makeFridayFormFieldFor("url_pattern", { cols: 12, sm: 6 }),
            ],
          ];
        case "date":
          return [
            [
              makeFridayFormFieldFor("default_value", { cols: 12, sm: 6 }),
              makeFridayFormFieldFor("url_pattern", { cols: 12, sm: 6 }),
            ],
          ];
        case "enumeration":
          return [
            id.value === null || id.value === 0
              ? [
                  makeFridayFormFieldFor("url_pattern", { cols: 12, sm: 6 }),
                  makeFridayFormFieldFor("multiple", { cols: 12, sm: 6 }),
                ]
              : [
                  makeFridayFormFieldFor("default_value", { cols: 12, sm: 4 }),
                  makeFridayFormFieldFor("url_pattern", { cols: 12, sm: 4 }),
                  makeFridayFormFieldFor("multiple", { cols: 12, sm: 4 }),
                ],
          ];
        case "float":
          return [
            [
              makeFridayFormFieldFor("min_length", { cols: 12, sm: 6 }),
              makeFridayFormFieldFor("max_length", { cols: 12, sm: 6 }),
            ],
            [
              makeFridayFormFieldFor("default_value", { cols: 12, sm: 6 }),
              makeFridayFormFieldFor("regexp", { cols: 12, sm: 6 }),
            ],
          ];
        case "int":
          return [
            [
              makeFridayFormFieldFor("min_length", { cols: 12, sm: 6 }),
              makeFridayFormFieldFor("max_length", { cols: 12, sm: 6 }),
            ],
            [
              makeFridayFormFieldFor("default_value", { cols: 12, sm: 6 }),
              makeFridayFormFieldFor("regexp", { cols: 12, sm: 6 }),
            ],
          ];
        case "link":
          return [
            [
              makeFridayFormFieldFor("min_length", { cols: 12, sm: 6 }),
              makeFridayFormFieldFor("max_length", { cols: 12, sm: 6 }),
            ],
            [
              makeFridayFormFieldFor("default_value", { cols: 12, sm: 4 }),
              makeFridayFormFieldFor("url_pattern", { cols: 12, sm: 4 }),
              makeFridayFormFieldFor("regexp", { cols: 12, sm: 4 }),
            ],
          ];
        case "list":
          return [
            [
              makeFridayFormFieldFor("possible_values", { cols: 12, sm: 9 }),
              makeFridayFormFieldFor("multiple", { cols: 12, sm: 3 }),
            ],
            [
              makeFridayFormFieldFor("default_value", { cols: 12, sm: 6 }),
              makeFridayFormFieldFor("url_pattern", { cols: 12, sm: 6 }),
            ],
          ];
        case "string":
          return [
            [
              makeFridayFormFieldFor("min_length", { cols: 12, sm: 6 }),
              makeFridayFormFieldFor("max_length", { cols: 12, sm: 6 }),
            ],
            [
              makeFridayFormFieldFor("default_value", { cols: 12, sm: 6 }),
              makeFridayFormFieldFor("url_pattern", { cols: 12, sm: 6 }),
            ],
          ];
        case "text":
          return [
            [
              makeFridayFormFieldFor("min_length", { cols: 12, sm: 6 }),
              makeFridayFormFieldFor("max_length", { cols: 12, sm: 6 }),
            ],
            [makeFridayFormFieldFor("default_value", { cols: 12 })],
          ];
        case "user":
          return [
            [
              makeFridayFormFieldFor("user_role", { cols: 12, sm: 9 }),
              makeFridayFormFieldFor("multiple", { cols: 12, sm: 3 }),
            ],
          ];
        case "version":
          return [
            [
              makeFridayFormFieldFor("version_status", { cols: 12, sm: 9 }),
              makeFridayFormFieldFor("multiple", { cols: 12, sm: 3 }),
            ],
          ];
        default:
          return [] as FridayFormStructure;
      }
    });
    const formStructure = computed<FridayFormStructure>(() => {
      const modelTypeRow = [
        {
          cols: 12,
          fieldComponent: VAutocomplete,
          formKey: "type",
          valueKey: "type",
          label: t(`${i18nPrefix.value}.content.fields.type`),
          validator: getFormFieldValidator(
            t,
            Joi.string()
              .required()
              .allow(...types.value.map((t) => t.value)),
            t(`${i18nPrefix.value}.content.fields.type`),
          ),
          bindings: {
            items: types.value.map((t) => ({
              label: t.label,
              value: t.value,
            })),
            itemTitle: "label",
            itemValue: "value",
            label: t(`${i18nPrefix.value}.content.fields.type`),
            disabled: "number" === typeof id.value && id.value > 0,
            readonly: "number" === typeof id.value && id.value > 0,
          },
        } as FridayFormStructureField,
      ] as [FridayFormStructureField];
      const has = {
        is_required: "undefined" !== typeof knownFields.value.is_required,
        visible: "undefined" !== typeof knownFields.value.visible,
        editable: "undefined" !== typeof knownFields.value.editable,
        is_filter: "undefined" !== typeof knownFields.value.is_filter,
        searchable: "undefined" !== typeof knownFields.value.searchable,
      };
      const countOfHas = Object.keys(has).filter(
        (k) => has[k as keyof typeof has],
      ).length;
      let mdCols = 12;
      switch (countOfHas) {
        case 1:
          mdCols = 12;
          break;
        case 2:
          mdCols = 6;
          break;
        case 3:
          mdCols = 4;
          break;
        case 4:
        case 5:
        default:
          mdCols = 3;
          break;
      }
      const checkBoxesRow:
        | []
        | [FridayFormStructureField]
        | [FridayFormStructureField, FridayFormStructureField]
        | [
            FridayFormStructureField,
            FridayFormStructureField,
            FridayFormStructureField,
          ]
        | [
            FridayFormStructureField,
            FridayFormStructureField,
            FridayFormStructureField,
            FridayFormStructureField,
          ]
        | [
            FridayFormStructureField,
            FridayFormStructureField,
            FridayFormStructureField,
            FridayFormStructureField,
            FridayFormStructureField,
          ] = Object.keys(has)
        .map((k) => {
          if (!has[k as keyof typeof has]) {
            return undefined;
          } else {
            return makeFridayFormFieldFor(k, {
              cols: 12,
              md: mdCols,
            });
          }
        })
        .filter((v) => v !== undefined) as any;
      switch (reportedType.value) {
        case "DocumentCategoryCustomField":
          return [
            modelTypeRow,
            [
              makeFridayFormFieldFor("field_format", {
                cols: 12,
                md: 3,
                bindings: {
                  disabled: id.value !== null && id.value !== 0,
                  readonly: id.value !== null && id.value !== 0,
                  clearable: id.value === null && id.value === 0,
                },
              }),
              makeFridayFormFieldFor("name", { cols: 12, md: 9 }),
            ],
            [makeFridayFormFieldFor("description", { cols: 12 })],
            checkBoxesRow,
            ...formatSpecificOptionsStructure.value,
          ];
        case "DocumentCustomField":
          return [
            modelTypeRow,
            [
              makeFridayFormFieldFor("field_format", {
                cols: 12,
                md: 3,
                bindings: {
                  disabled: id.value !== null && id.value !== 0,
                  readonly: id.value !== null && id.value !== 0,
                  clearable: id.value === null && id.value === 0,
                },
              }),
              makeFridayFormFieldFor("name", { cols: 12, md: 9 }),
            ],
            [makeFridayFormFieldFor("description", { cols: 12 })],
            checkBoxesRow,
            ...formatSpecificOptionsStructure.value,
          ];
        case "GroupCustomField":
          return [
            modelTypeRow,
            [
              makeFridayFormFieldFor("field_format", {
                cols: 12,
                md: 3,
                bindings: {
                  disabled: id.value !== null && id.value !== 0,
                  readonly: id.value !== null && id.value !== 0,
                  clearable: id.value === null && id.value === 0,
                },
              }),
              makeFridayFormFieldFor("name", { cols: 12, md: 9 }),
            ],
            [makeFridayFormFieldFor("description", { cols: 12 })],
            checkBoxesRow,
            ...formatSpecificOptionsStructure.value,
          ];
        case "IssueCustomField":
          return [
            modelTypeRow,
            [
              makeFridayFormFieldFor("field_format", {
                cols: 12,
                md: 3,
                bindings: {
                  disabled: id.value !== null && id.value !== 0,
                  readonly: id.value !== null && id.value !== 0,
                  clearable: id.value === null && id.value === 0,
                },
              }),
              makeFridayFormFieldFor("name", { cols: 12, md: 9 }),
            ],
            [makeFridayFormFieldFor("description", { cols: 12 })],
            checkBoxesRow,
            ...formatSpecificOptionsStructure.value,
            [
              makeFridayFormFieldFor("role_ids", { cols: 12, md: 3 }),
              makeFridayFormFieldFor("tracker_ids", { cols: 12, md: 3 }),
              makeFridayFormFieldFor("project_ids", { cols: 12, md: 3 }),
              makeFridayFormFieldFor("is_for_all", { cols: 12, md: 3 }),
            ],
          ];
        case "IssuePriorityCustomField":
          return [
            modelTypeRow,
            [
              makeFridayFormFieldFor("field_format", {
                cols: 12,
                md: 3,
                bindings: {
                  disabled: id.value !== null && id.value !== 0,
                  readonly: id.value !== null && id.value !== 0,
                  clearable: id.value === null && id.value === 0,
                },
              }),
              makeFridayFormFieldFor("name", { cols: 12, md: 9 }),
            ],
            [makeFridayFormFieldFor("description", { cols: 12 })],
            checkBoxesRow,
            ...formatSpecificOptionsStructure.value,
          ];
        case "IssueImpactCustomField":
          return [
            modelTypeRow,
            [
              makeFridayFormFieldFor("field_format", {
                cols: 12,
                md: 3,
                bindings: {
                  disabled: id.value !== null && id.value !== 0,
                  readonly: id.value !== null && id.value !== 0,
                  clearable: id.value === null && id.value === 0,
                },
              }),
              makeFridayFormFieldFor("name", { cols: 12, md: 9 }),
            ],
            [makeFridayFormFieldFor("description", { cols: 12 })],
            checkBoxesRow,
            ...formatSpecificOptionsStructure.value,
          ];
        case "ProjectCustomField":
          return [
            modelTypeRow,
            [
              makeFridayFormFieldFor("field_format", {
                cols: 12,
                md: 3,
                bindings: {
                  disabled: id.value !== null && id.value !== 0,
                  readonly: id.value !== null && id.value !== 0,
                  clearable: id.value === null && id.value === 0,
                },
              }),
              makeFridayFormFieldFor("name", { cols: 12, md: 9 }),
            ],
            [makeFridayFormFieldFor("description", { cols: 12 })],
            checkBoxesRow,
            ...formatSpecificOptionsStructure.value,
            [makeFridayFormFieldFor("role_ids", { cols: 12 })],
          ];
        case "TimeEntryActivityCustomField":
          return [
            modelTypeRow,
            [
              makeFridayFormFieldFor("field_format", {
                cols: 12,
                md: 3,
                bindings: {
                  disabled: id.value !== null && id.value !== 0,
                  readonly: id.value !== null && id.value !== 0,
                  clearable: id.value === null && id.value === 0,
                },
              }),
              makeFridayFormFieldFor("name", { cols: 12, md: 9 }),
            ],
            [makeFridayFormFieldFor("description", { cols: 12 })],
            checkBoxesRow,
            ...formatSpecificOptionsStructure.value,
          ];
        case "TimeEntryCustomField":
          return [
            modelTypeRow,
            [
              makeFridayFormFieldFor("field_format", {
                cols: 12,
                md: 3,
                bindings: {
                  disabled: id.value !== null && id.value !== 0,
                  readonly: id.value !== null && id.value !== 0,
                  clearable: id.value === null && id.value === 0,
                },
              }),
              makeFridayFormFieldFor("name", { cols: 12, md: 9 }),
            ],
            [makeFridayFormFieldFor("description", { cols: 12 })],
            checkBoxesRow,
            ...formatSpecificOptionsStructure.value,
            [makeFridayFormFieldFor("role_ids", { cols: 12 })],
          ];
        case "UserCustomField":
          return [
            modelTypeRow,
            [
              makeFridayFormFieldFor("field_format", {
                cols: 12,
                md: 3,
                bindings: {
                  disabled: id.value !== null && id.value !== 0,
                  readonly: id.value !== null && id.value !== 0,
                  clearable: id.value === null && id.value === 0,
                },
              }),
              makeFridayFormFieldFor("name", { cols: 12, md: 9 }),
            ],
            [makeFridayFormFieldFor("description", { cols: 12 })],
            checkBoxesRow,
            ...formatSpecificOptionsStructure.value,
          ];
        case "VersionCustomField":
          return [
            modelTypeRow,
            [
              makeFridayFormFieldFor("field_format", {
                cols: 12,
                md: 3,
                bindings: {
                  disabled: id.value !== null && id.value !== 0,
                  readonly: id.value !== null && id.value !== 0,
                  clearable: id.value === null && id.value === 0,
                },
              }),
              makeFridayFormFieldFor("name", { cols: 12, md: 9 }),
            ],
            [makeFridayFormFieldFor("description", { cols: 12 })],
            checkBoxesRow,
            ...formatSpecificOptionsStructure.value,
            [makeFridayFormFieldFor("role_ids", { cols: 12 })],
          ];
        default:
          return [modelTypeRow];
      }
    });
    const formValues = computed<Record<string, unknown>>(() =>
      cloneObject(
        Object.assign(
          {},
          {
            type: reportedType.value,
            field_format:
              reportedFieldFormat.value ||
              knownFields.value.field_format?.value ||
              "",
          },
          ...Object.keys(knownFields.value).map((k) => ({
            [k]:
              "undefined" !==
              typeof knownFields.value[k as keyof typeof knownFields.value]
                ? knownFields.value[k as keyof typeof knownFields.value]!.value
                : null,
          })),
          {
            field_format:
              reportedFieldFormat.value ||
              knownFields.value.field_format?.value ||
              "",
          },
        ),
      ),
    );
    const fridayFormBindings = computed(() => ({
      action: `/custom_fields${id.value ? `/${id.value}` : ""}`,
      method: id.value ? "put" : "post",
      structure: formStructure.value.filter(
        (r) => Array.isArray(r) && r.length > 0,
      ),
      values: formValues.value,
      getFieldOverrides: (
        formKey: string,
        _value: unknown,
        values: Record<string, unknown>,
      ) => {
        switch (formKey) {
          case "role_ids":
            if (values.visible === "1") {
              return { disabled: true, readonly: true };
            }
            break;
          case "project_ids":
            if (values.is_for_all === "1") {
              return { disabled: true, readonly: true };
            }
            break;
        }
        return {};
      },
      modifyPayload,
      validHttpStatus: 201,
      "onUpdate:values": (values: Record<string, unknown>) => {
        if (!checkObjectEquality(values, currentFieldValues.value)) {
          currentFieldValues.value = values;
        }
      },
    }));
    return {
      breadcrumbsBindings,
      fridayFormBindings,
      accentColor,
      onSuccess,
      onError,
      currentFieldValues,
      reportedFieldFormat,
    };
  },
});
</script>
