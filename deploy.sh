#!/bin/sh

if [ "$1" = "" ]
then
  echo "Usage: $0 <stage>"
  exit
fi

STAGE=$1
APP_NAME="express-beanstalk"
VERSION=$(git describe --tags --abbrev=0)
SOURCE_BUNDLE=".elasticbeanstalk/$APP_NAME-$VERSION.zip"
NOW=$(date +%d%m%y%H%M%S)

# Criando zip usando git
echo "Zipping version $VERSION..."
git archive $VERSION --format=zip --output="$SOURCE_BUNDLE"

# Get Bucket Name
echo "Getting deployment bucket..."
DEPLOYMENT_BUCKET=$(aws elasticbeanstalk create-storage-location --output text)
OBJECT_KEY="$APP_NAME/$VERSION-$NOW.zip"

# Upload
aws s3 cp "$SOURCE_BUNDLE" s3://$DEPLOYMENT_BUCKET/$OBJECT_KEY

# Update values inside 01_CreateApplicationVersion.yaml
sed -i "s/<APP_NAME>/$APP_NAME/g" .elasticbeanstalk/01_CreateApplicationVersion.yaml
sed -i "s/<APP_VERSION>/$VERSION-$NOW/g" .elasticbeanstalk/01_CreateApplicationVersion.yaml
sed -i "s/<APP_BUCKET>/$DEPLOYMENT_BUCKET/g" .elasticbeanstalk/01_CreateApplicationVersion.yaml
sed -i "s/<APP_SOURCE_BUNDLE>/$APP_NAME\/$VERSION-$NOW.zip/g" .elasticbeanstalk/01_CreateApplicationVersion.yaml

# Create Application Version
echo "Creating Application Version..."
aws elasticbeanstalk create-application-version --no-cli-pager --cli-input-yaml file://.elasticbeanstalk/01_CreateApplicationVersion.yaml

# Update Values inside 02_CreateEnvironment.yaml
sed -i "s/<APP_NAME>/$APP_NAME/g" .elasticbeanstalk/02_CreateEnvironment.yaml
sed -i "s/<STAGE>/$STAGE/g" .elasticbeanstalk/02_CreateEnvironment.yaml
sed -i "s/<APP_VERSION>/$VERSION-$NOW/g" .elasticbeanstalk/02_CreateEnvironment.yaml

# Creating/Updating Environment
echo "Creating Application Environment..."
aws elasticbeanstalk create-environment --no-cli-pager --cli-input-yaml file://.elasticbeanstalk/02_CreateEnvironment.yaml
