Set-PSDebug -Trace 1

$folder = Join-Path '/var/docker-deploy/nginx/volumes/html' (Get-ChildItem Env:DEPLOY_FOLDER).Value

rm -rf $folder

ls
$file = $args[0]
unzip "content/$($file)" -d $folder

# Clear the cache
$cfEmail = (Get-ChildItem Env:CF_EMAIL).Value
$cfApiKey = (Get-ChildItem Env:CF_API_KEY).Value
$cfZone = (Get-ChildItem Env:CF_ZONE).Value

$headers = @{
    "X-Auth-Email"=$cfEmail;
    "X-Auth-Key"=$cfApiKey;
    "Content-Type"="application/json"
}

$body = @{
    purge_everything=$true
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/zones/$($cfZone)/purge_cache" -Method 'DELETE' -Headers $headers -Body $body