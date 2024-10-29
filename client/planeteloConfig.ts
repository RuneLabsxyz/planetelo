import manifest from "../planetelo/manifests/slot/deployment/manifest.json";

import { createDojoConfig } from "@dojoengine/core";

export const dojoConfig = createDojoConfig({
  manifest,
});
