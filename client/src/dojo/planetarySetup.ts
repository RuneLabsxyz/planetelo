import type { DojoConfig } from "@dojoengine/core";
import { DojoProvider } from "@dojoengine/core";
import * as torii from "@dojoengine/torii-client";
import { createPlanetaryClientComponents } from "./createPlanetaryComponents";
import { defineContractComponents } from "./bindings/planetary/models.gen";
import { world } from "./world";
import { setupWorld } from "./bindings/planetary/contracts.gen";
import { getSyncEntities, getSyncEvents } from "@dojoengine/state";

export type SetupResult = Awaited<ReturnType<typeof planetarySetup>>;

export async function planetarySetup({ ...config }: DojoConfig) {
  // torii client
  const toriiClient = await torii.createClient({
    rpcUrl: 'https://api.cartridge.gg/x/planetelo/katana',
    toriiUrl: 'https://api.cartridge.gg/x/planetelo-planetary/torii',
    relayUrl: "",
    worldAddress: config.manifest.world.address || "",
  });

  // create contract components
  const contractComponents = defineContractComponents(world);

  // create client components
  const planetaryComponents = createPlanetaryClientComponents({ contractComponents });

  // create dojo provider
  const dojoProvider = new DojoProvider(config.manifest, config.rpcUrl);
  const planets = toriiClient.getAllEntities(1000, 0);

  const sync = await getSyncEntities(
    toriiClient,
    contractComponents as any,
    undefined,
    []
  );

  const eventSync = getSyncEvents(
    toriiClient,
    contractComponents as any,
    undefined,
    []
  );

  // setup world
  const client = await setupWorld(dojoProvider);

  return {
    client,
    planetaryComponents,
    contractComponents,
    config,
    dojoProvider,
    toriiClient,
    eventSync,
    torii,
    sync,
    planets
  };
}
