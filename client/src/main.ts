import "./app.css";
import App from "./App.svelte";
import { planeteloSetup } from "./dojo/planeteloSetup";
import { planetarySetup } from "./dojo/planetarySetup";
import { dojoConfig as planetaryConfig } from "../planetaryConfig";
import { dojoConfig as planeteloConfig } from "../planeteloConfig";

import { accountStore, burnerStore, planeteloStore, planetaryStore } from "./stores";

// Create a writable store for the setup result

async function initApp() {
  // Update the store with the setup result
  let setupRes = await planeteloSetup(planeteloConfig);
  let planetarySetupRes = await planetarySetup(planetaryConfig);
  planeteloStore.set(setupRes);
  planetaryStore.set(planetarySetupRes);
  burnerStore.set(setupRes.burnerManager.list());
  accountStore.set(setupRes.burnerManager.getActiveAccount())

  console.log("App initialized");

  const app = new App({
    target: document.getElementById("app")!,
  });

  return app;
}

export default initApp();
