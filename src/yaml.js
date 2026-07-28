export function toYaml(value, indentation = 0) {
  const prefix = " ".repeat(indentation);

  if (Array.isArray(value)) {
    if (value.length === 0) {
      return `${prefix}[]`;
    }
    return value
      .map((item) => {
        if (isContainer(item)) {
          const nested = toYaml(item, indentation + 2);
          return `${prefix}-\n${nested}`;
        }
        return `${prefix}- ${scalar(item)}`;
      })
      .join("\n");
  }

  if (value && typeof value === "object") {
    return Object.entries(value)
      .map(([key, item]) => {
        if (isContainer(item) && Object.keys(item).length > 0) {
          return `${prefix}${key}:\n${toYaml(item, indentation + 2)}`;
        }
        return `${prefix}${key}: ${isContainer(item) ? "[]" : scalar(item)}`;
      })
      .join("\n");
  }

  return `${prefix}${scalar(value)}`;
}

function isContainer(value) {
  return Array.isArray(value) || (value !== null && typeof value === "object");
}

function scalar(value) {
  if (value === null) {
    return "null";
  }
  if (typeof value === "boolean" || typeof value === "number") {
    return String(value);
  }
  return JSON.stringify(String(value));
}
