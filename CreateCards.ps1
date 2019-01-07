Set-PSDebug -Trace 2

cp _data/cards.json CardsGenerator/

$dockerVolumesPath = (Get-ChildItem Env:DOCKER_VOLUMES_PATH).Value
$sitePath = Join-Path $dockerVolumesPath '_site'
mv _site $sitePath

$cardsGeneratorPath = Join-Path $dockerVolumesPath 'CardsGenerator'
mv CardsGenerator $cardsGeneratorPath

docker run --rm -v "$($sitePath):/var/site-content/_site" -v "$($cardsGeneratorPath):/var/cards-generator" -w="/var/cards-generator" microsoft/dotnet:2.1.6-aspnetcore-runtime-stretch-slim dotnet CardGenerator.dll /var/cards-generator/cards.json 2>&1
if($LASTEXITCODE){
    Exit $LASTEXITCODE
}

mv $sitePath .