import { createDojoConfig } from "@dojoengine/core";

import manifest from "../planetelo/manifests/dev/deployment/manifest.json";

export const dojoConfig = createDojoConfig({
    manifest,
});
