# ─── LABEL CREATION ────────────────────────────────────────────────
cls
$Name="PS_Anydesk_fusion_log"
$version="0.1"
$Creation_Date = "22:07 14/08/2025"

# Logo Exemple
$Logo = "... ->`n... ->   __|\`n... ->  |    \`n... ->  |__  /`n... ->     |/`n"

# Label
if (($Name.Length) -gt ($version.Length)){
	$fior1=$Name.Length+10;
	$fior2=($name.length)-($name.length)
    $fior3=($name.length)-($version.length)
} else {
    $fior1=$version.length+10;
    $fior2=($version.length)-($name.length)
    $fior3=(($version.length)-($version.length))
}

$fior1result="";for ($j=1; $j -le $fior1; $j++) { $fior1result+="#" }
$fior2result="";for ($j=1; $j -le $fior2; $j++) { $fior2result+=" " }
$fior3result="";for ($j=1; $j -le $fior3; $j++) { $fior3result+=" " }

write-host $fior1result
write-host "####"$Name$fior2result" ####"
write-host "####"$version$fior3result" ####"
write-host $fior1result
get-date -displayHint Time
write-host $Logo

Start-Sleep 1
cls

# ─── FOLDER CREATION ────────────────────────────────────────────────
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
foreach ($dir in "IN","OUT") {
	$FullPath = Join-Path $ScriptPath $dir
	if (-Not (Test-Path $FullPath)) { New-Item $FullPath -ItemType Directory | Out-Null }
}

cls
Write-Host -ForegroundColor Red "Run this script at X:\Users\"
Start-Sleep -Seconds 2

# ─── Search connection_trace.txt files into user's profiles ─────────────────
$Files = Get-ChildItem -Path $ScriptPath -Recurse -Filter "connection_trace.txt"

$OutFile = Join-Path $ScriptPath "OUT\out_anydesk_cnx.txt"

# Ajouter le header directement dans le fichier
$Header = "Type`tDateTime`tConnexionType`tAnyDeskSession1`tAnyDeskSession2`tUserName"
$Header | Out-File -FilePath $OutFile -Encoding UTF8

foreach ($file in $Files) {

	# UserName
	$UserName = $file.Directory.Parent.Parent.Parent.Name

	# Read file as UTF-16 LE BOM
	$Bytes = [System.IO.File]::ReadAllBytes($file.FullName)
	$Lines = [System.Text.Encoding]::Unicode.GetString($Bytes) -split "`r?`n"

	foreach ($line in $Lines) {
		if ($line.Trim() -ne "") {

			# Supprimer les virgules
			$CleanLine = $line -replace ",", ""

			# Découper la ligne en mots
			$parts = $CleanLine -split "\s+"

			# Vérifier qu'il y a assez de colonnes
			if ($parts.Count -ge 3) {
				$Type = $parts[0]
				$DateTime = $parts[1] + " " + $parts[2]
				$Rest = if ($parts.Count -gt 3) { $parts[3..($parts.Count-1)] -join "`t" } else { "" }

				# Écrire directement dans le fichier pour éviter l'accumulation en mémoire
				"$Type`t$DateTime`t$Rest`t$UserName" | Out-File -FilePath $OutFile -Encoding UTF8 -Append
			}
		}
	}
}

Write-Host -ForegroundColor Green "Look at the result : $OutFile"
& notepad $OutFile
