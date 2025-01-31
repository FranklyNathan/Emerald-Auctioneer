<!-- title -->
# Emerald Auctioneer
<!-- description -->
A PowerShell script for automating Pokemon auction drafts.

## Key Features
- **Random Pokémon Selection:** Emerald Auctioneer randomly selects and displays Pokémon for auction so that you don't have to.
- **Item Pool:** Each time a Pokémon is auctioned, Emerald Auctioneer considers a 40% chance to sell it alongside a held item. Items, like Pokémon, are displayed to buyers with both their name and their official art.
- **2-For-1 Sales:** Each time a Pokémon is auctioned, Emerald Auctioneer considers a 15% chance to sell it alongside a second Pokémon.
- **Sold Counter:** Emerald Auctioneer keeps track of how many Pokémon have sold in the give auction, resetting to 0 when you click the "Reset Pool" option.
- **Customizable Pools:** Because Emerald Auctioneer uses images and file names to select Pokémon for auction, customizing both the Pokémon and Item pools is as simple as adding new .png files to their folders.

<!-- TOC -->
## Contents

- [Instillation](#instillation)
- [PowerShell Usage](#powershell-usage)
- [Sample Auction Rules](#sample-auction-rules)
- [Sample Auction Procedure](#sample-auction-procedure)
- [Pokémon Emerald Speedchoice (Draft Edition)](#pokemon-emerald-speedchoice-draft-edition)

<!-- CONTENT -->

## Instillation
1. At the top of [this repository’s main page](https://crate.io/docs/crate/), click the green `<> Code` button at the top right of the screen.
2. In the dropdown menu, select `Download ZIP`.
3. The entire repository will be downloaded as a `.zip` file to your computer.
4. Navigate to the newly downloaded folder, right click it and select `Extract`.

## PowerShell Usage
Once installed, it’s easy to run the script in just two clicks.
1. Open the `Emerald Auctioneer` folder.
2. Right click `emerald-auctioneer.ps1` and select `Run with PowerShell`.

Alternatively, you can run the script directly through PowerShell
1. Copy Emerald Auctioneer’s location to your clipboard by right clicking the `Emerald Auctioneer` folder and select `Copy as path`.
2. Open Windows PowerShell.
3. type `cd ` and then paste the copied path. Press Enter.
4. Type `.\emerald-auctioneer.ps1` into PowerShell and press Enter.

## Sample Auction Rules:
Use these rules for reference when developing your own auction rules with your play group:
- Each player begins with a $25,000 budget.
- Bids must be placed in $100 increments. For example, if the highest bid is currently $700, you can’t bid $701. The lowest possible bid would be $800.
- Once you run out of money, you can no longer bid. You can't bid more than your current budget.
- The total number of Pokémon sold at auction is equal to 13 * the total number of players.
- Consider using a [spreadsheet like this](https://docs.google.com/spreadsheets/d/1blP95h4Cz0T74W3kKG3VQsoUubtwCcGR7ylJ2YZrbmU/) to track your auction.

## Sample Auction Procedure:
Use this example for reference when developing your own auction procedure with your play group:
1. Using a video-chat app like Discord or Skype, share your screen to display Emerald Auctioneer to all players.
3. Press the `Next Pokémon` button for Emerald Auctioneer to present the first Pokémon for sale.
4. Opening at $100, players bid on each Pokémon until bidding stops and the host declares a winner. The sold Pokémon is then added to the winner’s roster, and its cost is deducted from their budget.
5. After a sale completes, press the `Next Pokémon` button to begin the next sale.
6. Once all Pokémon have been sold, the auction is finished and the race begins.

## Pokemon Emerald Speedchoice (Draft Edition)
While Emerald Auctioneer's pool can be customized to support any multiplayer auction race, the default pool is aligned with the available Pokémon and items in [FranklyNathan's Draft Edition](https://github.com/FranklyNathan/Draft-Auction-Race) of Pokémon Emerald Speedchoice. It's a game made specifically for multiplayer draft races, including full access to all drafted Pokémon and items in the starting PC, expedited gameplay and many quality of life improvements.

<!-- END CONTENT -->
