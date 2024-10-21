<script lang="ts">
    import type { Entity } from "@dojoengine/recs";
    import { componentValueStore, type ComponentStore } from "./dojo/componentValueStore";
    import { planeteloStore, planetaryStore, accountStore, burnerStore } from "./stores";
    import { Account } from "starknet";
    import { type Burner } from "@dojoengine/create-burner";
    import { handleBurnerChange, handleNewBurner, handleClearBurners } from "./handlers";

    let entityId: Entity;
    let account: Account;
    let queue: ComponentStore;
    let burners: Burner[];
    let entities: any;
    
    $: ({ planeteloComponents, torii, toriiClient, burnerManager, client } = $planeteloStore);
    $: ({ planets, planetaryComponents, planetaryTorii } = $planetaryStore);
    if ($accountStore) account = $accountStore; 

    console.log(planets);

    if (torii && $accountStore) entityId = torii.poseidonHash(['0x76756c63616e', '0'])

    $: if (planeteloStore) queue = componentValueStore(planeteloComponents.Queue, entityId);
    $: if ($burnerStore) burners = $burnerStore

    if (toriiClient) entities = toriiClient.getAllEntities(1000, 0);

    console.log(entities);
    console.log(queue!);

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
        <div class="playlist-item">
            <button on:click={() => client.queue.queue({account, game: BigInt(0), playlist: BigInt(0)})}>Select</button>
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
      
