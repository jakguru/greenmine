export interface FieldValidationMetaInfo {
  field: string;
  name: string;
  label?: string;
  value: unknown;
  form: Record<string, unknown>;
  rule?: {
    name: string;
    params?: Record<string, unknown> | unknown[];
  };
}

export interface FormFieldValidator<T = unknown> {
  (value: T, meta: FieldValidationMetaInfo): true | string;
}
