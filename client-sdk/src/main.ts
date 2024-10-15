import { StrictMode } from "react";
import { createRoot } from "react-dom/client";

import App from "./App.svelte";

import "./index.css";
import { init } from "@dojoengine/sdk";
import { type Schema, schema } from "./bindings.ts";
import { dojoConfig } from "../dojoConfig.ts";
import { setupBurnerManager } from "@dojoengine/create-burner";

    

async function initApp() {
  // Update the store with the setup result
  const sdk = await init<Schema>(
        {
            client: {
                rpcUrl: dojoConfig.rpcUrl,
                toriiUrl: dojoConfig.toriiUrl,
                relayUrl: dojoConfig.relayUrl,
                worldAddress: dojoConfig.manifest.world.address,
            },
            domain: {
                name: "WORLD_NAME",
                version: "1.0",
                chainId: "KATANA",
                revision: "1",
            },
        },
        schema
  );

  const burnerManager = await setupBurnerManager(dojoConfig);

  console.log("App initialized");

  const app = new App({
    target: document.getElementById("app")!,
    props: {
        sdk: sdk,
    },
  });

  return app;
}

export default initApp();
