# PhotoCraft 最新版をダウンロードして、確認してから、インストーラーを開きます。
# 最後の「インストール」ボタンは、あなたが押します。
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$r = Invoke-RestMethod "https://api.github.com/repos/storytold/photocraft/releases/latest"
Write-Host "最新版: $($r.tag_name)"
$a = $r.assets | Where-Object { $_.name -like "*windows*x64*.msi" } | Select-Object -First 1
if (-not $a) {
  Write-Host "Windows用のインストーラーが見つかりません。ファイル一覧:"
  $r.assets | ForEach-Object { Write-Host " - $($_.name)" }
  Write-Host "この一覧をClaudeに貼ってください。"
  return
}
$f = Join-Path $env:USERPROFILE "Downloads\$($a.name)"
Write-Host "ダウンロード中: $($a.name)"
Invoke-WebRequest $a.browser_download_url -OutFile $f
$s = $r.assets | Where-Object { $_.name -like "SHA256SUMS*" } | Select-Object -First 1
if ($s) {
  $txt = (Invoke-WebRequest $s.browser_download_url -UseBasicParsing).Content
  if ($txt -is [byte[]]) { $txt = [Text.Encoding]::UTF8.GetString($txt) }
  $line = ($txt -split "`n" | Where-Object { $_ -match [regex]::Escape($a.name) } | Select-Object -First 1)
  $want = ($line.Trim() -split "\s+")[0]
  $got = (Get-FileHash $f -Algorithm SHA256).Hash
  if ($want -ine $got) { Write-Host "NG: ファイルが公開値と一致しません。開かずに止めました。"; return }
  Write-Host "OK: 公開されている指紋と一致しました。"
} else { Write-Host "注意: 照合用の指紋ファイルが見つからず、照合できませんでした。" }
Write-Host "インストーラーを開きます。内容を確認して、よければ進めてください。"
Start-Process $f
