# :raised_hand: Shoggoths Planetary Deli - What is it?

The deli is a discovery service for Autonomous Worlds build in the Dojo framework and ecosystem.

It is a PoC around **composability** and **discovery** for Autonomous Worlds.

Effectivly it is a form of DNS for Autonomous Worlds.

## :raised_hand: Why do we need a deli?

Because composability is delicious! The deli lets you find fine food from other worlds to compose an autonomous sandwich.

## :raised_hand: What is Discovery?

In a TCP/Networking sense Discoverability refers to the ability of devices and services to identify and locate each other within the network. This process is plainly essential for establishing communication and enabling  interaction of various components. It involves the use of protocols that allow devices to broadcast their presence and capabilities, as well as listen for similar broadcasts from other devices. For instance, when a device joins a network, it may send out discovery requests to find available services, such as printers, file servers, or other networked resources. Discovery allows us to dynamically discover "things" without manual configuration.

DNS (Domain Name System) plays a crucial role in this landscape by translating human-readable domain names into addresses, which are necessary for routing data to the correct locations in a network. In the context of discoverability, DNS allows devices to resolve names of services or other devices. 

## :raised_hand: What is Composability?

Composability in autonomous worlds refers to the ability of different game elements, assets, and systems to seamlessly interact and integrate with one another across multiple games or virtual environments, as a result, game assets, characters, or even entire game mechanics can be reused and repurposed across different game worlds. 

We hope and beleive that this will allow for the emergence of complex, evolving game universes where players' actions and achievements have meaningful impact across multiple interconnected experiences.

## :raised_hand: Why now?

It doesnt exist as yet. If we are working on worlds and we want to compose then we need to know about each other and right now that means we need to hard code the addresses of each others worlds (fine but also  annoying). Let's just have a place to publish and discover them.

## :hammer: How do we build it?

Right now we have a very simple implementation of a deli that just lets you publish and list worlds. It is based on the work done at the dojo residency game jam.

The `deli` itself is a contract deployed to the desired chain. This contract address needs to be known to the contract at deployment time so that it can register itself with the deli. There is ofc no reason that this registration needs to happen on deployment but the address of the `deli` must be known. It is entirely resonable to expect that this initial address may send back further `deli`'s to query in the future and may itself publish updates in a manner at least somewhat similar to DNS.

Worlds that wish to compose also need access to each others interfaces so that dispatchers can be created. Right now we we create a simple interface that gets published to an intermediate repository and then added as a dependency to the project via `Scarb.toml`.

It may be possible to find a mechanism that allows for dynamic composability based on some kind of mutually agreed standard to allow for dynamic :bacon:. As of right now this is being thought about, perhaps some kind of RFC as to how this is described, this may allow for dynamic contract interop without the need to publish interfaces or perhaps there are native mechanisms that could be leveraged.

