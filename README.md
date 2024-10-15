# Overview
Planetelo is a generalized elo matchmaking system that leverages planetary, by @mataleone @itrainspiders. Any 1v1 dojo game can easily become compatible by simply implementing interface that tells planetelo how to create and settle a game, and then registering the world with planetary. In planetelo you can then attempt to queue any game registered with planetary, where it will attempt to create a dispatcher for the interface, and if successful the player will enter the queue and be matched based on their elo.

![diagram](images/planetelo.png)

## How
There are 4 main components in this system, being Planetelo, Planetary, the game it's being implemented for, and the game's planetelo implementation. The planetelo implementation is defined in the planetelo namespace in your game's world as a contract that implements the interface that enables planetelo to create games and get the results. 

# Why
This design has 2 main benefits.

1. Persistence, since the elo is in its own world we can have it persist across versions if we need to deploy a new world
2. Composability, since any game can easily implement the system for their own game, and other matchmaking, ranked, or tournament systems built with it will be instantly available for all games implementing it

# Implementing For Your Game

To implement planetelo for your game you create a contract in your world called planetelo in the planetelo namespace and implement the IOneOnOne interface, which you can find in planetary_interfaces, like 

```
#[dojo::contract(namespace="planetelo")]
mod planetelo {
	use planetary_interfaces::interfaces::IOneOnOne;

	#[abi(embed_v0)]
	impl IOneOnOneImpl of IOneOnOne {
	
		fn create_match(...)
		fn settle_match(...)
	}

}
```
and then make sure that your world is registered with planetary, which you can do on init like this 
```
use planetary_interface::interfaces::planetary::{
  PlanetaryInterface, PlanetaryInterfaceTrait,
};

fn dojo_init(ref world: IWorldDispatcher) {

  let planetary: PlanetaryInterface = PlanetaryInterfaceTrait::new();

  planetary.dispatcher().register(NAMESPACE, world.contract_address);

}
```
where contract interface trait is the 
One argument that the create function takes is the playlist id, which enables your game to define different playlists in the planetelo namespace and manage them separately. For example, in octoguns playlists are the map pool and the primitives like bullet speed, and we could define it so that we have an offical ranked playlist and have logic for how the settings and map pool for that playlist are decided upon and updated. 