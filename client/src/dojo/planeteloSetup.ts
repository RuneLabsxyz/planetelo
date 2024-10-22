import type { DojoConfig } from "@dojoengine/core";
import { DojoProvider } from "@dojoengine/core";
import * as torii from "@dojoengine/torii-client";
import { createPlaneteloClientComponents } from "./createPlaneteloClientComponents";
import { defineContractComponents } from "./bindings/planetelo/models.gen";
import { world } from "./world";
import { setupWorld } from "./bindings/planetelo/contracts.gen";
import { Account } from "starknet";
import type { ArraySignatureType } from "starknet";
import { BurnerManager } from "@dojoengine/create-burner";
import { getSyncEntities, getSyncEvents } from "@dojoengine/state";

export type SetupResult = Awaited<ReturnType<typeof planeteloSetup>>;

export async function planeteloSetup({ ...config }: DojoConfig) {
  // torii client
  const toriiClient = await torii.createClient({
    rpcUrl: 'https://api.cartridge.gg/x/planetelo/katana',
    toriiUrl: 'https://api.cartridge.gg/x/planetelo/torii',
    relayUrl: "",
    worldAddress: config.manifest.world.address || "",
  });

  // create contract components
  const contractComponents = defineContractComponents(world);

  // create client components
  const planeteloComponents = createPlaneteloClientComponents({ contractComponents });

  // create dojo provider
  const dojoProvider = new DojoProvider(config.manifest, 'https://api.cartridge.gg/x/planetelo/katana');

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

  // create burner manager
  const burnerManager = new BurnerManager({
    masterAccount: new Account(
      {
        nodeUrl: 'https://api.cartridge.gg/x/planetelo/katana',
      },
      '0x955b7ec33a80e83bf1a2f1b2569b1aa6fccbb49480ff924d4c88b239d69da9',
      '0x145ce5d0c6512ace2e6480a05e8c4617bcc0ef432f12bf2fe33b3e1483e788d'
    ),
    accountClassHash: config.accountClassHash,
    rpcProvider: dojoProvider.provider,
    feeTokenAddress: config.feeTokenAddress,
  });

  try {
    await burnerManager.init();
    if (burnerManager.list().length === 0) {
      await burnerManager.create();
    }
  } catch (e) {
    console.error(e);
  }

  return {
    client,
    planeteloComponents,
    contractComponents,
    publish: (typedData: string, signature: ArraySignatureType) => {
      toriiClient.publishMessage(typedData, signature);
    },
    config,
    dojoProvider,
    burnerManager,
    toriiClient,
    eventSync,
    torii,
    sync,
  };
}
