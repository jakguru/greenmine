import Joi from "joi";
import type { useI18n } from "./i18n";
import type { FormFieldValidator, FieldValidationMetaInfo } from "@/types";

type I18nT = ReturnType<typeof useI18n>["t"];

const getTranslatedErrorMessage = (
  error: Joi.ValidationError,
  t: I18nT,
  label: string,
) => {
  if (0 === error.details.length) {
    return error.message;
  }
  if (!error.details[0].context) {
    error.details[0].context = { label };
  }
  error.details[0].context.label = label.trim();
  const { context, type } = error.details[0];
  const i18nKey = `validation.${type}`;
  return t(i18nKey, context);
};

export function getJoiValidationErrorI18n(
  error: Error | undefined,
  t: I18nT,
  label = "the Field",
) {
  if (!error) {
    return "";
  }
  if (!(error instanceof Joi.ValidationError)) {
    return error.message;
  }
  return getTranslatedErrorMessage(error, t, label);
}

export const doSchemaValidation = <T = any>(
  t: I18nT,
  schema: Joi.Schema<T>,
  value: T,
  label: string,
): true | string => {
  const { error } = schema.validate(value);
  if (error instanceof Joi.ValidationError) {
    return getJoiValidationErrorI18n(error as Joi.ValidationError, t, label);
  }
  return true;
};

export const doVeeValidateValidation = <T = any>(
  t: I18nT,
  schema: Joi.Schema,
  value: T,
  meta: FieldValidationMetaInfo,
  label?: string,
): true | string => {
  if ("string" !== typeof label) {
    label = meta.label || meta.name;
  }
  return doSchemaValidation(t, schema, value, label);
};

export const getFormFieldValidator = <T = any>(
  t: I18nT,
  schema: Joi.Schema,
  label?: string,
): FormFieldValidator<T> => {
  return (value, meta) =>
    doVeeValidateValidation(t, schema, value, meta, label);
};

export const vuetifyConfig = (
  state: any,
  focused?: boolean,
  defaultHideDetailsState: "auto" | boolean = "auto",
) => {
  const ret = {
    props: {
      "error-messages": state.touched
        ? state.errors.filter(
            (v: unknown) => typeof v === "string" && v.trim().length > 0,
          )
        : [],
      "hide-details":
        !state.touched ||
        focused ||
        state.errors.filter(
          (v: unknown) => typeof v === "string" && v.trim().length > 0,
        ).length === 0
          ? true
          : defaultHideDetailsState,
    },
  };
  return ret;
};
