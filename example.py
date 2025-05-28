import asyncio
from kasa import Discover

async def main():
    dev = await Discover.discover_single("192.168.42.3", username="un@example.com", password="pw")
    await dev.turn_on()
    await dev.update()

if __name__ == "__main__":
    asyncio.run(main())