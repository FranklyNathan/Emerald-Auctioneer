Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to get the directory of the current script or EXE
function Get-SafeScriptDirectory {
    $scriptDirectory = ""

    try {
        # Attempt to get the EXE's directory using Reflection
        $scriptDirectory = [System.IO.Path]::GetDirectoryName([System.Reflection.Assembly]::GetExecutingAssembly().Location)

        # If the result is an invalid or empty path, throw an exception
        if ([string]::IsNullOrEmpty($scriptDirectory)) {
            throw "Invalid directory from reflection."
        }
    } catch {
        Write-Host "Error getting the EXE directory using reflection: $_"
    }

    # Fallback: if Reflection fails, try to use the working directory (where the script/EXE is executed)
    if ([string]::IsNullOrEmpty($scriptDirectory)) {
        $scriptDirectory = Get-Location
        Write-Host "Fallback to working directory: $scriptDirectory"
    }

    # Ensure the directory is valid
    if ([string]::IsNullOrEmpty($scriptDirectory)) {
        Write-Host "ERROR: The script or EXE directory could not be determined."
        exit
    }

    Write-Host "Using directory: $scriptDirectory"
    return $scriptDirectory
}

$scriptDirectory = Get-SafeScriptDirectory

# Define paths to folders based on script/exe directory
$imageFolder = Join-Path -Path $scriptDirectory -ChildPath "Pokemon"
$itemFolder = Join-Path -Path $scriptDirectory -ChildPath "Items"
$soldPokemonFolder = Join-Path -Path $scriptDirectory -ChildPath "SoldPokemon"

# Function to get available images
function Get-AvailableImages {
    return Get-ChildItem -Path $imageFolder -Filter "*.png" | Where-Object { Test-Path $_.FullName }
}

# Get all .png image files from the Item folder
$itemFiles = Get-ChildItem -Path $itemFolder -Filter "*.png"   # List of Item images

$form = New-Object System.Windows.Forms.Form
$form.Text = "The Great Pokemon Auction"
$form.Size = New-Object System.Drawing.Size(1400, 686)
$form.BackColor = [System.Drawing.Color]::LightBlue

$dittoImagePath = Join-Path -Path $scriptDirectory -ChildPath "Ditto.jpg"
$eeveesImagePath = Join-Path -Path $scriptDirectory -ChildPath "Eevees.jpg"
$remorseImagePath = Join-Path -Path $scriptDirectory -ChildPath "Remorse.jpg"
$switchImagePath = Join-Path -Path $scriptDirectory -ChildPath "Switch.jpg"
$raceImagePath = Join-Path -Path $scriptDirectory -ChildPath "Race.jpg"
$secondChanceImagePath = Join-Path -Path $scriptDirectory -ChildPath "Chance.jpg"
$ForSaleImagePath = Join-Path -Path $scriptDirectory -ChildPath "ForSale.png"

# Create PictureBox for the ForSale image (initially hidden)
$forSalePictureBox = New-Object System.Windows.Forms.PictureBox
$forSalePictureBox.Size = New-Object System.Drawing.Size(600, 90)
$forSalePictureBox.Location = New-Object System.Drawing.Point(310, 20)
$forSalePictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$forSalePictureBox.Image = [System.Drawing.Image]::FromFile($ForSaleImagePath)
$form.Controls.Add($forSalePictureBox)

# Create PictureBoxes to display the Pokemon images (two if needed)
$pictureBox1 = New-Object System.Windows.Forms.PictureBox
$pictureBox1.Location = New-Object System.Drawing.Point(420, 130)
$pictureBox1.Size = New-Object System.Drawing.Size(200, 200)  # Set PictureBox size to 200x200 pixels
$pictureBox1.BackColor = [System.Drawing.Color]::LightBlue  # Set PictureBox background color to pale blue
$pictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::CenterImage
$form.Controls.Add($pictureBox1)

$pictureBox2 = New-Object System.Windows.Forms.PictureBox
$pictureBox2.Location = New-Object System.Drawing.Point(670, 130)  # Position second Pokemon 150px to the right
$pictureBox2.Size = New-Object System.Drawing.Size(200, 200)  # Set PictureBox size to 200x200 pixels
$pictureBox2.BackColor = [System.Drawing.Color]::LightBlue  # Set PictureBox background color to pale blue
$form.Controls.Add($pictureBox2)

# Create labels to display the file names below each Pokemon image
$labelFileName1 = New-Object System.Windows.Forms.Label
$labelFileName1.Location = New-Object System.Drawing.Point(420, 320)  # Below the first Pokemon
$labelFileName1.Width = 220
$labelFileName1.Height = 150
$labelFileName1.Font = New-Object System.Drawing.Font("Pixelon", 24)
$labelFileName1.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($labelFileName1)

$labelFileName2 = New-Object System.Windows.Forms.Label
$labelFileName2.Location = New-Object System.Drawing.Point(670, 320)  # Below the second Pokemon
$labelFileName2.Width = 220
$labelFileName2.Height = 150
$labelFileName2.Font = New-Object System.Drawing.Font("Pixelon", 24)
$labelFileName2.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($labelFileName2)

$TwoForOneImagePath = Join-Path -Path $scriptDirectory -ChildPath "TwoForOne.png"
$SpecialEventImagePath = Join-Path -Path $scriptDirectory -ChildPath "SpecialEvent.png"

# Create PictureBox for the TwoForOne image (initially hidden)
$twoForOnePictureBox = New-Object System.Windows.Forms.PictureBox
$twoForOnePictureBox.Size = New-Object System.Drawing.Size(210, 140)
$twoForOnePictureBox.Location = New-Object System.Drawing.Point(1050, 10)
$twoForOnePictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$twoForOnePictureBox.Visible = $false  # Start off as invisible
$twoForOnePictureBox.Image = [System.Drawing.Image]::FromFile($TwoForOneImagePath)
$form.Controls.Add($twoForOnePictureBox)

# Create PictureBox for the specialEvent image (initially hidden)
$specialEventPictureBox = New-Object System.Windows.Forms.PictureBox
$specialEventPictureBox.Size = New-Object System.Drawing.Size(300, 200)
$specialEventPictureBox.Location = New-Object System.Drawing.Point(980, 20)
$specialEventPictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$specialEventPictureBox.Visible = $false  # Start off as invisible
$specialEventPictureBox.Image = [System.Drawing.Image]::FromFile($SpecialEventImagePath)
$form.Controls.Add($specialEventPictureBox)

# Create PictureBoxes for the item images (will be added or removed dynamically)
$itemPictureBox1 = New-Object System.Windows.Forms.PictureBox
$itemPictureBox1.Size = New-Object System.Drawing.Size(100, 100)
$itemPictureBox1.BackColor = [System.Drawing.Color]::LightBlue
$itemPictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::AutoSize  # Ensure proper sizing of the item
$itemPictureBox1.Visible = $false  # Start off as invisible
$form.Controls.Add($itemPictureBox1)

$itemPictureBox2 = New-Object System.Windows.Forms.PictureBox
$itemPictureBox2.Size = New-Object System.Drawing.Size(100, 100)
$itemPictureBox2.BackColor = [System.Drawing.Color]::LightBlue
$itemPictureBox2.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::AutoSize  # Ensure proper sizing of the item
$itemPictureBox2.Visible = $false  # Start off as invisible
$form.Controls.Add($itemPictureBox2)

# Create Labels to display the "Holding file_name" text for each item
$itemLabel1 = New-Object System.Windows.Forms.Label
$itemLabel1.Location = New-Object System.Drawing.Point(288, 330)  # Below the first item image
$itemLabel1.Width = 120  # Adjust the width
$itemLabel1.Height = 50  # Adjust the height
$itemLabel1.Font = New-Object System.Drawing.Font("Pixelon", 12)
$itemLabel1.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight  # Left align the text
$itemLabel1.Visible = $false  # Start off as invisible
$form.Controls.Add($itemLabel1)

$itemLabel2 = New-Object System.Windows.Forms.Label
$itemLabel2.Location = New-Object System.Drawing.Point(870, 330)  # Below the second item image
$itemLabel2.Width = 120  # Adjust the width
$itemLabel2.Height = 50  # Adjust the height
$itemLabel2.Font = New-Object System.Drawing.Font("Pixelon", 12)
$itemLabel2.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft  # Left align the text
$itemLabel2.Visible = $false  # Start off as invisible
$form.Controls.Add($itemLabel2)

$specialEventLabel = New-Object System.Windows.Forms.Label
$specialEventLabel.Location = New-Object System.Drawing.Point(640, 160)
$specialEventLabel.Width = 330  # Adjust the width
$specialEventLabel.Height = 300  # Adjust the height
$specialEventLabel.Font = New-Object System.Drawing.Font("Pixelon", 14)
$specialEventLabel.Visible = $false  # Start off as invisible
$form.Controls.Add($specialEventLabel)

# Create label for displaying how many Pokemon have been sold in the current auction
$soldCounterLabel = New-Object System.Windows.Forms.Label
$soldCounterLabel.Text = "Total Pokemon Sold: 0"
$soldCounterLabel.Font = New-Object System.Drawing.Font("Pixelon", 20)
$soldCounterLabel.ForeColor = [System.Drawing.Color]::White
$soldCounterLabel.Location = New-Object System.Drawing.Point(20, 450)
$soldCounterLabel.Width = 400
$soldCounterLabel.Height = 34
$soldCounterLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$form.Controls.Add($soldCounterLabel)

# Variable to keep track of the number of sold Pokemon
$soldCount = 0

# Variables to ensure that each event can only happen once
$global:DeathRaceEventOccurred = $false
$global:TradeTimeEventOccurred = $false
$global:EeveeEventOccurred = $false
$global:DittoEventOccurred = $false
$global:RemorseEventOccurred = $false
$global:SecondChanceEventOccurred = $false

# Function to get Pokemon stats from the Stats.txt file
function Get-PokemonStats {
    param (
        [string]$pokemonName
    )
    
    $statsFilePath = Join-Path -Path $scriptDirectory -ChildPath "Stats.txt"
    
    if (Test-Path $statsFilePath) {
        $fileContent = Get-Content -Path $statsFilePath
        $pokemonStats = ""
        $pokemonFound = $false
        foreach ($line in $fileContent) {
            if ($line.Trim() -eq $pokemonName) {
                $pokemonFound = $true
                continue
            }
            if ($pokemonFound) {
                if ([string]::IsNullOrWhiteSpace($line)) {
                    break
                }
                $pokemonStats += "$line`r`n"
            }
        }
        return $pokemonStats.Trim()
    } else {
        Write-Host "Stats.txt not found"
        return ""
    }
}

function Show-RandomImage {
    # Always fetch the available images directly and filter out non-existing files
    $imageFiles = Get-AvailableImages
    # Reset item visibility and labels before showing new images
    $itemPictureBox1.Visible = $false
    $itemLabel1.Visible = $false
    $itemPictureBox2.Visible = $false
    $itemLabel2.Visible = $false
    $twoForOnePictureBox.Visible = $false
    $specialEventPictureBox.Visible = $false
    $specialEventLabel.Visible = $false

    $randomRollForSpecialEvent = Get-Random -Minimum 1 -Maximum 120

if ($randomRollForSpecialEvent -eq 1 -and $global:soldCount -gt 16 -and $global:DittoEventOccurred -eq $false) {
        $eventImage = [System.Drawing.Image]::FromFile($dittoImagePath)
        $resizedEventImage = $eventImage.GetThumbnailImage(200, 150, $null, [System.IntPtr]::Zero)
        $pictureBox1.Image = $resizedEventImage
        $labelFileName1.Location = New-Object System.Drawing.Point(406, 320)
        $labelFileName1.Text = "Something's Not Quite Right!"
        $specialEventLabel.Text = "All players choose one of their Pokemon to inspect. Ut oh, they were actually Ditto in disguise! Delete them and replace them with Ditto."
        $specialEventLabel.BringToFront()
        $specialEventLabel.Visible = $true
        $pictureBox2.Image = $null
        $labelFileName2.Text = ""
        $twoForOnePictureBox.Visible = $false
        $specialEventPictureBox.Visible = $true
        $global:pictureBox1HasPokemon = $false
        $global:pictureBox2HasPokemon = $false
        $global:DittoEventOccurred = $true
        }

elseif ($randomRollForSpecialEvent -le 2 -and $global:soldCount -gt 16 -and $global:RemorseEventOccurred -eq $false) {
        $eventImage = [System.Drawing.Image]::FromFile($remorseImagePath)
        $resizedEventImage = $eventImage.GetThumbnailImage(200, 150, $null, [System.IntPtr]::Zero)
        $pictureBox1.Image = $resizedEventImage
        $labelFileName1.Text = "Buyer's Remorse!"
        $specialEventLabel.Text = "As the winner of the previous auction, you may sell one of your Pokemon back to the auctioneer for a full refund.`n(You do not return any held items. You can't sell Pokemon obtained in a 2-for-1.)"
        $specialEventLabel.BringToFront()
        $specialEventLabel.Visible = $true
        $pictureBox2.Image = $null
        $labelFileName2.Text = ""
        $twoForOnePictureBox.Visible = $false
        $specialEventPictureBox.Visible = $true
        $global:pictureBox1HasPokemon = $false
        $global:pictureBox2HasPokemon = $false
        $global:RemorseEventOccurred = $true
        }

elseif ($randomRollForSpecialEvent -le 3 -and $global:soldCount -gt 16 -and $global:EeveeEventOccurred -eq $false) {
        $eventImage = [System.Drawing.Image]::FromFile($eeveesImagePath)
        $resizedEventImage = $eventImage.GetThumbnailImage(200, 150, $null, [System.IntPtr]::Zero)
        $pictureBox1.Image = $resizedEventImage
        $labelFileName1.Location = New-Object System.Drawing.Point(406, 320)
        $labelFileName1.Text = "One of a Kind!"
        $specialEventLabel.Text = "All players without an Eevee receive one now for free! During the race, if two players' Eevees evolve into the same Pokemon, both are considered fainted and can no longer be used.`n(During the race, you must reveal what you evolve your Eevee into when you evolve it. A duplicate Eeveelution is considered fainted at the soonest possible opportunity it can be boxed.)"
        $specialEventLabel.BringToFront()
        $specialEventLabel.Visible = $true
        $pictureBox2.Image = $null
        $labelFileName2.Text = ""
        $twoForOnePictureBox.Visible = $false
        $specialEventPictureBox.Visible = $true
        $global:pictureBox1HasPokemon = $false
        $global:pictureBox2HasPokemon = $false
        $global:EeveeEventOccurred = $true
        }

elseif ($randomRollForSpecialEvent -le 4 -and $global:soldCount -gt 16 -and $global:SecondChanceEventOccurred -eq $false) {
        $eventImage = [System.Drawing.Image]::FromFile($secondChanceImagePath)
        $resizedEventImage = $eventImage.GetThumbnailImage(200, 150, $null, [System.IntPtr]::Zero)
        $pictureBox1.Image = $resizedEventImage
        $labelFileName1.Text = "Second Chance!"
        $specialEventLabel.Text = "As the winner of the previous auction, choose one Pokemon on any team and refund half its cost. If that Pokemon faints, all other players are now allowed to use it on their team.`n(When refunding, round the new cost up to the nearest 100. You can't choose a Pokemon obtained in a 2-for-1.)"
        $specialEventLabel.BringToFront()
        $specialEventLabel.Visible = $true  # Start off as invisible
        $pictureBox2.Image = $null
        $labelFileName2.Text = ""
        $twoForOnePictureBox.Visible = $false
        $specialEventPictureBox.Visible = $true
        $global:pictureBox1HasPokemon = $false
        $global:pictureBox2HasPokemon = $false
        $global:SecondChanceEventOccurred = $true
    }

elseif ($randomRollForSpecialEvent -le 5 -and $global:soldCount -gt 16 -and $global:DeathRaceEventOccurred -eq $false) {
        $eventImage = [System.Drawing.Image]::FromFile($raceImagePath)
        $resizedEventImage = $eventImage.GetThumbnailImage(200, 150, $null, [System.IntPtr]::Zero)
        $pictureBox1.Image = $resizedEventImage
        $labelFileName1.Location = New-Object System.Drawing.Point(406, 320)
        $labelFileName1.Text = "A Race to the Death!"
        $specialEventLabel.Text = "All players receive the next Pokemon listed for auction for free. During the race, the first player to beat Roxanne may keep the Pokemon. For all other players, the Pokemon is considered fainted and can no longer be used."
        $specialEventLabel.BringToFront()
        $specialEventLabel.Visible = $true
        $pictureBox2.Image = $null
        $labelFileName2.Text = ""
        $twoForOnePictureBox.Visible = $false
        $specialEventPictureBox.Visible = $true
        $global:pictureBox1HasPokemon = $false
        $global:pictureBox2HasPokemon = $false
        $global:DeathRaceEventOccurred = $true
        }

elseif ($randomRollForSpecialEvent -le 6 -and $global:soldCount -gt 16 -and $global:TradeTimeEventOccurred -eq $false) {
        $eventImage = [System.Drawing.Image]::FromFile($switchImagePath)
        $resizedEventImage = $eventImage.GetThumbnailImage(200, 150, $null, [System.IntPtr]::Zero)
        $pictureBox1.Image = $resizedEventImage
        $labelFileName1.Text = "Trade Time!"
        $specialEventLabel.Text = "As the winner of the previous auction, swap one of your Pokemon for another player's. Then, that player may swap one of their Pokemon for one of yours.`n(Pokemon involved in the first trade cannot be swapped in the second. Held items are not swapped.)"
        $specialEventLabel.BringToFront()
        $specialEventLabel.Visible = $true  # Start off as invisible
        $pictureBox2.Image = $null
        $labelFileName2.Text = ""
        $twoForOnePictureBox.Visible = $false
        $specialEventPictureBox.Visible = $true
        $global:pictureBox1HasPokemon = $false
        $global:pictureBox2HasPokemon = $false
        $global:TradeTimeEventOccurred = $true
    }

    else {

    # Select a random Pokemon for Pokemon 1
    $randomPokemon = Get-Random -InputObject $imageFiles
    # Load and resize the first Pokemon image to 200x200 pixels
    $image1 = [System.Drawing.Image]::FromFile($randomPokemon.FullName)
    $resizedImage1 = $image1.GetThumbnailImage(200, 200, $null, [System.IntPtr]::Zero)
    $pictureBox1.Image = $resizedImage1
    $labelFileName1.Text = $randomPokemon.Name.Replace(".png", "")  # Display file name below first Pokemon

    $global:pokemonStatsLabels = @()

    # Get stats for the first Pokemon and create label for stats
    $pokemonStats1 = Get-PokemonStats -pokemonName $randomPokemon.Name.Replace(".png", "")
    $statsLabel1 = New-Object System.Windows.Forms.Label
    $statsLabel1.Text = $pokemonStats1
    $statsLabel1.Font = New-Object System.Drawing.Font("Pixelon", 15)
    $statsLabel1.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#0A0A0A")
    $statsLabel1.Location = New-Object System.Drawing.Point(670, 130) # Position the label to the right of Pokemon 1
    $statsLabel1.Width = 244
    $statsLabel1.Height = 320
    $statsLabel1.Visible = $true
    $form.Controls.Add($statsLabel1)
    $statsLabel1.BringToFront()
    $global:pokemonStatsLabels += $statsLabel1

    # Set flag to indicate that Pokemon have been displayed in PictureBox1
    $global:pictureBox1HasPokemon = $true

    # Check for second Pokemon with a 15% chance
    $randomRollForTwoPokemon = Get-Random -Minimum 1 -Maximum 101
    $displayTwoPokemon = $randomRollForTwoPokemon -le 15
    if ($displayTwoPokemon) {
        # Ensure the second Pokemon is different from the first
        $remainingImageFiles = $imageFiles | Where-Object { $_.FullName -ne $randomPokemon.FullName }
        $randomPokemon2 = Get-Random -InputObject $remainingImageFiles
        # Load and resize the second Pokemon image to 200x200 pixels
        $image2 = [System.Drawing.Image]::FromFile($randomPokemon2.FullName)
        $resizedImage2 = $image2.GetThumbnailImage(200, 200, $null, [System.IntPtr]::Zero)
        $pictureBox2.Image = $resizedImage2
        $labelFileName2.Text = $randomPokemon2.Name.Replace(".png", "")

        # Get stats for the second Pokemon and create label for stats
        $pokemonStats2 = Get-PokemonStats -pokemonName $randomPokemon2.Name.Replace(".png", "")
        $statsLabel2 = New-Object System.Windows.Forms.Label
        $statsLabel2.Text = $pokemonStats2
        $statsLabel2.Font = New-Object System.Drawing.Font("Pixelon", 15)
        $statsLabel2.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#0A0A0A")
        $statsLabel2.Location = New-Object System.Drawing.Point(934, 130) # Position the label to the right of Pokemon 2
        $statsLabel2.Width = 244
        $statsLabel2.Height = 320
        $statsLabel2.Visible = $true
        $form.Controls.Add($statsLabel2)
        $global:pokemonStatsLabels += $statsLabel2

        $twoForOnePictureBox.Visible = $true

        # Set flag to indicate that Pokemon have been displayed in PictureBox2
        $global:pictureBox2HasPokemon = $true

    } else {
        $pictureBox2.Image = $null
        $labelFileName2.Text = ""
        $twoForOnePictureBox.Visible = $false
        $global:pictureBox2HasPokemon = $false
    }

    # Independent chance for an item to appear for each Pokemon
    $randomRollForItem1 = Get-Random -Minimum 1 -Maximum 101
    $displayItem1 = $randomRollForItem1 -le 40

    if ($displayItem1) {
        # Show an item for Pokemon 1
        $randomItem1 = Get-Random -InputObject $itemFiles
        $itemImage1 = [System.Drawing.Image]::FromFile($randomItem1.FullName)
        $resizedItemImage1 = $itemImage1.GetThumbnailImage(90, 90, $null, [System.IntPtr]::Zero)
        $itemPictureBox1.Image = $resizedItemImage1
        $itemPictureBox1.Location = New-Object System.Drawing.Point(330, 220)  # Position the item to the left of Pokemon 1
        $itemPictureBox1.Visible = $true
        $itemPictureBox1.BringToFront()

        # Update the text "Holding file_name" below the item
        $itemLabel1.Text = "Holding`n" + $randomItem1.Name.Replace(".png", "").Replace("_", "")  # "Holding" and file name on separate lines
        $itemLabel1.Visible = $true
    }

    # If there's a second Pokemon, give it an independent 40% chance for an item too
    if ($displayTwoPokemon) {
        $randomRollForItem2 = Get-Random -Minimum 1 -Maximum 101
        $displayItem2 = $randomRollForItem2 -le 40

        if ($displayItem2) {
            # Show an item for Pokemon 2
            $randomItem2 = Get-Random -InputObject $itemFiles
            $itemImage2 = [System.Drawing.Image]::FromFile($randomItem2.FullName)
            $resizedItemImage2 = $itemImage2.GetThumbnailImage(90, 90, $null, [System.IntPtr]::Zero)
            $itemPictureBox2.Image = $resizedItemImage2
            $itemPictureBox2.Location = New-Object System.Drawing.Point(870, 220)  # Position the item to the right of Pokemon 2
            $itemPictureBox2.Visible = $true
            $itemPictureBox2.BringToFront()

            # Update the text "Holding file_name" below the item
            $itemLabel2.Text = "Holding`n" + $randomItem2.Name.Replace(".png", "").Replace("_", "")  # "Holding" and file name on separate lines
            $itemLabel2.Visible = $true
            $itemLabel2.BringToFront()
        }
    }

            # Move the left Pokemon's label in a 2-for-1 so that it doesn't overlap anything
        if ($displayTwoPokemon) { 
            if ($displayItem1) {
                $statsLabel1.Location = New-Object System.Drawing.Point(70, 130)
            } else {
                $statsLabel1.Location = New-Object System.Drawing.Point(170, 130)
            }
            if ($displayItem2) {
                $statsLabel2.Location = New-Object System.Drawing.Point(994, 130)
        }
    }

    $image1.Dispose()
    if ($image2) { $image2.Dispose() }

    # Move the Pokemon to the SoldPokemon folder
    $soldPokemonPath1 = Join-Path -Path $soldPokemonFolder -ChildPath $randomPokemon.Name
    Move-Item -Path $randomPokemon.FullName -Destination $soldPokemonPath1

    # If two Pokemon were selected, move the second Pokemon as well
    if ($displayTwoPokemon -and $randomPokemon2 -and (Test-Path $randomPokemon2.FullName)) {
        $soldPokemonPath2 = Join-Path -Path $soldPokemonFolder -ChildPath $randomPokemon2.Name
        Move-Item -Path $randomPokemon2.FullName -Destination $soldPokemonPath2
    }
}
}

function Hide-StatsLabels {
    foreach ($label in $global:pokemonStatsLabels) {
        $label.Visible = $false
    }
}

# Create the Next Pokemon button
$NextButton = New-Object System.Windows.Forms.Button
$NextButton.Text = "Next Pokemon"
$NextButton.Location = New-Object System.Drawing.Point(50, 500)  # Position the button below the images
$NextButton.Size = New-Object System.Drawing.Size(100, 50)

$NextButton.Add_Click({
    Hide-StatsLabels

    # Increment the counter only if a Pokemon image is displayed in PictureBox1 or PictureBox2
    $soldCountIncrement = 0

    if ($global:pictureBox1HasPokemon) {
        $soldCountIncrement += 1
    }

    if ($global:pictureBox2HasPokemon) {
        $soldCountIncrement += 1
    }

    # Only update the counter after the current Pokemon has been shown
    if ($soldCountIncrement -gt 0) {
        $global:soldCount += $soldCountIncrement
    }
    
    # Now we can finally put the next Pokemon for sale
    Show-RandomImage

    # Update the counter label to reflect how many Pokemon have been seen prior to the currently displayed
    $soldCounterLabel.Text = "Total Pokemon Sold: $global:soldCount"
})

$form.Controls.Add($NextButton)

# Create the Reset Pool button
$ResetButton = New-Object System.Windows.Forms.Button
$ResetButton.Text = "Reset Pool"
$ResetButton.Location = New-Object System.Drawing.Point(50, 570)  # Position the Reset button at bottom right
$ResetButton.Size = New-Object System.Drawing.Size(100, 50)

# Create the Reset Pool button
$ResetButton.Add_Click({
    # Move all Pokemon back to the original folder
    $soldPokemonFiles = Get-ChildItem -Path $soldPokemonFolder -Filter "*.png"
    foreach ($file in $soldPokemonFiles) {
        $originalFilePath = Join-Path -Path $imageFolder -ChildPath $file.Name
        Move-Item -Path $file.FullName -Destination $originalFilePath
    }

    # Reset the sold count and update the counter label
    $global:soldCount = 0
    $soldCounterLabel.Text = "Total Pokemon Sold: $global:soldCount"

    # Erase the current Pokemon
    $pictureBox1.Image = $null
    $pictureBox2.Image = $null
    $labelFileName1.Text = ""
    $labelFileName2.Text = ""

    # Reset the "2-for-1" label and item-related controls
    $twoForOnePictureBox.Visible = $false
    $specialEventPictureBox.Visible = $false
    $itemPictureBox1.Visible = $false
    $itemLabel1.Visible = $false
    $itemPictureBox2.Visible = $false
    $itemLabel2.Visible = $false
    $specialEventLabel.Visible = $false  # Start off as invisible
    Hide-StatsLabels

    # Set the flag to false since no Pokemon have been displayed yet
    $global:pictureBox1HasPokemon = $false
    $global:pictureBox2HasPokemon = $false

    # Reset the event flags
    $global:DeathRaceEventOccurred = $false
    $global:TradeTimeEventOccurred = $false
    $global:EeveeEventOccurred = $false
    $global:DittoEventOccurred = $false
    $global:RemorseEventOccurred = $false
    $global:SecondChanceEventOccurred = $false
})

$form.Controls.Add($ResetButton)

# Load the 'grass.png' image to be displayed at the bottom
$grassImagePath = Join-Path -Path $scriptDirectory -ChildPath "grass.png"

# Create a PictureBox for the grass image
$grassPictureBox = New-Object System.Windows.Forms.PictureBox
$grassPictureBox.Size = New-Object System.Drawing.Size(1400, 163)
$grassPictureBox.Location = New-Object System.Drawing.Point(0, 485)  # Position it at the bottom of the form
$grassPictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$grassPictureBox.Image = [System.Drawing.Image]::FromFile($grassImagePath)
$form.Controls.Add($grassPictureBox)

# Display the form
$form.ShowDialog()
