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
$form.Text = "The Great Pokemon Auction"  # Updated title
$form.Size = New-Object System.Drawing.Size(1400, 686)
$form.BackColor = [System.Drawing.Color]::LightBlue  # Set form background color to pale blue

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
$form.Controls.Add($pictureBox1)

$pictureBox2 = New-Object System.Windows.Forms.PictureBox
$pictureBox2.Location = New-Object System.Drawing.Point(670, 130)  # Position second Pokemon 150px to the right
$pictureBox2.Size = New-Object System.Drawing.Size(200, 200)  # Set PictureBox size to 200x200 pixels
$pictureBox2.BackColor = [System.Drawing.Color]::LightBlue  # Set PictureBox background color to pale blue
$form.Controls.Add($pictureBox2)

# Create labels to display the file names below each Pokemon image
$labelFileName1 = New-Object System.Windows.Forms.Label
$labelFileName1.Location = New-Object System.Drawing.Point(420, 320)  # Below the first Pokemon
$labelFileName1.Width = 200
$labelFileName1.Height = 100
$labelFileName1.Font = New-Object System.Drawing.Font("Pixelon", 24)  # Increase text size
$labelFileName1.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter  # Center the text
$form.Controls.Add($labelFileName1)

$labelFileName2 = New-Object System.Windows.Forms.Label
$labelFileName2.Location = New-Object System.Drawing.Point(670, 320)  # Below the second Pokemon
$labelFileName2.Width = 200
$labelFileName2.Height = 100
$labelFileName2.Font = New-Object System.Drawing.Font("Pixelon", 24)  # Increase text size
$labelFileName2.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter  # Center the text
$form.Controls.Add($labelFileName2)

$TwoForOneImagePath = Join-Path -Path $scriptDirectory -ChildPath "TwoForOne.png"

# Create PictureBox for the TwoForOne image (initially hidden)
$twoForOnePictureBox = New-Object System.Windows.Forms.PictureBox
$twoForOnePictureBox.Size = New-Object System.Drawing.Size(300, 200)
$twoForOnePictureBox.Location = New-Object System.Drawing.Point(910, 40)
$twoForOnePictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$twoForOnePictureBox.Visible = $false  # Start off as invisible
$twoForOnePictureBox.Image = [System.Drawing.Image]::FromFile($TwoForOneImagePath)
$form.Controls.Add($twoForOnePictureBox)

# Create PictureBoxes for the item images (will be added or removed dynamically)
$itemPictureBox1 = New-Object System.Windows.Forms.PictureBox
$itemPictureBox1.Size = New-Object System.Drawing.Size(100, 100)  # Set item size to 100x100 pixels
$itemPictureBox1.BackColor = [System.Drawing.Color]::LightBlue  # Set background color to pale blue
$itemPictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::AutoSize  # Ensure proper sizing of the item
$itemPictureBox1.Visible = $false  # Start off as invisible
$form.Controls.Add($itemPictureBox1)

$itemPictureBox2 = New-Object System.Windows.Forms.PictureBox
$itemPictureBox2.Size = New-Object System.Drawing.Size(100, 100)  # Set item size to 100x100 pixels
$itemPictureBox2.BackColor = [System.Drawing.Color]::LightBlue  # Set background color to pale blue
$itemPictureBox2.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::AutoSize  # Ensure proper sizing of the item
$itemPictureBox2.Visible = $false  # Start off as invisible
$form.Controls.Add($itemPictureBox2)

# Create Labels to display the "Holding file_name" text for each item
$itemLabel1 = New-Object System.Windows.Forms.Label
$itemLabel1.Location = New-Object System.Drawing.Point(300, 330)  # Below the first item image
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

# Create label for displaying how many Pokemon have been sold in the current auction
$soldCounterLabel = New-Object System.Windows.Forms.Label
$soldCounterLabel.Text = "Total Pokemon Sold: 0"
$soldCounterLabel.Font = New-Object System.Drawing.Font("Pixelon", 20)
$soldCounterLabel.ForeColor = [System.Drawing.Color]::White
$soldCounterLabel.Location = New-Object System.Drawing.Point(20, 430)
$soldCounterLabel.Width = 400
$soldCounterLabel.Height = 50
$soldCounterLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$form.Controls.Add($soldCounterLabel)

# Variable to keep track of the number of sold Pokémon
$soldCount = 0

function Show-RandomImage {
    # Always fetch the available images directly and filter out non-existing files
    $imageFiles = Get-AvailableImages

    # Reset item visibility and labels before showing new images
    $itemPictureBox1.Visible = $false
    $itemLabel1.Visible = $false
    $itemPictureBox2.Visible = $false
    $itemLabel2.Visible = $false
    $twoForOnePictureBox.Visible = $false

    # Select a random Pokemon for Pokemon 1
    $randomPokemon = Get-Random -InputObject $imageFiles

    # Load and resize the first Pokemon image to 200x200 pixels
    $image1 = [System.Drawing.Image]::FromFile($randomPokemon.FullName)
    $resizedImage1 = $image1.GetThumbnailImage(200, 200, $null, [System.IntPtr]::Zero)
    $pictureBox1.Image = $resizedImage1
    $labelFileName1.Text = $randomPokemon.Name.Replace(".png", "")  # Display file name without .png below first Pokemon

    # Set flag to indicate that Pokémon have been displayed in PictureBox1
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
        $twoForOnePictureBox.Visible = $true

        # Set flag to indicate that Pokémon have been displayed in PictureBox2
        $global:pictureBox2HasPokemon = $true
    } else {
        $pictureBox2.Image = $null
        $labelFileName2.Text = ""
        $twoForOnePictureBox.Visible = $false

        # Set flag to indicate no Pokémon in PictureBox2
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

    # If there's a second Pokémon, give it an independent 40% chance for an item too
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
        }
    }

    # Dispose of the images before removing the item
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

# Create the Next Pokemon button
$NextButton = New-Object System.Windows.Forms.Button
$NextButton.Text = "Next Pokemon"
$NextButton.Location = New-Object System.Drawing.Point(50, 500)  # Position the button below the images
$NextButton.Size = New-Object System.Drawing.Size(100, 50)

$NextButton.Add_Click({
    # Increment the counter only if a Pokémon image is displayed in PictureBox1 or PictureBox2
    $soldCountIncrement = 0

    if ($global:pictureBox1HasPokemon) {
        $soldCountIncrement += 1
    }

    if ($global:pictureBox2HasPokemon) {
        $soldCountIncrement += 1
    }

    # Only update the counter after the current Pokémon has been shown
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
    # Move all Pokémon back to the original folder
    $soldPokemonFiles = Get-ChildItem -Path $soldPokemonFolder -Filter "*.png"
    foreach ($file in $soldPokemonFiles) {
        $originalFilePath = Join-Path -Path $imageFolder -ChildPath $file.Name
        Move-Item -Path $file.FullName -Destination $originalFilePath
    }

    # Reset the sold count and update the counter label
    $global:soldCount = 0
    $soldCounterLabel.Text = "Total Pokemon Sold: $global:soldCount"

    # Erase the current Pokémon
    $pictureBox1.Image = $null
    $pictureBox2.Image = $null
    $labelFileName1.Text = ""
    $labelFileName2.Text = ""

    # Reset the "2-for-1" label and item-related controls
    $twoForOnePictureBox.Visible = $false
    $itemPictureBox1.Visible = $false
    $itemLabel1.Visible = $false
    $itemPictureBox2.Visible = $false
    $itemLabel2.Visible = $false

    # Set the flag to false since no Pokémon have been displayed yet
    $global:pictureBox1HasPokemon = $false
    $global:pictureBox2HasPokemon = $false
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
