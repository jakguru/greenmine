import { DateTime } from "luxon";

export const formatDateTime = (value: string | null) => {
  if (!value) {
    return "";
  }
  const dto = DateTime.fromISO(value);
  if (!dto.isValid) {
    return "";
  }
  return dto.toLocaleString(DateTime.DATETIME_MED);
};

export const formatDateTimeAsUTC = (value: string | null) => {
  if (!value) {
    return "";
  }
  const dto = DateTime.fromISO(value);
  if (!dto.isValid) {
    return "";
  }
  return [dto.toUTC().toLocaleString(DateTime.DATETIME_MED), "UTC"].join(" ");
};
