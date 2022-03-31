<#
 .Synopsis
  Generates and outputs a list of random names using an input text file as a model for the generated names.

 .Description
  The input file is processed to

 .Parameter Path
  The file to read in. Required.

 .Parameter NumberofNames
  The number of names to generate. Optional; 1 by default.

 .Parameter lengthOfEachName
  The number of characters that should be in each name. Optional; 5 by default.

 .Example
   # Generate a name from a file named "names.txt" that is located in the current working directory.
   Get-RandomizedNames names.txt

 .Example
   # Generate a name from a file named "names.txt" that is located in directory named "folder" on the C drive.
   Get-RandomizedNames c:\path\to\folder\names.txt

 .Example
   # Generate a list of seven names that are each five characters long using a file named "names.txt".
   Get-RandomizedNames names.txt 7

 .Example
   # Generate a list of seven names that are each twelve characters long using a file named "names.txt".
   Get-RandomizedNames names.txt 7 12
#>

Function Get-RandomizedNames {
    param (
        [parameter(Mandatory=$true)][ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$Path,

        [parameter(Mandatory=$false)][ValidateRange(1, [int]::MaxValue)]
        [Int]$NumberofNames = 1,

        [parameter(Mandatory=$false)][ValidateRange(1, [int]::MaxValue)]
        [Int]$LengthOfEachName = 5
    )

    try {
        [string[]]$sampleNames = Get-Content $path;
    } catch {
        Write-Host "An error occurred while processing the source file:";
        Write-Host $_;
    }


    $startingCounts = @{};
    $startingTotal = 0;

    $followingCounts = @{};
    $followingTotals = @{};

    foreach ($sampleName in $sampleNames) {
        $previousCharacter = "";
        foreach ($character in $sampleName.toUpper().toCharArray()) {
            if (!$previousCharacter) {
                if (!$startingCounts.ContainsKey($character)) {
                    $startingCounts.Add($character, 0);
                }
                $startingCounts[$character]++;
                $startingTotal++;
            } else {
                if (!$followingCounts.ContainsKey($previousCharacter)) {
                    $followingCounts.Add($previousCharacter, @{});
                    $followingTotals.Add($previousCharacter, 0);
                }
                $followingTotals[$previousCharacter]++;
                if (!$followingCounts[$previousCharacter].ContainsKey($character)) {
                    $followingCounts[$previousCharacter].Add($character, 1);
                } else {
                    $followingCounts[$previousCharacter][$character]++;
                }
            }
            $previousCharacter = $character.toString();
        }
    }


    for ($i = 0; $i -lt $NumberofNames; $i++) {
        $name = "";
        $previousCharacter = '';

        $weight = Get-Random -Maximum $startingTotal;
        foreach($count in $startingCounts.GetEnumerator()) {
            if ($weight -lt $count.Value) {
                $name += $count.Key.toString();
                $previousCharacter = $count.Key.toString();
                break;
            }
            $weight -= $count.Value;
        }

        for ($j = 1; $j -lt $LengthOfEachName; $j++) {
            $weight = Get-Random -Maximum $followingTotals[$previousCharacter];

            foreach ($count in $followingCounts[$previousCharacter].GetEnumerator()) {
                if ($weight -lt $count.Value) {
                    $name += $count.Key.toString().ToLower();
                    $previousCharacter = $count.Key.toString();
                    break;
                }
                $weight -= $count.Value;
            }
        }

        Write-Output $name;
    }
}
