<script lang="ts">
    import type { Entity } from "@dojoengine/recs";
    import { componentValueStore, type ComponentStore } from "./dojo/componentValueStore";
    import { planeteloStore, planetaryStore, accountStore, burnerStore } from "./stores";
    import { Account } from "starknet";
    import type { Burner } from "@dojoengine/create-burner";
    import { handleBurnerChange, handleNewBurner, handleClearBurners } from "./handlers";
    import { getEntityIdFromKeys } from "@dojoengine/utils";
    import { getComponentValue } from "@dojoengine/recs";

    let queueId: Entity;
    let addressId: Entity;
    let playerId: Entity; 
    let account: Account;
    let queue: ComponentStore;
    let status: ComponentStore;
    let game_planet: ComponentStore;
    let player: ComponentStore;
    let burners: Burner[];
    let entities: any;
    
    $: ({ planeteloComponents, torii, toriiClient, burnerManager, client } = $planeteloStore);
    $: ({ planets, planetaryComponents, planetaryTorii } = $planetaryStore);
    if ($accountStore) account = $accountStore; 

    if ($accountStore) console.log(account!.address);

    if (planetaryComponents) game_planet = componentValueStore(planetaryComponents.Planet, torii.poseidonHash(['0x76756c63616e']));

    if (torii && $accountStore) queueId = torii.poseidonHash(['0x76756c63616e', '0x0'])
    if (torii && account!) addressId = getEntityIdFromKeys([BigInt(account.address)]);

    if (torii && account!) playerId = torii.poseidonHash([account.address, '0x76756c63616e', '0x0'])

    if (planeteloComponents)console.log(getComponentValue(planeteloComponents.Player, addressId));


    $: if ($planeteloStore) queue = componentValueStore(planeteloComponents.Queue, queueId);
    $: if ($planeteloStore) player = componentValueStore(planeteloComponents.Player, addressId);

    $: if ($planeteloStore) status = componentValueStore(planeteloComponents.PlayerStatus, playerId);

    console.log($player);
    console.log($status);
    console.log($queue);

    $: if ($burnerStore) burners = $burnerStore



</script>

<main>
    {#if $planeteloStore}
        <p>Setup completed</p>
    {:else}
        <p>Setting up...</p>
    {/if}

    <button on:click={handleNewBurner}>
        {burnerManager?.isDeploying ? "deploying burner" : "create burner"}
    </button>

    <div class="card">
        <div>{`burners deployed: ${burners.length}`}</div>
        <div>
            select signer:{" "}
            <select on:change={handleBurnerChange}>
                {#each burners as burner}
                        <option value={burner.address}>
                            {burner.address}
                        </option>
                {/each}
            </select>
        </div>
        <div>
            <button on:click={handleClearBurners}>
                Clear burners
            </button>
        </div>
    </div>

    <div class="queue">
        <div class="queue-item">
            <button on:click={() => client.queue.queue({account, game: BigInt('0x76756c63616e'), playlist: BigInt(0)})}>Queue</button>
            <button on:click={() => client.queue.dequeue({account, game: BigInt('0x76756c63616e'), playlist: BigInt(0)})}>Dequeue</button>
            <button on:click={() => client.queue.matchmake({account, game: BigInt('0x76756c63616e'), playlist: BigInt(0)})}>Refresh</button>

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
      
