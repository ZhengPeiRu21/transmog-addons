# Transmog Addons
Transmog Catalogue Addons for WotLK 3.3.5 Client

These are designed to be used with the AzerothCore Transmog module so that you can see which items you have added to your appearance collection and which are available for Transmog.

This addon can be used for any 3.3.5 Client and server and be used to track own appearance collection for fun, but actually transmog the item needs to server to be running the Transmog component.

## Included Addons
### TransmogTip
![155623313-86918348-8529-4ba8-bc31-d6f7d07cd686](https://user-images.githubusercontent.com/98835050/161623825-7d21ce3a-9db9-40b9-9dc9-b17f0221964f.png)

This addon creates a tooltip note for items not yet added to appearance collection. Once an item has been equipped by your character, the tooltip note will disappear.

### MogIt
![155623541-029ac6ef-c425-419e-acab-0b109c510c03](https://user-images.githubusercontent.com/98835050/161624321-04b959f2-af94-4800-bc12-322d9c13d5e9.png)

This is a modified version of MogIt that can be used for appearance data. It will show all items available for transmog, grouping together items with the same appearance. Once an item has been added to your appearance collection, it will be marked with a green check.
Many thanks to Aelobin (The Maelstrom EU) and Lombra (Defias Brotherhood EU) as original authors of MogIt.

## How to Install
Place all directories into your Interface/AddOns directory

## How to Sync with Server Data
There are some ways transmog items can be added to the appearance collection which are difficult to track through the add on API, leading to some times when the local database is out of date. If this happens, just run the command `.transmog sync` and the local database will be synced with the server.
