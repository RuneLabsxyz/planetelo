import "./app.css";
import App from "./App.svelte";
import { planeteloSetup } from "./dojo/planeteloSetup";
import { planetarySetup } from "./dojo/planetarySetup";
import { dojoConfig } from "../dojoConfig";
import { accountStore, burnerStore, planeteloStore, planetaryStore } from "./stores";

// Create a writable store for the setup result

async function initApp() {
  // Update the store with the setup result
  let setupRes = await planeteloSetup(dojoConfig);
  let planetarySetupRes = await planetarySetup(dojoConfig);
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
