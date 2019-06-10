Set-PSDebug -Trace 1

cd src
git lfs pull

# version everything
$tcVersion = (Get-ChildItem Env:BUILD_NUMBER).Value

$hash = git rev-parse HEAD
$version = "$($hash.Substring(0, 7)).$tcVersion"
$version > _data/version.json

Write-Output "##teamcity[buildNumber '$version']"

# fix config values for prod
sed -i '/#local/d' _config.yml
sed -i 's/#prod://g' _config.yml

# prepare the stage for docker
cd ../
$dockerVolumesPath = (Get-ChildItem Env:DOCKER_VOLUMES_PATH).Value
$srcPath = Join-Path $dockerVolumesPath 'src'
mv src $srcPath

docker run --rm -v "$($srcPath):/var/site-content" g3rv4/blog-builder /root/.rbenv/shims/jekyll build 2>&1
if($LASTEXITCODE){
    Exit $LASTEXITCODE
}

mv "$srcPath/_site" .
cp -r "$srcPath/_data" .
cd _site
$project = $args[0]
zip -r "../$($project)-$($version).zip" *