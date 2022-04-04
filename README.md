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
If installing for a character who is already having a server-stored appearance collection, you may want to sync initial data with the server. There are also some other times that server will record an item as collected but addon will not, such as completing a quest but not equipping the reward.

A script is provided to sync addon data with server data. Syncing with the server requires access to the server's MySQL database - if you are not having access, you may need to ask your server admin to do it for you.

### Sync Script Requirements
* Python 3
* Python MySQL Connector (can be installed through `pip install mysql-connector-python`)

### Sync Steps
1. Edit syncTransmog.py to put your MySQL credentials in the correct location
2. (optional) Edit account_id in the script to your account_id
3. Run the syncTransmog.py script. If you did not edit the account_id, you will be prompted to enter either your account_id or character name.
4. After sync is complete, a file `transmogTip.lua` will be output. Place this file in \<WoW Dir\>/WTF/Account/\<AccountName\>/\<CharName\>/SavedVariables, and overwrite any existing files.
  
Alternately, you just can play without performing a sync, and over time most discrepency will be resolved as you equip items.
