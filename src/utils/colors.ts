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

export const calculateColorFromNumber = (number: number): string => {
  const choices = [
    "bazooka",
    "asphalt",
    "mud",
    "grass",
    "done",
    "bright",
    "saladish",
    "yolk",
    "working",
    "peach",
    "sunset",
    "stuck",
    "sofia",
    "lipstick",
    "bubble",
    "purple",
    "berry",
    "indigo",
    "navy",
    "aquamarine",
    "chili",
    "river",
    "winter",
    "explosive",
    "american",
    "blackish",
    "orchid",
    "tan",
    "sky",
    "coffee",
    "royal",
    "lavender",
    "steel",
    "lilac",
    "pecan",
    "marble",
    "gainsboro",
    "glitter",
    "turquoise",
    "aqua",
    "jeans",
    "eggplant",
    "mustered",
    "jade",
    "cannabis",
    "amethyst",
    "charcoal",
    "gold",
    "iris",
    "malachite",
    "snow-white",
    "riverstone-gray",
    "wolf-gray",
    "dark-marble",
    "jaco-gray",
    "storm-gray",
    "trolley-grey",
  ];
  if (number < 0) {
    number = number * -1;
  }
  number = Math.abs(number);
  const choicesIndex =
    number < choices.length ? number : number % choices.length;
  const color = choices[choicesIndex];
  const power = Math.min(Math.floor(number / choices.length), 11);
  const powerMap = new Map<number, string>([
    [0, "lighten-5"],
    [1, "lighten-4"],
    [2, "lighten-3"],
    [3, "lighten-2"],
    [4, "lighten-1"],
    [5, ""],
    [6, "darken-1"],
    [7, "darken-2"],
    [8, "darken-3"],
    [9, "darken-4"],
    [10, "darken-5"],
  ]);
  return [color, powerMap.get(power)]
    .filter((v) => "string" === typeof v && v.trim().length > 0)
    .join("-");
};
