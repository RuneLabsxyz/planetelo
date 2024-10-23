<script lang="ts">
    import type { Entity } from "@dojoengine/recs";
    import { componentValueStore, type ComponentStore } from "./dojo/componentValueStore";
    import { planeteloStore, planetaryStore, accountStore, usernameStore } from "./stores";
    import { Account } from "starknet";
    import type { Burner } from "@dojoengine/create-burner";
    import { getEntityIdFromKeys } from "@dojoengine/utils";
    import { getComponentValue } from "@dojoengine/recs";
    import Controller from "@cartridge/controller";
    import { onMount } from "svelte";

    let queueId: Entity;
    let addressId: Entity;
    let playerId: Entity; 
    let account: Controller;
    let queue: ComponentStore;
    let status: ComponentStore;
    let game_planet: ComponentStore;
    let player: ComponentStore;
    let entities: any;
    
    $: ({ planeteloComponents, torii, toriiClient, client } = $planeteloStore);
    $: ({ planets, planetaryComponents, planetaryTorii } = $planetaryStore);
    if ($accountStore) account = $accountStore; 

    if ($accountStore) console.log(account!.account!.address);

    if (planetaryComponents) game_planet = componentValueStore(planetaryComponents.Planet, torii.poseidonHash(['0x6f63746f67756e73']));

    if (torii && $accountStore) queueId = torii.poseidonHash(['0x6f63746f67756e73', '0x0'])
    if (torii && account!) addressId = getEntityIdFromKeys([BigInt(account.account!.address)]);

    if (torii && account!) playerId = torii.poseidonHash([account.account!.address, '0x6f63746f67756e73', '0x0'])

    if (planeteloComponents)console.log(getComponentValue(planeteloComponents.Player, addressId));


    $: if ($planeteloStore) queue = componentValueStore(planeteloComponents.Queue, queueId);
    $: if ($planeteloStore) player = componentValueStore(planeteloComponents.Player, addressId);

    $: if ($planeteloStore) status = componentValueStore(planeteloComponents.PlayerStatus, playerId);

    console.log($player);
    console.log($status);
    console.log($queue);

    let controller = new Controller({
        policies: [
    ],
    rpc: "https://api.cartridge.gg/x/planetelo/katana" // sepolia, mainnet, or slot. (default sepolia)
    });

    async function connect() {
        try {
            const res = await controller.connect();
            if (res) {
                accountStore.set(controller);
                usernameStore.set(await controller.username()!);
                console.log(usernameStore);
            }
        } catch (e) {
            console.log(e);
        }
    }




</script>

<main>
    {#if $planeteloStore}
        <p>Setup completed</p>
    {:else}
        <p>Setting up...</p>
    {/if}

      <div>
        {#if $usernameStore}
            <p>{$usernameStore}</p>
        {/if}
          <button on:click={connect}>
              Connect
          </button>
      </div>

    <div class="queue">
        <div class="queue-item">
            <button on:click={() => console.log("queue")}>Queue</button>

        </div>
</div>

</main>
<style>
    .playlists {
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }
    .playlist-item {
        padding: 1rem;
        border: 1px solid #ccc;
        border-radius: 8px;
    }
    button {
        margin-top: 0.5rem;
        padding: 0.5rem 1rem;
        background-color: #007BFF;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
    }
    button:hover {
        background-color: #0056b3;
    }
</style>
      
