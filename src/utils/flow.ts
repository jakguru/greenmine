import { isRef } from "vue";
import type { Ref } from "vue";

/**
 * Asyncronously wait until a value is defined before resolving the promise
 *
 * @typeParam T The type of the value to check for when it is defined
 * @typeParam B The type of the value to return if the value is not defined
 *
 * @param what The value to check for when it is defined
 * @param signal An abort controller signal which can be used to prematurely end the promise
 * @param bad An array of values to consider as "bad" or "undefined"
 * @returns A promise that resolves to the value of `what` if it is defined, otherwise `undefined`
 */
export const defined = async <T = any, B = undefined>(
  what: T | B | Ref<T | B>,
  signal?: AbortSignal,
  bad: any[] = [undefined],
): Promise<T | B> => {
  // eslint-disable-next-line no-async-promise-executor
  return new Promise(async (resolve) => {
    if (isRef(what)) {
      while (bad.includes(what.value) && (!signal || !signal.aborted)) {
        await new Promise((r) => setTimeout(r, 100));
      }
      resolve(what.value);
    } else {
      while (bad.includes(what) && (!signal || !signal.aborted)) {
        await new Promise((r) => setTimeout(r, 100));
      }
      resolve(what);
    }
  });
};

/**
 * Asyncronously wait until an array of values are defined before resolving the promise
 *
 * @typeParam T The type of the value to check for when it is defined
 * @typeParam B The type of the value to return if the value is not defined
 *
 * @param what The array of values to check to ensure they are defined
 * @param signal An abort controller signal which can be used to prematurely end the promise
 * @param bad An array of values to consider as "bad" or "undefined"
 * @returns A promise that resolves to an array of values that are defined
 */
export const arrayOfDefined = async <T = any, B = undefined>(
  what: T[] | Ref<T[]>,
  signal?: AbortSignal,
  bad: any[] = [undefined],
): Promise<Array<T | B>> => {
  if (
    (isRef(what) && (!Array.isArray(what.value) || what.value.length === 0)) ||
    (!isRef(what) && (!Array.isArray(what) || what.length === 0))
  ) {
    return [];
  }
  let ret: Array<T | B>;
  if (isRef(what)) {
    ret = await Promise.all(
      what.value.map(async (w) => defined<T, B>(w, signal, bad)),
    );
  } else {
    ret = await Promise.all(
      what.map(async (w) => defined<T, B>(w, signal, bad)),
    );
  }
  return ret.filter((r) => !bad.includes(r));
};
