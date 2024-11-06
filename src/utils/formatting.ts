import { DateTime, Duration } from "luxon";
import ordinal from "ordinal";

export const formatDate = (value: string | null) => {
  if (!value) {
    return "";
  }
  const dto = DateTime.fromISO(value);
  if (!dto.isValid) {
    return "";
  }
  return dto.toLocaleString(DateTime.DATE_MED);
};

export const formatDateAsUTC = (value: string | null) => {
  if (!value) {
    return "";
  }
  const dto = DateTime.fromISO(value);
  if (!dto.isValid) {
    return "";
  }
  return [dto.toUTC().toLocaleString(DateTime.DATE_MED), "UTC"].join(" ");
};

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

export const formatDuration = (hours: number | null) => {
  if (hours === null) {
    return "";
  }
  const duration = Duration.fromObject({ hours });
  duration.shiftTo("hours", "minutes", "seconds");
  return duration.toFormat("hh:mm:ss");
};

export const formatDurationForHumans = (hours: number | null) => {
  if (hours === null) {
    return "";
  }
  const duration = Duration.fromObject({ hours });
  duration.shiftToAll();
  return duration.toHuman();
};

export const capitalize = (value: string) => {
  return value.charAt(0).toUpperCase() + value.slice(1);
};

export { ordinal };
