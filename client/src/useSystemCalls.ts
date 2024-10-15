import { getEntityIdFromKeys } from "@dojoengine/utils";
import { dojoStore, setupStore } from "./stores";
import { get } from "svelte/store";
import { v4 as uuidv4 } from "uuid";

export const useSystemCalls = () => {
    const state = get(dojoStore);
    const setup = get(setupStore);
    const account = setup.account;
    const client = setup.client;
    const generateEntityId = () => {
        return getEntityIdFromKeys([BigInt(account?.address)]);
    };

  }
