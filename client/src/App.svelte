<script lang="ts">
    import type { Entity } from "@dojoengine/recs";
    import { componentValueStore, type ComponentStore } from "./dojo/componentValueStore";
    import { dojoStore, accountStore, burnerStore } from "./stores";
    import { Account } from "starknet";
    import { type Burner } from "@dojoengine/create-burner";
    import { handleBurnerChange, handleNewBurner, handleClearBurners } from "./handlers";

    let entityId: Entity;
    let account: Account;
    let queues: ComponentStore;
    let burners: Burner[]
    
    $: ({ clientComponents, torii, toriiClient, burnerManager, client } = $dojoStore);
    $: if ($accountStore) account = $accountStore; 

    $: if (torii && account) entityId = torii.poseidonHash([account.address])

    $: if (dojoStore) queues = componentValueStore(clientComponents.Queue, entityId);
    $: if ($burnerStore) burners = $burnerStore

    let entities = toriiClient.getAllEntities(1000, 0);

    console.log(entities);

</script>

<main>
    {#if $dojoStore}
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
      
</main>
