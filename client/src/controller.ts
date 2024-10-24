import Controller from '@cartridge/controller';
import { accountStore, usernameStore } from './stores';
import { get } from 'svelte/store';

export const queueContract = '0x11e7a657668ca83c556f7545ab5bde00c1a1275c6c9ed17bea33104fcda2f3b'


export const controller = new Controller({
  policies: [
    {
      target: queueContract,
      method: 'queue'
    },
    {
      target: queueContract,
      method: 'dequeue'
    },
    {
      target: queueContract,
      method: 'matchmake'
    },
    {
      target: queueContract,
      method: 'settle'
    }
  ],
    rpc: "https://api.cartridge.gg/x/planetelo/katana" // sepolia, mainnet, or slot. (default sepolia)
})



export async function connect(event: Event) {
    try {
        const res = await controller.connect();
        if (res) {
            accountStore.set(controller.account!);
            usernameStore.set(await controller.username()!);
        }
      

    } catch (e) {
        console.log(e);
    }
}