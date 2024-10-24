export const interpolateColor = (
  lowColor: string,
  highColor: string,
  factor: number,
): string => {
  const hexToRgb = (hex: string) => {
    const bigint = parseInt(hex.slice(1), 16);
    return {
      r: (bigint >> 16) & 255,
      g: (bigint >> 8) & 255,
      b: bigint & 255,
    };
  };

  const rgbToHex = (r: number, g: number, b: number) => {
    return (
      "#" +
      [r, g, b]
        .map((x) => {
          const hex = x.toString(16);
          return hex.length === 1 ? "0" + hex : hex;
        })
        .join("")
    );
  };

  const lowRgb = hexToRgb(lowColor);
  const highRgb = hexToRgb(highColor);

  const r = Math.round(lowRgb.r + factor * (highRgb.r - lowRgb.r));
  const g = Math.round(lowRgb.g + factor * (highRgb.g - lowRgb.g));
  const b = Math.round(lowRgb.b + factor * (highRgb.b - lowRgb.b));

  return rgbToHex(r, g, b);
};

export const calculateColorForPriority = (
  lowestPriorityPosition: number,
  highestPriorityPosition: number,
  currentPriorityPosition: number,
  lowColorHex: string,
  highColorHex: string,
): string => {
  if (lowestPriorityPosition === highestPriorityPosition) {
    return highColorHex;
  }

  const factor =
    (currentPriorityPosition - lowestPriorityPosition) /
    (highestPriorityPosition - lowestPriorityPosition);

  return interpolateColor(lowColorHex, highColorHex, factor);
};
