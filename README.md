# SkyFactory 4

CurseForge link: https://www.curseforge.com/minecraft/modpacks/skyfactory-4

## Volumes

- /minecraft/world
- /minecraft/prestige

## Environment variables

- Change `MIN_RAM` (default `1024M`) to tune `-Xms`
- Change `MAX_RAM` (default `4096M`) to tune `-Xmx`
- Change `JAVA_PARAMETERS` to configure all other Java parameters (advanced)

# Security

This container runs Java as a non-privileged user, with `uid=567` and `gid=567`, meaning that local volumes need to set according permissions.

## Example command

```
# Create volumes and set permissions
mkdir world prestige
chown -R 567:567 world prestige

# Run the server
docker run -d \
	--name skyfactory4 \
	--restart always \
	-p 25565:25565 \
	-e MIN_RAM=512M \
	-e MAX_RAM=2048M \
	-v $(pwd)/world:/minecraft/world \
	-v $(pwd)/prestige:/minecraft/prestige \
	filoozom/skyfactory4
```

