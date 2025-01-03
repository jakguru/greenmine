import { DateTime, Duration } from "luxon";
import ordinal from "ordinal";

export const toISODate = (value: string | null) => {
  if (!value) {
    return "";
  }
  const dto = DateTime.fromISO(value);
  if (!dto.isValid) {
    return "";
  }
  return dto.toUTC().toISODate();
};

export const formatDate = (value: string | null) => {
  if (!value) {
    return "";
  }
  const dto = DateTime.fromISO(value);
  if (!dto.isValid) {
    return "";
  }
  return dto.toUTC().toLocaleString(DateTime.DATE_MED);
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

export const formatShortDuration = (hours: number | null) => {
  if (hours === null) {
    return "";
  }
  const duration = Duration.fromObject({ hours });
  duration.shiftTo("hours", "minutes");
  return duration.toFormat("hh:mm");
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

export const formatTime = (value: string | null) => {
  if (!value) {
    return "";
  }
  const dto = DateTime.fromISO(value);
  if (!dto.isValid) {
    return "";
  }
  return dto.toLocaleString(DateTime.TIME_24_SIMPLE);
};

export const formatTimeAsUTC = (value: string | null) => {
  if (!value) {
    return "";
  }
  const dto = DateTime.fromISO(value);
  if (!dto.isValid) {
    return "";
  }
  return [dto.toUTC().toLocaleString(DateTime.TIME_24_SIMPLE), "UTC"].join(" ");
};
